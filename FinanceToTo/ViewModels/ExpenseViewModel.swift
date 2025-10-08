import Foundation
import Combine

@MainActor
final class ExpenseViewModel: ObservableObject {
    @Published private(set) var expenses: [Expense] = []
    @Published private(set) var summary: ExpenseSummary
    @Published var shouldTriggerReminder: Bool = false

    private let storage: any ExpenseStorage
    private let reminderService: any ReminderService
    private var cancellables = Set<AnyCancellable>()

    init(storage: any ExpenseStorage = FileExpenseStorage(), reminderService: any ReminderService = BudgetReminderService(), preview: Bool = false) {
        if preview {
            let previewStorage = InMemoryExpenseStorage()
            let previewReminder = PreviewReminderService()
            self.storage = previewStorage
            self.reminderService = previewReminder

            let sampleExpenses = previewStorage.loadExpenses()
            expenses = sampleExpenses
            summary = Self.makeSummary(from: sampleExpenses, budget: previewReminder.currentBudget)
        } else {
            self.storage = storage
            self.reminderService = reminderService

            let stored = storage.loadExpenses()
            expenses = stored
            summary = Self.makeSummary(from: stored, budget: reminderService.currentBudget)
        }

        setupSubscriptions()
    }

    var greetingTitle: String {
        "Hello, Sunshine!"
    }

    var greetingSubtitle: String {
        "Let's keep your sparkle fund smiling."
    }

    var randomAffirmation: String {
        [
            "Every coin you keep is a future adventure!",
            "You deserve joy and stability—go you!",
            "Budgeting is self-care with glitter.",
            "Tiny mindful choices grow mighty dreams."
        ].randomElement() ?? "You're doing amazing!"
    }

    func canSaveExpense(title: String, amount: Double) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && amount > 0
    }

    func addExpense(title: String, category: ExpenseCategory, amount: Double, date: Date) {
        let newExpense = Expense(title: title, category: category, amount: amount, date: date, currencyCode: summary.currencyCode)
        expenses.insert(newExpense, at: 0)
        storage.save(expenses: expenses)
        updateSummary()
    }

    func remove(atOffsets offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        storage.save(expenses: expenses)
        updateSummary()
    }

    func markReminderDelivered() {
        shouldTriggerReminder = false
    }

    private func updateSummary() {
        summary = Self.makeSummary(from: expenses, budget: reminderService.currentBudget)
        evaluateReminder()
    }

    private func evaluateReminder() {
        shouldTriggerReminder = summary.isOverBudget || summary.progress > 0.85
        if shouldTriggerReminder {
            reminderService.scheduleReminder(for: summary)
        }
    }

    private func setupSubscriptions() {
        reminderService.budgetPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newBudget in
                guard let self else { return }
                summary = Self.makeSummary(from: expenses, budget: newBudget)
                evaluateReminder()
            }
            .store(in: &cancellables)
    }

    private static func makeSummary(from expenses: [Expense], budget: Double) -> ExpenseSummary {
        let total = expenses.reduce(0) { $0 + $1.amount }
        return ExpenseSummary(budget: budget, totalSpent: total, currencyCode: Locale.current.currency?.identifier ?? "USD")
    }
}
