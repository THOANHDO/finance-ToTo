import Foundation

struct Budget: Identifiable, Codable, Hashable {
    let id: UUID
    var category: TransactionCategory
    var limit: Decimal
    var period: BudgetPeriod
    var startDate: Date
    var notificationsEnabled: Bool

    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        limit: Decimal,
        period: BudgetPeriod,
        startDate: Date = .now,
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.period = period
        self.startDate = startDate
        self.notificationsEnabled = notificationsEnabled
    }
}

enum BudgetPeriod: String, CaseIterable, Codable, Identifiable {
    case weekly
    case monthly
    case quarterly
    case yearly

    var id: String { rawValue }

    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .quarterly: return .quarter
        case .yearly: return .year
        }
    }

    var localizedTitle: String {
        switch self {
        case .weekly: return String(localized: "Weekly")
        case .monthly: return String(localized: "Monthly")
        case .quarterly: return String(localized: "Quarterly")
        case .yearly: return String(localized: "Yearly")
        }
    }
}
