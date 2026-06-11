import AppKit
import SwiftUI
import MacDailyCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillResignActive(_ notification: Notification) {
        NotificationCenter.default.post(name: .flushPendingSaves, object: nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            Task { @MainActor in
                MainWindowOpener.present()
            }
        }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        NotificationCenter.default.post(name: .flushPendingSaves, object: nil)

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Quit macdaily?"
        alert.informativeText =
            "If you quit, daily reminders will not fire and today's note will not be created automatically at midnight. " +
            "Keep macdaily running in the menu bar to stay on schedule."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Quit")

        return alert.runModal() == .alertSecondButtonReturn ? .terminateNow : .terminateCancel
    }
}

@main
struct MacDailyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var app = AppViewModel()

    var body: some Scene {
        WindowGroup(id: "main") {
            RootView()
                .environment(app)
                .presentsMainWindow()
                .hidesMainWindowOnClose()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1100, height: 720)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Today's Note") {
                    app.openTodaysNote()
                }
                .keyboardShortcut("t", modifiers: [.command])

                Button("Choose Notes Folder…") {
                    app.chooseNotesFolder()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                .disabled(!app.canCreateNotes)
            }

            CommandGroup(after: .toolbar) {
                Button("Search Notes…") {
                    app.openNoteSearch()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                .disabled(!app.hasNotesFolder)

                Divider()

                Button("Zoom In") {
                    app.increaseEditorZoom()
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    app.decreaseEditorZoom()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Actual Size") {
                    app.resetEditorZoom()
                }
                .keyboardShortcut("0", modifiers: .command)
            }

            CommandMenu("Format") {
                ForEach(MarkdownFormatAction.formattingCases) { action in
                    formatButton(for: action)
                }
            }
        }

        Settings {
            SettingsView()
                .environment(app)
        }
    }

    @ViewBuilder
    private func formatButton(for action: MarkdownFormatAction) -> some View {
        let shortcut = app.config.keyboardShortcuts.binding(for: action)
        if let keyEquivalent = shortcut.keyEquivalent {
            Button(action.label) {
                NotificationCenter.default.post(name: .applyMarkdownFormat, object: action)
            }
            .keyboardShortcut(keyEquivalent, modifiers: shortcut.swiftUIModifiers)
        } else {
            Button(action.label) {
                NotificationCenter.default.post(name: .applyMarkdownFormat, object: action)
            }
        }
    }
}
