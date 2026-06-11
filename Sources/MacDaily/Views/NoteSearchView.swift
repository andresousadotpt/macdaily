import SwiftUI
import MacDailyCore

struct NoteSearchView: View {
    @Environment(AppViewModel.self) private var app
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if app.isSearchingNotes {
                ProgressView("Searching…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if trimmedQuery.isEmpty {
                emptyPrompt
            } else if app.noteSearchResults.isEmpty {
                noResults
            } else {
                resultsList
            }
        }
        .frame(minWidth: 480, minHeight: 360)
        .onAppear {
            isSearchFieldFocused = true
        }
        .onChange(of: app.noteSearchQuery) { _, newValue in
            app.updateNoteSearchQuery(newValue)
        }
    }

    private var trimmedQuery: String {
        app.noteSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Search Notes")
                        .font(.headline)
                    Text("Find text across all daily notes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Done") {
                    app.closeNoteSearch()
                }
                .keyboardShortcut(.cancelAction)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search all notes", text: Binding(
                    get: { app.noteSearchQuery },
                    set: { app.noteSearchQuery = $0 }
                ))
                .textFieldStyle(.plain)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    Task { await app.performNoteSearchNow() }
                }

                if !app.noteSearchQuery.isEmpty {
                    Button {
                        app.noteSearchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Clear search")
                }
            }
            .padding(8)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))

            if !trimmedQuery.isEmpty, !app.isSearchingNotes {
                Text(resultSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private var resultSummary: String {
        let count = app.noteSearchResults.count
        if count == 1 {
            return "1 match"
        }
        return "\(count) matches"
    }

    private var emptyPrompt: some View {
        ContentUnavailableView {
            Label("Search your notes", systemImage: "text.magnifyingglass")
        } description: {
            Text("Type to find matching lines in every daily note.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResults: some View {
        ContentUnavailableView {
            Label("No matches", systemImage: "magnifyingglass")
        } description: {
            Text("Try a different search term.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsList: some View {
        List(app.noteSearchResults) { match in
            Button {
                app.selectSearchResult(match)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(resultTitle(for: match.date))
                        .font(.headline)

                    Text("Line \(match.lineNumber): \(match.lineText)")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .listStyle(.inset)
    }

    private func resultTitle(for date: Date) -> String {
        if DateFormatting.isSameDay(date, Date()) {
            return "Today"
        }
        return DateFormatting.title(for: date)
    }
}
