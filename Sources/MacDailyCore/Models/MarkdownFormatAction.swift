import Foundation

public enum MarkdownFormatAction: String, Codable, Sendable, CaseIterable, Identifiable {
    case bold
    case italic
    case strikethrough
    case underline
    case inlineCode
    case link
    case heading1
    case heading2
    case heading3
    case heading4
    case heading5
    case heading6

    public var id: String { rawValue }

    public static let formattingCases: [MarkdownFormatAction] = [
        .bold, .italic, .strikethrough, .underline, .inlineCode, .link,
        .heading1, .heading2, .heading3, .heading4, .heading5, .heading6,
    ]

    public var label: String {
        switch self {
        case .bold: "Bold"
        case .italic: "Italic"
        case .strikethrough: "Strikethrough"
        case .underline: "Underline"
        case .inlineCode: "Inline Code"
        case .link: "Link"
        case .heading1: "Heading 1"
        case .heading2: "Heading 2"
        case .heading3: "Heading 3"
        case .heading4: "Heading 4"
        case .heading5: "Heading 5"
        case .heading6: "Heading 6"
        }
    }

    public var settingsCategory: String {
        switch self {
        case .bold, .italic, .strikethrough, .underline, .inlineCode, .link:
            "Text Formatting"
        case .heading1, .heading2, .heading3, .heading4, .heading5, .heading6:
            "Headings"
        }
    }
}
