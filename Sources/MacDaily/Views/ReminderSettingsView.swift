import SwiftUI
import MacDailyCore

struct ReminderSettingsView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        Form {
            Toggle("Enable Reminders", isOn: Binding(
                get: { app.config.remindersEnabled },
                set: { enabled in
                    app.updateConfig { $0.remindersEnabled = enabled }
                }
            ))

            if app.config.remindersEnabled {
                Section {
                    if app.config.reminderTimes.isEmpty {
                        Text("No reminder times yet. Add one below.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(app.config.reminderTimes) { time in
                            HStack {
                                DatePicker(
                                    "Reminder",
                                    selection: binding(for: time.id),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()

                                Spacer()

                                Button(role: .destructive) {
                                    removeReminder(id: time.id)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .buttonStyle(.plain)
                                .help("Remove reminder")
                            }
                        }
                    }

                    Button {
                        addReminder()
                    } label: {
                        Label("Add Reminder", systemImage: "plus")
                    }
                } header: {
                    Text("Daily Times")
                } footer: {
                    Text("Reminders use your Mac's local time zone and repeat every day.")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func binding(for id: UUID) -> Binding<Date> {
        Binding(
            get: {
                guard let time = app.config.reminderTimes.first(where: { $0.id == id }) else {
                    return Date()
                }
                var components = DateComponents()
                components.hour = time.hour
                components.minute = time.minute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                app.updateConfig { config in
                    guard let index = config.reminderTimes.firstIndex(where: { $0.id == id }) else {
                        return
                    }
                    config.reminderTimes[index] = ReminderTime(
                        id: id,
                        hour: components.hour ?? 9,
                        minute: components.minute ?? 0
                    )
                }
            }
        )
    }

    private func addReminder() {
        app.updateConfig { config in
            config.reminderTimes.append(ReminderTime(hour: 9, minute: 0))
        }
    }

    private func removeReminder(id: UUID) {
        app.updateConfig { config in
            config.reminderTimes.removeAll { $0.id == id }
        }
    }
}
