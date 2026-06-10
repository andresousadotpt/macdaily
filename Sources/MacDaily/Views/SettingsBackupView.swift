import SwiftUI
import MacDailyCore

struct SettingsBackupView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        Form {
            Section {
                LabeledContent("Settings file") {
                    Text(AppPaths.configURL.path)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Automatic Save")
            } footer: {
                Text("Appearance, shortcuts, reminders, and startup preferences are saved automatically whenever you change them.")
            }

            Section {
                Button {
                    app.exportSettings()
                } label: {
                    Label("Export Settings…", systemImage: "square.and.arrow.up")
                }

                Button {
                    app.importSettings()
                } label: {
                    Label("Import Settings…", systemImage: "square.and.arrow.down")
                }
            } header: {
                Text("Backup")
            } footer: {
                Text("Export saves appearance, keyboard shortcuts, reminders, and launch-at-login to a JSON file. Your notes folder path is not included. Import replaces those settings on this Mac.")
            }

            Section("Included in export") {
                Label("Appearance & preview colors", systemImage: "paintbrush")
                Label("Keyboard shortcuts", systemImage: "keyboard")
                Label("Reminder times", systemImage: "bell")
                Label("Launch at login preference", systemImage: "power")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
