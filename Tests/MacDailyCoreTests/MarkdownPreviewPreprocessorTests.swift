import XCTest
@testable import MacDailyCore

final class MarkdownPreviewPreprocessorTests: XCTestCase {
    func testSwapsBulletMarkerBeforeTaskItem() {
        let input = """
        - Hello
        - [ ] Task
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("+ Hello\n- [ ] Task"))
        XCTAssertFalse(output.contains("<!--"))
    }

    func testSwapsBulletMarkerAfterTaskItem() {
        let input = """
        - [ ] Task
        - Hello
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("- [ ] Task\n+ Hello"))
        XCTAssertFalse(output.contains("<!--"))
    }

    func testSwapsBulletMarkerAfterTaskWithBlankLines() {
        let input = """
        - [ ] Task


        - Hello
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("- [ ] Task\n\n\n+ Hello"))
    }

    func testInsertsBlankLineAfterTaskBeforePlainText() {
        let input = """
        - [ ] Task
        Hello
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("- [ ] Task\n\nHello"))
    }

    func testInsertsBlankLineAfterBulletBeforePlainText() {
        let input = """
        - [ ] Task
        - Item
        Plain
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("+ Item\n\nPlain"))
    }

    func testDoesNotModifyTaskOnlyList() {
        let input = """
        - [ ] One
        - [x] Two
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertEqual(output, input)
    }

    func testDoesNotModifyBulletOnlyList() {
        let input = """
        - One
        - Two
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertEqual(output, input)
    }

    func testNormalizesTaskListFollowedByBulletsAndPlainText() {
        let input = """
        - [x] Completed task
        - [ ] Open task


        - asdfasdf
        asdfasdf
        - adfasdfasdf
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("- [ ] Open task\n\n\n+ asdfasdf"))
        XCTAssertTrue(output.contains("+ asdfasdf\n\nasdfasdf"))
        XCTAssertTrue(output.contains("asdfasdf\n- adfasdfasdf"))
        XCTAssertFalse(output.contains("<!--"))
    }

    func testNormalizesMixedListAndTrailingPlainText() {
        let input = """
        # Hello
        - Hello
        - [ ] Task
        Hello
        How
        are
        you?
        """
        let output = MarkdownPreviewPreprocessor.normalizeForPreview(input)

        XCTAssertTrue(output.contains("+ Hello\n- [ ] Task"))
        XCTAssertTrue(output.contains("- [ ] Task\n\nHello"))
    }
}
