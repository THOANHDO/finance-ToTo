import SwiftUI

struct BudgetProgressRing: View {
    let progress: BudgetProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(progress.budget.category.rawValue)
                    .font(.headline)
                Spacer()
                Text(progress.budget.limit.currencyString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 12)
                        .foregroundStyle(Color.secondary.opacity(0.2))
                    Circle()
                        .trim(from: 0, to: min(progress.ratio, 1))
                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .foregroundStyle(progress.ratio > 1 ? Color.red : Color.green)
                        .rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(Int(min(progress.ratio, 1) * 100))%")
                            .font(.headline)
                        Text(String(localized: "Used"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Spent: \(progress.spent.currencyString)"))
                        .font(.subheadline)
                    Text(String(localized: "Remaining: \(progress.remaining.currencyString)"))
                        .font(.caption)
                        .foregroundStyle(progress.remaining > 0 ? .secondary : .red)
                }
            }
        }
        .padding()
        .background(Color.financeBackground)
        .cornerRadius(16)
    }
}
