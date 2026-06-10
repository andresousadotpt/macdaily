import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject, NSPopoverDelegate {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var localClickMonitor: Any?
    private var globalClickMonitor: Any?
    private weak var app: AppViewModel?

    var isInstalled: Bool { statusItem != nil }

    private override init() {
        super.init()
    }

    func install(app: AppViewModel) {
        self.app = app

        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "MacDailyStatusItem"
        item.isVisible = true
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        item.button?.toolTip = "macdaily — today's note"
        statusItem = item

        updateIcon()
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }

        if let logo = NSImage(named: "Logo") {
            logo.size = NSSize(width: 18, height: 18)
            logo.isTemplate = true
            button.image = logo
            button.title = ""
        } else {
            let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            button.image = NSImage(systemSymbolName: "book.closed.fill", accessibilityDescription: "macdaily")?
                .withSymbolConfiguration(config)
            button.image?.isTemplate = true
            button.title = ""
        }
        button.imagePosition = .imageOnly
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else { return }

        if let popover, popover.isShown {
            closePopover()
            return
        }

        guard let app else { return }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
        popover.contentSize = NSSize(width: 340, height: 380)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environment(app)
        )

        self.popover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        startOutsideClickMonitors()
        NSApp.activate()
    }

    func closePopover() {
        stopOutsideClickMonitors()
        popover?.performClose(nil)
        popover = nil
    }

    private func startOutsideClickMonitors() {
        stopOutsideClickMonitors()

        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.closePopoverIfNeeded()
            return event
        }

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.closePopoverIfNeeded()
            }
        }
    }

    private func stopOutsideClickMonitors() {
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
            self.localClickMonitor = nil
        }
        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
            self.globalClickMonitor = nil
        }
    }

    private func closePopoverIfNeeded() {
        guard let popover, popover.isShown else { return }

        let mouseLocation = NSEvent.mouseLocation

        if let button = statusItem?.button, let window = button.window {
            let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
            if buttonFrame.contains(mouseLocation) {
                return
            }
        }

        if let window = popover.contentViewController?.view.window,
           window.frame.contains(mouseLocation) {
            return
        }

        closePopover()
    }

    func popoverDidClose(_ notification: Notification) {
        stopOutsideClickMonitors()
        popover = nil
    }
}

extension Notification.Name {
    static let openMainWindow = Notification.Name("macdaily.openMainWindow")
}
