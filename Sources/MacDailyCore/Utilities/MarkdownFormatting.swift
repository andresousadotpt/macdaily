import Foundation

public struct MarkdownFormatResult: Equatable, Sendable {
    public var text: String
    public var selectedRange: NSRange

    public init(text: String, selectedRange: NSRange) {
        self.text = text
        self.selectedRange = selectedRange
    }
}

public enum MarkdownFormatting {
    public static func lineCount(in text: String) -> Int {
        guard !text.isEmpty else { return 1 }
        return text.reduce(into: 1) { count, character in
            if character == "\n" { count += 1 }
        }
    }

    public static func apply(_ action: MarkdownFormatAction, to text: String, range: NSRange) -> MarkdownFormatResult {
        switch action {
        case .bold:
            return toggleWrap(text: text, range: range, marker: "**")
        case .italic:
            return toggleWrap(text: text, range: range, marker: "*")
        case .strikethrough:
            return toggleWrap(text: text, range: range, marker: "~~")
        case .underline:
            return toggleWrap(text: text, range: range, prefix: "<u>", suffix: "</u>")
        case .inlineCode:
            return toggleWrap(text: text, range: range, marker: "`")
        case .link:
            return insertLink(text: text, range: range)
        case .heading1:
            return toggleHeading(text: text, range: range, level: 1)
        case .heading2:
            return toggleHeading(text: text, range: range, level: 2)
        case .heading3:
            return toggleHeading(text: text, range: range, level: 3)
        case .heading4:
            return toggleHeading(text: text, range: range, level: 4)
        case .heading5:
            return toggleHeading(text: text, range: range, level: 5)
        case .heading6:
            return toggleHeading(text: text, range: range, level: 6)
        }
    }

    private static func toggleWrap(text: String, range: NSRange, marker: String) -> MarkdownFormatResult {
        toggleWrap(text: text, range: range, prefix: marker, suffix: marker)
    }

    private static func toggleWrap(
        text: String,
        range: NSRange,
        prefix: String,
        suffix: String
    ) -> MarkdownFormatResult {
        let nsText = text as NSString
        let safeRange = safeRange(in: nsText, range: range)
        let selected = nsText.substring(with: safeRange)

        if selected.hasPrefix(prefix), selected.hasSuffix(suffix), selected.count >= prefix.count + suffix.count {
            let inner = String(selected.dropFirst(prefix.count).dropLast(suffix.count))
            return replace(
                text: text,
                range: safeRange,
                with: inner,
                selectedRange: NSRange(location: safeRange.location, length: (inner as NSString).length)
            )
        }

        if selected.isEmpty {
            let insertion = prefix + suffix
            let cursor = safeRange.location + (prefix as NSString).length
            return replace(
                text: text,
                range: safeRange,
                with: insertion,
                selectedRange: NSRange(location: cursor, length: 0)
            )
        }

        let wrapped = prefix + selected + suffix
        return replace(
            text: text,
            range: safeRange,
            with: wrapped,
            selectedRange: NSRange(location: safeRange.location, length: (wrapped as NSString).length)
        )
    }

    private static func insertLink(text: String, range: NSRange) -> MarkdownFormatResult {
        let nsText = text as NSString
        let safeRange = safeRange(in: nsText, range: range)
        let selected = nsText.substring(with: safeRange)
        let label = selected.isEmpty ? "text" : selected
        let insertion = "[\(label)](https://)"
        let urlStart = safeRange.location + (label as NSString).length + 3
        return replace(
            text: text,
            range: safeRange,
            with: insertion,
            selectedRange: NSRange(location: urlStart, length: ("https://" as NSString).length)
        )
    }

    private static func toggleHeading(text: String, range: NSRange, level: Int) -> MarkdownFormatResult {
        let nsText = text as NSString
        let lineRange = lineRange(in: nsText, for: range)
        let line = nsText.substring(with: lineRange)
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let existingLevel = headingLevel(for: trimmed)

        let newLine: String
        if existingLevel == level {
            newLine = stripHeadingPrefix(from: line)
        } else {
            let content = existingLevel == nil ? trimmed : String(trimmed.drop(while: { $0 == "#" }).drop(while: { $0 == " " }))
            newLine = String(repeating: "#", count: level) + " " + content
        }

        return replace(
            text: text,
            range: lineRange,
            with: newLine,
            selectedRange: NSRange(location: lineRange.location, length: (newLine as NSString).length)
        )
    }

    private static func headingLevel(for trimmedLine: String) -> Int? {
        guard trimmedLine.hasPrefix("#") else { return nil }
        let hashes = trimmedLine.prefix(while: { $0 == "#" }).count
        guard (1...6).contains(hashes) else { return nil }
        let remainder = trimmedLine.dropFirst(hashes)
        guard remainder.first == " " else { return nil }
        return hashes
    }

    private static func stripHeadingPrefix(from line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let level = headingLevel(for: trimmed) else { return line }
        let content = String(trimmed.dropFirst(level + 1))
        let leadingWhitespace = line.prefix(while: { $0.isWhitespace })
        return String(leadingWhitespace) + content
    }

    private static func lineRange(in text: NSString, for range: NSRange) -> NSRange {
        var lineStart = 0
        var lineEnd = 0
        text.getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, for: range)
        return NSRange(location: lineStart, length: lineEnd - lineStart)
    }

    private static func safeRange(in text: NSString, range: NSRange) -> NSRange {
        let location = min(max(range.location, 0), text.length)
        let length = min(max(range.length, 0), text.length - location)
        return NSRange(location: location, length: length)
    }

    private static func replace(
        text: String,
        range: NSRange,
        with replacement: String,
        selectedRange: NSRange
    ) -> MarkdownFormatResult {
        let nsText = text as NSString
        let updated = nsText.replacingCharacters(in: range, with: replacement)
        return MarkdownFormatResult(text: updated, selectedRange: selectedRange)
    }
}
