import SwiftUI
import MacDailyCore

struct SidebarView: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        List(selection: Binding(
            get: { app.selectedDate },
            set: { app.select(date: $0) }
        )) {
            Section {
                if let today = app.notes.first(where: { DateFormatting.isSameDay($0.date, Date()) }) {
                    noteRow(today, label: "Today")
                } else {
                    Button {
                        app.openTodaysNote()
                    } label: {
                        Label("Today", systemImage: "sun.max.fill")
                    }
                }
            }

            Section("Notes") {
                ForEach(app.notes.filter { !DateFormatting.isSameDay($0.date, Date()) }) { note in
                    noteRow(note, label: DateFormatting.sidebarLabel(for: note.date))
                }
            }

            if app.config.appearance.sidebarShowsNoteCount, !app.notes.isEmpty {
                Section {
                    Text("\(app.notes.count) daily notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("macdaily")
        .listStyle(.sidebar)
    }

    private func noteRow(_ note: DailyNote, label: String) -> some View {
        Text(label)
            .tag(note.date)
    }
}
