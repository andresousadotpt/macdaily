import AppKit
import MarkdownUI
import Splash
import SwiftUI

struct SplashTextOutputFormat: OutputFormat {
    private let theme: Splash.Theme

    init(theme: Splash.Theme) {
        self.theme = theme
    }

    func makeBuilder() -> Builder {
        Builder(theme: theme)
    }
}

extension SplashTextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var accumulatedText: [Text]

        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.accumulatedText = []
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = theme.tokenColors[type] ?? theme.plainTextColor
            accumulatedText.append(Text(token).foregroundColor(Color(nsColor: color)))
        }

        mutating func addPlainText(_ text: String) {
            accumulatedText.append(
                Text(text).foregroundColor(Color(nsColor: theme.plainTextColor))
            )
        }

        mutating func addWhitespace(_ whitespace: String) {
            accumulatedText.append(Text(whitespace))
        }

        func build() -> Text {
            accumulatedText.reduce(Text(""), +)
        }
    }
}

struct MacDailySplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<SplashTextOutputFormat>

    init(theme: Splash.Theme) {
        syntaxHighlighter = SyntaxHighlighter(format: SplashTextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text {
        guard let language, !language.isEmpty else {
            return Text(content)
        }

        return syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == MacDailySplashCodeSyntaxHighlighter {
    static func macDaily(theme: Splash.Theme) -> Self {
        MacDailySplashCodeSyntaxHighlighter(theme: theme)
    }
}

enum SplashSyntaxTheme {
    static func theme(colorScheme: ColorScheme?, editorZoom: Double) -> Splash.Theme {
        let size = AppearanceFormatting.baseEditorSize * editorZoom * 0.85
        let font = Splash.Font(size: size)

        switch colorScheme {
        case .dark:
            return .wwdc17(withFont: font)
        case .light, .none:
            return .sunset(withFont: font)
        @unknown default:
            return .sunset(withFont: font)
        }
    }
}
