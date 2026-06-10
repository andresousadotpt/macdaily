import AppKit
import Foundation
import MacDailyCore
import UserNotifications

@MainActor
final class ReminderManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = ReminderManager()

    private let categoryIdentifier = "macdaily.daily"
    private var isConfigured = false

    /// UserNotifications requires a real `.app` bundle and crashes under `swift run`.
    static var isAvailable: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    override private init() {
        super.init()
    }

    private func notificationCenter() -> UNUserNotificationCenter? {
        guard Self.isAvailable else { return nil }
        let center = UNUserNotificationCenter.current()
        if !isConfigured {
            center.delegate = self
            isConfigured = true
        }
        return center
    }

    func authorizationStatus() async -> UNAuthorizationStatus? {
        guard let center = notificationCenter() else { return nil }
        return await center.notificationSettings().authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        guard let center = notificationCenter() else { return false }

        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        @unknown default:
            return false
        }
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        guard let center = notificationCenter() else { return false }

        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return await requestAuthorization()
        @unknown default:
            return false
        }
    }

    func openSystemSettings() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleID)")
            ?? URL(string: "x-apple.systempreferences:com.apple.preference.notifications")
        if let url {
            NSWorkspace.shared.open(url)
        }
    }

    func reschedule(from config: AppConfig) async {
        guard notificationCenter() != nil else { return }

        await removeScheduledReminders()

        guard config.remindersEnabled, !config.reminderTimes.isEmpty else { return }
        guard await requestAuthorizationIfNeeded() else { return }
        guard let center = notificationCenter() else { return }

        for time in config.reminderTimes {
            let content = UNMutableNotificationContent()
            content.title = "Time for your daily note"
            content.body = "Open macdaily to write today's note."
            content.sound = .default
            content.categoryIdentifier = categoryIdentifier

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: time.dateComponents(),
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: notificationID(for: time),
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    func removeScheduledReminders() async {
        guard let center = notificationCenter() else { return }

        let pending = await center.pendingNotificationRequests()
        let ids = pending
            .map(\.identifier)
            .filter { $0.hasPrefix("macdaily.") }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            NotificationCenter.default.post(name: .openTodaysNote, object: nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func notificationID(for time: ReminderTime) -> String {
        "macdaily.\(time.id.uuidString)"
    }
}

extension Notification.Name {
    static let openTodaysNote = Notification.Name("macdaily.openTodaysNote")
}
