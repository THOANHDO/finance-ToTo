import Foundation
import SwiftUI

enum TransactionCategory: String, CaseIterable, Codable, Identifiable {
    case foodAndDining = "Food & Dining"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case education = "Education"
    case savings = "Savings"
    case income = "Income"
    case investment = "Investment"
    case subscription = "Subscription"
    case other = "Other"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .foodAndDining: return .orange
        case .transportation: return .blue
        case .shopping: return .pink
        case .entertainment: return .purple
        case .utilities: return .teal
        case .healthcare: return .red
        case .education: return .indigo
        case .savings: return .green
        case .income: return .mint
        case .investment: return .cyan
        case .subscription: return .brown
        case .other: return .gray
        }
    }

    var icon: String {
        switch self {
        case .foodAndDining: return "fork.knife"
        case .transportation: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .utilities: return "bolt.fill"
        case .healthcare: return "cross.fill"
        case .education: return "book.fill"
        case .savings: return "banknote.fill"
        case .income: return "arrow.down.circle.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .subscription: return "creditcard.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
