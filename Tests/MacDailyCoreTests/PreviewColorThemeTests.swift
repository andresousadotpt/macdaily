import XCTest
@testable import MacDailyCore

final class PreviewColorThemeTests: XCTestCase {
    func testPreviewColorThemeInference() {
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.forest.colors), .forest)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.monokai.colors), .monokai)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewColorTheme.dracula.colors), .dracula)
        XCTAssertEqual(PreviewColorTheme.inferred(from: PreviewElementColors(body: .rgb(1, 2, 3))), .custom)
    }

    func testPreviewColorThemeMatchesPresetColors() {
        XCTAssertTrue(PreviewColorTheme.ocean.matches(PreviewColorTheme.ocean.colors))
        XCTAssertFalse(PreviewColorTheme.ocean.matches(PreviewColorTheme.forest.colors))
        XCTAssertFalse(PreviewColorTheme.custom.matches(PreviewElementColors()))
    }

    func testAllPresetThemesInferCorrectly() {
        for preset in PreviewColorTheme.presetCases {
            XCTAssertEqual(PreviewColorTheme.inferred(from: preset.colors), preset)
        }
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
}
