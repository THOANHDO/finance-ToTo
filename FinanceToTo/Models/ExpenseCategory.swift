import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case treats
    case travel
    case essentials
    case wellness
    case learning

    var id: String { rawValue }

    var title: String {
        switch self {
        case .treats: return "Treat Yourself"
        case .travel: return "Tiny Trips"
        case .essentials: return "Essentials"
        case .wellness: return "Wellness"
        case .learning: return "Curious Mind"
        }
    }

    var symbol: String {
        switch self {
        case .treats: return "cup.and.saucer.fill"
        case .travel: return "airplane"
        case .essentials: return "cart.fill"
        case .wellness: return "heart.circle.fill"
        case .learning: return "book.fill"
        }
    }

    var color: Color {
        switch self {
        case .treats: return .pink
        case .travel: return .blue
        case .essentials: return .purple
        case .wellness: return .green
        case .learning: return .orange
        }
    }
}
