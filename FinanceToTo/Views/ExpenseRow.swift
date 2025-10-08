import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(expense.category.color.gradient)
                    .frame(width: 48, height: 48)
                Image(systemName: expense.category.symbol)
                    .font(.title3)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(expense.title)
                    .font(.headline)
                Text(expense.category.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: expense.currencyCode))
                .font(.headline)
                .foregroundColor(expense.isLarge ? .red : .primary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: expense.category.color.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    ExpenseRow(expense: Expense.preview)
        .padding()
        .background(Color(.systemGroupedBackground))
}
