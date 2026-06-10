import Foundation

public struct DailyNote: Identifiable, Hashable, Sendable {
    public let date: Date
    public let url: URL

    public var id: Date { date }

    public var filename: String {
        DateFormatting.filename(for: date)
    }
}
