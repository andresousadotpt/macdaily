import XCTest
@testable import MacDailyCore

final class MarkdownFormattingTests: XCTestCase {
    func testMarkdownFormattingWrapsBold() {
        let result = MarkdownFormatting.apply(.bold, to: "hello world", range: NSRange(location: 0, length: 5))
        XCTAssertEqual(result.text, "**hello** world")
    }

    func testMarkdownFormattingUnwrapsBold() {
        let result = MarkdownFormatting.apply(.bold, to: "**hello** world", range: NSRange(location: 0, length: 9))
        XCTAssertEqual(result.text, "hello world")
    }

    func testMarkdownFormattingWrapsItalic() {
        let result = MarkdownFormatting.apply(.italic, to: "hello world", range: NSRange(location: 6, length: 5))
        XCTAssertEqual(result.text, "hello *world*")
    }

    func testMarkdownFormattingWrapsStrikethrough() {
        let result = MarkdownFormatting.apply(.strikethrough, to: "remove", range: NSRange(location: 0, length: 6))
        XCTAssertEqual(result.text, "~~remove~~")
    }

    func testMarkdownFormattingWrapsUnderline() {
        let result = MarkdownFormatting.apply(.underline, to: "text", range: NSRange(location: 0, length: 4))
        XCTAssertEqual(result.text, "<u>text</u>")
    }

    func testMarkdownFormattingWrapsInlineCode() {
        let result = MarkdownFormatting.apply(.inlineCode, to: "code", range: NSRange(location: 0, length: 4))
        XCTAssertEqual(result.text, "`code`")
    }

    func testMarkdownFormattingInsertsLinkWithSelection() {
        let result = MarkdownFormatting.apply(.link, to: "click here", range: NSRange(location: 0, length: 5))
        XCTAssertEqual(result.text, "[click](https://) here")
        XCTAssertEqual(result.selectedRange, NSRange(location: 8, length: 8))
    }

    func testMarkdownFormattingInsertsLinkWithEmptySelection() {
        let result = MarkdownFormatting.apply(.link, to: "hello", range: NSRange(location: 5, length: 0))
        XCTAssertEqual(result.text, "hello[text](https://)")
    }

    func testMarkdownFormattingTogglesHeading() {
        let result = MarkdownFormatting.apply(.heading1, to: "Title", range: NSRange(location: 0, length: 5))
        XCTAssertEqual(result.text, "# Title")

        let cleared = MarkdownFormatting.apply(.heading1, to: result.text, range: NSRange(location: 0, length: result.text.count))
        XCTAssertEqual(cleared.text, "Title")
    }

    func testMarkdownFormattingSwapsHeadingLevel() {
        let result = MarkdownFormatting.apply(.heading2, to: "# Title", range: NSRange(location: 0, length: 7))
        XCTAssertEqual(result.text, "## Title")
    }

    func testMarkdownFormattingAppliesHeadingOnMultilineSelection() {
        let text = "first line\nsecond line"
        let result = MarkdownFormatting.apply(.heading3, to: text, range: NSRange(location: 11, length: 5))
        XCTAssertEqual(result.text, "first line\n### second line")
    }

    func testMarkdownFormattingInsertsEmptyWrapMarkers() {
        let result = MarkdownFormatting.apply(.bold, to: "hello", range: NSRange(location: 5, length: 0))
        XCTAssertEqual(result.text, "hello****")
        XCTAssertEqual(result.selectedRange.location, 7)
        XCTAssertEqual(result.selectedRange.length, 0)
    }

    func testLineCount() {
        XCTAssertEqual(MarkdownFormatting.lineCount(in: ""), 1)
        XCTAssertEqual(MarkdownFormatting.lineCount(in: "one"), 1)
        XCTAssertEqual(MarkdownFormatting.lineCount(in: "one\ntwo"), 2)
        XCTAssertEqual(MarkdownFormatting.lineCount(in: "one\ntwo\n"), 3)
    }
}
