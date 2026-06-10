import AppKit
import SwiftUI
import MacDailyCore

struct MenuBarView: View {
    @Environment(AppViewModel.self) private var app
    @State private var text = ""
    @State private var isLoading = true

    private var isReadyToWrite: Bool {
        app.canCreateNotes && app.hasNotesFolder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .foregroundStyle(.tint)
                Text("macdaily")
                    .font(.headline)
            }

            Text(DateFormatting.title(for: Date()))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if isReadyToWrite {
                    TextEditor(text: $text)
                        .font(AppearanceFormatting.editorFont(for: app.config.appearance))
                        .lineSpacing(app.config.appearance.lineSpacing.points)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200, maxHeight: 240)
                        .onChange(of: text) { _, newValue in
                            app.saveTodaysNoteDebounced(newValue)
                        }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Complete setup in the main app first:")
                            .font(.subheadline)
                        if app.needsNotificationSetup {
                            Text("• Allow notifications")
                        }
                        if !app.hasNotesFolder {
                            Text("• Choose a notes folder")
                        }
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                }
            }

            Button {
                openMainWindow()
            } label: {
                Label("Open macdaily", systemImage: "macwindow")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding(14)
        .frame(width: 312)
        .preferredColorScheme(AppearanceFormatting.preferredColorScheme(for: app.config.appearance))
        .task(id: app.folderRevision) {
            await reload()
        }
    }

    private func reload() async {
        isLoading = true
        defer { isLoading = false }
        text = await app.loadTodaysNote()
    }

    private func openMainWindow() {
        StatusBarController.shared.closePopover()
        Task { @MainActor in
            MainWindowOpener.present()
            await app.ensureTodaysNote(switchToToday: true)
        }
    }
}
