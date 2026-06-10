import Foundation

public enum EditorShortcutAction: String, Codable, Sendable, CaseIterable, Identifiable {
    case beginningOfLine
    case endOfLine
    case indent
    case outdent

    public var id: String { rawValue }

    public static let shortcutCases: [EditorShortcutAction] = [
        .beginningOfLine, .endOfLine, .indent, .outdent,
    ]

    public var label: String {
        switch self {
        case .beginningOfLine: "Beginning of Line"
        case .endOfLine: "End of Line"
        case .indent: "Indent"
        case .outdent: "Outdent"
        }
    }

    public var settingsCategory: String {
        switch self {
        case .beginningOfLine, .endOfLine: "Navigation"
        case .indent, .outdent: "Indentation"
        }
    }

    public var allowsShiftSelectionExtension: Bool {
        switch self {
        case .beginningOfLine, .endOfLine: true
        case .indent, .outdent: false
        }
    }
}
