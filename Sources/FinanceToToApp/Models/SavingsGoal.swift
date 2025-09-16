import Foundation

struct SavingsGoal: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var dueDate: Date?
    var colorHex: String
    var isAutomated: Bool

    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Decimal,
        currentAmount: Decimal,
        dueDate: Date? = nil,
        colorHex: String = "00B894",
        isAutomated: Bool = false
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.dueDate = dueDate
        self.colorHex = colorHex
        self.isAutomated = isAutomated
    }
}

extension SavingsGoal {
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        let percentage = (currentAmount as NSDecimalNumber).doubleValue / (targetAmount as NSDecimalNumber).doubleValue
        return min(max(percentage, 0), 1)
    }
}
