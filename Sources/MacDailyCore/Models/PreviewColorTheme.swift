import Foundation

public enum PreviewColorTheme: String, Codable, Sendable, CaseIterable, Identifiable {
    case githubLight
    case githubDark
    case monokai
    case dracula
    case oneDark
    case nord
    case tokyoNight
    case gruvboxDark
    case solarizedDark
    case solarizedLight
    case ocean
    case forest
    case sunset
    case lavender
    case rose
    case mono
    case custom

    public var id: String { rawValue }

    public static let presetCases: [PreviewColorTheme] = [
        .githubLight, .githubDark,
        .monokai, .dracula, .oneDark, .nord, .tokyoNight, .gruvboxDark,
        .solarizedDark, .solarizedLight,
        .ocean, .forest, .sunset, .lavender, .rose, .mono,
    ]

    public var label: String {
        switch self {
        case .githubLight: "GitHub Light"
        case .githubDark: "GitHub Dark"
        case .monokai: "Monokai"
        case .dracula: "Dracula"
        case .oneDark: "One Dark"
        case .nord: "Nord"
        case .tokyoNight: "Tokyo Night"
        case .gruvboxDark: "Gruvbox Dark"
        case .solarizedDark: "Solarized Dark"
        case .solarizedLight: "Solarized Light"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .sunset: "Sunset"
        case .lavender: "Lavender"
        case .rose: "Rose"
        case .mono: "Monochrome"
        case .custom: "Custom"
        }
    }

    public var description: String {
        switch self {
        case .githubLight: "Clean neutral palette inspired by GitHub."
        case .githubDark: "Soft light text on dark backgrounds."
        case .monokai: "Classic Sublime Text palette with pink, green, and orange accents."
        case .dracula: "Popular dark theme with purple, pink, and cyan highlights."
        case .oneDark: "Atom One Dark with blue, purple, and green accents."
        case .nord: "Arctic-inspired frost blues and aurora tones."
        case .tokyoNight: "Modern dark theme with soft blue and purple highlights."
        case .gruvboxDark: "Retro warm dark theme with earthy accent colors."
        case .solarizedDark: "Ethan Schoonover's balanced dark palette."
        case .solarizedLight: "Ethan Schoonover's balanced light palette."
        case .ocean: "Cool blues and teals."
        case .forest: "Calm greens and earth tones."
        case .sunset: "Warm oranges and amber accents."
        case .lavender: "Purple headings with soft contrast."
        case .rose: "Pink and coral highlights."
        case .mono: "Grayscale with minimal accent color."
        case .custom: "Your hand-picked colors."
        }
    }

    public var colors: PreviewElementColors {
        switch self {
        case .githubLight:
            return PreviewElementColors()
        case .githubDark:
            return PreviewElementColors(
                body: .rgb(251, 251, 252),
                heading1: .rgb(251, 251, 252),
                heading2: .rgb(251, 251, 252),
                heading3: .rgb(230, 231, 235),
                heading4: .rgb(210, 212, 220),
                heading5: .rgb(190, 192, 202),
                heading6: .rgb(146, 148, 160),
                bold: .rgb(251, 251, 252),
                italic: .rgb(230, 231, 235),
                underline: .rgb(76, 142, 248),
                strikethrough: .rgb(146, 148, 160),
                inlineCode: .rgb(230, 231, 235),
                inlineCodeBackground: .rgb(37, 38, 42),
                codeBlock: .rgb(230, 231, 235),
                codeBlockBackground: .rgb(37, 38, 42),
                link: .rgb(76, 142, 248),
                blockquote: .rgb(146, 148, 160),
                blockquoteBar: .rgb(66, 68, 78),
                listMarker: .rgb(210, 212, 220),
                listText: .rgb(230, 231, 235),
                thematicBreak: .rgb(66, 68, 78),
                tableHeader: .rgb(251, 251, 252),
                tableBorder: .rgb(66, 68, 78)
            )
        case .monokai:
            return PreviewElementColors(
                body: .rgb(248, 248, 242),
                heading1: .rgb(249, 38, 114),
                heading2: .rgb(166, 226, 46),
                heading3: .rgb(174, 129, 255),
                heading4: .rgb(253, 151, 31),
                heading5: .rgb(230, 219, 116),
                heading6: .rgb(117, 113, 94),
                bold: .rgb(249, 38, 114),
                italic: .rgb(166, 226, 46),
                underline: .rgb(102, 217, 239),
                strikethrough: .rgb(117, 113, 94),
                inlineCode: .rgb(230, 219, 116),
                inlineCodeBackground: .rgb(62, 61, 50),
                codeBlock: .rgb(248, 248, 242),
                codeBlockBackground: .rgb(39, 40, 34),
                link: .rgb(102, 217, 239),
                blockquote: .rgb(117, 113, 94),
                blockquoteBar: .rgb(249, 38, 114),
                listMarker: .rgb(166, 226, 46),
                listText: .rgb(248, 248, 242),
                thematicBreak: .rgb(117, 113, 94),
                tableHeader: .rgb(174, 129, 255),
                tableBorder: .rgb(117, 113, 94)
            )
        case .dracula:
            return PreviewElementColors(
                body: .rgb(248, 248, 242),
                heading1: .rgb(255, 121, 198),
                heading2: .rgb(189, 147, 249),
                heading3: .rgb(80, 250, 123),
                heading4: .rgb(139, 233, 253),
                heading5: .rgb(255, 184, 108),
                heading6: .rgb(98, 114, 164),
                bold: .rgb(255, 121, 198),
                italic: .rgb(189, 147, 249),
                underline: .rgb(139, 233, 253),
                strikethrough: .rgb(98, 114, 164),
                inlineCode: .rgb(241, 250, 140),
                inlineCodeBackground: .rgb(68, 71, 90),
                codeBlock: .rgb(248, 248, 242),
                codeBlockBackground: .rgb(40, 42, 54),
                link: .rgb(139, 233, 253),
                blockquote: .rgb(98, 114, 164),
                blockquoteBar: .rgb(189, 147, 249),
                listMarker: .rgb(255, 121, 198),
                listText: .rgb(248, 248, 242),
                thematicBreak: .rgb(68, 71, 90),
                tableHeader: .rgb(255, 184, 108),
                tableBorder: .rgb(68, 71, 90)
            )
        case .oneDark:
            return PreviewElementColors(
                body: .rgb(171, 178, 191),
                heading1: .rgb(224, 108, 117),
                heading2: .rgb(97, 175, 239),
                heading3: .rgb(152, 195, 121),
                heading4: .rgb(198, 120, 221),
                heading5: .rgb(229, 192, 123),
                heading6: .rgb(92, 99, 112),
                bold: .rgb(224, 108, 117),
                italic: .rgb(198, 120, 221),
                underline: .rgb(97, 175, 239),
                strikethrough: .rgb(92, 99, 112),
                inlineCode: .rgb(209, 154, 102),
                inlineCodeBackground: .rgb(33, 37, 43),
                codeBlock: .rgb(171, 178, 191),
                codeBlockBackground: .rgb(40, 44, 52),
                link: .rgb(97, 175, 239),
                blockquote: .rgb(92, 99, 112),
                blockquoteBar: .rgb(86, 182, 194),
                listMarker: .rgb(152, 195, 121),
                listText: .rgb(171, 178, 191),
                thematicBreak: .rgb(92, 99, 112),
                tableHeader: .rgb(229, 192, 123),
                tableBorder: .rgb(92, 99, 112)
            )
        case .nord:
            return PreviewElementColors(
                body: .rgb(216, 222, 233),
                heading1: .rgb(191, 97, 106),
                heading2: .rgb(136, 192, 208),
                heading3: .rgb(163, 190, 140),
                heading4: .rgb(235, 203, 139),
                heading5: .rgb(180, 142, 173),
                heading6: .rgb(129, 161, 193),
                bold: .rgb(236, 239, 244),
                italic: .rgb(136, 192, 208),
                underline: .rgb(129, 161, 193),
                strikethrough: .rgb(76, 86, 106),
                inlineCode: .rgb(143, 188, 187),
                inlineCodeBackground: .rgb(59, 66, 82),
                codeBlock: .rgb(216, 222, 233),
                codeBlockBackground: .rgb(46, 52, 64),
                link: .rgb(136, 192, 208),
                blockquote: .rgb(76, 86, 106),
                blockquoteBar: .rgb(136, 192, 208),
                listMarker: .rgb(163, 190, 140),
                listText: .rgb(216, 222, 233),
                thematicBreak: .rgb(76, 86, 106),
                tableHeader: .rgb(235, 203, 139),
                tableBorder: .rgb(76, 86, 106)
            )
        case .tokyoNight:
            return PreviewElementColors(
                body: .rgb(192, 202, 245),
                heading1: .rgb(247, 118, 142),
                heading2: .rgb(122, 162, 247),
                heading3: .rgb(158, 206, 106),
                heading4: .rgb(187, 154, 247),
                heading5: .rgb(224, 175, 104),
                heading6: .rgb(86, 95, 137),
                bold: .rgb(247, 118, 142),
                italic: .rgb(187, 154, 247),
                underline: .rgb(125, 207, 255),
                strikethrough: .rgb(86, 95, 137),
                inlineCode: .rgb(255, 158, 100),
                inlineCodeBackground: .rgb(22, 22, 30),
                codeBlock: .rgb(192, 202, 245),
                codeBlockBackground: .rgb(26, 27, 38),
                link: .rgb(125, 207, 255),
                blockquote: .rgb(86, 95, 137),
                blockquoteBar: .rgb(187, 154, 247),
                listMarker: .rgb(158, 206, 106),
                listText: .rgb(192, 202, 245),
                thematicBreak: .rgb(86, 95, 137),
                tableHeader: .rgb(224, 175, 104),
                tableBorder: .rgb(86, 95, 137)
            )
        case .gruvboxDark:
            return PreviewElementColors(
                body: .rgb(235, 219, 178),
                heading1: .rgb(251, 73, 52),
                heading2: .rgb(184, 187, 38),
                heading3: .rgb(250, 189, 47),
                heading4: .rgb(131, 165, 152),
                heading5: .rgb(211, 134, 155),
                heading6: .rgb(146, 131, 116),
                bold: .rgb(251, 73, 52),
                italic: .rgb(211, 134, 155),
                underline: .rgb(131, 165, 152),
                strikethrough: .rgb(146, 131, 116),
                inlineCode: .rgb(254, 128, 25),
                inlineCodeBackground: .rgb(60, 56, 54),
                codeBlock: .rgb(235, 219, 178),
                codeBlockBackground: .rgb(40, 40, 40),
                link: .rgb(131, 165, 152),
                blockquote: .rgb(146, 131, 116),
                blockquoteBar: .rgb(254, 128, 25),
                listMarker: .rgb(184, 187, 38),
                listText: .rgb(235, 219, 178),
                thematicBreak: .rgb(80, 73, 69),
                tableHeader: .rgb(250, 189, 47),
                tableBorder: .rgb(80, 73, 69)
            )
        case .solarizedDark:
            return PreviewElementColors(
                body: .rgb(131, 148, 150),
                heading1: .rgb(220, 50, 47),
                heading2: .rgb(42, 161, 152),
                heading3: .rgb(133, 153, 0),
                heading4: .rgb(38, 139, 210),
                heading5: .rgb(181, 137, 0),
                heading6: .rgb(101, 123, 131),
                bold: .rgb(147, 161, 161),
                italic: .rgb(42, 161, 152),
                underline: .rgb(38, 139, 210),
                strikethrough: .rgb(101, 123, 131),
                inlineCode: .rgb(211, 54, 130),
                inlineCodeBackground: .rgb(7, 54, 66),
                codeBlock: .rgb(147, 161, 161),
                codeBlockBackground: .rgb(0, 43, 54),
                link: .rgb(38, 139, 210),
                blockquote: .rgb(88, 110, 117),
                blockquoteBar: .rgb(42, 161, 152),
                listMarker: .rgb(133, 153, 0),
                listText: .rgb(131, 148, 150),
                thematicBreak: .rgb(88, 110, 117),
                tableHeader: .rgb(181, 137, 0),
                tableBorder: .rgb(88, 110, 117)
            )
        case .solarizedLight:
            return PreviewElementColors(
                body: .rgb(101, 123, 131),
                heading1: .rgb(203, 75, 22),
                heading2: .rgb(38, 139, 210),
                heading3: .rgb(133, 153, 0),
                heading4: .rgb(108, 113, 196),
                heading5: .rgb(181, 137, 0),
                heading6: .rgb(147, 161, 161),
                bold: .rgb(220, 50, 47),
                italic: .rgb(42, 161, 152),
                underline: .rgb(38, 139, 210),
                strikethrough: .rgb(147, 161, 161),
                inlineCode: .rgb(211, 54, 130),
                inlineCodeBackground: .rgb(238, 232, 213),
                codeBlock: .rgb(101, 123, 131),
                codeBlockBackground: .rgb(253, 246, 227),
                link: .rgb(38, 139, 210),
                blockquote: .rgb(147, 161, 161),
                blockquoteBar: .rgb(42, 161, 152),
                listMarker: .rgb(133, 153, 0),
                listText: .rgb(101, 123, 131),
                thematicBreak: .rgb(220, 215, 196),
                tableHeader: .rgb(203, 75, 22),
                tableBorder: .rgb(220, 215, 196)
            )
        case .ocean:
            return PreviewElementColors(
                body: .rgb(24, 44, 58),
                heading1: .rgb(8, 74, 112),
                heading2: .rgb(12, 96, 140),
                heading3: .rgb(20, 118, 165),
                heading4: .rgb(30, 130, 175),
                heading5: .rgb(45, 145, 185),
                heading6: .rgb(80, 130, 150),
                bold: .rgb(8, 74, 112),
                italic: .rgb(20, 100, 130),
                underline: .rgb(0, 128, 160),
                strikethrough: .rgb(100, 130, 145),
                inlineCode: .rgb(8, 74, 112),
                inlineCodeBackground: .rgb(230, 244, 250),
                codeBlock: .rgb(8, 74, 112),
                codeBlockBackground: .rgb(230, 244, 250),
                link: .rgb(0, 128, 160),
                blockquote: .rgb(60, 110, 130),
                blockquoteBar: .rgb(120, 190, 215),
                listMarker: .rgb(0, 128, 160),
                listText: .rgb(24, 44, 58),
                thematicBreak: .rgb(170, 215, 230),
                tableHeader: .rgb(8, 74, 112),
                tableBorder: .rgb(170, 215, 230)
            )
        case .forest:
            return PreviewElementColors(
                body: .rgb(28, 42, 32),
                heading1: .rgb(34, 94, 52),
                heading2: .rgb(46, 118, 64),
                heading3: .rgb(58, 136, 78),
                heading4: .rgb(72, 148, 90),
                heading5: .rgb(88, 158, 104),
                heading6: .rgb(110, 140, 118),
                bold: .rgb(34, 94, 52),
                italic: .rgb(52, 110, 68),
                underline: .rgb(46, 130, 72),
                strikethrough: .rgb(110, 130, 115),
                inlineCode: .rgb(34, 94, 52),
                inlineCodeBackground: .rgb(232, 244, 234),
                codeBlock: .rgb(34, 94, 52),
                codeBlockBackground: .rgb(232, 244, 234),
                link: .rgb(46, 130, 72),
                blockquote: .rgb(80, 120, 90),
                blockquoteBar: .rgb(140, 195, 155),
                listMarker: .rgb(46, 130, 72),
                listText: .rgb(28, 42, 32),
                thematicBreak: .rgb(180, 215, 188),
                tableHeader: .rgb(34, 94, 52),
                tableBorder: .rgb(180, 215, 188)
            )
        case .sunset:
            return PreviewElementColors(
                body: .rgb(52, 36, 28),
                heading1: .rgb(160, 62, 20),
                heading2: .rgb(185, 82, 28),
                heading3: .rgb(200, 100, 40),
                heading4: .rgb(210, 118, 55),
                heading5: .rgb(185, 105, 60),
                heading6: .rgb(150, 110, 85),
                bold: .rgb(160, 62, 20),
                italic: .rgb(170, 90, 45),
                underline: .rgb(210, 95, 30),
                strikethrough: .rgb(150, 110, 95),
                inlineCode: .rgb(140, 70, 30),
                inlineCodeBackground: .rgb(255, 242, 230),
                codeBlock: .rgb(140, 70, 30),
                codeBlockBackground: .rgb(255, 242, 230),
                link: .rgb(210, 95, 30),
                blockquote: .rgb(140, 100, 80),
                blockquoteBar: .rgb(235, 170, 120),
                listMarker: .rgb(210, 95, 30),
                listText: .rgb(52, 36, 28),
                thematicBreak: .rgb(240, 200, 170),
                tableHeader: .rgb(160, 62, 20),
                tableBorder: .rgb(240, 200, 170)
            )
        case .lavender:
            return PreviewElementColors(
                body: .rgb(38, 32, 52),
                heading1: .rgb(88, 52, 140),
                heading2: .rgb(108, 68, 165),
                heading3: .rgb(125, 82, 180),
                heading4: .rgb(140, 98, 190),
                heading5: .rgb(155, 112, 195),
                heading6: .rgb(130, 115, 155),
                bold: .rgb(88, 52, 140),
                italic: .rgb(110, 75, 155),
                underline: .rgb(120, 80, 200),
                strikethrough: .rgb(130, 115, 155),
                inlineCode: .rgb(88, 52, 140),
                inlineCodeBackground: .rgb(242, 236, 252),
                codeBlock: .rgb(88, 52, 140),
                codeBlockBackground: .rgb(242, 236, 252),
                link: .rgb(120, 80, 200),
                blockquote: .rgb(110, 95, 140),
                blockquoteBar: .rgb(190, 165, 225),
                listMarker: .rgb(120, 80, 200),
                listText: .rgb(38, 32, 52),
                thematicBreak: .rgb(210, 190, 235),
                tableHeader: .rgb(88, 52, 140),
                tableBorder: .rgb(210, 190, 235)
            )
        case .rose:
            return PreviewElementColors(
                body: .rgb(52, 32, 38),
                heading1: .rgb(160, 45, 75),
                heading2: .rgb(180, 58, 88),
                heading3: .rgb(195, 72, 100),
                heading4: .rgb(205, 88, 112),
                heading5: .rgb(185, 90, 110),
                heading6: .rgb(150, 105, 115),
                bold: .rgb(160, 45, 75),
                italic: .rgb(175, 70, 95),
                underline: .rgb(210, 70, 105),
                strikethrough: .rgb(150, 105, 115),
                inlineCode: .rgb(140, 50, 80),
                inlineCodeBackground: .rgb(255, 236, 242),
                codeBlock: .rgb(140, 50, 80),
                codeBlockBackground: .rgb(255, 236, 242),
                link: .rgb(210, 70, 105),
                blockquote: .rgb(140, 95, 105),
                blockquoteBar: .rgb(235, 165, 185),
                listMarker: .rgb(210, 70, 105),
                listText: .rgb(52, 32, 38),
                thematicBreak: .rgb(240, 190, 205),
                tableHeader: .rgb(160, 45, 75),
                tableBorder: .rgb(240, 190, 205)
            )
        case .mono:
            return PreviewElementColors(
                body: .rgb(30, 30, 30),
                heading1: .rgb(15, 15, 15),
                heading2: .rgb(25, 25, 25),
                heading3: .rgb(40, 40, 40),
                heading4: .rgb(55, 55, 55),
                heading5: .rgb(70, 70, 70),
                heading6: .rgb(110, 110, 110),
                bold: .rgb(15, 15, 15),
                italic: .rgb(55, 55, 55),
                underline: .rgb(60, 60, 60),
                strikethrough: .rgb(120, 120, 120),
                inlineCode: .rgb(30, 30, 30),
                inlineCodeBackground: .rgb(240, 240, 240),
                codeBlock: .rgb(30, 30, 30),
                codeBlockBackground: .rgb(240, 240, 240),
                link: .rgb(60, 60, 60),
                blockquote: .rgb(100, 100, 100),
                blockquoteBar: .rgb(180, 180, 180),
                listMarker: .rgb(60, 60, 60),
                listText: .rgb(30, 30, 30),
                thematicBreak: .rgb(200, 200, 200),
                tableHeader: .rgb(15, 15, 15),
                tableBorder: .rgb(200, 200, 200)
            )
        case .custom:
            return PreviewElementColors()
        }
    }

    public func matches(_ colors: PreviewElementColors) -> Bool {
        self != .custom && colors == self.colors
    }

    public static func inferred(from colors: PreviewElementColors) -> PreviewColorTheme {
        for preset in presetCases where preset.colors == colors {
            return preset
        }
        return .custom
    }
}
