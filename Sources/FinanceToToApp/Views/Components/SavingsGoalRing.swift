import SwiftUI

struct SavingsGoalRing: View {
    let goal: SavingsGoal

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .foregroundStyle(Color.secondary.opacity(0.2))
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundStyle(Color(hex: goal.colorHex) ?? .green)
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text(String(format: "%0.f%%", goal.progress * 100))
                        .font(.headline)
                    Text(goal.title)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding(4)
            }
            Text(goal.targetAmount.currencyString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 120, height: 140)
        .padding()
        .background(Color.financeBackground)
        .cornerRadius(16)
    }
}
