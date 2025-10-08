import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct ExpenseActivityAttributes: ActivityAttributes {
    public typealias ContentState = DynamicIslandState

    struct DynamicIslandState: Codable, Hashable {
        var totalSpent: Double
        var remainingBudget: Double
        var isOverBudget: Bool
    }

    var budget: Double
    var currencyCode: String
}
