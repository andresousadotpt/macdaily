import XCTest
@testable import MacDailyCore

final class SettingsExportTests: XCTestCase {
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

    func testSettingsExportExcludesNotesFolderPath() throws {
        var config = AppConfig(notesFolderPath: "/Users/me/notes")
        config.remindersEnabled = false

        let data = try SettingsExporter.encode(SettingsExport(from: config))
        let json = String(data: data, encoding: .utf8)!

        XCTAssertFalse(json.contains("notesFolderPath"))
        XCTAssertFalse(json.contains("/Users/me/notes"))
    }

    func testSettingsExportApplyingNormalizesZoom() {
        var export = SettingsExport(from: AppConfig())
        export.appearance.editorZoom = 99

        let applied = export.applying(to: AppConfig())
        XCTAssertEqual(applied.appearance.editorZoom, AppearanceSettings.zoomRange.upperBound)
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

    func testSettingsExporterDefaultFilenameUsesSafeCharacters() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 10
        components.hour = 15
        components.minute = 30
        components.second = 0
        let date = calendar.date(from: components)!

        let filename = SettingsExporter.defaultFilename(for: date)
        XCTAssertTrue(filename.hasPrefix("macdaily-settings-"))
        XCTAssertFalse(filename.contains(":"))
        XCTAssertTrue(filename.hasSuffix(".json"))
    }
}
