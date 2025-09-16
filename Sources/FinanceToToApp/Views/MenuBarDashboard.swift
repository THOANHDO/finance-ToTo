import SwiftUI

struct MenuBarDashboard: View {
    @EnvironmentObject private var financeStore: FinanceDataStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Today's Snapshot"))
                .font(.headline)
            Text(String(localized: "Balance: \(financeStore.netWorth().currencyString)"))
            Divider()
            ForEach(Array(financeStore.transactions.prefix(5))) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
        .padding()
        .frame(width: 320)
    }
}
