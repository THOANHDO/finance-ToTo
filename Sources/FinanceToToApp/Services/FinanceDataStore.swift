import Foundation
import Combine

@MainActor
final class FinanceDataStore: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var budgets: [Budget] = []
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var assets: [Asset] = []
    @Published private(set) var debts: [Debt] = []
    @Published private(set) var savingsGoals: [SavingsGoal] = []
    @Published private(set) var reminders: [PaymentReminder] = []

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager: FileManager
    private let persistenceQueue = DispatchQueue(label: "FinanceDataStore.Persistence")

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load() async {
        do {
            guard fileManager.fileExists(atPath: storageURL.path) else {
                populateSampleData()
                return
            }
            let data = try Data(contentsOf: storageURL)
            let snapshot = try decoder.decode(Snapshot.self, from: data)
            transactions = snapshot.transactions
            budgets = snapshot.budgets
            accounts = snapshot.accounts
            assets = snapshot.assets
            debts = snapshot.debts
            savingsGoals = snapshot.savingsGoals
            reminders = snapshot.reminders
        } catch {
            print("Failed to load data: \(error)")
            populateSampleData()
        }
    }

    func persist() async {
        let snapshot = Snapshot(
            transactions: transactions,
            budgets: budgets,
            accounts: accounts,
            assets: assets,
            debts: debts,
            savingsGoals: savingsGoals,
            reminders: reminders
        )
        await withCheckedContinuation { continuation in
            persistenceQueue.async {
                do {
                    let data = try self.encoder.encode(snapshot)
                    try self.ensureDirectoryExists()
                    try data.write(to: self.storageURL, options: .atomic)
                } catch {
                    print("Failed to persist data: \(error)")
                }
                continuation.resume()
            }
        }
    }

    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
    }

    func updateTransaction(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func deleteTransactions(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
    }

    func addBudget(_ budget: Budget) {
        budgets.append(budget)
    }

    func updateBudget(_ budget: Budget) {
        guard let index = budgets.firstIndex(where: { $0.id == budget.id }) else { return }
        budgets[index] = budget
    }

    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
    }

    func addAccount(_ account: Account) {
        accounts.append(account)
    }

    func updateAccount(_ account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index] = account
    }

    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
    }

    func addAsset(_ asset: Asset) {
        assets.append(asset)
    }

    func updateAsset(_ asset: Asset) {
        guard let index = assets.firstIndex(where: { $0.id == asset.id }) else { return }
        assets[index] = asset
    }

    func deleteAsset(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
    }

    func addDebt(_ debt: Debt) {
        debts.append(debt)
    }

    func updateDebt(_ debt: Debt) {
        guard let index = debts.firstIndex(where: { $0.id == debt.id }) else { return }
        debts[index] = debt
    }

    func deleteDebt(_ debt: Debt) {
        debts.removeAll { $0.id == debt.id }
    }

    func addReminder(_ reminder: PaymentReminder) {
        reminders.append(reminder)
    }

    func updateReminder(_ reminder: PaymentReminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
    }

    func deleteReminder(_ reminder: PaymentReminder) {
        reminders.removeAll { $0.id == reminder.id }
    }

    func addSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.append(goal)
    }

    func updateSavingsGoal(_ goal: SavingsGoal) {
        guard let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        savingsGoals[index] = goal
    }

    func deleteSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll { $0.id == goal.id }
    }

    func totalSpent(in range: ClosedRange<Date>) -> Decimal {
        transactions
            .filter { !$0.isIncome && range.contains($0.date) }
            .map { $0.amount }
            .reduce(0, +)
    }

    func totalIncome(in range: ClosedRange<Date>) -> Decimal {
        transactions
            .filter { $0.isIncome && range.contains($0.date) }
            .map { $0.amount }
            .reduce(0, +)
    }

    func transactions(in category: TransactionCategory, during range: ClosedRange<Date>? = nil) -> [Transaction] {
        transactions.filter { transaction in
            guard transaction.category == category else { return false }
            if let range { return range.contains(transaction.date) }
            return true
        }
    }

    func netWorth() -> Decimal {
        let assetTotal = assets.map { $0.value }.reduce(0, +)
        let debtTotal = debts.map { $0.outstandingBalance }.reduce(0, +)
        return assetTotal - debtTotal
    }

    func approachingBudgets(threshold: Double = 0.9) -> [BudgetAlert] {
        budgets.compactMap { budget in
            let periodRange = budget.period.dateRange(starting: budget.startDate)
            let spent = transactions(in: budget.category, during: periodRange)
                .filter { !$0.isIncome }
                .map { $0.amount }
                .reduce(0, +)
            guard budget.limit > 0 else { return nil }
            let ratio = (spent as NSDecimalNumber).doubleValue / (budget.limit as NSDecimalNumber).doubleValue
            guard ratio >= threshold else { return nil }
            return BudgetAlert(budget: budget, spent: spent, ratio: ratio)
        }
    }

    func budgetProgress(for budget: Budget) -> BudgetProgress {
        let range = budget.period.dateRange(starting: budget.startDate)
        let spent = transactions
            .filter { !$0.isIncome && $0.category == budget.category && range.contains($0.date) }
            .map { $0.amount }
            .reduce(0, +)
        let ratio = budget.limit > 0 ? (spent as NSDecimalNumber).doubleValue / (budget.limit as NSDecimalNumber).doubleValue : 0
        let remaining = max(budget.limit - spent, 0)
        return BudgetProgress(budget: budget, spent: spent, remaining: remaining, ratio: ratio)
    }

    func trendAnalysis(period: Calendar.Component, count: Int = 6) -> [TrendPoint] {
        let calendar = Calendar.current
        return (0..<count).compactMap { offset in
            guard let periodStart = calendar.date(byAdding: period, value: -offset, to: .now)?.start(of: period) else { return nil }
            let periodEnd = periodStart.end(of: period)
            let range = periodStart...periodEnd
            let income = totalIncome(in: range)
            let expenses = totalSpent(in: range)
            let net = income - expenses
            return TrendPoint(periodStart: periodStart, income: income, expenses: expenses, net: net)
        }.sorted(by: { $0.periodStart < $1.periodStart })
    }
}

private extension FinanceDataStore {
    struct Snapshot: Codable {
        var transactions: [Transaction]
        var budgets: [Budget]
        var accounts: [Account]
        var assets: [Asset]
        var debts: [Debt]
        var savingsGoals: [SavingsGoal]
        var reminders: [PaymentReminder]
    }

    var storageURL: URL {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return directory.appendingPathComponent("FinanceToTo", isDirectory: true).appendingPathComponent("finance-data.json")
    }

    func ensureDirectoryExists() throws {
        let directory = storageURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    func populateSampleData() {
        let sample = FinanceSampleData.generate()
        transactions = sample.transactions
        budgets = sample.budgets
        accounts = sample.accounts
        assets = sample.assets
        debts = sample.debts
        savingsGoals = sample.savingsGoals
        reminders = sample.reminders
    }
}

struct BudgetAlert: Identifiable {
    let id = UUID()
    let budget: Budget
    let spent: Decimal
    let ratio: Double
}

struct BudgetProgress: Identifiable {
    let id = UUID()
    let budget: Budget
    let spent: Decimal
    let remaining: Decimal
    let ratio: Double
}

struct TrendPoint: Identifiable {
    let id = UUID()
    let periodStart: Date
    let income: Decimal
    let expenses: Decimal
    let net: Decimal
}

private extension BudgetPeriod {
    func dateRange(starting startDate: Date) -> ClosedRange<Date> {
        let start = startDate.start(of: calendarComponent)
        let end = start.end(of: calendarComponent)
        return start...end
    }
}

private struct FinanceSampleData {
    let transactions: [Transaction]
    let budgets: [Budget]
    let accounts: [Account]
    let assets: [Asset]
    let debts: [Debt]
    let savingsGoals: [SavingsGoal]
    let reminders: [PaymentReminder]

    static func generate() -> FinanceSampleData {
        let groceries = Transaction(
            amount: 82.45,
            category: .foodAndDining,
            merchant: "Whole Foods",
            notes: "Weekly groceries"
        )
        let salary = Transaction(
            amount: 3400,
            category: .income,
            merchant: "ACME Corp",
            notes: "Monthly salary",
            isIncome: true
        )
        let transport = Transaction(
            amount: 42.10,
            category: .transportation,
            merchant: "Lyft"
        )
        let subscription = Transaction(
            amount: 12.99,
            category: .subscription,
            merchant: "Spotify"
        )

        let budgets = [
            Budget(category: .foodAndDining, limit: 500, period: .monthly),
            Budget(category: .transportation, limit: 200, period: .monthly),
            Budget(category: .entertainment, limit: 150, period: .monthly)
        ]

        let accounts = [
            Account(name: "Everyday Checking", balance: 2400, type: .checking, institution: "ToTo Bank"),
            Account(name: "High-Yield Savings", balance: 9200, type: .savings, institution: "ToTo Bank")
        ]

        let assets = [
            Asset(name: "Emergency Fund", value: 5000, type: .cash),
            Asset(name: "Index Fund", value: 12000, type: .investment)
        ]

        let debts = [
            Debt(name: "City Bank Visa", outstandingBalance: 824, interestRate: 19.99, minimumPayment: 50, dueDate: .now.addingTimeInterval(60 * 60 * 24 * 8), type: .creditCard),
            Debt(name: "Home Mortgage", outstandingBalance: 184_000, interestRate: 3.25, minimumPayment: 1200, dueDate: .now.addingTimeInterval(60 * 60 * 24 * 15), type: .mortgage)
        ]

        let goals = [
            SavingsGoal(title: "Hawaii Vacation", targetAmount: 5000, currentAmount: 1800, dueDate: Calendar.current.date(byAdding: .month, value: 9, to: .now), colorHex: "00A8E8"),
            SavingsGoal(title: "Emergency Fund", targetAmount: 10000, currentAmount: 6500, isAutomated: true)
        ]

        let reminders = [
            PaymentReminder(title: "Mortgage Payment", dueDate: .now.addingTimeInterval(60 * 60 * 24 * 5), amount: 1200, isRecurring: true, linkedDebt: debts[1]),
            PaymentReminder(title: "City Bank Visa", dueDate: .now.addingTimeInterval(60 * 60 * 24 * 3), amount: 50, isRecurring: true, linkedDebt: debts[0])
        ]

        return FinanceSampleData(
            transactions: [groceries, salary, transport, subscription],
            budgets: budgets,
            accounts: accounts,
            assets: assets,
            debts: debts,
            savingsGoals: goals,
            reminders: reminders
        )
    }
}
