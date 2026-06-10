import MarkdownUI
import SwiftUI
import MacDailyCore

@MainActor
enum MacDailyMarkdownTheme {
    static func theme(for appearance: AppearanceSettings) -> Theme {
        guard appearance.useCustomPreviewColors else {
            return .gitHub
        }

        let colors = appearance.previewColors
        let highContrast = appearance.highContrast

        return Theme.gitHub
            .text {
                ForegroundColor(Color(fromCodable: colors.body))
            }
            .strong {
                FontWeight(highContrast ? .bold : .semibold)
                ForegroundColor(Color(fromCodable: colors.bold))
            }
            .emphasis {
                FontStyle(.italic)
                ForegroundColor(Color(fromCodable: colors.italic))
            }
            .strikethrough {
                StrikethroughStyle(.single)
                ForegroundColor(Color(fromCodable: colors.strikethrough))
            }
            .code {
                FontFamilyVariant(.monospaced)
                FontSize(.em(0.85))
                ForegroundColor(Color(fromCodable: colors.inlineCode))
                BackgroundColor(Color(fromCodable: colors.inlineCodeBackground))
            }
            .link {
                ForegroundColor(Color(fromCodable: colors.link))
                UnderlineStyle(.single)
            }
            .heading1 { configuration in
                headingBlock(configuration, color: colors.heading1, highContrast: highContrast, size: 2, showDivider: true)
            }
            .heading2 { configuration in
                headingBlock(configuration, color: colors.heading2, highContrast: highContrast, size: 1.5, showDivider: true)
            }
            .heading3 { configuration in
                headingBlock(configuration, color: colors.heading3, highContrast: highContrast, size: 1.25, showDivider: false)
            }
            .heading4 { configuration in
                headingBlock(configuration, color: colors.heading4, highContrast: highContrast, size: 1, showDivider: false)
            }
            .heading5 { configuration in
                headingBlock(configuration, color: colors.heading5, highContrast: highContrast, size: 0.875, showDivider: false)
            }
            .heading6 { configuration in
                headingBlock(configuration, color: colors.heading6, highContrast: highContrast, size: 0.85, showDivider: false)
            }
            .blockquote { configuration in
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(fromCodable: colors.blockquoteBar))
                        .relativeFrame(width: .em(0.2))
                    configuration.label
                        .markdownTextStyle {
                            ForegroundColor(Color(fromCodable: colors.blockquote))
                        }
                        .relativePadding(.horizontal, length: .em(1))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .listItem { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(Color(fromCodable: colors.listText))
                    }
                    .markdownMargin(top: .em(0.25))
            }
            .thematicBreak {
                Divider()
                    .relativeFrame(height: .em(0.25))
                    .overlay(Color(fromCodable: colors.thematicBreak))
                    .markdownMargin(top: 24, bottom: 24)
            }
            .table { configuration in
                configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .markdownTableBorderStyle(.init(color: Color(fromCodable: colors.tableBorder)))
                    .markdownMargin(top: 0, bottom: 16)
            }
            .tableCell { configuration in
                configuration.label
                    .markdownTextStyle {
                        if configuration.row == 0 {
                            FontWeight(.semibold)
                            ForegroundColor(Color(fromCodable: colors.tableHeader))
                        } else {
                            ForegroundColor(Color(fromCodable: colors.body))
                        }
                        BackgroundColor(nil)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .relativeLineSpacing(.em(0.25))
            }
    }

    @ViewBuilder
    private static func headingBlock(
        _ configuration: BlockConfiguration,
        color: CodableColor,
        highContrast: Bool,
        size: Double,
        showDivider: Bool
    ) -> some View {
        if showDivider {
            VStack(alignment: .leading, spacing: 0) {
                configuration.label
                    .relativePadding(.bottom, length: .em(0.3))
                    .relativeLineSpacing(.em(0.125))
                    .markdownMargin(top: 24, bottom: 16)
                    .markdownTextStyle {
                        FontWeight(highContrast ? .bold : .semibold)
                        FontSize(.em(size))
                        ForegroundColor(Color(fromCodable: color))
                    }
                Divider().overlay(Color(fromCodable: color).opacity(0.35))
            }
        } else {
            configuration.label
                .relativeLineSpacing(.em(0.125))
                .markdownMargin(top: 24, bottom: 16)
                .markdownTextStyle {
                    FontWeight(highContrast ? .bold : .semibold)
                    FontSize(.em(size))
                    ForegroundColor(Color(fromCodable: color))
                }
        }
    }
}
