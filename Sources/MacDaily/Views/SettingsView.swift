import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            notesTab
                .tabItem {
                    Label("Notes", systemImage: "folder")
                }

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

            KeyboardShortcutsSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            SettingsBackupView()
                .tabItem {
                    Label("Backup", systemImage: "tray.and.arrow.up")
                }

            ReminderSettingsView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }

            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(minWidth: 560, minHeight: 480)
        .sheet(isPresented: Binding(
            get: { app.showFormattingPreviewSheet },
            set: { newValue in
                if newValue {
                    app.openFormattingPreview()
                } else {
                    app.closeFormattingPreview()
                }
            }
        )) {
            PreviewColorsSheet()
                .environment(app)
        }
        .onDisappear {
            app.closeFormattingPreview()
        }
    }

    private var generalTab: some View {
        Form {
            Section {
                Toggle("Open macdaily at login", isOn: Binding(
                    get: { app.config.launchAtLogin },
                    set: { app.setLaunchAtLogin($0) }
                ))
                .disabled(!LaunchAtLoginManager.isSupported)
            } header: {
                Text("Startup")
            } footer: {
                if LaunchAtLoginManager.isSupported {
                    Text("Recommended so reminders fire and today's note is created even if you don't open the window.")
                } else {
                    Text("Launch at login is available when running the packaged macdaily.app.")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var notesTab: some View {
        Form {
            Section("Notes Folder") {
                if let path = app.config.notesFolderPath {
                    Text(path)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No folder selected")
                        .foregroundStyle(.secondary)
                }

                Button("Change Notes Folder…") {
                    app.chooseNotesFolder()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
