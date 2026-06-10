import Foundation

/// Normalizes markdown before preview rendering.
///
/// MarkdownUI treats an entire list as a task list when any item contains a checkbox,
/// so regular bullets in the same list are shown with checkboxes too. Plain lines that
/// follow a list item without a blank line are also merged into that item per CommonMark.
public enum MarkdownPreviewPreprocessor {
    private static let taskListItemPattern = #"^\s*[-*+]\s+\[[ xX]\]\s+"#
    private static let bulletListItemPattern = #"^\s*[-*+]\s+(?!\[[ xX]\])"#
    private static let bulletMarkerPattern = #"^(\s*)([-*+])(\s+)"#
    private static let blockStarterPattern = #"^\s*(#{1,6}\s|>\s|\d+\.\s|```|~~~|\||-{3,}|\*{3,}|_{3,})"#

    public static func normalizeForPreview(_ markdown: String) -> String {
        let lines = markdown.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map(String.init)
        guard !lines.isEmpty else { return markdown }

        var output: [String] = []

        for index in lines.indices {
            let line = lines[index]

            if isPlainTextLine(line), let previous = previousListItem(before: index, in: lines),
               (isTaskListItem(previous.line) || isBulletListItem(previous.line)),
               !hasBlankLineBetween(previous.index, and: index, in: lines) {
                output.append("")
            }

            var lineToAppend = line
            if isBulletListItem(line), shouldSwapBulletMarker(at: index, in: lines) {
                lineToAppend = swappedBulletMarker(line)
            }

            output.append(lineToAppend)
        }

        return output.joined(separator: "\n")
    }

    private static func shouldSwapBulletMarker(at index: Int, in lines: [String]) -> Bool {
        guard bulletMarker(lines[index]) == "-" else { return false }

        if let previous = previousListItem(before: index, in: lines) {
            if isTaskListItem(previous.line) {
                return true
            }
            if isBulletListItem(previous.line), bulletMarker(previous.line) != "-" {
                return true
            }
        }

        if let next = nextListItem(after: index, in: lines), isTaskListItem(next.line) {
            return true
        }

        return false
    }

    private static func swappedBulletMarker(_ line: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: bulletMarkerPattern) else { return line }
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range),
              let markerRange = Range(match.range(at: 2), in: line) else {
            return line
        }

        var result = line
        let marker = line[markerRange]
        let swapped: Character = marker == "-" ? "+" : (marker == "+" ? "*" : "-")
        result.replaceSubrange(markerRange, with: String(swapped))
        return result
    }

    private static func bulletMarker(_ line: String) -> Character? {
        guard let regex = try? NSRegularExpression(pattern: bulletMarkerPattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let markerRange = Range(match.range(at: 2), in: line) else {
            return nil
        }
        return line[markerRange].first
    }

    private static func previousListItem(before index: Int, in lines: [String]) -> (line: String, index: Int)? {
        guard index > 0 else { return nil }

        var cursor = index - 1
        while cursor >= 0 {
            let line = lines[cursor]
            if line.isEmpty {
                cursor -= 1
                continue
            }
            if isTaskListItem(line) || isBulletListItem(line) {
                return (line, cursor)
            }
            return nil
        }
        return nil
    }

    private static func nextListItem(after index: Int, in lines: [String]) -> (line: String, index: Int)? {
        guard index + 1 < lines.count else { return nil }

        var cursor = index + 1
        while cursor < lines.count {
            let line = lines[cursor]
            if line.isEmpty {
                cursor += 1
                continue
            }
            if isTaskListItem(line) || isBulletListItem(line) {
                return (line, cursor)
            }
            return nil
        }
        return nil
    }

    private static func hasBlankLineBetween(_ previousIndex: Int, and index: Int, in lines: [String]) -> Bool {
        guard previousIndex + 1 < index else { return false }
        return lines[(previousIndex + 1)..<index].contains(where: \.isEmpty)
    }

    private static func isTaskListItem(_ line: String) -> Bool {
        line.range(of: taskListItemPattern, options: .regularExpression) != nil
    }

    private static func isBulletListItem(_ line: String) -> Bool {
        line.range(of: bulletListItemPattern, options: .regularExpression) != nil
    }

    private static func isPlainTextLine(_ line: String) -> Bool {
        guard !line.isEmpty else { return false }
        if isTaskListItem(line) || isBulletListItem(line) { return false }
        if line.range(of: blockStarterPattern, options: .regularExpression) != nil { return false }
        return line.first?.isWhitespace != true
    }
}
