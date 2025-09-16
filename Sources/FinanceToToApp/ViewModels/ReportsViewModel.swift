import Foundation
import Combine

@MainActor
final class ReportsViewModel: ObservableObject {
    @Published var period: Calendar.Component = .month {
        didSet { refresh() }
    }
    @Published var trend: [TrendPoint] = []
    @Published var distribution: [CategorySpending] = []

    private var financeStore: FinanceDataStore?
    private var analytics: AnalyticsService?
    private var cancellables = Set<AnyCancellable>()

    func configure(with financeStore: FinanceDataStore) {
        guard self.financeStore !== financeStore else { return }
        self.financeStore = financeStore
        analytics = AnalyticsService(financeStore: financeStore)
        bind()
        refresh()
    }

    private func bind() {
        cancellables.removeAll()
        financeStore?.$transactions
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
    }

    func refresh() {
        guard let financeStore, let analytics else { return }
        let range = Date().start(of: .month)...Date().end(of: .month)
        trend = financeStore.trendAnalysis(period: period, count: 12)
        distribution = analytics.spendingDistribution(for: range)
    }
}
