import AppKit
import SwiftUI
import MacDailyCore

extension KeyBinding {
    func matches(_ event: NSEvent, toleratingExtraShift: Bool = false) -> Bool {
        guard event.type == .keyDown else { return false }

        let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
        let hasCommand = flags.contains(.command)
        var hasShift = flags.contains(.shift)
        let hasOption = flags.contains(.option)
        let hasControl = flags.contains(.control)

        if toleratingExtraShift && hasShift && !shift {
            hasShift = false
        }

        guard hasCommand == command,
              hasShift == shift,
              hasOption == option,
              hasControl == control else {
            return false
        }

        switch key {
        case "home":
            return event.specialKey == .home
        case "end":
            return event.specialKey == .end
        case "tab":
            return event.specialKey == .tab
        default:
            break
        }

        guard let characters = event.charactersIgnoringModifiers?.lowercased(),
              let pressed = characters.last else {
            return false
        }

        return String(pressed) == key.lowercased()
    }

    func matches(_ event: NSEvent) -> Bool {
        matches(event, toleratingExtraShift: false)
    }

    var swiftUIModifiers: EventModifiers {
        var modifiers: EventModifiers = []
        if command { modifiers.insert(.command) }
        if shift { modifiers.insert(.shift) }
        if option { modifiers.insert(.option) }
        if control { modifiers.insert(.control) }
        return modifiers
    }

    var keyEquivalent: KeyEquivalent? {
        guard let character = key.first else { return nil }
        return KeyEquivalent(character)
    }
}

extension KeyboardShortcuts {
    func matchingAction(for event: NSEvent) -> MarkdownFormatAction? {
        for action in MarkdownFormatAction.formattingCases {
            if binding(for: action).matches(event) {
                return action
            }
        }
        return nil
    }

    func matchingEditorAction(for event: NSEvent) -> EditorShortcutAction? {
        for action in EditorShortcutAction.shortcutCases {
            let binding = binding(for: action)
            if binding.matches(event, toleratingExtraShift: action.allowsShiftSelectionExtension) {
                return action
            }
        }
        return nil
    }
}
