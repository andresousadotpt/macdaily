import Foundation

public struct KeyBinding: Codable, Sendable, Equatable, Hashable {
    public var key: String
    public var command: Bool
    public var shift: Bool
    public var option: Bool
    public var control: Bool

    public init(
        key: String,
        command: Bool = false,
        shift: Bool = false,
        option: Bool = false,
        control: Bool = false
    ) {
        self.key = key.lowercased()
        self.command = command
        self.shift = shift
        self.option = option
        self.control = control
    }

    public static func command(_ key: String, shift: Bool = false, option: Bool = false, control: Bool = false) -> KeyBinding {
        KeyBinding(key: key, command: true, shift: shift, option: option, control: control)
    }

    public var displayLabel: String {
        var parts: [String] = []
        if control { parts.append("⌃") }
        if option { parts.append("⌥") }
        if shift { parts.append("⇧") }
        if command { parts.append("⌘") }
        parts.append(key.uppercased())
        return parts.joined()
    }

    public var modifierFlagsRawValue: UInt {
        var flags: UInt = 0
        if shift { flags |= 1 << 17 } // NSEvent.ModifierFlags.shift
        if control { flags |= 1 << 18 }
        if option { flags |= 1 << 19 }
        if command { flags |= 1 << 20 }
        return flags
    }
}
