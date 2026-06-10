import AppKit
import Foundation
import MacDailyCore
import Observation
import UserNotifications

enum NotificationSetupState: Equatable {
    case loading
    case unavailable
    case needsPermission
    case denied
    case authorized
}

@MainActor
@Observable
final class AppViewModel {
    private(set) var config: AppConfig = AppConfig()
    private(set) var notes: [DailyNote] = []
    private(set) var selectedDate: Date = DateFormatting.startOfDay(Date())
    private(set) var isReady = false
    private(set) var folderRevision = 0
    private(set) var notificationSetup: NotificationSetupState = .loading

    var errorMessage: String?
    var showFormattingPreviewSheet = false

    @ObservationIgnored private let configStore = ConfigStore()
    @ObservationIgnored private var noteStore: NoteStore?
    @ObservationIgnored private var dayRolloverMonitor: DayRolloverMonitor?
    @ObservationIgnored private var activeObserver: NSObjectProtocol?
    @ObservationIgnored private let menuBarSaveDebouncer = Debouncer()

    var hasNotesFolder: Bool { config.notesFolderURL != nil }

    /// New users must allow notifications before choosing a folder or creating notes.
    var needsNotificationSetup: Bool {
        if hasNotesFolder { return false }
        if !config.remindersEnabled { return false }
        switch notificationSetup {
        case .authorized, .unavailable:
            return false
        case .loading, .needsPermission, .denied:
            return true
        }
    }

    var canCreateNotes: Bool {
        !needsNotificationSetup
    }

    var needsLaunchAtLoginSetup: Bool {
        !config.launchAtLoginConfigured
    }

    var isOnboardingComplete: Bool {
        canCreateNotes && hasNotesFolder && !needsLaunchAtLoginSetup
    }

    init() {
        Task { await bootstrap() }
    }

    func bootstrap() async {
        let loadResult = await configStore.load()
        config = loadResult.config
        if let loadError = loadResult.loadError {
            errorMessage = loadError.localizedDescription
        }
        await refreshNotificationSetup()
        startNotificationStatusObserver()

        if canCreateNotes, let folder = config.notesFolderURL {
            await openNotesFolder(folder, persist: false)
        }
        if config.launchAtLoginConfigured {
            try? LaunchAtLoginManager.sync(preference: config.launchAtLogin)
        }
        isReady = true
        startDayRolloverMonitor()
        StatusBarController.shared.install(app: self)
        await ReminderManager.shared.reschedule(from: config)
    }

    func loadTodaysNote() async -> String {
        guard hasNotesFolder, canCreateNotes, let noteStore else { return "" }

        do {
            await ensureTodaysNote(switchToToday: false)
            let note = try await noteStore.ensureNote(for: Date())
            return try await noteStore.readContents(of: note)
        } catch {
            errorMessage = error.localizedDescription
            return ""
        }
    }

    func saveTodaysNoteDebounced(_ text: String) {
        menuBarSaveDebouncer.schedule("menuBarSave") { [weak self] in
            await self?.persistTodaysNote(text)
        }
    }

    func persistTodaysNote(_ text: String) async {
        guard hasNotesFolder, canCreateNotes, let noteStore else { return }

        do {
            let note = try await noteStore.ensureNote(for: Date())
            try await noteStore.writeContents(text, to: note)
            try await refreshNotes(selectToday: false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func flushPendingSaves() async {
        await menuBarSaveDebouncer.flush("menuBarSave")
    }

    func continueWithoutReminders() {
        config.remindersEnabled = false
        Task {
            await ReminderManager.shared.removeScheduledReminders()
            do {
                try await configStore.save(config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func startNotificationStatusObserver() {
        if let activeObserver {
            NotificationCenter.default.removeObserver(activeObserver)
        }
        activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { await self?.refreshNotificationSetup() }
        }
    }

    func refreshNotificationSetup() async {
        guard ReminderManager.isAvailable else {
            notificationSetup = .unavailable
            return
        }

        guard let status = await ReminderManager.shared.authorizationStatus() else {
            notificationSetup = .unavailable
            return
        }

        switch status {
        case .authorized, .provisional, .ephemeral:
            notificationSetup = .authorized
        case .denied:
            notificationSetup = .denied
        case .notDetermined:
            notificationSetup = .needsPermission
        @unknown default:
            notificationSetup = .needsPermission
        }
    }

    func requestNotificationPermission() async {
        let granted = await ReminderManager.shared.requestAuthorization()
        await refreshNotificationSetup()
        if granted {
            await ReminderManager.shared.reschedule(from: config)
        }
    }

    func openNotificationSettings() {
        ReminderManager.shared.openSystemSettings()
    }

    func confirmLaunchAtLogin(enabled: Bool) {
        config.launchAtLogin = enabled
        config.launchAtLoginConfigured = true
        Task {
            do {
                try await applyLaunchAtLoginPreference()
                try await configStore.save(config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        config.launchAtLogin = enabled
        config.launchAtLoginConfigured = true
        Task {
            do {
                try await applyLaunchAtLoginPreference()
                try await configStore.save(config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func applyLaunchAtLoginPreference() async throws {
        try LaunchAtLoginManager.sync(preference: config.launchAtLogin)
    }

    private func startDayRolloverMonitor() {
        dayRolloverMonitor?.stop()
        dayRolloverMonitor = DayRolloverMonitor { [weak self] in
            await self?.ensureTodaysNote(switchToToday: false)
        }
        dayRolloverMonitor?.start()
    }

    /// Ensures `YYYY-MM-DD.md` exists for today. Called on launch, at midnight, on wake, and when the app becomes active.
    func ensureTodaysNote(switchToToday: Bool = false) async {
        guard let noteStore else { return }

        do {
            let today = DateFormatting.startOfDay(Date())
            let hadToday = notes.contains { DateFormatting.isSameDay($0.date, today) }

            _ = try await noteStore.ensureNote(for: Date())
            try await refreshNotes(selectToday: switchToToday)

            if switchToToday {
                selectedDate = today
            }

            if !hadToday {
                folderRevision += 1
            }
            await ReminderManager.shared.reschedule(from: config)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func chooseNotesFolder() {
        guard canCreateNotes else { return }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        panel.message = "Choose a folder for your daily markdown notes. Existing YYYY-MM-DD.md files will be picked up automatically."

        guard panel.runModal() == .OK, let url = panel.url else { return }
        Task { await openNotesFolder(url, persist: true, confirmExistingNotes: true) }
    }

    func openNotesFolder(
        _ url: URL,
        persist: Bool,
        confirmExistingNotes: Bool = false
    ) async {
        guard canCreateNotes else { return }

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

            let existingCount = try await NoteStore(folderURL: url).existingNoteCount()
            if confirmExistingNotes, existingCount > 0 {
                let alert = NSAlert()
                alert.messageText = "Use this notes folder?"
                alert.informativeText =
                    "Found \(existingCount) daily note\(existingCount == 1 ? "" : "s") in this folder."
                alert.addButton(withTitle: "Use Folder")
                alert.addButton(withTitle: "Cancel")
                guard alert.runModal() == .alertFirstButtonReturn else { return }
            }

            config.setNotesFolder(url)
            noteStore = NoteStore(folderURL: url)
            folderRevision += 1

            if persist {
                try await configStore.save(config)
            }

            try await refreshNotes(selectToday: true)
            await ReminderManager.shared.reschedule(from: config)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshNotes(selectToday: Bool = false) async throws {
        guard let noteStore else { return }

        var listed = try await noteStore.listNotes()

        if selectToday {
            let today = DateFormatting.startOfDay(Date())
            let hasToday = listed.contains { DateFormatting.isSameDay($0.date, today) }

            if !hasToday {
                _ = try await noteStore.ensureNote(for: Date())
                listed = try await noteStore.listNotes()
            }

            if listed.contains(where: { DateFormatting.isSameDay($0.date, today) }) {
                selectedDate = today
            } else if let newest = listed.first {
                selectedDate = newest.date
            } else {
                selectedDate = today
            }
        } else if !listed.contains(where: { DateFormatting.isSameDay($0.date, selectedDate) }) {
            selectedDate = listed.first?.date ?? DateFormatting.startOfDay(Date())
        }

        notes = listed
    }

    func select(date: Date) {
        selectedDate = DateFormatting.startOfDay(date)
    }

    func openTodaysNote() {
        Task {
            await ensureTodaysNote(switchToToday: true)
        }
    }

    func openFolderInFinder() {
        guard let url = config.notesFolderURL else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    func updateConfig(_ transform: (inout AppConfig) -> Void) {
        transform(&config)
        config.reminderTimes = ReminderTime.deduplicatedSorted(config.reminderTimes)
        Task {
            do {
                try await configStore.save(config)
                await ReminderManager.shared.reschedule(from: config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateAppearance(_ transform: (inout AppearanceSettings) -> Void) {
        transform(&config.appearance)
        config.appearance.normalize()
        Task {
            do {
                try await configStore.save(config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func increaseEditorZoom() {
        updateAppearance { $0.editorZoom = min($0.editorZoom + 0.1, AppearanceSettings.zoomRange.upperBound) }
    }

    func decreaseEditorZoom() {
        updateAppearance { $0.editorZoom = max($0.editorZoom - 0.1, AppearanceSettings.zoomRange.lowerBound) }
    }

    func resetEditorZoom() {
        updateAppearance { $0.editorZoom = AppearanceSettings.defaultZoom }
    }

    func setEditorZoom(_ zoom: Double) {
        updateAppearance { $0.editorZoom = zoom }
    }

    func applyPreviewColorTheme(_ theme: PreviewColorTheme) {
        updateAppearance { settings in
            settings.previewColorTheme = theme
            if theme != .custom {
                settings.previewColors = theme.colors
            }
        }
    }

    func openFormattingPreview() {
        showFormattingPreviewSheet = true
    }

    func closeFormattingPreview() {
        showFormattingPreviewSheet = false
    }

    func updateKeyboardShortcuts(_ transform: (inout KeyboardShortcuts) -> Void) {
        transform(&config.keyboardShortcuts)
        Task {
            do {
                try await configStore.save(config)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func resetKeyboardShortcuts() {
        updateKeyboardShortcuts { $0.resetToDefaults() }
    }

    func exportSettings() {
        let export = SettingsExport(from: config)
        let panel = NSSavePanel()
        panel.title = "Export macdaily Settings"
        panel.nameFieldStringValue = SettingsExporter.defaultFilename()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.prompt = "Export"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try SettingsExporter.encode(export)
            try AtomicWrite.write(data, to: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importSettings() {
        let panel = NSOpenPanel()
        panel.title = "Import macdaily Settings"
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Import"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try Data(contentsOf: url)
            let export = try SettingsExporter.decode(data)

            let alert = NSAlert()
            alert.alertStyle = .informational
            alert.messageText = "Import settings?"
            alert.informativeText =
                "This replaces appearance, keyboard shortcuts, reminders, and launch-at-login on this Mac. " +
                "Your notes folder will not change."
            alert.addButton(withTitle: "Import")
            alert.addButton(withTitle: "Cancel")

            guard alert.runModal() == .alertFirstButtonReturn else { return }

            config = export.applying(to: config)
            Task {
                do {
                    try await applyLaunchAtLoginPreference()
                    try await configStore.save(config)
                    await ReminderManager.shared.reschedule(from: config)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func noteStoreIfAvailable() -> NoteStore? {
        noteStore
    }

    func selectedNote() async throws -> DailyNote? {
        guard let noteStore else { return nil }
        return try await noteStore.ensureNote(for: selectedDate)
    }
}
