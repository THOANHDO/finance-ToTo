import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if !granted {
                print("Notification authorization not granted")
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }

    func scheduleBudgetAlert(_ alert: BudgetAlert) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Budget Alert")
        content.body = String(localized: "You have used %lld%% of your %@ budget.", table: nil, comment: "Budget alert body")
            .replacingOccurrences(of: "%lld", with: String(Int(alert.ratio * 100)))
            .replacingOccurrences(of: "%@", with: alert.budget.category.rawValue)
        content.sound = .default

        let request = UNNotificationRequest(identifier: "budget-\(alert.id)", content: content, trigger: nil)
        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule budget alert: \(error)")
        }
    }

    func schedulePaymentReminder(_ reminder: PaymentReminder) async {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = String(localized: "Due on %@ for %@", comment: "Payment reminder body")
            .replacingOccurrences(of: "%@", with: reminder.dueDate.formatted(date: .abbreviated, time: .shortened))
            .replacingOccurrences(of: "%@", with: reminder.amount.currencyString)
        content.sound = .defaultCritical

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: reminder.isRecurring)
        let request = UNNotificationRequest(identifier: "reminder-\(reminder.id)", content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule payment reminder: \(error)")
        }
    }
}
