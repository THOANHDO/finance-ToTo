import Foundation

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    let total: Decimal
    let percentage: Double
}

struct ForecastPoint: Identifiable {
    let id = UUID()
    let date: Date
    let projectedExpense: Decimal
}

@MainActor
final class AnalyticsService {
    private let financeStore: FinanceDataStore

    init(financeStore: FinanceDataStore) {
        self.financeStore = financeStore
    }

    func spendingDistribution(for range: ClosedRange<Date>) -> [CategorySpending] {
        let expenses = financeStore.transactions
            .filter { !$0.isIncome && range.contains($0.date) }
        let total = expenses.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        return TransactionCategory.allCases.compactMap { category in
            let categoryTotal = expenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
            guard categoryTotal > 0 else { return nil }
            let ratio = (categoryTotal as NSDecimalNumber).doubleValue / (total as NSDecimalNumber).doubleValue
            return CategorySpending(category: category, total: categoryTotal, percentage: ratio)
        }
    }

    func forecastSpending(months: Int = 6) -> [ForecastPoint] {
        let calendar = Calendar.current
        let historical = financeStore.trendAnalysis(period: .month, count: months)
        guard !historical.isEmpty else { return [] }
        let averageExpense = historical.map { $0.expenses }.reduce(0, +) / Decimal(historical.count)
        return (1...months).compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: offset, to: .now)?.start(of: .month) else { return nil }
            let growthFactor = pow(1.015, Double(offset))
            let projected = (averageExpense as NSDecimalNumber).doubleValue * growthFactor
            return ForecastPoint(date: date, projectedExpense: Decimal(projected))
        }
    }
}

private func /(lhs: Decimal, rhs: Decimal) -> Decimal {
    let lhsNumber = NSDecimalNumber(decimal: lhs)
    let rhsNumber = NSDecimalNumber(decimal: rhs)
    guard rhsNumber != .zero else { return 0 }
    return lhsNumber.dividing(by: rhsNumber).decimalValue
}
