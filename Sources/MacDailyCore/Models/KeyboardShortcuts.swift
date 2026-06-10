import Foundation

public struct KeyboardShortcuts: Codable, Sendable, Equatable, Hashable {
    public var bindings: [String: KeyBinding]

    public init(bindings: [String: KeyBinding] = Self.defaultBindings) {
        self.bindings = bindings
    }

    public static let defaultBindings: [String: KeyBinding] = {
        var bindings = defaultFormatBindings
        for (key, value) in defaultEditorBindings {
            bindings[key] = value
        }
        return bindings
    }()

    private static let defaultFormatBindings: [String: KeyBinding] = [
        MarkdownFormatAction.bold.rawValue: .command("b"),
        MarkdownFormatAction.italic.rawValue: .command("i"),
        MarkdownFormatAction.strikethrough.rawValue: .command("x", shift: true),
        MarkdownFormatAction.underline.rawValue: .command("u"),
        MarkdownFormatAction.inlineCode.rawValue: .command("e"),
        MarkdownFormatAction.link.rawValue: .command("k"),
        MarkdownFormatAction.heading1.rawValue: .command("1", option: true),
        MarkdownFormatAction.heading2.rawValue: .command("2", option: true),
        MarkdownFormatAction.heading3.rawValue: .command("3", option: true),
        MarkdownFormatAction.heading4.rawValue: .command("4", option: true),
        MarkdownFormatAction.heading5.rawValue: .command("5", option: true),
        MarkdownFormatAction.heading6.rawValue: .command("6", option: true),
    ]

    public static let defaultEditorBindings: [String: KeyBinding] = [
        EditorShortcutAction.beginningOfLine.rawValue: KeyBinding(key: "home"),
        EditorShortcutAction.endOfLine.rawValue: KeyBinding(key: "end"),
        EditorShortcutAction.indent.rawValue: KeyBinding(key: "tab"),
        EditorShortcutAction.outdent.rawValue: KeyBinding(key: "tab", shift: true),
    ]

    public func binding(for action: MarkdownFormatAction) -> KeyBinding {
        bindings[action.rawValue] ?? Self.defaultBindings[action.rawValue] ?? KeyBinding(key: "")
    }

    public mutating func setBinding(_ binding: KeyBinding, for action: MarkdownFormatAction) {
        bindings[action.rawValue] = binding
    }

    public func binding(for action: EditorShortcutAction) -> KeyBinding {
        bindings[action.rawValue] ?? Self.defaultEditorBindings[action.rawValue] ?? KeyBinding(key: "")
    }

    public mutating func setBinding(_ binding: KeyBinding, for action: EditorShortcutAction) {
        bindings[action.rawValue] = binding
    }

    public mutating func resetToDefaults() {
        bindings = Self.defaultBindings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bindings = try container.decodeIfPresent([String: KeyBinding].self, forKey: .bindings) ?? Self.defaultBindings
    }
}
