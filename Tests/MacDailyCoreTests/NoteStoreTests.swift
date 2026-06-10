import XCTest
@testable import MacDailyCore

final class NoteStoreTests: XCTestCase {
    func testNoteStoreCreatesAndListsNotes() async throws {
        let root = try TestFixtures.makeTempDirectory()
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

    func testNoteStoreEnsureNoteIsIdempotent() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let date = TestFixtures.normalizedFixedDate()
        let first = try await store.ensureNote(for: date)
        try await store.writeContents("draft", to: first)

        let second = try await store.ensureNote(for: date)
        XCTAssertEqual(first.url, second.url)
        let contents = try await store.readContents(of: second)
        XCTAssertEqual(contents, "draft")
    }

    func testNoteStoreListsNotesInDescendingOrder() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let older = TestFixtures.normalizedFixedDate(year: 2026, month: 6, day: 8)
        let newer = TestFixtures.normalizedFixedDate(year: 2026, month: 6, day: 10)
        _ = try await store.ensureNote(for: older)
        _ = try await store.ensureNote(for: newer)

        let listed = try await store.listNotes()
        XCTAssertEqual(listed.count, 2)
        XCTAssertTrue(listed[0].date > listed[1].date)
    }

    func testNoteStoreIgnoresNonDailyNoteFiles() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        try "notes".write(to: root.appendingPathComponent("readme.md"), atomically: true, encoding: .utf8)
        _ = try await NoteStore(folderURL: root).ensureNote(for: TestFixtures.normalizedFixedDate())

        let count = try await NoteStore(folderURL: root).existingNoteCount()
        XCTAssertEqual(count, 1)
    }

    func testNoteStoreReadContentsReturnsEmptyForMissingFile() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let date = TestFixtures.normalizedFixedDate()
        let note = DailyNote(date: date, url: root.appendingPathComponent(DateFormatting.filename(for: date)))
        let contents = try await store.readContents(of: note)
        XCTAssertEqual(contents, "")
    }

    func testNoteStoreRejectsInvalidNotePath() async throws {
        let root = try TestFixtures.makeTempDirectory()
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

    func testNoteStoreRejectsWriteOutsideFolder() async throws {
        let root = try TestFixtures.makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let store = NoteStore(folderURL: root)
        let outside = DailyNote(date: Date(), url: root.deletingLastPathComponent().appendingPathComponent("outside.md"))

        do {
            try await store.writeContents("nope", to: outside)
            XCTFail("Expected invalidNote error")
        } catch let error as NoteStoreError {
            XCTAssertEqual(error, .invalidNote)
        }
    }

    func testDailyNoteFilenameMatchesDateFormatting() {
        let date = TestFixtures.normalizedFixedDate()
        let note = DailyNote(date: date, url: URL(fileURLWithPath: "/tmp/2026-06-10.md"))
        XCTAssertEqual(note.filename, "2026-06-10.md")
    }
}
