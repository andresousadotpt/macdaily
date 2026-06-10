import Foundation

public struct AppConfig: Codable, Sendable, Equatable {
    public var notesFolderPath: String?
    public var remindersEnabled: Bool
    public var reminderTimes: [ReminderTime]
    public var launchAtLogin: Bool
    public var launchAtLoginConfigured: Bool
    public var appearance: AppearanceSettings
    public var keyboardShortcuts: KeyboardShortcuts

    public init(
        notesFolderPath: String? = nil,
        remindersEnabled: Bool = true,
        reminderTimes: [ReminderTime] = ReminderTime.defaults,
        launchAtLogin: Bool = true,
        launchAtLoginConfigured: Bool = false,
        appearance: AppearanceSettings = AppearanceSettings(),
        keyboardShortcuts: KeyboardShortcuts = KeyboardShortcuts()
    ) {
        self.notesFolderPath = notesFolderPath
        self.remindersEnabled = remindersEnabled
        self.reminderTimes = ReminderTime.deduplicatedSorted(reminderTimes)
        self.launchAtLogin = launchAtLogin
        self.launchAtLoginConfigured = launchAtLoginConfigured
        self.appearance = appearance
        self.keyboardShortcuts = keyboardShortcuts
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notesFolderPath = try container.decodeIfPresent(String.self, forKey: .notesFolderPath)
        remindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? true
        reminderTimes = ReminderTime.deduplicatedSorted(
            try container.decodeIfPresent([ReminderTime].self, forKey: .reminderTimes) ?? ReminderTime.defaults
        )
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? true
        launchAtLoginConfigured = try container.decodeIfPresent(Bool.self, forKey: .launchAtLoginConfigured) ?? false
        appearance = try container.decodeIfPresent(AppearanceSettings.self, forKey: .appearance) ?? AppearanceSettings()
        keyboardShortcuts = try container.decodeIfPresent(KeyboardShortcuts.self, forKey: .keyboardShortcuts) ?? KeyboardShortcuts()
    }

    public var notesFolderURL: URL? {
        guard let notesFolderPath else { return nil }
        return URL(fileURLWithPath: notesFolderPath, isDirectory: true)
    }

    public mutating func setNotesFolder(_ url: URL) {
        notesFolderPath = url.path
    }

    public mutating func setReminderTimes(_ times: [ReminderTime]) {
        reminderTimes = ReminderTime.deduplicatedSorted(times)
    }
}

public enum AppPaths {
    public static let appSupportDirectory: URL = {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return FileManager.default.temporaryDirectory.appendingPathComponent("MacDaily", isDirectory: true)
        }
        return base.appendingPathComponent("MacDaily", isDirectory: true)
    }()

    public static let configURL: URL = {
        appSupportDirectory.appendingPathComponent("config.json")
    }()
}

public enum ConfigStoreError: LocalizedError, Equatable {
    case decodeFailed

    public var errorDescription: String? {
        switch self {
        case .decodeFailed:
            return "Could not read macdaily settings."
        }
    }
}

public struct ConfigLoadResult: Sendable {
    public var config: AppConfig
    public var loadError: ConfigStoreError?

    public init(config: AppConfig, loadError: ConfigStoreError? = nil) {
        self.config = config
        self.loadError = loadError
    }
}

public actor ConfigStore {
    private let configURL: URL

    public init(configURL: URL = AppPaths.configURL) {
        self.configURL = configURL
    }

    public func load() -> ConfigLoadResult {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return ConfigLoadResult(config: AppConfig())
        }
        do {
            let data = try Data(contentsOf: configURL)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            return ConfigLoadResult(config: config)
        } catch {
            return ConfigLoadResult(config: AppConfig(), loadError: .decodeFailed)
        }
    }

    public func save(_ config: AppConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try AtomicWrite.write(data, to: configURL)
    }
}
