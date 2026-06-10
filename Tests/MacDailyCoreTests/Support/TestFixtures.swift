import Foundation
@testable import MacDailyCore

enum TestFixtures {
    static func fixedDate(
        year: Int = 2026,
        month: Int = 6,
        day: Int = 10,
        calendar: Calendar = .current
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)!
    }

    static func normalizedFixedDate(
        year: Int = 2026,
        month: Int = 6,
        day: Int = 10
    ) -> Date {
        DateFormatting.startOfDay(fixedDate(year: year, month: month, day: day))
    }

    static func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
