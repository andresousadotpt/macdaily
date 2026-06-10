import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
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
        popover.contentSize = NSSize(width: 340, height: 380)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environment(app)
        )

        self.popover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate()
    }

    func closePopover() {
        popover?.performClose(nil)
        popover = nil
    }
}

extension Notification.Name {
    static let openMainWindow = Notification.Name("macdaily.openMainWindow")
}
