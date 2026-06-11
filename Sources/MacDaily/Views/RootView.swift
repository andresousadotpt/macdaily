import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var app
    @State private var editor = EditorViewModel()

    var body: some View {
        Group {
            if app.isReady {
                NavigationSplitView {
                    SidebarView()
                } detail: {
                    EditorView(editor: editor)
                }
            } else {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .preferredColorScheme(AppearanceFormatting.preferredColorScheme(for: app.config.appearance))
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { app.errorMessage != nil },
                set: { if !$0 { app.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(app.errorMessage ?? "")
        }
        .onReceive(NotificationCenter.default.publisher(for: .openTodaysNote)) { _ in
            Task {
                await app.ensureTodaysNote(switchToToday: true)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .flushPendingSaves)) { _ in
            Task {
                if let store = app.noteStoreIfAvailable() {
                    await editor.flushAllPendingSaves(to: store)
                }
                await app.flushPendingSaves()
            }
        }
        .sheet(isPresented: Binding(
            get: { app.showNoteSearch },
            set: { newValue in
                if newValue {
                    app.openNoteSearch()
                } else {
                    app.closeNoteSearch()
                }
            }
        )) {
            NoteSearchView()
                .environment(app)
        }
    }
}
