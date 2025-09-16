import Foundation
import CoreLocation

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var amount: Decimal
    var category: TransactionCategory
    var merchant: String
    var notes: String
    var receipt: Receipt?
    var location: CLLocationCoordinate2D?
    var isIncome: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        amount: Decimal,
        category: TransactionCategory,
        merchant: String,
        notes: String = "",
        receipt: Receipt? = nil,
        location: CLLocationCoordinate2D? = nil,
        isIncome: Bool = false
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.category = category
        self.merchant = merchant
        self.notes = notes
        self.receipt = receipt
        self.location = location
        self.isIncome = isIncome
    }
}

extension Transaction {
    var signedAmount: Decimal { isIncome ? amount : -amount }
}
