import SwiftUI

struct NetWorthCard: View {
    let snapshot: NetWorthSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(String(localized: "Net Worth"), systemImage: "dollarsign.circle.fill")
                    .font(.headline)
                Spacer()
                Text(snapshot.netWorth.currencyString)
                    .font(.title.bold())
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: "Assets"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(snapshot.totalAssets.currencyString)
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(String(localized: "Debts"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(snapshot.totalDebts.currencyString)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(Color.financeBackground)
        .cornerRadius(16)
    }
}
