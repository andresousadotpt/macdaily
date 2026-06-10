import Foundation
import XCTest
@testable import MacDailyCore

final class MacDailyCoreTests: XCTestCase {
    func testFilenameUsesIsoDate() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2026
        components.month = 6
        components.day = 10
        let date = calendar.date(from: components)!
        let normalized = DateFormatting.startOfDay(date)

        XCTAssertEqual(DateFormatting.filename(for: normalized), "2026-06-10.md")
    }

    func testParsesDailyNoteFilename() {
        XCTAssertTrue(DateFormatting.isDailyNoteFilename("2026-06-10.md"))
        XCTAssertFalse(DateFormatting.isDailyNoteFilename("notes.md"))
        XCTAssertFalse(DateFormatting.isDailyNoteFilename("2026-13-40.md"))
    }

    func testReminderTimesAreDeduplicatedAndSorted() {
        let first = ReminderTime(hour: 9, minute: 30)
        let times = ReminderTime.deduplicatedSorted([
            ReminderTime(hour: 16, minute: 0),
            first,
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 13, minute: 0),
        ])

        XCTAssertEqual(times.count, 3)
        XCTAssertEqual(times[0].hour, 9)
        XCTAssertEqual(times[0].minute, 30)
        XCTAssertEqual(times[1].hour, 13)
        XCTAssertEqual(times[2].hour, 16)
    }

    func testNoteStoreCreatesAndListsNotes() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let note = try await store.ensureNote(for: Date(timeIntervalSince1970: 1_718_000_000))
        XCTAssertTrue(FileManager.default.fileExists(atPath: note.url.path))

        try await store.writeContents("# Hello", to: note)
        let contents = try await store.readContents(of: note)
        XCTAssertEqual(contents, "# Hello")

        let listed = try await store.listNotes()
        XCTAssertEqual(listed.count, 1)
    }

    func testMarkdownFormattingWrapsBold() {
        let result = MarkdownFormatting.apply(.bold, to: "hello world", range: NSRange(location: 0, length: 5))
        XCTAssertEqual(result.text, "**hello** world")
    }

    func testMarkdownFormattingUnwrapsBold() {
        let result = MarkdownFormatting.apply(.bold, to: "**hello** world", range: NSRange(location: 0, length: 9))
        XCTAssertEqual(result.text, "hello world")
    }

    func testMarkdownFormattingTogglesHeading() {
        let result = MarkdownFormatting.apply(.heading1, to: "Title", range: NSRange(location: 0, length: 5))
        XCTAssertEqual(result.text, "# Title")

        let cleared = MarkdownFormatting.apply(.heading1, to: result.text, range: NSRange(location: 0, length: result.text.count))
        XCTAssertEqual(cleared.text, "Title")
    }

    func testLineCount() {
        XCTAssertEqual(MarkdownFormatting.lineCount(in: ""), 1)
        XCTAssertEqual(MarkdownFormatting.lineCount(in: "one"), 1)
        XCTAssertEqual(MarkdownFormatting.lineCount(in: "one\ntwo"), 2)
    }

    func testConfigEncodesKeyboardShortcuts() throws {
        var config = AppConfig(
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

    func testSettingsExportRoundTrip() throws {
        var config = AppConfig(
            appearance: AppearanceSettings(
                editorZoom: 1.25,
                useCustomPreviewColors: true,
                previewColorTheme: .ocean,
                previewColors: PreviewColorTheme.ocean.colors
            ),
            keyboardShortcuts: KeyboardShortcuts(bindings: [
                MarkdownFormatAction.italic.rawValue: .command("i"),
            ])
        )
        config.remindersEnabled = false

        let export = SettingsExport(from: config)
        let data = try SettingsExporter.encode(export)
        let loaded = try SettingsExporter.decode(data)
        let applied = loaded.applying(to: AppConfig())

        XCTAssertEqual(loaded.appearance.previewColorTheme, .ocean)
        XCTAssertEqual(applied.appearance.previewColorTheme, .ocean)
        XCTAssertEqual(applied.appearance.previewColors.link.hex, PreviewColorTheme.ocean.colors.link.hex)
        XCTAssertFalse(applied.remindersEnabled)
    }

    func testPreviewColorThemeInference() {
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.forest.colors), .forest)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.monokai.colors), .monokai)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.dracula.colors), .dracula)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewElementColors(body: .rgb(1, 2, 3))), .custom)
    }

    func testDateFromFilenameRoundTrip() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = 2026
        components.month = 6
        components.day = 10
        let date = calendar.date(from: components)!
        let normalized = DateFormatting.startOfDay(date)

        let filename = DateFormatting.filename(for: normalized)
        let parsed = DateFormatting.date(fromFilename: filename)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(DateFormatting.isSameDay(parsed!, normalized))
    }

    func testStartOfDayAndSameDay() {
        let now = Date()
        let start = DateFormatting.startOfDay(now)
        XCTAssertTrue(DateFormatting.isSameDay(start, now))
        XCTAssertTrue(DateFormatting.isSameDay(start, start))
    }

    func testAtomicWriteCreatesParentDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = root.appendingPathComponent("nested/note.md")
        defer { try? FileManager.default.removeItem(at: root) }

        try AtomicWrite.write("# Note", to: fileURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(contents, "# Note")

        try AtomicWrite.write("# Updated", to: fileURL)
        let updated = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertEqual(updated, "# Updated")
    }

    func testConfigStoreRoundTrip() async throws {
        let configURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")
        defer { try? FileManager.default.removeItem(at: configURL.deletingLastPathComponent()) }

        let store = ConfigStore(configURL: configURL)
        var config = AppConfig(notesFolderPath: "/tmp/notes", remindersEnabled: false)
        try await store.save(config)

        let loaded = await store.load()
        XCTAssertNil(loaded.loadError)
        XCTAssertEqual(loaded.config.notesFolderPath, "/tmp/notes")
        XCTAssertFalse(loaded.config.remindersEnabled)
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

    func testSettingsExporterRejectsWrongApp() throws {
        var export = SettingsExport(from: AppConfig())
        export.appName = "other-app"
        let data = try SettingsExporter.encode(export)

        XCTAssertThrowsError(try SettingsExporter.decode(data)) { error in
            guard case SettingsExportError.wrongApp(let name) = error else {
                return XCTFail("Expected wrongApp error, got \(error)")
            }
            XCTAssertEqual(name, "other-app")
        }
    }

    func testSettingsExporterRejectsUnsupportedVersion() throws {
        var export = SettingsExport(from: AppConfig())
        export.formatVersion = SettingsExport.formatVersion + 1
        let data = try SettingsExporter.encode(export)

        XCTAssertThrowsError(try SettingsExporter.decode(data)) { error in
            guard case SettingsExportError.unsupportedVersion(let version) = error else {
                return XCTFail("Expected unsupportedVersion error, got \(error)")
            }
            XCTAssertEqual(version, SettingsExport.formatVersion + 1)
        }
    }

    func testSettingsExporterRejectsInvalidFile() {
        XCTAssertThrowsError(try SettingsExporter.decode(Data("not json".utf8))) { error in
            guard case SettingsExportError.invalidFile = error else {
                return XCTFail("Expected invalidFile error, got \(error)")
            }
        }
    }

    func testSettingsExportDecodingDeduplicatesReminderTimes() throws {
        let json = """
        {
          "formatVersion": 1,
          "exportedAt": "2026-06-10T12:00:00Z",
          "appName": "macdaily",
          "appearance": {},
          "keyboardShortcuts": {},
          "remindersEnabled": true,
          "reminderTimes": [
            {"hour": 9, "minute": 30},
            {"hour": 9, "minute": 30},
            {"hour": 16, "minute": 0}
          ],
          "launchAtLogin": true
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let export = try decoder.decode(SettingsExport.self, from: Data(json.utf8))
        XCTAssertEqual(export.reminderTimes.count, 2)
    }

    func testNoteStoreRejectsInvalidNotePath() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let outside = DailyNote(date: Date(), url: root.deletingLastPathComponent().appendingPathComponent("outside.md"))

        do {
            _ = try await store.readContents(of: outside)
            XCTFail("Expected invalidNote error")
        } catch let error as NoteStoreError {
            XCTAssertEqual(error, .invalidNote)
        }
    }

    func testAppearanceSettingsClampsZoomOnDecode() throws {
        let json = """
        {"editorZoom": 99.0}
        """
        let settings = try JSONDecoder().decode(AppearanceSettings.self, from: Data(json.utf8))
        XCTAssertEqual(settings.editorZoom, AppearanceSettings.zoomRange.upperBound)
    }

    func testReminderTimeClampsOnDecode() throws {
        let json = """
        {"hour": 99, "minute": 99}
        """
        let time = try JSONDecoder().decode(ReminderTime.self, from: Data(json.utf8))
        XCTAssertEqual(time.hour, 23)
        XCTAssertEqual(time.minute, 59)
    }
}
