import Foundation

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var balance: Decimal
    var type: AccountType
    var institution: String
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal,
        type: AccountType,
        institution: String,
        lastUpdated: Date = .now
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.type = type
        self.institution = institution
        self.lastUpdated = lastUpdated
    }
}

enum AccountType: String, CaseIterable, Codable, Identifiable {
    case cash
    case checking
    case savings
    case investment
    case retirement
    case creditCard
    case loan

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .cash: return String(localized: "Cash")
        case .checking: return String(localized: "Checking")
        case .savings: return String(localized: "Savings")
        case .investment: return String(localized: "Investment")
        case .retirement: return String(localized: "Retirement")
        case .creditCard: return String(localized: "Credit Card")
        case .loan: return String(localized: "Loan")
        }
    }
}
