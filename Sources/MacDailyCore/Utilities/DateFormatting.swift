import Foundation

public enum DateFormatting {
    private static let filenameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    private static let sidebarFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static func filename(for date: Date) -> String {
        "\(filenameFormatter.string(from: date)).md"
    }

    public static func title(for date: Date) -> String {
        titleFormatter.string(from: date)
    }

    public static func sidebarLabel(for date: Date) -> String {
        sidebarFormatter.string(from: date)
    }

    public static func timeString(for date: Date) -> String {
        timeFormatter.string(from: date)
    }

    public static func date(fromFilename filename: String) -> Date? {
        let stem = (filename as NSString).deletingPathExtension
        return filenameFormatter.date(from: stem)
    }

    public static func isDailyNoteFilename(_ filename: String) -> Bool {
        filename.hasSuffix(".md") && date(fromFilename: filename) != nil
    }

    public static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    public static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        Calendar.current.isDate(lhs, inSameDayAs: rhs)
    }
}
