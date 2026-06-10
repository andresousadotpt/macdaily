import SwiftUI
import MacDailyCore

private enum ShortcutSettingsItem: Hashable, Identifiable {
    case format(MarkdownFormatAction)
    case editor(EditorShortcutAction)

    var id: String {
        switch self {
        case .format(let action): "format-\(action.rawValue)"
        case .editor(let action): "editor-\(action.rawValue)"
        }
    }

    var label: String {
        switch self {
        case .format(let action): action.label
        case .editor(let action): action.label
        }
    }

    var settingsCategory: String {
        switch self {
        case .format(let action): action.settingsCategory
        case .editor(let action): action.settingsCategory
        }
    }
}

struct KeyboardShortcutsSettingsView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        Form {
            ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                Section(category) {
                    ForEach(groupedItems[category] ?? [], id: \.self) { item in
                        HStack {
                            Text(item.label)
                            Spacer()
                            KeyBindingRecorder(binding: binding(for: item))
                        }
                    }
                }
            }

            Section {
                Button("Reset All to Defaults") {
                    app.resetKeyboardShortcuts()
                }
            } footer: {
                Text("Click a shortcut, then press the new key combination. Underline inserts HTML tags. Heading shortcuts apply to the current line. Tab indents selected lines or inserts a tab on a single line. Outdent removes indentation from selected lines.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var shortcutItems: [ShortcutSettingsItem] {
        MarkdownFormatAction.formattingCases.map(ShortcutSettingsItem.format)
            + EditorShortcutAction.shortcutCases.map(ShortcutSettingsItem.editor)
    }

    private var groupedItems: [String: [ShortcutSettingsItem]] {
        Dictionary(grouping: shortcutItems, by: \.settingsCategory)
    }

    private func binding(for item: ShortcutSettingsItem) -> Binding<KeyBinding> {
        switch item {
        case .format(let action):
            Binding(
                get: { app.config.keyboardShortcuts.binding(for: action) },
                set: { newValue in
                    app.updateKeyboardShortcuts { $0.setBinding(newValue, for: action) }
                }
            )
        case .editor(let action):
            Binding(
                get: { app.config.keyboardShortcuts.binding(for: action) },
                set: { newValue in
                    app.updateKeyboardShortcuts { $0.setBinding(newValue, for: action) }
                }
            )
        }
    }
}

private struct KeyBindingRecorder: View {
    @Binding var binding: KeyBinding
    @FocusState private var isRecording: Bool

    var body: some View {
        Button {
            isRecording = true
        } label: {
            Text(isRecording ? "Press shortcut…" : binding.displayLabel)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(isRecording ? Color.accentColor : Color.secondary)
                .frame(minWidth: 120, alignment: .trailing)
        }
        .buttonStyle(.plain)
        .focusable(isRecording)
        .focused($isRecording)
        .onKeyPress { press in
            guard isRecording else { return .ignored }

            if press.key == .escape {
                isRecording = false
                return .handled
            }

            let key = recordedKey(for: press)
            guard let key else { return .ignored }

            binding = KeyBinding(
                key: key,
                command: press.modifiers.contains(.command),
                shift: press.modifiers.contains(.shift),
                option: press.modifiers.contains(.option),
                control: press.modifiers.contains(.control)
            )
            isRecording = false
            return .handled
        }
    }

    private func recordedKey(for press: KeyPress) -> String? {
        switch press.key {
        case .home: return "home"
        case .end: return "end"
        case .tab: return "tab"
        default:
            let characters = press.characters.lowercased()
            guard !characters.isEmpty else { return nil }
            return String(characters.last!)
        }
    }
}
