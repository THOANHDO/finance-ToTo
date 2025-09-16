import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        List {
            ForEach(viewModel.filteredTransactions) { transaction in
                TransactionRow(transaction: transaction)
            }
            .onDelete(perform: viewModel.delete)
        }
        .searchable(text: $viewModel.searchText, prompt: Text(String(localized: "Search transactions")))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddTransactionView()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            NavigationStack {
                Form {
                    Picker(String(localized: "Category"), selection: $viewModel.selectedCategory) {
                        Text(String(localized: "All")).tag(TransactionCategory?.none)
                        ForEach(TransactionCategory.allCases) { category in
                            Text(category.rawValue).tag(TransactionCategory?.some(category))
                        }
                    }
                }
                .navigationTitle(String(localized: "Filters"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Clear")) {
                            viewModel.selectedCategory = nil
                            showingFilterSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Done")) {
                            showingFilterSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
        .onAppear {
            viewModel.configure(with: financeStore)
        }
        .platformNavigationTitle(String(localized: "Transactions"))
    }
}
