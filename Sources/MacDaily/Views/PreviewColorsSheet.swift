import MarkdownUI
import SwiftUI
import MacDailyCore

struct PreviewColorsSampleView: View {
    let appearance: AppearanceSettings

    var body: some View {
        Markdown(PreviewColorsSample.markdown)
            .macDailyMarkdownPreview(appearance: appearance)
            .font(AppearanceFormatting.previewFont(for: appearance))
            .lineSpacing(appearance.lineSpacing.points)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PreviewColorsSheet: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Preview Formatting")
                        .font(.headline)
                    Text("Adjust colors on the left and see changes live on the right.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Done") {
                    app.closeFormattingPreview()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()

            Divider()

            HSplitView {
                ScrollView {
                    Form {
                        PreviewColorControls(
                            showsCustomizeToggle: true,
                            showsMatchEditorToggle: true
                        )
                    }
                    .formStyle(.grouped)
                    .padding()
                }
                .frame(minWidth: 300, idealWidth: 320, maxWidth: 360)

                ScrollView {
                    PreviewColorsSampleView(appearance: app.config.appearance)
                        .padding(24)
                }
                .background(Color(nsColor: .textBackgroundColor))
                .frame(minWidth: 420)
            }
        }
        .frame(minWidth: 820, minHeight: 640)
        .preferredColorScheme(AppearanceFormatting.preferredColorScheme(for: app.config.appearance))
    }
}
