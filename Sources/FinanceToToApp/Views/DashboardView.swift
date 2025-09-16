import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                quickActionsSection
                budgetAlertsSection
                trendSection
                forecastSection
                savingsGoalsSection
                remindersSection
            }
            .padding()
        }
        .background(Color.financeBackground.opacity(0.4).ignoresSafeArea())
        .onAppear {
            viewModel.configure(with: financeStore)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Financial Overview"))
                .font(.largeTitle.bold())
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                SummaryCard(
                    title: String(localized: "Income (30d)"),
                    value: financeStore.totalIncome(in: Date().addingTimeInterval(-30 * 24 * 3600)...Date()).currencyString,
                    subtitle: nil,
                    systemImage: "arrow.down.circle.fill"
                )
                SummaryCard(
                    title: String(localized: "Expenses (30d)"),
                    value: financeStore.totalSpent(in: Date().addingTimeInterval(-30 * 24 * 3600)...Date()).currencyString,
                    subtitle: nil,
                    systemImage: "arrow.up.circle.fill",
                    gradient: LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                SummaryCard(
                    title: String(localized: "Net Worth"),
                    value: viewModel.netWorthSnapshot.netWorth.currencyString,
                    subtitle: nil,
                    systemImage: "chart.line.uptrend.xyaxis",
                    gradient: LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                SummaryCard(
                    title: String(localized: "Active Budgets"),
                    value: "\(financeStore.budgets.count)",
                    subtitle: nil,
                    systemImage: "target",
                    gradient: LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Quick Actions"))
                .font(.title3.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.quickActions) { action in
                        QuickActionButton(action: action)
                    }
                }
            }
        }
    }

    private var budgetAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.approachingBudgets.isEmpty {
                EmptyView()
            } else {
                Text(String(localized: "Budget Alerts"))
                    .font(.title3.bold())
                ForEach(viewModel.approachingBudgets) { alert in
                    BudgetProgressRing(progress: financeStore.budgetProgress(for: alert.budget))
                }
            }
        }
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Cashflow Trend"))
                .font(.title3.bold())
            TrendChartView(points: viewModel.trend)
                .frame(height: 220)
        }
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Spending Forecast"))
                .font(.title3.bold())
            if viewModel.forecast.isEmpty {
                Text(String(localized: "Not enough data to forecast yet."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.forecast) { point in
                    HStack {
                        Text(point.date.formatted(.dateTime.month(.wide)))
                        Spacer()
                        Text(point.projectedExpense.currencyString)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var savingsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Savings Goals"))
                .font(.title3.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(financeStore.savingsGoals) { goal in
                        SavingsGoalRing(goal: goal)
                    }
                }
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Upcoming Payments"))
                .font(.title3.bold())
            PaymentReminderList(reminders: financeStore.reminders)
        }
    }
}
