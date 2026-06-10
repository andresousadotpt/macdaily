import Foundation

public struct ReminderTime: Codable, Hashable, Sendable, Identifiable {
    public var id: UUID
    public var hour: Int
    public var minute: Int

    public init(id: UUID = UUID(), hour: Int, minute: Int) {
        self.id = id
        self.hour = hour
        self.minute = minute
    }

    public static let defaults: [ReminderTime] = [
        ReminderTime(hour: 9, minute: 30),
        ReminderTime(hour: 13, minute: 0),
        ReminderTime(hour: 16, minute: 0),
    ]

    public func normalized() -> ReminderTime {
        ReminderTime(
            id: id,
            hour: max(0, min(23, hour)),
            minute: max(0, min(59, minute))
        )
    }

    public func dateComponents() -> DateComponents {
        DateComponents(hour: hour, minute: minute)
    }

    public func displayString(calendar: Calendar = .current) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = calendar.date(from: components) ?? Date()
        return DateFormatting.timeString(for: date)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        hour = try container.decode(Int.self, forKey: .hour)
        minute = try container.decode(Int.self, forKey: .minute)
        let clamped = normalized()
        hour = clamped.hour
        minute = clamped.minute
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case hour
        case minute
    }
}

public extension ReminderTime {
    static func deduplicatedSorted(_ times: [ReminderTime]) -> [ReminderTime] {
        var seen = Set<String>()
        return times
            .map { $0.normalized() }
            .filter { seen.insert("\($0.hour):\($0.minute)").inserted }
            .sorted {
                if $0.hour != $1.hour { return $0.hour < $1.hour }
                return $0.minute < $1.minute
            }
    }
}
