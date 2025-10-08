import WidgetKit
import SwiftUI
import ActivityKit

struct FinanceToToWidgetEntryView: View {
    let context: ActivityViewContext<ExpenseActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(context.state.isOverBudget ? "Over Budget!" : "Keep Gliding ✨")
                .font(.headline)
                .foregroundColor(context.state.isOverBudget ? .red : .white)
            Text("Spent: \(context.state.totalSpent, format: .currency(code: context.attributes.currencyCode))")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Text("Left: \(context.state.remainingBudget, format: .currency(code: context.attributes.currencyCode))")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            ProgressView(value: min(context.state.totalSpent / context.attributes.budget, 1))
                .tint(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(context.state.isOverBudget ? Color.red.gradient : Color.blue.gradient)
    }
}

@available(iOS 16.1, *)
@main
struct FinanceToToWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExpenseActivityAttributes.self) { context in
            FinanceToToWidgetEntryView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Budget: \(context.attributes.budget, format: .currency(code: context.attributes.currencyCode))")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Spent")
                            .font(.caption)
                        Text(context.state.totalSpent, format: .currency(code: context.attributes.currencyCode))
                            .font(.headline)
                            .foregroundColor(context.state.isOverBudget ? .yellow : .white)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(context.state.isOverBudget ? "Time to pause the party!" : "You're glowing on track.")
                            .font(.subheadline)
                        ProgressView(value: min(context.state.totalSpent / context.attributes.budget, 1))
                            .progressViewStyle(.linear)
                            .tint(context.state.isOverBudget ? .yellow : .mint)
                    }
                    .foregroundColor(.white)
                }
            } compactLeading: {
                Image(systemName: context.state.isOverBudget ? "exclamationmark.triangle.fill" : "sparkles")
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(context.state.totalSpent, format: .currency(code: context.attributes.currencyCode))
                    .font(.caption2)
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: context.state.isOverBudget ? "flame.fill" : "leaf.fill")
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}

#Preview("Dynamic Island") {
    if #available(iOS 16.1, *) {
        FinanceToToWidgetEntryView(
            context: .init(
                attributes: ExpenseActivityAttributes(budget: 500, currencyCode: "USD"),
                state: ExpenseActivityAttributes.ContentState(totalSpent: 520, remainingBudget: 0, isOverBudget: true)
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
