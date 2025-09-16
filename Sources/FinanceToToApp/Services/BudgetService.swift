import Foundation
import UserNotifications

@MainActor
final class BudgetService {
    private let notificationService: NotificationService
    private let financeStore: FinanceDataStore

    init(notificationService: NotificationService, financeStore: FinanceDataStore) {
        self.notificationService = notificationService
        self.financeStore = financeStore
    }

    func refreshBudgetAlerts() async {
        let alerts = financeStore.approachingBudgets()
        for alert in alerts where alert.budget.notificationsEnabled {
            await notificationService.scheduleBudgetAlert(alert)
        }
    }
}
