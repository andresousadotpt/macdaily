import XCTest
@testable import MacDailyCore

final class TextIndentationTests: XCTestCase {
    func testTabInsertsTabCharacterOnSingleLine() {
        let result = TextIndentation.applyTab(to: "hello", range: NSRange(location: 2, length: 0))
        XCTAssertEqual(result.text, "he\tllo")
        XCTAssertEqual(result.selectedRange, NSRange(location: 3, length: 0))
    }

    func testTabReplacesSelectionWithTabCharacter() {
        let result = TextIndentation.applyTab(to: "hello world", range: NSRange(location: 6, length: 5))
        XCTAssertEqual(result.text, "hello \t")
        XCTAssertEqual(result.selectedRange, NSRange(location: 7, length: 0))
    }

    func testTabIndentsMultipleSelectedLines() {
        let result = TextIndentation.applyTab(
            to: "line one\nline two\nline three",
            range: NSRange(location: 0, length: 17)
        )
        XCTAssertEqual(result.text, "\tline one\n\tline two\nline three")
        XCTAssertEqual(result.selectedRange, NSRange(location: 1, length: 18))
    }

    func testShiftTabOutdentsMultipleSelectedLines() {
        let result = TextIndentation.applyShiftTab(
            to: "\tline one\n\tline two",
            range: NSRange(location: 0, length: 15)
        )
        XCTAssertEqual(result?.text, "line one\nline two")
        XCTAssertEqual(result?.selectedRange, NSRange(location: 0, length: 13))
    }

    func testShiftTabOutdentsSpaces() {
        let result = TextIndentation.applyShiftTab(
            to: "    indented",
            range: NSRange(location: 4, length: 0)
        )
        XCTAssertEqual(result?.text, "indented")
        XCTAssertEqual(result?.selectedRange, NSRange(location: 0, length: 0))
    }

    func testShiftTabDoesNothingWithoutIndentation() {
        let result = TextIndentation.applyShiftTab(to: "plain text", range: NSRange(location: 0, length: 0))
        XCTAssertNil(result)
    }

    func testSpansMultipleLinesRequiresSelectionAcrossLines() {
        XCTAssertFalse(TextIndentation.spansMultipleLines(in: "one line", range: NSRange(location: 0, length: 3)))
        XCTAssertTrue(TextIndentation.spansMultipleLines(in: "one\n two", range: NSRange(location: 0, length: 4)))
    }
}
