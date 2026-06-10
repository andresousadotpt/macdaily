import AppKit
import MacDailyCore

extension NSColor {
    convenience init(fromCodable codable: CodableColor) {
        self.init(hex: codable.hex)
    }

    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red, green, blue, alpha: CGFloat
        switch cleaned.count {
        case 6:
            red = CGFloat((value & 0xFF0000) >> 16) / 255
            green = CGFloat((value & 0x00FF00) >> 8) / 255
            blue = CGFloat(value & 0x0000FF) / 255
            alpha = 1
        case 8:
            red = CGFloat((value & 0xFF00_0000) >> 24) / 255
            green = CGFloat((value & 0x00FF_0000) >> 16) / 255
            blue = CGFloat((value & 0x0000_FF00) >> 8) / 255
            alpha = CGFloat(value & 0x0000_00FF) / 255
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }

        self.init(srgbRed: red, green: green, blue: blue, alpha: alpha)
    }
}

@MainActor
struct EditorColorPalette {
    let body: NSColor
    let bold: NSColor
    let italic: NSColor
    let underline: NSColor
    let strikethrough: NSColor
    let inlineCode: NSColor
    let inlineCodeBackground: NSColor
    let codeBlock: NSColor
    let codeBlockBackground: NSColor
    let link: NSColor
    let blockquote: NSColor
    let blockquoteBar: NSColor
    let heading1: NSColor
    let heading2: NSColor
    let heading3: NSColor
    let heading4: NSColor
    let heading5: NSColor
    let heading6: NSColor

    init(appearance: AppearanceSettings) {
        let colors = Self.colors(for: appearance)

        body = NSColor(fromCodable: colors.body)
        bold = NSColor(fromCodable: colors.bold)
        italic = NSColor(fromCodable: colors.italic)
        underline = NSColor(fromCodable: colors.underline)
        strikethrough = NSColor(fromCodable: colors.strikethrough)
        inlineCode = NSColor(fromCodable: colors.inlineCode)
        inlineCodeBackground = NSColor(fromCodable: colors.inlineCodeBackground)
        codeBlock = NSColor(fromCodable: colors.codeBlock)
        codeBlockBackground = NSColor(fromCodable: colors.codeBlockBackground)
        link = NSColor(fromCodable: colors.link)
        blockquote = NSColor(fromCodable: colors.blockquote)
        blockquoteBar = NSColor(fromCodable: colors.blockquoteBar)
        heading1 = NSColor(fromCodable: colors.heading1)
        heading2 = NSColor(fromCodable: colors.heading2)
        heading3 = NSColor(fromCodable: colors.heading3)
        heading4 = NSColor(fromCodable: colors.heading4)
        heading5 = NSColor(fromCodable: colors.heading5)
        heading6 = NSColor(fromCodable: colors.heading6)
    }

    func headingColor(level: Int) -> NSColor {
        switch level {
        case 1: heading1
        case 2: heading2
        case 3: heading3
        case 4: heading4
        case 5: heading5
        default: heading6
        }
    }

    private static func colors(for appearance: AppearanceSettings) -> PreviewElementColors {
        if appearance.useCustomPreviewColors {
            return appearance.previewColors
        }

        let theme: PreviewColorTheme = switch appearance.colorScheme {
        case .light:
            .githubLight
        case .dark:
            .githubDark
        case .system:
            isDarkMode ? .githubDark : .githubLight
        }
        return theme.colors
    }

    private static var isDarkMode: Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
