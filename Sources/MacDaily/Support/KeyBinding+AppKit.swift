import AppKit
import SwiftUI
import MacDailyCore

extension KeyBinding {
    func matches(_ event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return false }

        let flags = event.modifierFlags.intersection([.command, .shift, .option, .control])
        let hasCommand = flags.contains(.command)
        let hasShift = flags.contains(.shift)
        let hasOption = flags.contains(.option)
        let hasControl = flags.contains(.control)

        guard hasCommand == command,
              hasShift == shift,
              hasOption == option,
              hasControl == control else {
            return false
        }

        guard let characters = event.charactersIgnoringModifiers?.lowercased(),
              let pressed = characters.last else {
            return false
        }

        return String(pressed) == key.lowercased()
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
}
