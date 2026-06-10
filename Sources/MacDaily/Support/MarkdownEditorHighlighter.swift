import AppKit
import MacDailyCore

@MainActor
enum MarkdownEditorHighlighter {
    static func highlight(_ text: String, appearance: AppearanceSettings) -> NSAttributedString {
        let font = AppearanceFormatting.editorNSFont(for: appearance)
        let palette = EditorColorPalette(appearance: appearance)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = appearance.lineSpacing.points

        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: palette.body,
                .paragraphStyle: paragraphStyle,
            ]
        )

        applyFencedCodeBlocks(to: attributed, palette: palette, font: font)
        applyPattern(#"(?m)^#{1,6}\s+.+$"#, to: attributed) { range, string in
            let line = (string as NSString).substring(with: range)
            let level = line.prefix(while: { $0 == "#" }).count
            return [.foregroundColor: palette.headingColor(level: level)]
        }
        applyPattern(#"(?m)^>\s+.+$"#, to: attributed) { _, _ in
            [.foregroundColor: palette.blockquote]
        }
        applyPattern(#"`[^`\n]+`"#, to: attributed) { _, _ in
            [
                .foregroundColor: palette.inlineCode,
                .backgroundColor: palette.inlineCodeBackground,
            ]
        }
        applyPattern(#"\[[^\]\n]+\]\([^)\n]+\)"#, to: attributed) { _, _ in
            [
                .foregroundColor: palette.link,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        }
        applyPattern(#"\*\*[^*\n]+\*\*"#, to: attributed) { _, _ in
            [.foregroundColor: palette.bold]
        }
        applyPattern(#"(?<!\*)\*(?!\*)[^*\n]+\*(?!\*)"#, to: attributed) { _, _ in
            [.foregroundColor: palette.italic]
        }
        applyPattern(#"~~[^~\n]+~~"#, to: attributed) { _, _ in
            [
                .foregroundColor: palette.strikethrough,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            ]
        }
        applyPattern(#"<u>[^<\n]+</u>"#, to: attributed) { _, _ in
            [
                .foregroundColor: palette.underline,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        }

        return attributed
    }

    private static func applyFencedCodeBlocks(
        to attributed: NSMutableAttributedString,
        palette: EditorColorPalette,
        font: NSFont
    ) {
        let pattern = "(?s)```[^\\n]*\\n.*?```"
        applyPattern(pattern, to: attributed) { _, _ in
            [
                .foregroundColor: palette.codeBlock,
                .backgroundColor: palette.codeBlockBackground,
                .font: NSFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular),
            ] as [NSAttributedString.Key: Any]
        }
    }

    private static func applyPattern(
        _ pattern: String,
        to attributed: NSMutableAttributedString,
        attributes: @escaping (NSRange, String) -> [NSAttributedString.Key: Any]
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }

        let string = attributed.string
        let nsString = string as NSString
        let matches = regex.matches(in: string, range: NSRange(location: 0, length: nsString.length))

        for match in matches {
            let attrs = attributes(match.range, string)
            for (key, value) in attrs {
                attributed.addAttribute(key, value: value, range: match.range)
            }
        }
    }
}
