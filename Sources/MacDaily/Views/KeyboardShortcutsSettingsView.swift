import SwiftUI
import MacDailyCore

struct KeyboardShortcutsSettingsView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        Form {
            ForEach(groupedActions.keys.sorted(), id: \.self) { category in
                Section(category) {
                    ForEach(groupedActions[category] ?? [], id: \.self) { action in
                        HStack {
                            Text(action.label)
                            Spacer()
                            KeyBindingRecorder(binding: binding(for: action))
                        }
                    }
                }
            }

            Section {
                Button("Reset All to Defaults") {
                    app.resetKeyboardShortcuts()
                }
            } footer: {
                Text("Click a shortcut, then press the new key combination. Underline inserts HTML tags. Heading shortcuts apply to the current line.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var groupedActions: [String: [MarkdownFormatAction]] {
        Dictionary(grouping: MarkdownFormatAction.formattingCases, by: \.settingsCategory)
    }

    private func binding(for action: MarkdownFormatAction) -> Binding<KeyBinding> {
        Binding(
            get: { app.config.keyboardShortcuts.binding(for: action) },
            set: { newValue in
                app.updateKeyboardShortcuts { $0.setBinding(newValue, for: action) }
            }
        )
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

            let characters = press.characters.lowercased()
            guard !characters.isEmpty else { return .ignored }

            binding = KeyBinding(
                key: String(characters.last!),
                command: press.modifiers.contains(.command),
                shift: press.modifiers.contains(.shift),
                option: press.modifiers.contains(.option),
                control: press.modifiers.contains(.control)
            )
            isRecording = false
            return .handled
        }
    }
}
