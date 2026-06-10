import AppKit
import MarkdownUI
import SwiftUI
import MacDailyCore

enum AppearanceFormatting {
    static let baseEditorSize: CGFloat = 14

    static func editorFont(for appearance: AppearanceSettings) -> Font {
        let size = baseEditorSize * appearance.editorZoom
        let weight: Font.Weight = appearance.highContrast ? .semibold : .regular

        switch appearance.editorFontStyle {
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        }
    }

    static func previewFont(for appearance: AppearanceSettings) -> Font {
        let size = baseEditorSize * appearance.editorZoom
        return .system(size: size, weight: appearance.highContrast ? .semibold : .regular)
    }

    static func editorPadding(for appearance: AppearanceSettings) -> CGFloat {
        appearance.comfortableMargins ? 24 : 12
    }

    static func preferredColorScheme(for appearance: AppearanceSettings) -> ColorScheme? {
        switch appearance.colorScheme {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    static func editorPreviewMode(for preference: PreviewModePreference) -> EditorPreviewMode {
        switch preference {
        case .editor: .editor
        case .split: .split
        case .preview: .preview
        }
    }

    static func previewModePreference(for mode: EditorPreviewMode) -> PreviewModePreference {
        switch mode {
        case .editor: .editor
        case .split: .split
        case .preview: .preview
        }
    }

    static func zoomLabel(_ zoom: Double) -> String {
        "\(Int((zoom * 100).rounded()))%"
    }

    static func editorNSFont(for appearance: AppearanceSettings) -> NSFont {
        let size = baseEditorSize * appearance.editorZoom
        let weight: NSFont.Weight = appearance.highContrast ? .semibold : .regular

        switch appearance.editorFontStyle {
        case .monospaced:
            return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
        case .rounded:
            if let descriptor = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) {
                return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
            }
            return NSFont.systemFont(ofSize: size, weight: weight)
        case .serif:
            if let descriptor = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.serif) {
                return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
            }
            return NSFont.systemFont(ofSize: size, weight: weight)
        }
    }

    static func editorBackgroundColor(for appearance: AppearanceSettings) -> NSColor {
        if appearance.matchEditorColorsToPreview {
            return .textBackgroundColor
        }
        return appearance.highContrast ? .textBackgroundColor : .windowBackgroundColor
    }

    static func editorUsesPreviewColors(_ appearance: AppearanceSettings) -> Bool {
        appearance.matchEditorColorsToPreview
    }

    @MainActor
    static func markdownTheme(for appearance: AppearanceSettings) -> Theme {
        MacDailyMarkdownTheme.theme(for: appearance)
    }
}
