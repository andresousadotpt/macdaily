import AppKit
import Foundation

/// Creates today's note at local midnight and whenever the Mac wakes or the app becomes active.
@MainActor
final class DayRolloverMonitor {
    private var midnightTimer: Timer?
    private var wakeObserver: NSObjectProtocol?
    private var activeObserver: NSObjectProtocol?
    private let onCheck: @MainActor () async -> Void

    init(onCheck: @escaping @MainActor () async -> Void) {
        self.onCheck = onCheck
    }

    func start() {
        scheduleNextMidnight()

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.checkNow()
            }
        }

        activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.checkNow()
            }
        }
    }

    func stop() {
        midnightTimer?.invalidate()
        midnightTimer = nil

        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
        if let activeObserver {
            NotificationCenter.default.removeObserver(activeObserver)
        }
        wakeObserver = nil
        activeObserver = nil
    }

    private func checkNow() async {
        await onCheck()
    }

    private func scheduleNextMidnight() {
        midnightTimer?.invalidate()

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return
        }

        midnightTimer = Timer(fire: nextMidnight, interval: 0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.checkNow()
                self?.scheduleNextMidnight()
            }
        }

        if let midnightTimer {
            RunLoop.main.add(midnightTimer, forMode: .common)
        }
    }
}
