import Foundation
import MacDailyCore
import Observation

enum EditorPreviewMode: String, CaseIterable, Identifiable {
    case editor
    case split
    case preview

    var id: String { rawValue }

    var label: String {
        switch self {
        case .editor: "Editor"
        case .split: "Split"
        case .preview: "Preview"
        }
    }

    var systemImage: String {
        switch self {
        case .editor: "square.and.pencil"
        case .split: "rectangle.split.2x1"
        case .preview: "eye"
        }
    }
}

@MainActor
@Observable
final class EditorViewModel {
    private(set) var text = ""
    private(set) var isLoading = false
    private(set) var previewMode: EditorPreviewMode = .editor
    private(set) var formatRequest: MarkdownFormatAction?
    var scrollToLine: Int?

    @ObservationIgnored private var currentNote: DailyNote?
    @ObservationIgnored private let debouncer = Debouncer()
    @ObservationIgnored var onError: ((String) -> Void)?

    func setPreviewMode(_ mode: EditorPreviewMode) {
        previewMode = mode
    }

    func requestFormat(_ action: MarkdownFormatAction) {
        formatRequest = action
    }

    func clearFormatRequest() {
        formatRequest = nil
    }

    func requestScrollToLine(_ line: Int) {
        scrollToLine = line
    }

    func clearScrollToLineRequest() {
        scrollToLine = nil
    }

    func resetForFolderChange() {
        debouncer.cancelAll()
        currentNote = nil
        text = ""
    }

    func load(note: DailyNote, store: NoteStore) async {
        if currentNote?.url == note.url {
            await flushSave(to: store)
        } else {
            debouncer.cancel("save")
        }

        isLoading = true
        defer { isLoading = false }

        currentNote = note
        do {
            text = try await store.readContents(of: note)
        } catch {
            text = ""
            onError?(error.localizedDescription)
        }
    }

    func updateText(_ newValue: String, store: NoteStore) {
        text = newValue
        guard let currentNote else { return }

        debouncer.schedule("save") { [weak self] in
            guard let self else { return }
            do {
                try await store.writeContents(newValue, to: currentNote)
            } catch {
                self.onError?(error.localizedDescription)
            }
        }
    }

    func flushSave(to store: NoteStore) async {
        await debouncer.flush("save")
    }

    func flushAllPendingSaves(to store: NoteStore) async {
        debouncer.cancel("save")
        guard let currentNote else { return }
        do {
            try await store.writeContents(text, to: currentNote)
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
