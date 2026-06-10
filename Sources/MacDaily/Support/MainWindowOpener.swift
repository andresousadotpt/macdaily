import AppKit
import SwiftUI

@MainActor
enum MainWindowOpener {
    private static var registeredOpenWindow: OpenWindowAction?

    static func register(_ openWindow: OpenWindowAction) {
        registeredOpenWindow = openWindow
    }

    static func present(openWindow: OpenWindowAction? = nil) {
        NSApp.setActivationPolicy(.regular)

        let action = openWindow ?? registeredOpenWindow
        let mainWindow = findMainWindow()

        if let mainWindow {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        action?(id: "main")
        NSApp.activate(ignoringOtherApps: true)

        // Window creation from openWindow is async; retry once it exists.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            findMainWindow()?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private static func findMainWindow() -> NSWindow? {
        NSApp.windows.first { window in
            window.canBecomeMain &&
                window.level == .normal &&
                !window.isKind(of: NSPanel.self) &&
                !String(describing: type(of: window)).contains("Popover")
        }
    }
}

/// Hides the main window instead of closing it so the app stays alive in the menu bar.
struct MainWindowCloseBehavior: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                context.coordinator.attach(to: view.window)
            }
        }
        return view
    }

    @MainActor
    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.attach(to: nsView.window)
    }

    final class Coordinator: NSObject, NSWindowDelegate {
        private weak var guardedWindow: NSWindow?
        private weak var previousDelegate: NSWindowDelegate?

        @MainActor
        func attach(to window: NSWindow?) {
            guard let window, guardedWindow !== window else { return }

            if let guardedWindow, guardedWindow.delegate === self {
                guardedWindow.delegate = previousDelegate
            }

            guardedWindow = window
            previousDelegate = window.delegate
            window.delegate = self
        }

        func windowShouldClose(_ sender: NSWindow) -> Bool {
            sender.orderOut(nil)
            return false
        }
    }
}

extension View {
    func hidesMainWindowOnClose() -> some View {
        background(MainWindowCloseBehavior())
    }
}
