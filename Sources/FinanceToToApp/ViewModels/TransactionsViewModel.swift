import Foundation
import Combine

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedCategory: TransactionCategory?

    private var financeStore: FinanceDataStore?
    private var cancellables = Set<AnyCancellable>()

    init() {}

    func configure(with financeStore: FinanceDataStore) {
        guard self.financeStore !== financeStore else { return }
        self.financeStore = financeStore
        bind()
    }

    private func bind() {
        cancellables.removeAll()
        guard let financeStore else { return }
        financeStore.$transactions
            .combineLatest($searchText, $selectedCategory)
            .map { transactions, searchText, category in
                Self.filter(transactions: transactions, searchText: searchText, category: category)
            }
            .assign(to: &$filteredTransactions)
    }

    func delete(at offsets: IndexSet) {
        financeStore?.deleteTransactions(at: offsets)
    }

    func add(_ transaction: Transaction) {
        financeStore?.addTransaction(transaction)
    }

    private static func filter(transactions: [Transaction], searchText: String, category: TransactionCategory?) -> [Transaction] {
        transactions.filter { transaction in
            let matchesCategory = category.map { $0 == transaction.category } ?? true
            guard matchesCategory else { return false }
            if searchText.isEmpty { return true }
            let normalized = searchText.lowercased()
            return transaction.merchant.lowercased().contains(normalized) ||
                transaction.notes.lowercased().contains(normalized)
        }
    }
}
