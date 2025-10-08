import Foundation
import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    var amount: Double
    var note: String
    var date: Date
}

struct BudgetCategory: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var limit: Double
    var expenses: [Expense] = []

    var spent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1)
    }

    var remaining: Double {
        max(limit - spent, 0)
    }

    var friendlyLimitDescription: String {
        "Mức giới hạn: \(limit, format: .currency(code: Locale.current.currency?.identifier ?? "VND"))"
    }
}

final class BudgetViewModel: ObservableObject {
    @Published var categories: [BudgetCategory]
    @Published var lastReminder: FriendlyReminderMessage?
    @Published var activeCategory: BudgetCategory?

    let userName: String
    private let speaker = FriendlySpeaker()

    init(userName: String = "ToTo") {
        self.userName = userName
        self.categories = BudgetViewModel.defaultCategories
    }

    func prepareAudioSession() {
        speaker.prepare()
    }

    func addExpense(amount: Double, note: String, date: Date = .now, to category: BudgetCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        let expense = Expense(amount: amount, note: note, date: date)
        categories[index].expenses.insert(expense, at: 0)
        let updatedCategory = categories[index]
        let reminder = FriendlyReminder.message(for: updatedCategory, newExpense: amount, userName: userName)
        lastReminder = reminder
        speaker.speak(reminder.voiceLine)

        if #available(iOS 16.1, *) {
            LiveActivityBridge.shared.startOrUpdate(with: updatedCategory, reminder: reminder, userName: userName)
        }
    }
}

private extension BudgetViewModel {
    static var defaultCategories: [BudgetCategory] {
        [
            BudgetCategory(
                name: "Ăn uống",
                icon: "fork.knife",
                color: Color.pink,
                limit: 1_500_000,
                expenses: [
                    Expense(amount: 120_000, note: "Cà phê sáng", date: .now.addingTimeInterval(-7200)),
                    Expense(amount: 85_000, note: "Bánh mì kẹp", date: .now.addingTimeInterval(-36_000))
                ]
            ),
            BudgetCategory(
                name: "Di chuyển",
                icon: "car.fill",
                color: Color.blue,
                limit: 800_000,
                expenses: [
                    Expense(amount: 150_000, note: "Grab đi làm", date: .now.addingTimeInterval(-18_000))
                ]
            ),
            BudgetCategory(
                name: "Giải trí",
                icon: "sparkles",
                color: Color.purple,
                limit: 600_000,
                expenses: [
                    Expense(amount: 220_000, note: "Rạp phim cuối tuần", date: .now.addingTimeInterval(-200_000))
                ]
            )
        ]
    }
}
