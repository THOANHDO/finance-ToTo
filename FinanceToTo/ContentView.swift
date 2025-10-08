import SwiftUI

@available(iOS 16.1, *)
struct ContentView: View {
    @EnvironmentObject private var viewModel: ExpenseViewModel
    @EnvironmentObject private var dynamicIslandController: DynamicIslandController
    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header
                progressCard
                expenseList
            }
            .padding()
            .background(LinearGradient(colors: [.mint.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea())
            .navigationTitle("Finance ToTo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense.toggle()
                    }) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .pink)
                            .font(.title2)
                    }
                    .accessibilityIdentifier("addExpenseButton")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium, .large])
            }
            .onReceive(viewModel.$shouldTriggerReminder) { shouldTrigger in
                guard shouldTrigger else { return }
                dynamicIslandController.triggerReminder(for: viewModel.summary)
                viewModel.markReminderDelivered()
            }
            .task {
                await dynamicIslandController.requestAuthorization()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greetingTitle)
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text(viewModel.greetingSubtitle)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Monthly Budget", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                Text(viewModel.summary.budget, format: .currency(code: viewModel.summary.currencyCode))
                    .font(.headline)
            }
            .foregroundColor(.primary)

            ProgressView(value: viewModel.summary.progress)
                .tint(.pink)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .accessibilityIdentifier("budgetProgressView")

            HStack {
                Text("You've spent")
                Text(viewModel.summary.totalSpent, format: .currency(code: viewModel.summary.currencyCode))
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.summary.isOverBudget ? .red : .green)
                Text("this month on joy sparks!")
            }
            .font(.callout)
            .foregroundColor(.secondary)

            Text(viewModel.summary.statusMessage)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(viewModel.summary.isOverBudget ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .animation(.spring(), value: viewModel.summary.isOverBudget)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var expenseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Adventures")
                .font(.title2.bold())
                .foregroundColor(.primary)

            if viewModel.expenses.isEmpty {
                ContentUnavailableView(
                    "No Expenses Yet",
                    systemImage: "star.bubble",
                    description: Text("Tap the + button to log your sparkly spends!")
                )
            } else {
                List {
                    ForEach(viewModel.expenses) { expense in
                        ExpenseRow(expense: expense)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            viewModel.remove(atOffsets: indexSet)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 320)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    if #available(iOS 16.1, *) {
        ContentView()
            .environmentObject(ExpenseViewModel(preview: true))
            .environmentObject(DynamicIslandController())
    } else {
        Text("Dynamic Island requires iOS 16.1+")
    }
}
