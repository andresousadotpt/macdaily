import XCTest
@testable import MacDailyCore

final class DateFormattingTests: XCTestCase {
    func testFilenameUsesIsoDate() {
        let normalized = TestFixtures.normalizedFixedDate()
        XCTAssertEqual(DateFormatting.filename(for: normalized), "2026-06-10.md")
    }

    func testParsesDailyNoteFilename() {
        XCTAssertTrue(DateFormatting.isDailyNoteFilename("2026-06-10.md"))
        XCTAssertFalse(DateFormatting.isDailyNoteFilename("notes.md"))
        XCTAssertFalse(DateFormatting.isDailyNoteFilename("2026-13-40.md"))
        XCTAssertFalse(DateFormatting.isDailyNoteFilename("2026-06-10.txt"))
    }

    func testDateFromFilenameRoundTrip() {
        let normalized = TestFixtures.normalizedFixedDate()
        let filename = DateFormatting.filename(for: normalized)
        let parsed = DateFormatting.date(fromFilename: filename)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(DateFormatting.isSameDay(parsed!, normalized))
    }

    func testDateFromFilenameReturnsNilForInvalidStem() {
        XCTAssertNil(DateFormatting.date(fromFilename: "not-a-date.md"))
    }

    func testStartOfDayAndSameDay() {
        let now = Date()
        let start = DateFormatting.startOfDay(now)
        XCTAssertTrue(DateFormatting.isSameDay(start, now))
        XCTAssertTrue(DateFormatting.isSameDay(start, start))
    }
}
