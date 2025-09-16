import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.2))
                    .frame(width: 42, height: 42)
                Image(systemName: transaction.category.icon)
                    .foregroundColor(transaction.category.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchant)
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.signedAmount.currencyString)
                .font(.headline)
                .foregroundColor(transaction.isIncome ? .green : .primary)
        }
        .padding(.vertical, 8)
    }
}
