import Foundation

public struct CodableColor: Codable, Sendable, Equatable, Hashable {
    public var hex: String

    public init(hex: String) {
        self.hex = hex
    }

    public static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> CodableColor {
        CodableColor(hex: String(format: "#%02X%02X%02X", red, green, blue))
    }
}
