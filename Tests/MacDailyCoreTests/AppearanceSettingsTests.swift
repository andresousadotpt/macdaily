import XCTest
@testable import MacDailyCore

final class AppearanceSettingsTests: XCTestCase {
    func testAppearanceSettingsClampsZoomOnDecode() throws {
        let json = """
        {"editorZoom": 99.0}
        """
        let settings = try JSONDecoder().decode(AppearanceSettings.self, from: Data(json.utf8))
        XCTAssertEqual(settings.editorZoom, AppearanceSettings.zoomRange.upperBound)
    }

    func testAppearanceSettingsClampsZoomBelowMinimum() throws {
        let json = """
        {"editorZoom": 0.1}
        """
        let settings = try JSONDecoder().decode(AppearanceSettings.self, from: Data(json.utf8))
        XCTAssertEqual(settings.editorZoom, AppearanceSettings.zoomRange.lowerBound)
    }

    func testAppearanceSettingsDecodesLegacyShowLineCountKey() throws {
        let json = """
        {"showLineCount": false}
        """
        let settings = try JSONDecoder().decode(AppearanceSettings.self, from: Data(json.utf8))
        XCTAssertFalse(settings.showLineNumbers)
    }

    func testAppearanceSettingsNormalizeClampsZoom() {
        var settings = AppearanceSettings(editorZoom: 5.0)
        settings.normalize()
        XCTAssertEqual(settings.editorZoom, AppearanceSettings.zoomRange.upperBound)
    }

    func testLineSpacingPreferencePoints() {
        XCTAssertEqual(LineSpacingPreference.compact.points, 2)
        XCTAssertEqual(LineSpacingPreference.normal.points, 6)
        XCTAssertEqual(LineSpacingPreference.relaxed.points, 12)
    }
}
