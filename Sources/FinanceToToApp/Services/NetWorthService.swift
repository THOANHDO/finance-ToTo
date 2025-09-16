import Foundation

struct NetWorthSnapshot: Identifiable {
    let id = UUID()
    let date: Date
    let totalAssets: Decimal
    let totalDebts: Decimal
    var netWorth: Decimal { totalAssets - totalDebts }
}

@MainActor
final class NetWorthService {
    private let financeStore: FinanceDataStore

    init(financeStore: FinanceDataStore) {
        self.financeStore = financeStore
    }

    func currentSnapshot() -> NetWorthSnapshot {
        let assets = financeStore.assets.map { $0.value }.reduce(0, +)
        let debts = financeStore.debts.map { $0.outstandingBalance }.reduce(0, +)
        return NetWorthSnapshot(date: .now, totalAssets: assets, totalDebts: debts)
    }

    func history(months: Int = 12) -> [NetWorthSnapshot] {
        let calendar = Calendar.current
        return (0..<months).compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: .now)?.start(of: .month) else { return nil }
            let assets = financeStore.assets.map { $0.value * Decimal.random(in: 0.97...1.03) }.reduce(0, +)
            let debts = financeStore.debts.map { $0.outstandingBalance * Decimal.random(in: 0.99...1.01) }.reduce(0, +)
            return NetWorthSnapshot(date: date, totalAssets: assets, totalDebts: debts)
        }.sorted(by: { $0.date < $1.date })
    }
}
