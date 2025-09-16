import Foundation

extension Date {
    private var baseComponents: Set<Calendar.Component> {
        [.year, .month, .day, .weekOfYear, .yearForWeekOfYear]
    }

    func start(of component: Calendar.Component, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents(baseComponents, from: self)
        switch component {
        case .day:
            return calendar.date(from: DateComponents(year: components.year, month: components.month, day: components.day)) ?? self
        case .weekOfYear:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
        case .month:
            return calendar.date(from: DateComponents(year: components.year, month: components.month)) ?? self
        case .quarter:
            let quarter = ((components.month ?? 1) - 1) / 3 + 1
            let month = (quarter - 1) * 3 + 1
            return calendar.date(from: DateComponents(year: components.year, month: month)) ?? self
        case .year:
            return calendar.date(from: DateComponents(year: components.year)) ?? self
        default:
            return self
        }
    }

    func end(of component: Calendar.Component, calendar: Calendar = .current) -> Date {
        switch component {
        case .day:
            return calendar.date(byAdding: .day, value: 1, to: start(of: .day, calendar: calendar))?.addingTimeInterval(-1) ?? self
        case .weekOfYear:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: start(of: .weekOfYear, calendar: calendar))?.addingTimeInterval(-1) ?? self
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: start(of: .month, calendar: calendar))?.addingTimeInterval(-1) ?? self
        case .quarter:
            return calendar.date(byAdding: .month, value: 3, to: start(of: .quarter, calendar: calendar))?.addingTimeInterval(-1) ?? self
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: start(of: .year, calendar: calendar))?.addingTimeInterval(-1) ?? self
        default:
            return self
        }
    }

    func formattedRange(in component: Calendar.Component) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let startDate = start(of: component)
        let endDate = end(of: component)
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
