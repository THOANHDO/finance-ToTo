import Foundation
import ActivityKit

@available(iOS 16.1, *)
@MainActor
final class DynamicIslandController: ObservableObject {
    private var currentActivity: Activity<ExpenseActivityAttributes>?

    func requestAuthorization() async {
        let info = ActivityAuthorizationInfo()
        guard info.areActivitiesEnabled else { return }
        _ = await ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func triggerReminder(for summary: ExpenseSummary) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = ExpenseActivityAttributes(budget: summary.budget, currencyCode: summary.currencyCode)
        let state = ExpenseActivityAttributes.ContentState(
            totalSpent: summary.totalSpent,
            remainingBudget: summary.remaining,
            isOverBudget: summary.isOverBudget
        )

        if let currentActivity {
            Task { await currentActivity.update(using: state) }
        } else {
            currentActivity = try? Activity.request(attributes: attributes, contentState: state, pushType: nil)
        }
    }

    func endActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .default)
            currentActivity = nil
        }
    }
}
