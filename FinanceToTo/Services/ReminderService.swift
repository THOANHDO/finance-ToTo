import Foundation
import Combine
import UserNotifications

protocol ReminderService {
    var currentBudget: Double { get }
    var budgetPublisher: AnyPublisher<Double, Never> { get }
    func scheduleReminder(for summary: ExpenseSummary)
}

final class BudgetReminderService: NSObject, ReminderService, UNUserNotificationCenterDelegate {
    private(set) var currentBudget: Double
    private let center = UNUserNotificationCenter.current()
    private let subject: CurrentValueSubject<Double, Never>

    override init() {
        let defaultBudget = UserDefaults.standard.double(forKey: "monthlyBudget")
        currentBudget = defaultBudget == 0 ? 600 : defaultBudget
        subject = CurrentValueSubject(currentBudget)
        super.init()
        center.delegate = self
        requestNotificationPermission()
    }

    var budgetPublisher: AnyPublisher<Double, Never> {
        subject.eraseToAnyPublisher()
    }

    func updateBudget(to newValue: Double) {
        currentBudget = newValue
        UserDefaults.standard.set(newValue, forKey: "monthlyBudget")
        subject.send(newValue)
    }

    func scheduleReminder(for summary: ExpenseSummary) {
        let content = UNMutableNotificationContent()
        content.title = summary.isOverBudget ? "Budget SOS" : "Sparkle Alert"
        let overBudgetAmount = summary.totalSpent - summary.budget
        content.body = summary.isOverBudget
            ? "You're over budget by \(overBudgetAmount, format: .currency(code: summary.currencyCode)). Time for a chill night?"
            : "You've used \(Int(summary.progress * 100))% of your budget. Maybe review your wishlist?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    private func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}

struct PreviewReminderService: ReminderService {
    var currentBudget: Double = 800
    var budgetPublisher: AnyPublisher<Double, Never> = Just(800).eraseToAnyPublisher()

    func scheduleReminder(for summary: ExpenseSummary) { }
}
