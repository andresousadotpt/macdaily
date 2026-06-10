import SwiftUI
import MacDailyCore

struct PreviewThemeSwatch: View {
    let colors: PreviewElementColors

    var body: some View {
        HStack(spacing: 4) {
            swatch(colors.heading1)
            swatch(colors.link)
            swatch(colors.inlineCodeBackground)
            swatch(colors.blockquoteBar)
        }
    }

    private func swatch(_ color: CodableColor) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(fromCodable: color))
            .frame(width: 14, height: 14)
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5)
            }
    }
}

struct AppearanceSettingsView: View {
    @Environment(AppViewModel.self) private var app

    private var appearance: AppearanceSettings {
        app.config.appearance
    }

    var body: some View {
        ScrollView {
            Form {
                textSizeSection
                themeSection
                editorSection
                previewColorsSection
                sidebarSection
            }
            .formStyle(.grouped)
            .padding()
        }
    }

    private var textSizeSection: some View {
        Section {
            HStack {
                Text("Editor zoom")
                Spacer()
                Text(AppearanceFormatting.zoomLabel(appearance.editorZoom))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(
                value: Binding(
                    get: { appearance.editorZoom },
                    set: { app.setEditorZoom($0) }
                ),
                in: AppearanceSettings.zoomRange,
                step: 0.05
            )

            HStack {
                Button("Zoom Out") { app.decreaseEditorZoom() }
                Spacer()
                Button("Reset") { app.resetEditorZoom() }
                Spacer()
                Button("Zoom In") { app.increaseEditorZoom() }
            }
        } header: {
            Text("Text Size")
        } footer: {
            Text("Use ⌘+ and ⌘− in the editor, or ⌘0 to reset.")
        }
    }

    private var themeSection: some View {
        Section("Theme") {
            Picker("Appearance", selection: binding(\.colorScheme)) {
                ForEach(ColorSchemePreference.allCases) { scheme in
                    Text(scheme.label).tag(scheme)
                }
            }

            Toggle("High contrast text", isOn: binding(\.highContrast))
        }
    }

    private var editorSection: some View {
        Section("Editor") {
            Picker("Font style", selection: binding(\.editorFontStyle)) {
                ForEach(EditorFontStyle.allCases) { style in
                    Text(style.label).tag(style)
                }
            }

            Picker("Line spacing", selection: binding(\.lineSpacing)) {
                ForEach(LineSpacingPreference.allCases) { spacing in
                    Text(spacing.label).tag(spacing)
                }
            }

            Toggle("Comfortable margins", isOn: binding(\.comfortableMargins))
            Toggle("Show line numbers", isOn: binding(\.showLineNumbers))

            Picker("Default view", selection: binding(\.defaultPreviewMode)) {
                ForEach(PreviewModePreference.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
        }
    }

    private var previewColorsSection: some View {
        Section {
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
                    if newValue {
                        app.openFormattingPreview()
                    }
                }
            ))

            Toggle("Match editor colors to preview", isOn: binding(\.matchEditorColorsToPreview))

            if appearance.useCustomPreviewColors {
                PreviewColorControls()

                Button {
                    app.openFormattingPreview()
                } label: {
                    Label("Show formatting preview", systemImage: "eye")
                }
            }
        } header: {
            Text("Preview Formatting")
        } footer: {
            Text("Choose a preset theme or switch to Custom to fine-tune each element. Open the live preview to adjust colors while you edit.")
        }
    }

    private var sidebarSection: some View {
        Section("Sidebar") {
            Toggle("Show note count in sidebar", isOn: binding(\.sidebarShowsNoteCount))
        }
    }

    private func binding<T>(_ keyPath: WritableKeyPath<AppearanceSettings, T>) -> Binding<T> {
        Binding(
            get: { appearance[keyPath: keyPath] },
            set: { newValue in
                app.updateAppearance { $0[keyPath: keyPath] = newValue }
            }
        )
    }
}
