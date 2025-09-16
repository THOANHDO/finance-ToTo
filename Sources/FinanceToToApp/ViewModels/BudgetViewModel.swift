import Foundation
import Combine

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published var budgets: [BudgetProgress] = []
    @Published var selectedPeriod: BudgetPeriod = .monthly {
        didSet { refresh() }
    }

    private var financeStore: FinanceDataStore?
    private var cancellables = Set<AnyCancellable>()

    func configure(with financeStore: FinanceDataStore) {
        guard self.financeStore !== financeStore else { return }
        self.financeStore = financeStore
        bind()
        refresh()
    }

    private func bind() {
        cancellables.removeAll()
        guard let financeStore else { return }
        financeStore.$budgets
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
        financeStore.$transactions
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    func refresh() {
        guard let financeStore else { return }
        budgets = financeStore.budgets
            .filter { $0.period == selectedPeriod }
            .map { financeStore.budgetProgress(for: $0) }
    }

    func addBudget(category: TransactionCategory, limit: Decimal, period: BudgetPeriod) {
        let budget = Budget(category: category, limit: limit, period: period)
        financeStore?.addBudget(budget)
        refresh()
    }

    func deleteBudget(_ budget: Budget) {
        financeStore?.deleteBudget(budget)
        refresh()
    }
}
