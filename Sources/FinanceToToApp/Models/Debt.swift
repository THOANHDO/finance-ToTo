import Foundation

struct Debt: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var outstandingBalance: Decimal
    var interestRate: Decimal
    var minimumPayment: Decimal
    var dueDate: Date
    var type: DebtType

    init(
        id: UUID = UUID(),
        name: String,
        outstandingBalance: Decimal,
        interestRate: Decimal,
        minimumPayment: Decimal,
        dueDate: Date,
        type: DebtType
    ) {
        self.id = id
        self.name = name
        self.outstandingBalance = outstandingBalance
        self.interestRate = interestRate
        self.minimumPayment = minimumPayment
        self.dueDate = dueDate
        self.type = type
    }
}

enum DebtType: String, CaseIterable, Codable, Identifiable {
    case creditCard
    case mortgage
    case studentLoan
    case personalLoan
    case autoLoan
    case other

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .creditCard: return String(localized: "Credit Card")
        case .mortgage: return String(localized: "Mortgage")
        case .studentLoan: return String(localized: "Student Loan")
        case .personalLoan: return String(localized: "Personal Loan")
        case .autoLoan: return String(localized: "Auto Loan")
        case .other: return String(localized: "Other")
        }
    }
}
