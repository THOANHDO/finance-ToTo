import Foundation

#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
struct BudgetActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var categoryName: String
        var spent: Double
        var limit: Double
        var message: String
    }

    var userName: String
}

@available(iOS 16.1, *)
final class LiveActivityBridge {
    static let shared = LiveActivityBridge()

    private var activity: Activity<BudgetActivityAttributes>?

    func startOrUpdate(with category: BudgetCategory, reminder: FriendlyReminderMessage, userName: String) {
        let contentState = BudgetActivityAttributes.ContentState(
            categoryName: category.name,
            spent: category.spent,
            limit: category.limit,
            message: reminder.compactMessage
        )
        Task {
            if let activity {
                await activity.update(ActivityContent(state: contentState, staleDate: .now.addingTimeInterval(3600)))
            } else {
                let attributes = BudgetActivityAttributes(userName: userName)
                do {
                    activity = try Activity.request(
                        attributes: attributes,
                        content: ActivityContent(state: contentState, staleDate: .now.addingTimeInterval(3600)),
                        pushType: nil
                    )
                } catch {
                    #if DEBUG
                    print("Không thể tạo Live Activity: \(error)")
                    #endif
                }
            }
        }
    }

    func endActivity() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }
    }
}
#else
final class LiveActivityBridge {
    static let shared = LiveActivityBridge()

    func startOrUpdate(with category: BudgetCategory, reminder: FriendlyReminderMessage, userName: String) { }
    func endActivity() { }
}
#endif
