import XCTest
@testable import MacDailyCore

final class KeyboardShortcutsTests: XCTestCase {
    func testKeyBindingLowercasesKey() {
        let binding = KeyBinding(key: "B", command: true)
        XCTAssertEqual(binding.key, "b")
    }

    func testKeyBindingDisplayLabel() {
        let binding = KeyBinding(key: "k", command: true, shift: true, option: true)
        XCTAssertEqual(binding.displayLabel, "⌥⇧⌘K")
    }

    func testKeyBindingModifierFlags() {
        let binding = KeyBinding(key: "b", command: true, shift: true)
        let flags = binding.modifierFlagsRawValue
        XCTAssertNotEqual(flags, 0)
        XCTAssertEqual(binding.modifierFlagsRawValue, binding.modifierFlagsRawValue)
    }

    func testKeyboardShortcutsFallsBackToDefaultBinding() {
        let shortcuts = KeyboardShortcuts()
        XCTAssertEqual(shortcuts.binding(for: .bold).key, "b")
        XCTAssertTrue(shortcuts.binding(for: .bold).command)
    }

    func testKeyboardShortcutsUsesCustomBinding() {
        var shortcuts = KeyboardShortcuts()
        shortcuts.setBinding(.command("m"), for: .bold)
        XCTAssertEqual(shortcuts.binding(for: .bold).key, "m")
    }

    func testKeyboardShortcutsResetToDefaults() {
        var shortcuts = KeyboardShortcuts()
        shortcuts.setBinding(.command("m"), for: .bold)
        shortcuts.resetToDefaults()
        XCTAssertEqual(shortcuts.binding(for: .bold).key, "b")
    }

    func testKeyboardShortcutsDecodeUsesDefaultsWhenMissing() throws {
        let json = """
        {}
        """
        let shortcuts = try JSONDecoder().decode(KeyboardShortcuts.self, from: Data(json.utf8))
        XCTAssertEqual(shortcuts.binding(for: .heading1).key, "1")
        XCTAssertTrue(shortcuts.binding(for: .heading1).option)
    }

    func testCodableColorRGBFormatsHex() {
        XCTAssertEqual(CodableColor.rgb(10, 20, 30).hex, "#0A141E")
    }
}
