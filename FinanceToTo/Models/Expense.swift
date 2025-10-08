import Foundation
import SwiftUI

struct Expense: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var category: ExpenseCategory
    var amount: Double
    var date: Date
    var currencyCode: String

    init(id: UUID = UUID(), title: String, category: ExpenseCategory, amount: Double, date: Date, currencyCode: String = Locale.current.currency?.identifier ?? "USD") {
        self.id = id
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
        self.currencyCode = currencyCode
    }

    var isLarge: Bool {
        amount >= 50
    }
}

extension Expense {
    static let preview = Expense(title: "Matcha Run", category: .treats, amount: 14, date: .now)
}
