import Foundation
import ServiceManagement

enum LaunchAtLoginError: LocalizedError {
    case notSupported
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "Launch at login requires the packaged macdaily app."
        case .operationFailed(let message):
            return message
        }
    }
}

@MainActor
enum LaunchAtLoginManager {
    /// Login items require a real `.app` bundle (same constraint as notifications).
    static var isSupported: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    static var isEnabled: Bool {
        guard isSupported else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        guard isSupported else {
            throw LaunchAtLoginError.notSupported
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            throw LaunchAtLoginError.operationFailed(error.localizedDescription)
        }
    }

    static func sync(preference enabled: Bool) throws {
        guard isSupported else { return }
        if enabled != isEnabled {
            try setEnabled(enabled)
        }
    }
}
