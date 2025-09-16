import Foundation

struct PaymentReminder: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var dueDate: Date
    var amount: Decimal
    var isRecurring: Bool
    var notes: String
    var linkedDebt: Debt?

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        amount: Decimal,
        isRecurring: Bool = false,
        notes: String = "",
        linkedDebt: Debt? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.amount = amount
        self.isRecurring = isRecurring
        self.notes = notes
        self.linkedDebt = linkedDebt
    }
}
