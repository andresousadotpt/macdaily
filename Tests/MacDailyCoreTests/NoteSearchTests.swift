import XCTest
@testable import MacDailyCore

final class NoteSearchTests: XCTestCase {
    func testMatchesReturnsEmptyForBlankQuery() {
        let date = TestFixtures.normalizedFixedDate()
        XCTAssertTrue(NoteSearch.matches(in: "hello", for: date, query: "").isEmpty)
        XCTAssertTrue(NoteSearch.matches(in: "hello", for: date, query: "   ").isEmpty)
    }

    func testMatchesFindsCaseInsensitiveSubstring() {
        let date = TestFixtures.normalizedFixedDate(year: 2026, month: 6, day: 10)
        let content = "# Morning\nWrote about Swift today.\n"

        let matches = NoteSearch.matches(in: content, for: date, query: "swift")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].lineNumber, 2)
        XCTAssertEqual(matches[0].lineText, "Wrote about Swift today.")
        XCTAssertEqual(matches[0].date, date)
    }

    func testMatchesReportsOneResultPerMatchingLine() {
        let date = TestFixtures.normalizedFixedDate()
        let content = "todo todo\ntodo again\n"

        let matches = NoteSearch.matches(in: content, for: date, query: "todo")
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(matches.map(\.lineNumber), [1, 2])
    }

    func testMatchesHandlesTrailingNewlineOnlyContent() {
        let date = TestFixtures.normalizedFixedDate()
        let matches = NoteSearch.matches(in: "find me\n", for: date, query: "find")
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].lineNumber, 1)
    }

    func testNoteStoreSearchAggregatesAcrossNotes() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let older = TestFixtures.normalizedFixedDate(year: 2026, month: 6, day: 8)
        let newer = TestFixtures.normalizedFixedDate(year: 2026, month: 6, day: 10)

        let olderNote = try await store.ensureNote(for: older)
        try await store.writeContents("alpha entry", to: olderNote)

        let newerNote = try await store.ensureNote(for: newer)
        try await store.writeContents("beta alpha", to: newerNote)

        let results = try await store.search(matching: "alpha")
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].date, newer)
        XCTAssertEqual(results[1].date, older)
    }

    func testNoteStoreSearchReturnsEmptyForBlankQuery() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        _ = try await store.ensureNote(for: TestFixtures.normalizedFixedDate())
        let results = try await store.search(matching: "  ")
        XCTAssertTrue(results.isEmpty)
    }
}
