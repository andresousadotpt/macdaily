import Foundation

@MainActor
final class Debouncer {
    private var tasks: [String: Task<Void, Never>] = [:]
    private var pendingOperations: [String: () async -> Void] = [:]
    private let delay: Duration

    init(delay: Duration = .milliseconds(400)) {
        self.delay = delay
    }

    func schedule(_ key: String, _ operation: @escaping () async -> Void) {
        tasks[key]?.cancel()
        pendingOperations[key] = operation
        tasks[key] = Task { [delay] in
            try? await Task.sleep(for: delay)
            if Task.isCancelled { return }
            pendingOperations.removeValue(forKey: key)
            await operation()
        }
    }

    func flush(_ key: String) async {
        tasks[key]?.cancel()
        tasks.removeValue(forKey: key)
        if let operation = pendingOperations.removeValue(forKey: key) {
            await operation()
        }
    }

    func flushAll() async {
        for key in Array(pendingOperations.keys) {
            await flush(key)
        }
    }

    func cancel(_ key: String) {
        tasks[key]?.cancel()
        tasks.removeValue(forKey: key)
        pendingOperations.removeValue(forKey: key)
    }

    func cancelAll() {
        for task in tasks.values {
            task.cancel()
        }
        tasks.removeAll()
        pendingOperations.removeAll()
    }
}
