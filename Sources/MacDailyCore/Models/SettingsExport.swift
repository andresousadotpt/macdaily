import Foundation

/// Portable settings bundle for export/import. Excludes machine-specific paths
/// such as the notes folder location.
public struct SettingsExport: Codable, Sendable, Equatable {
    public static let formatVersion = 1

    public var formatVersion: Int
    public var exportedAt: Date
    public var appName: String
    public var appearance: AppearanceSettings
    public var keyboardShortcuts: KeyboardShortcuts
    public var remindersEnabled: Bool
    public var reminderTimes: [ReminderTime]
    public var launchAtLogin: Bool

    public init(
        formatVersion: Int = Self.formatVersion,
        exportedAt: Date = Date(),
        appName: String = "macdaily",
        appearance: AppearanceSettings = AppearanceSettings(),
        keyboardShortcuts: KeyboardShortcuts = KeyboardShortcuts(),
        remindersEnabled: Bool = true,
        reminderTimes: [ReminderTime] = ReminderTime.defaults,
        launchAtLogin: Bool = true
    ) {
        self.formatVersion = formatVersion
        self.exportedAt = exportedAt
        self.appName = appName
        self.appearance = appearance
        self.keyboardShortcuts = keyboardShortcuts
        self.remindersEnabled = remindersEnabled
        self.reminderTimes = ReminderTime.deduplicatedSorted(reminderTimes)
        self.launchAtLogin = launchAtLogin
    }

    public init(from config: AppConfig, exportedAt: Date = Date()) {
        self.init(
            exportedAt: exportedAt,
            appearance: config.appearance,
            keyboardShortcuts: config.keyboardShortcuts,
            remindersEnabled: config.remindersEnabled,
            reminderTimes: config.reminderTimes,
            launchAtLogin: config.launchAtLogin
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        formatVersion = try container.decodeIfPresent(Int.self, forKey: .formatVersion) ?? Self.formatVersion
        exportedAt = try container.decodeIfPresent(Date.self, forKey: .exportedAt) ?? Date()
        appName = try container.decodeIfPresent(String.self, forKey: .appName) ?? "macdaily"
        appearance = try container.decodeIfPresent(AppearanceSettings.self, forKey: .appearance) ?? AppearanceSettings()
        keyboardShortcuts = try container.decodeIfPresent(KeyboardShortcuts.self, forKey: .keyboardShortcuts) ?? KeyboardShortcuts()
        remindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? true
        reminderTimes = ReminderTime.deduplicatedSorted(
            try container.decodeIfPresent([ReminderTime].self, forKey: .reminderTimes) ?? ReminderTime.defaults
        )
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? true
    }

    private enum CodingKeys: String, CodingKey {
        case formatVersion
        case exportedAt
        case appName
        case appearance
        case keyboardShortcuts
        case remindersEnabled
        case reminderTimes
        case launchAtLogin
    }

    public func applying(to config: AppConfig) -> AppConfig {
        var updated = config
        updated.appearance = appearance
        updated.keyboardShortcuts = keyboardShortcuts
        updated.remindersEnabled = remindersEnabled
        updated.setReminderTimes(reminderTimes)
        updated.launchAtLogin = launchAtLogin
        updated.appearance.normalize()
        return updated
    }
}

public enum SettingsExportError: LocalizedError {
    case unsupportedVersion(Int)
    case invalidFile
    case wrongApp(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let version):
            return "This settings file uses format version \(version), which macdaily cannot read."
        case .invalidFile:
            return "Could not read the selected settings file."
        case .wrongApp(let name):
            return "This file was exported from “\(name)”, not macdaily."
        }
    }
}

public enum SettingsExporter {
    public static let fileExtension = "macdaily-settings"
    public static let contentTypeIdentifier = "com.macdaily.settings"

    public static func encode(_ export: SettingsExport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(export)
    }

    public static func decode(_ data: Data) throws -> SettingsExport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let export: SettingsExport
        do {
            export = try decoder.decode(SettingsExport.self, from: data)
        } catch {
            throw SettingsExportError.invalidFile
        }

        guard export.formatVersion <= SettingsExport.formatVersion else {
            throw SettingsExportError.unsupportedVersion(export.formatVersion)
        }

        guard export.appName == "macdaily" else {
            throw SettingsExportError.wrongApp(export.appName)
        }

        return export
    }

    public static func defaultFilename(for date: Date = Date()) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        let stamp = formatter.string(from: date)
            .replacingOccurrences(of: ":", with: "-")
        return "macdaily-settings-\(stamp).json"
    }
}
