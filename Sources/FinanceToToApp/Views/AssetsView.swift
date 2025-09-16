import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct AssetsView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = AssetsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox(String(localized: "Net Worth")) {
                    NetWorthCard(snapshot: viewModel.currentSnapshot)
                }

                GroupBox(String(localized: "Net Worth History")) {
                    #if canImport(Charts)
                    Chart(viewModel.netWorthHistory) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Net Worth", point.netWorth.doubleValue)
                        )
                        .symbol(.circle)
                    }
                    .frame(height: 220)
                    #else
                    Text(String(localized: "Charts unavailable"))
                        .foregroundStyle(.secondary)
                    #endif
                }

                GroupBox(String(localized: "Accounts")) {
                    ForEach(viewModel.accounts) { account in
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            Text(account.balance.currencyString)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }

                GroupBox(String(localized: "Assets")) {
                    ForEach(viewModel.assets) { asset in
                        VStack(alignment: .leading) {
                            Text(asset.name)
                                .font(.headline)
                            Text(asset.value.currencyString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                GroupBox(String(localized: "Debts")) {
                    ForEach(viewModel.debts) { debt in
                        VStack(alignment: .leading) {
                            Text(debt.name)
                                .font(.headline)
                            Text(debt.outstandingBalance.currencyString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(String(localized: "Due: \(debt.dueDate.formatted(date: .abbreviated, time: .omitted))"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.configure(with: financeStore)
        }
        .platformNavigationTitle(String(localized: "Assets"))
    }
}
