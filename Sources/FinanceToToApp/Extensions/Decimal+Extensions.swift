import Foundation

extension Decimal {
    var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
}
