import SwiftUI

struct BudgetView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddBudget = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker(String(localized: "Period"), selection: $viewModel.selectedPeriod) {
                    ForEach(BudgetPeriod.allCases) { period in
                        Text(period.localizedTitle).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(viewModel.budgets) { progress in
                    BudgetProgressRing(progress: progress)
                }

                if viewModel.budgets.isEmpty {
                    Text(String(localized: "No budgets yet. Tap + to add one."))
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddBudget = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetSheet(onSave: { category, limit, period in
                viewModel.addBudget(category: category, limit: limit, period: period)
                showingAddBudget = false
            }, onCancel: {
                showingAddBudget = false
            })
        }
        .onAppear {
            viewModel.configure(with: financeStore)
        }
        .platformNavigationTitle(String(localized: "Budget"))
    }
}

private struct AddBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var category: TransactionCategory = .foodAndDining
    @State private var limit: Decimal = 0
    @State private var period: BudgetPeriod = .monthly
    let onSave: (TransactionCategory, Decimal, BudgetPeriod) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Picker(String(localized: "Category"), selection: $category) {
                    ForEach(TransactionCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                TextField(String(localized: "Limit"), value: $limit, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                Picker(String(localized: "Period"), selection: $period) {
                    ForEach(BudgetPeriod.allCases) { period in
                        Text(period.localizedTitle).tag(period)
                    }
                }
            }
            .navigationTitle(String(localized: "New Budget"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        onSave(category, limit, period)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.4), .medium])
    }
}
