import XCTest
@testable import MacDailyCore

final class ConfigStoreTests: XCTestCase {
    func testConfigEncodesKeyboardShortcuts() throws {
        let config = AppConfig(
            notesFolderPath: "/tmp/notes",
            remindersEnabled: true,
            reminderTimes: [ReminderTime(hour: 10, minute: 15)],
            keyboardShortcuts: KeyboardShortcuts(bindings: [
                MarkdownFormatAction.bold.rawValue: .command("b"),
            ])
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(config)
        let loaded = try JSONDecoder().decode(AppConfig.self, from: data)
        XCTAssertEqual(loaded.notesFolderPath, "/tmp/notes")
        XCTAssertEqual(loaded.keyboardShortcuts.binding(for: .bold).key, "b")
    }

    func testAppConfigSetNotesFolder() {
        var config = AppConfig()
        let folder = URL(fileURLWithPath: "/tmp/notes", isDirectory: true)
        config.setNotesFolder(folder)
        XCTAssertEqual(config.notesFolderPath, "/tmp/notes")
        XCTAssertEqual(config.notesFolderURL, folder)
    }

    func testAppConfigNotesFolderURLIsNilWhenUnset() {
        XCTAssertNil(AppConfig().notesFolderURL)
    }

    func testAppConfigDeduplicatesReminderTimesOnInit() {
        let config = AppConfig(reminderTimes: [
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 16, minute: 0),
        ])
        XCTAssertEqual(config.reminderTimes.count, 2)
    }

    func testAppConfigSetReminderTimesDeduplicates() {
        var config = AppConfig()
        config.setReminderTimes([
            ReminderTime(hour: 16, minute: 0),
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 9, minute: 30),
        ])
        XCTAssertEqual(config.reminderTimes.map(\.hour), [9, 16])
    }

    func testAppConfigDecodeUsesDefaultsForMissingFields() throws {
        let json = """
        {}
        """
        let config = try JSONDecoder().decode(AppConfig.self, from: Data(json.utf8))
        XCTAssertTrue(config.remindersEnabled)
        XCTAssertEqual(config.reminderTimes, ReminderTime.defaults)
        XCTAssertTrue(config.launchAtLogin)
        XCTAssertFalse(config.launchAtLoginConfigured)
    }

    func testConfigStoreRoundTrip() async throws {
        let configURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")
        defer { try? FileManager.default.removeItem(at: configURL.deletingLastPathComponent()) }

        let store = ConfigStore(configURL: configURL)
        let config = AppConfig(notesFolderPath: "/tmp/notes", remindersEnabled: false)
        try await store.save(config)

        let loaded = await store.load()
        XCTAssertNil(loaded.loadError)
        XCTAssertEqual(loaded.config.notesFolderPath, "/tmp/notes")
        XCTAssertFalse(loaded.config.remindersEnabled)
    }

    func testConfigStoreReturnsDefaultConfigWhenMissing() async {
        let configURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")

        let loaded = await ConfigStore(configURL: configURL).load()
        XCTAssertNil(loaded.loadError)
        XCTAssertEqual(loaded.config, AppConfig())
    }

    func testConfigStoreReturnsDecodeErrorForCorruptJSON() async throws {
        let configURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")
        defer { try? FileManager.default.removeItem(at: configURL.deletingLastPathComponent()) }

        try AtomicWrite.write("{ not json".data(using: .utf8)!, to: configURL)

        let store = ConfigStore(configURL: configURL)
        let loaded = await store.load()
        XCTAssertEqual(loaded.loadError, .decodeFailed)
        XCTAssertEqual(loaded.config, AppConfig())
    }
}
