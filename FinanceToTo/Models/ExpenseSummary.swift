import Foundation

struct ExpenseSummary: Codable {
    var budget: Double
    var totalSpent: Double
    var currencyCode: String

    var progress: Double {
        guard budget > 0 else { return 0 }
        return min(totalSpent / budget, 1.2)
    }

    var remaining: Double {
        max(budget - totalSpent, 0)
    }

    var isOverBudget: Bool {
        totalSpent > budget
    }

    var statusMessage: String {
        if isOverBudget {
            return "Whoa! You're on a glitter spree. Let's slow the sparkle." + reminderHint
        } else if progress > 0.8 {
            return "Almost at your budget. Maybe a cozy night in?" + reminderHint
        } else if progress > 0.4 {
            return "You're balancing joy and savings like a pro!"
        } else {
            return "Plenty of sparkle room left. Enjoy mindfully!"
        }
    }

    private var reminderHint: String {
        "\nDynamic Island will nudge you if things get too twinkly."
    }
}

extension ExpenseSummary {
    static let preview = ExpenseSummary(budget: 500, totalSpent: 320, currencyCode: "USD")
}
