import Foundation

public struct NoteSearchMatch: Identifiable, Hashable, Sendable {
    public let date: Date
    public let lineNumber: Int
    public let lineText: String

    public var id: String {
        "\(DateFormatting.filename(for: date)):\(lineNumber)"
    }

    public init(date: Date, lineNumber: Int, lineText: String) {
        self.date = date
        self.lineNumber = lineNumber
        self.lineText = lineText
    }
}

public enum NoteSearch {
    public static func matches(in content: String, for date: Date, query: String) -> [NoteSearchMatch] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let needle = trimmedQuery.lowercased()
        var results: [NoteSearchMatch] = []

        var lineStart = content.startIndex
        var lineNumber = 1

        while lineStart <= content.endIndex {
            let lineEnd = content[lineStart...].firstIndex(of: "\n") ?? content.endIndex
            let line = String(content[lineStart..<lineEnd])

            if line.lowercased().contains(needle) {
                results.append(NoteSearchMatch(date: date, lineNumber: lineNumber, lineText: line))
            }

            if lineEnd == content.endIndex {
                break
            }

            lineStart = content.index(after: lineEnd)
            lineNumber += 1
        }

        return results
    }
}
