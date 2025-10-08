import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: ExpenseViewModel

    @State private var title: String = ""
    @State private var category: ExpenseCategory = .treats
    @State private var amount: Double = 0
    @State private var date: Date = .now

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("What did you enjoy?", text: $title)
                        .textInputAutocapitalization(.sentences)
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.title, systemImage: category.symbol)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Cost") {
                    TextField("Amount", value: $amount, format: .currency(code: viewModel.summary.currencyCode))
                        .keyboardType(.decimalPad)
                    DatePicker("When did it happen?", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Mood Boost") {
                    Text(viewModel.randomAffirmation)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.orange.opacity(0.1))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.orange.opacity(0.08))
            .navigationTitle("Log Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation(.spring()) {
                            viewModel.addExpense(title: title, category: category, amount: amount, date: date)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSaveExpense(title: title, amount: amount))
                }
            }
        }
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(ExpenseViewModel(preview: true))
}
