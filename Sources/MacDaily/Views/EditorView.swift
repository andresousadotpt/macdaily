import MarkdownUI
import SwiftUI
import MacDailyCore

struct EditorView: View {
    @Environment(AppViewModel.self) private var app
    @Bindable var editor: EditorViewModel

    private var appearance: AppearanceSettings {
        app.config.appearance
    }

    var body: some View {
        Group {
            if app.isOnboardingComplete {
                editorContent
            } else {
                OnboardingView()
            }
        }
        .navigationTitle(DateFormatting.title(for: app.selectedDate))
        .toolbar {
            ToolbarItemGroup {
                Picker("Preview", selection: Binding(
                    get: { editor.previewMode },
                    set: { editor.setPreviewMode($0) }
                )) {
                    ForEach(EditorPreviewMode.allCases) { mode in
                        Label(mode.label, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Button {
                    app.openFolderInFinder()
                } label: {
                    Label("Show in Finder", systemImage: "folder")
                }
                .disabled(!app.hasNotesFolder)

                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
            }

        }
        .task(id: editorReloadID) {
            await reloadNote()
        }
        .onAppear {
            editor.onError = { message in
                app.errorMessage = message
            }
            editor.setPreviewMode(AppearanceFormatting.editorPreviewMode(for: appearance.defaultPreviewMode))
        }
        .onChange(of: app.config.appearance.defaultPreviewMode) { _, newValue in
            editor.setPreviewMode(AppearanceFormatting.editorPreviewMode(for: newValue))
        }
        .onReceive(NotificationCenter.default.publisher(for: .applyMarkdownFormat)) { notification in
            guard let action = notification.object as? MarkdownFormatAction else { return }
            editor.requestFormat(action)
        }
    }

    private var editorReloadID: String {
        "\(app.folderRevision)-\(app.selectedDate.timeIntervalSince1970)"
    }

    @ViewBuilder
    private var editorContent: some View {
        switch editor.previewMode {
        case .editor:
            editorPane
        case .preview:
            previewPane
        case .split:
            HSplitView {
                editorPane
                previewPane
            }
        }
    }

    private var editorPane: some View {
        MarkdownTextEditor(
            text: Binding(
                get: { editor.text },
                set: { _ in }
            ),
            appearance: appearance,
            font: AppearanceFormatting.editorNSFont(for: appearance),
            lineSpacing: appearance.lineSpacing.points,
            backgroundColor: AppearanceFormatting.editorBackgroundColor(for: appearance),
            keyboardShortcuts: app.config.keyboardShortcuts,
            formatRequest: Binding(
                get: { editor.formatRequest },
                set: { newValue in
                    if newValue == nil {
                        editor.clearFormatRequest()
                    } else if let newValue {
                        editor.requestFormat(newValue)
                    }
                }
            ),
            onTextChange: { newValue in
                guard let store = app.noteStoreIfAvailable() else { return }
                editor.updateText(newValue, store: store)
            }
        )
        .padding(AppearanceFormatting.editorPadding(for: appearance))
        .background(Color(nsColor: AppearanceFormatting.editorBackgroundColor(for: appearance)))
    }

    private var previewPane: some View {
        ScrollView {
            Markdown(editor.text)
                .macDailyMarkdownPreview(appearance: appearance)
                .font(AppearanceFormatting.previewFont(for: appearance))
                .lineSpacing(appearance.lineSpacing.points)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppearanceFormatting.editorPadding(for: appearance))
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func reloadNote() async {
        guard app.hasNotesFolder else {
            editor.resetForFolderChange()
            return
        }
        guard let store = app.noteStoreIfAvailable() else { return }
        do {
            guard let note = try await app.selectedNote() else { return }
            await editor.load(note: note, store: store)
        } catch {
            app.errorMessage = error.localizedDescription
        }
    }
}

extension Notification.Name {
    static let applyMarkdownFormat = Notification.Name("macdaily.applyMarkdownFormat")
    static let flushPendingSaves = Notification.Name("macdaily.flushPendingSaves")
}
