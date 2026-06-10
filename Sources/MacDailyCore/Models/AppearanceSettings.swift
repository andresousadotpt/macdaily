import Foundation

public enum ColorSchemePreference: String, Codable, Sendable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

public enum EditorFontStyle: String, Codable, Sendable, CaseIterable, Identifiable {
    case monospaced
    case rounded
    case serif

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .monospaced: "Monospaced"
        case .rounded: "Rounded"
        case .serif: "Serif"
        }
    }
}

public enum LineSpacingPreference: String, Codable, Sendable, CaseIterable, Identifiable {
    case compact
    case normal
    case relaxed

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .compact: "Compact"
        case .normal: "Normal"
        case .relaxed: "Relaxed"
        }
    }

    public var points: CGFloat {
        switch self {
        case .compact: 2
        case .normal: 6
        case .relaxed: 12
        }
    }
}

public enum PreviewModePreference: String, Codable, Sendable, CaseIterable, Identifiable {
    case editor
    case split
    case preview

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .editor: "Editor"
        case .split: "Split"
        case .preview: "Preview"
        }
    }
}

public struct AppearanceSettings: Codable, Sendable, Equatable, Hashable {
    public static let zoomRange = 0.75...2.0
    public static let defaultZoom = 1.0

    public var editorZoom: Double
    public var colorScheme: ColorSchemePreference
    public var editorFontStyle: EditorFontStyle
    public var lineSpacing: LineSpacingPreference
    public var defaultPreviewMode: PreviewModePreference
    public var highContrast: Bool
    public var comfortableMargins: Bool
    public var sidebarShowsNoteCount: Bool
    public var showLineNumbers: Bool
    public var useCustomPreviewColors: Bool
    public var matchEditorColorsToPreview: Bool
    public var previewColorTheme: PreviewColorTheme
    public var previewColors: PreviewElementColors

    public init(
        editorZoom: Double = Self.defaultZoom,
        colorScheme: ColorSchemePreference = .system,
        editorFontStyle: EditorFontStyle = .monospaced,
        lineSpacing: LineSpacingPreference = .normal,
        defaultPreviewMode: PreviewModePreference = .editor,
        highContrast: Bool = false,
        comfortableMargins: Bool = true,
        sidebarShowsNoteCount: Bool = true,
        showLineNumbers: Bool = true,
        useCustomPreviewColors: Bool = false,
        matchEditorColorsToPreview: Bool = false,
        previewColorTheme: PreviewColorTheme = .githubLight,
        previewColors: PreviewElementColors = PreviewElementColors()
    ) {
        self.editorZoom = editorZoom
        self.colorScheme = colorScheme
        self.editorFontStyle = editorFontStyle
        self.lineSpacing = lineSpacing
        self.defaultPreviewMode = defaultPreviewMode
        self.highContrast = highContrast
        self.comfortableMargins = comfortableMargins
        self.sidebarShowsNoteCount = sidebarShowsNoteCount
        self.showLineNumbers = showLineNumbers
        self.useCustomPreviewColors = useCustomPreviewColors
        self.matchEditorColorsToPreview = matchEditorColorsToPreview
        self.previewColorTheme = previewColorTheme
        self.previewColors = previewColors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        editorZoom = try container.decodeIfPresent(Double.self, forKey: .editorZoom) ?? Self.defaultZoom
        colorScheme = try container.decodeIfPresent(ColorSchemePreference.self, forKey: .colorScheme) ?? .system
        editorFontStyle = try container.decodeIfPresent(EditorFontStyle.self, forKey: .editorFontStyle) ?? .monospaced
        lineSpacing = try container.decodeIfPresent(LineSpacingPreference.self, forKey: .lineSpacing) ?? .normal
        defaultPreviewMode = try container.decodeIfPresent(PreviewModePreference.self, forKey: .defaultPreviewMode) ?? .editor
        highContrast = try container.decodeIfPresent(Bool.self, forKey: .highContrast) ?? false
        comfortableMargins = try container.decodeIfPresent(Bool.self, forKey: .comfortableMargins) ?? true
        sidebarShowsNoteCount = try container.decodeIfPresent(Bool.self, forKey: .sidebarShowsNoteCount) ?? true
        if let lineNumbers = try container.decodeIfPresent(Bool.self, forKey: .showLineNumbers) {
            showLineNumbers = lineNumbers
        } else {
            let legacy = try decoder.container(keyedBy: LegacyCodingKeys.self)
            showLineNumbers = try legacy.decodeIfPresent(Bool.self, forKey: .showLineCount) ?? true
        }
        useCustomPreviewColors = try container.decodeIfPresent(Bool.self, forKey: .useCustomPreviewColors) ?? false
        matchEditorColorsToPreview = try container.decodeIfPresent(Bool.self, forKey: .matchEditorColorsToPreview) ?? false
        previewColors = try container.decodeIfPresent(PreviewElementColors.self, forKey: .previewColors) ?? PreviewElementColors()
        previewColorTheme = try container.decodeIfPresent(PreviewColorTheme.self, forKey: .previewColorTheme)
            ?? PreviewColorTheme.inferred(from: previewColors)
        normalize()
    }

    public mutating func normalize() {
        editorZoom = min(max(editorZoom, Self.zoomRange.lowerBound), Self.zoomRange.upperBound)
    }

    private enum CodingKeys: String, CodingKey {
        case editorZoom
        case colorScheme
        case editorFontStyle
        case lineSpacing
        case defaultPreviewMode
        case highContrast
        case comfortableMargins
        case sidebarShowsNoteCount
        case showLineNumbers
        case useCustomPreviewColors
        case matchEditorColorsToPreview
        case previewColorTheme
        case previewColors
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case showLineCount
    }
}
