import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var approachingBudgets: [BudgetAlert] = []
    @Published var trend: [TrendPoint] = []
    @Published var netWorthSnapshot: NetWorthSnapshot = NetWorthSnapshot(date: .now, totalAssets: 0, totalDebts: 0)
    @Published var forecast: [ForecastPoint] = []
    @Published var quickActions: [QuickAction] = QuickAction.defaultActions

    private var financeStore: FinanceDataStore?
    private var analytics: AnalyticsService?
    private var netWorthService: NetWorthService?
    private var cancellables = Set<AnyCancellable>()

    func configure(with financeStore: FinanceDataStore) {
        guard self.financeStore !== financeStore else { return }
        self.financeStore = financeStore
        analytics = AnalyticsService(financeStore: financeStore)
        netWorthService = NetWorthService(financeStore: financeStore)
        bind()
        refresh()
    }

    private func bind() {
        cancellables.removeAll()
        guard let financeStore else { return }

        financeStore.$transactions
            .combineLatest(financeStore.$budgets)
            .sink { [weak self] _, _ in
                self?.refresh()
            }
            .store(in: &cancellables)

        financeStore.$assets
            .combineLatest(financeStore.$debts)
            .sink { [weak self] _, _ in
                self?.refreshNetWorth()
            }
            .store(in: &cancellables)
    }

    func refresh() {
        guard let financeStore else { return }
        approachingBudgets = financeStore.approachingBudgets()
        trend = financeStore.trendAnalysis(period: .month, count: 6)
        forecast = analytics?.forecastSpending() ?? []
        refreshNetWorth()
    }

    private func refreshNetWorth() {
        netWorthSnapshot = netWorthService?.currentSnapshot() ?? NetWorthSnapshot(date: .now, totalAssets: 0, totalDebts: 0)
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void

    static var defaultActions: [QuickAction] {
        [
            QuickAction(title: String(localized: "Scan Receipt"), icon: "doc.viewfinder", action: {}),
            QuickAction(title: String(localized: "Add Expense"), icon: "plus.circle.fill", action: {}),
            QuickAction(title: String(localized: "New Savings Goal"), icon: "target", action: {})
        ]
    }
}
