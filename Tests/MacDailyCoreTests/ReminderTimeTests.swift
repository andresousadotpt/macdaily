import XCTest
@testable import MacDailyCore

final class ReminderTimeTests: XCTestCase {
    func testReminderTimesAreDeduplicatedAndSorted() {
        let times = ReminderTime.deduplicatedSorted([
            ReminderTime(hour: 16, minute: 0),
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 9, minute: 30),
            ReminderTime(hour: 13, minute: 0),
        ])

        XCTAssertEqual(times.count, 3)
        XCTAssertEqual(times[0].hour, 9)
        XCTAssertEqual(times[0].minute, 30)
        XCTAssertEqual(times[1].hour, 13)
        XCTAssertEqual(times[2].hour, 16)
    }

    func testReminderTimeClampsOnDecode() throws {
        let json = """
        {"hour": 99, "minute": 99}
        """
        let time = try JSONDecoder().decode(ReminderTime.self, from: Data(json.utf8))
        XCTAssertEqual(time.hour, 23)
        XCTAssertEqual(time.minute, 59)
    }

    func testReminderTimeNormalizedClampsNegativeValues() {
        let time = ReminderTime(hour: -5, minute: -10).normalized()
        XCTAssertEqual(time.hour, 0)
        XCTAssertEqual(time.minute, 0)
    }

    func testReminderTimeDateComponents() {
        let time = ReminderTime(hour: 14, minute: 45)
        let components = time.dateComponents()
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 45)
    }

    func testReminderTimeDefaults() {
        XCTAssertEqual(ReminderTime.defaults.count, 3)
        XCTAssertEqual(ReminderTime.defaults[0].hour, 9)
        XCTAssertEqual(ReminderTime.defaults[0].minute, 30)
    }
}
