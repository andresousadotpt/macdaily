import Foundation

public struct TextIndentationResult: Equatable, Sendable {
    public var text: String
    public var selectedRange: NSRange
    public var replacedRange: NSRange

    public init(text: String, selectedRange: NSRange, replacedRange: NSRange) {
        self.text = text
        self.selectedRange = selectedRange
        self.replacedRange = replacedRange
    }
}

public enum TextIndentation {
    public static let indentUnit = "\t"
    private static let spaceIndentWidth = 4

    public static func applyTab(to text: String, range: NSRange) -> TextIndentationResult {
        if spansMultipleLines(in: text, range: range) {
            return indentLines(in: text, range: range)
        }
        return insertTab(in: text, range: range)
    }

    public static func applyShiftTab(to text: String, range: NSRange) -> TextIndentationResult? {
        if spansMultipleLines(in: text, range: range) {
            return outdentLines(in: text, range: range)
        }
        return outdentCurrentLine(in: text, range: range)
    }

    public static func spansMultipleLines(in text: String, range: NSRange) -> Bool {
        let nsText = text as NSString
        let safeRange = safeRange(in: nsText, range: range)
        guard safeRange.length > 0 else { return false }
        return nsText.substring(with: safeRange).contains("\n")
    }

    private static func insertTab(in text: String, range: NSRange) -> TextIndentationResult {
        let nsText = text as NSString
        let safeRange = safeRange(in: nsText, range: range)
        let updated = nsText.replacingCharacters(in: safeRange, with: indentUnit)
        let cursor = safeRange.location + (indentUnit as NSString).length
        return TextIndentationResult(
            text: updated,
            selectedRange: NSRange(location: cursor, length: 0),
            replacedRange: safeRange
        )
    }

    private static func indentLines(in text: String, range: NSRange) -> TextIndentationResult {
        let nsText = text as NSString
        let lineBlock = expandedLineRange(in: nsText, for: range)
        let block = nsText.substring(with: lineBlock)
        let lines = linesInBlock(block)
        let hadTrailingNewline = block.hasSuffix("\n")
        let indentedBlock = lines
            .map { indentUnit + $0 }
            .joined(separator: "\n") + (hadTrailingNewline ? "\n" : "")

        let updated = nsText.replacingCharacters(in: lineBlock, with: indentedBlock)
        let safeRange = safeRange(in: nsText, range: range)
        let startOffset = tabOffset(in: nsText, lineBlockStart: lineBlock.location, position: safeRange.location)
        let endOffset = tabOffset(
            in: nsText,
            lineBlockStart: lineBlock.location,
            position: safeRange.location + safeRange.length
        )

        return TextIndentationResult(
            text: updated,
            selectedRange: NSRange(
                location: safeRange.location + startOffset,
                length: safeRange.length + (endOffset - startOffset)
            ),
            replacedRange: lineBlock
        )
    }

    private static func outdentLines(in text: String, range: NSRange) -> TextIndentationResult? {
        let nsText = text as NSString
        let lineBlock = expandedLineRange(in: nsText, for: range)
        let block = nsText.substring(with: lineBlock)
        let lines = linesInBlock(block)

        let removedPerLine = lines.map(outdentPrefixLength(of:))
        guard removedPerLine.contains(where: { $0 > 0 }) else { return nil }

        let outdentedBlock = zip(lines, removedPerLine).map { line, removed in
            removed > 0 ? String(line.dropFirst(removed)) : line
        }.joined(separator: "\n") + (block.hasSuffix("\n") ? "\n" : "")

        let updated = nsText.replacingCharacters(in: lineBlock, with: outdentedBlock)
        let safeRange = safeRange(in: nsText, range: range)
        let startOffset = outdentOffset(lineBlockStart: lineBlock.location, lines: lines, position: safeRange.location)
        let endOffset = outdentOffset(
            lineBlockStart: lineBlock.location,
            lines: lines,
            position: safeRange.location + safeRange.length
        )

        return TextIndentationResult(
            text: updated,
            selectedRange: NSRange(
                location: safeRange.location - startOffset,
                length: max(safeRange.length - endOffset + startOffset, 0)
            ),
            replacedRange: lineBlock
        )
    }

    private static func outdentCurrentLine(in text: String, range: NSRange) -> TextIndentationResult? {
        let nsText = text as NSString
        let safeRange = safeRange(in: nsText, range: range)
        let lineBlock = expandedLineRange(in: nsText, for: safeRange)
        let line = nsText.substring(with: lineBlock)
        let removed = outdentPrefixLength(of: line)
        guard removed > 0 else { return nil }

        let outdentedLine = String(line.dropFirst(removed))
        let updated = nsText.replacingCharacters(in: lineBlock, with: outdentedLine)
        return TextIndentationResult(
            text: updated,
            selectedRange: NSRange(location: max(safeRange.location - removed, lineBlock.location), length: 0),
            replacedRange: lineBlock
        )
    }

    private static func outdentPrefixLength(of line: String) -> Int {
        if line.hasPrefix("\t") {
            return 1
        }
        let spaceCount = line.prefix(while: { $0 == " " }).count
        return min(spaceCount, spaceIndentWidth)
    }

    private static func tabOffset(in text: NSString, lineBlockStart: Int, position: Int) -> Int {
        guard position >= lineBlockStart else { return 0 }
        let segment = text.substring(with: NSRange(location: lineBlockStart, length: position - lineBlockStart))
        return segment.filter { $0 == "\n" }.count + 1
    }

    private static func outdentOffset(
        lineBlockStart: Int,
        lines: [String],
        position: Int
    ) -> Int {
        guard position >= lineBlockStart else { return 0 }

        var offset = 0
        var lineStart = lineBlockStart
        for line in lines {
            if position > lineStart {
                offset += outdentPrefixLength(of: line)
            } else {
                break
            }
            lineStart += (line as NSString).length + 1
        }
        return offset
    }

    private static func linesInBlock(_ block: String) -> [String] {
        guard !block.isEmpty else { return [] }
        var lines = block.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        if block.hasSuffix("\n"), lines.last == "" {
            lines.removeLast()
        }
        return lines
    }

    private static func expandedLineRange(in text: NSString, for range: NSRange) -> NSRange {
        let safeRange = safeRange(in: text, range: range)
        let startLocation = safeRange.location
        let endLocation = safeRange.length > 0 ? safeRange.location + safeRange.length - 1 : safeRange.location

        var firstLineStart = 0
        var firstLineEnd = 0
        text.getLineStart(&firstLineStart, end: &firstLineEnd, contentsEnd: nil, for: NSRange(location: startLocation, length: 0))

        var lastLineStart = 0
        var lastLineEnd = 0
        text.getLineStart(&lastLineStart, end: &lastLineEnd, contentsEnd: nil, for: NSRange(location: endLocation, length: 0))

        return NSRange(location: firstLineStart, length: lastLineEnd - firstLineStart)
    }

    private static func safeRange(in text: NSString, range: NSRange) -> NSRange {
        let location = min(max(range.location, 0), text.length)
        let length = min(max(range.length, 0), text.length - location)
        return NSRange(location: location, length: length)
    }
}
