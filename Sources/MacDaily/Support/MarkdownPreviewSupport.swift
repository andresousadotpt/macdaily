import AppKit
import MarkdownUI
import SwiftUI
import MacDailyCore

struct MacDailyCodeBlockView: View {
    let configuration: CodeBlockConfiguration
    let appearance: AppearanceSettings

    @State private var didCopy = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: true) {
                configuration.label
                    .relativeLineSpacing(.em(0.225))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                        BackgroundColor(nil)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .padding(.top, showsLanguage ? 10 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(codeBackground)

            if showsLanguage {
                HStack {
                    Text(languageLabel)
                        .font(.system(.caption2, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.lowercase)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .allowsHitTesting(false)
            }

            copyButton
                .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(borderColor, lineWidth: 1)
        }
        .markdownMargin(top: 0, bottom: 16)
    }

    private var showsLanguage: Bool {
        guard let language = configuration.language else { return false }
        return !language.isEmpty
    }

    private var languageLabel: String {
        configuration.language ?? ""
    }

    private var copyButton: some View {
        Button {
            copyCode()
        } label: {
            Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(didCopy ? Color.green : Color.secondary)
                .frame(width: 28, height: 28)
                .background(copyButtonBackground, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(didCopy ? "Copied to clipboard" : "Copy code")
    }

    private var copyButtonBackground: Color {
        if appearance.useCustomPreviewColors {
            return Color(fromCodable: appearance.previewColors.codeBlockBackground).opacity(0.95)
        }
        return Color(nsColor: .controlBackgroundColor).opacity(0.92)
    }

    private var codeBackground: Color {
        if appearance.useCustomPreviewColors {
            return Color(fromCodable: appearance.previewColors.codeBlockBackground)
        }
        return Color(nsColor: .textBackgroundColor)
    }

    private var borderColor: Color {
        if appearance.useCustomPreviewColors {
            return Color(fromCodable: appearance.previewColors.thematicBreak).opacity(0.6)
        }
        return Color(nsColor: .separatorColor).opacity(0.35)
    }

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(configuration.content, forType: .string)
        didCopy = true

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            didCopy = false
        }
    }
}

struct MacDailyMarkdownPreviewModifier: ViewModifier {
    let appearance: AppearanceSettings

    @Environment(\.colorScheme) private var colorScheme

    private var effectiveColorScheme: ColorScheme? {
        AppearanceFormatting.preferredColorScheme(for: appearance) ?? colorScheme
    }

    func body(content: Content) -> some View {
        content
            .markdownTheme(AppearanceFormatting.markdownTheme(for: appearance))
            .markdownCodeSyntaxHighlighter(
                .macDaily(theme: SplashSyntaxTheme.theme(
                    colorScheme: effectiveColorScheme,
                    editorZoom: appearance.editorZoom
                ))
            )
            .markdownBlockStyle(\.codeBlock) { configuration in
                MacDailyCodeBlockView(configuration: configuration, appearance: appearance)
            }
    }
}

extension View {
    func macDailyMarkdownPreview(appearance: AppearanceSettings) -> some View {
        modifier(MacDailyMarkdownPreviewModifier(appearance: appearance))
    }
}
