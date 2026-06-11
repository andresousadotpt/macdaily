import Foundation

public enum NoteStoreError: LocalizedError, Equatable {
    case noNotesFolder
    case invalidNote

    public var errorDescription: String? {
        switch self {
        case .noNotesFolder:
            return "Choose a notes folder before writing."
        case .invalidNote:
            return "This note could not be opened."
        }
    }
}

public actor NoteStore {
    private let folderURL: URL

    public init(folderURL: URL) {
        self.folderURL = folderURL
    }

    public var root: URL { folderURL }

    public func ensureNote(for date: Date) throws -> DailyNote {
        let day = DateFormatting.startOfDay(date)
        let note = DailyNote(date: day, url: fileURL(for: day))
        if !FileManager.default.fileExists(atPath: note.url.path) {
            try AtomicWrite.write("", to: note.url)
        }
        return note
    }

    public func listNotes() throws -> [DailyNote] {
        let urls = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        return urls
            .filter { DateFormatting.isDailyNoteFilename($0.lastPathComponent) }
            .compactMap { url -> DailyNote? in
                guard let date = DateFormatting.date(fromFilename: url.lastPathComponent) else {
                    return nil
                }
                return DailyNote(date: DateFormatting.startOfDay(date), url: url)
            }
            .sorted { $0.date > $1.date }
    }

    public func existingNoteCount() throws -> Int {
        try listNotes().count
    }

    public func readContents(of note: DailyNote) throws -> String {
        try validateNote(note)
        guard FileManager.default.fileExists(atPath: note.url.path) else {
            return ""
        }
        return try String(contentsOf: note.url, encoding: .utf8)
    }

    public func writeContents(_ contents: String, to note: DailyNote) throws {
        try validateNote(note)
        try AtomicWrite.write(contents, to: note.url)
    }

    private func validateNote(_ note: DailyNote) throws {
        let root = folderURL.standardizedFileURL.path
        let path = note.url.standardizedFileURL.path
        guard path.hasPrefix(root + "/") || path == root else {
            throw NoteStoreError.invalidNote
        }
    }

    public func fileURL(for date: Date) -> URL {
        folderURL.appendingPathComponent(DateFormatting.filename(for: DateFormatting.startOfDay(date)))
    }

    public func search(matching query: String) throws -> [NoteSearchMatch] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        var results: [NoteSearchMatch] = []
        for note in try listNotes() {
            let content = try readContents(of: note)
            results.append(contentsOf: NoteSearch.matches(in: content, for: note.date, query: trimmedQuery))
        }
        return results
    }
}
