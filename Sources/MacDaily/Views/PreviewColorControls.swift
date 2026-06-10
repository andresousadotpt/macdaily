import SwiftUI
import MacDailyCore

struct PreviewColorControls: View {
    @Environment(AppViewModel.self) private var app

    var showsCustomizeToggle = false
    var showsMatchEditorToggle = false

    private var appearance: AppearanceSettings {
        app.config.appearance
    }

    var body: some View {
        Group {
            if showsCustomizeToggle {
                Toggle("Customize preview colors", isOn: Binding(
                    get: { appearance.useCustomPreviewColors },
                    set: { newValue in
                        app.updateAppearance { settings in
                            settings.useCustomPreviewColors = newValue
                            if newValue, settings.previewColorTheme == .custom,
                               settings.previewColors == PreviewElementColors() {
                                settings.previewColorTheme = .githubLight
                                settings.previewColors = PreviewColorTheme.githubLight.colors
                            }
                        }
                    }
                ))
            }

            if showsMatchEditorToggle {
                Toggle("Match editor colors to preview", isOn: binding(\.matchEditorColorsToPreview))
            }

            if appearance.useCustomPreviewColors {
                Picker("Color theme", selection: themeBinding) {
                    ForEach(PreviewColorTheme.presetCases) { theme in
                        HStack {
                            Text(theme.label)
                            Spacer()
                            PreviewThemeSwatch(colors: theme.colors)
                        }
                        .tag(theme)
                    }
                    Text("Custom").tag(PreviewColorTheme.custom)
                }

                Text(activeThemeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if appearance.previewColorTheme == .custom {
                    customColorPickers
                } else {
                    Button("Customize individual colors…") {
                        app.updateAppearance { $0.previewColorTheme = .custom }
                    }
                }
            } else if showsCustomizeToggle {
                Text("Turn on “Customize preview colors” to pick a theme or set individual colors.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var customColorPickers: some View {
        Group {
            colorPicker("Body text", keyPath: \.body)
            colorPicker("Bold", keyPath: \.bold)
            colorPicker("Italic", keyPath: \.italic)
            colorPicker("Underline & links", keyPath: \.underline)
            colorPicker("Strikethrough", keyPath: \.strikethrough)
            colorPicker("Inline code", keyPath: \.inlineCode)
            colorPicker("Inline code background", keyPath: \.inlineCodeBackground)
            colorPicker("Code block text", keyPath: \.codeBlock)
            colorPicker("Code block background", keyPath: \.codeBlockBackground)
            colorPicker("Link", keyPath: \.link)
            colorPicker("Blockquote", keyPath: \.blockquote)
            colorPicker("Blockquote bar", keyPath: \.blockquoteBar)
            colorPicker("List text", keyPath: \.listText)
            colorPicker("Horizontal rule", keyPath: \.thematicBreak)
            colorPicker("Table header", keyPath: \.tableHeader)
            colorPicker("Table border", keyPath: \.tableBorder)

            Group {
                colorPicker("Heading 1", keyPath: \.heading1)
                colorPicker("Heading 2", keyPath: \.heading2)
                colorPicker("Heading 3", keyPath: \.heading3)
                colorPicker("Heading 4", keyPath: \.heading4)
                colorPicker("Heading 5", keyPath: \.heading5)
                colorPicker("Heading 6", keyPath: \.heading6)
            }

            if let matchingPreset = PreviewColorTheme.presetCases.first(where: { $0.matches(appearance.previewColors) }) {
                Button("Revert to \(matchingPreset.label)") {
                    app.applyPreviewColorTheme(matchingPreset)
                }
            } else {
                Button("Reset to GitHub Light") {
                    app.applyPreviewColorTheme(.githubLight)
                }
            }
        }
    }

    private var activeThemeDescription: String {
        if appearance.previewColorTheme == .custom {
            return PreviewColorTheme.custom.description
        }
        return appearance.previewColorTheme.description
    }

    private var themeBinding: Binding<PreviewColorTheme> {
        Binding(
            get: { appearance.previewColorTheme },
            set: { app.applyPreviewColorTheme($0) }
        )
    }

    private func binding<T>(_ keyPath: WritableKeyPath<AppearanceSettings, T>) -> Binding<T> {
        Binding(
            get: { appearance[keyPath: keyPath] },
            set: { newValue in
                app.updateAppearance { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private func colorPicker(
        _ label: String,
        keyPath: WritableKeyPath<PreviewElementColors, CodableColor>
    ) -> some View {
        ColorPicker(
            label,
            selection: Binding(
                get: { Color(fromCodable: appearance.previewColors[keyPath: keyPath]) },
                set: { newColor in
                    app.updateAppearance {
                        $0.previewColors[keyPath: keyPath] = newColor.codableHex
                        $0.previewColorTheme = .custom
                    }
                }
            ),
            supportsOpacity: false
        )
    }
}
