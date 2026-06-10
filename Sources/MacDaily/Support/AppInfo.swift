import AppKit
import Foundation

enum AppInfo {
    static let repositoryURL = URL(string: "https://github.com/andresousadotpt/macdaily")!
    static let releasesURL = URL(string: "https://github.com/andresousadotpt/macdaily/releases")!

    static var name: String {
        bundleString("CFBundleDisplayName")
            ?? bundleString("CFBundleName")
            ?? "macdaily"
    }

    static var version: String {
        bundleString("CFBundleShortVersionString") ?? "dev"
    }

    static var build: String {
        bundleString("CFBundleVersion") ?? "0"
    }

    static var versionLabel: String {
        if build == "0" || build.isEmpty {
            return version
        }
        return "\(version) (\(build))"
    }

    static var copyright: String {
        bundleString("NSHumanReadableCopyright") ?? "Daily markdown notes for macOS."
    }

    static var bundleIdentifier: String {
        bundleString("CFBundleIdentifier") ?? "com.macdaily.app"
    }

    private static func bundleString(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    static func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
