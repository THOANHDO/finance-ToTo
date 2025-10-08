# Finance ToTo

Finance ToTo is a playful SwiftUI budgeting companion designed for iPhone. It keeps spending joyful yet mindful with vibrant visuals, gentle affirmations, and timely reminders delivered straight from the Dynamic Island.

## Features

- **SwiftUI-first experience** with whimsical gradients, bubbly typography, and friendly copy.
- **Expense tracking** across themed categories such as treats, travel, wellness, and more.
- **Budget awareness** card with progress tracking, emoji-fueled status messages, and quick add sheet.
- **Dynamic Island live activity** that surfaces remaining budget, spending alerts, and motivational nudges even when the app is backgrounded.
- **Notifications & reminders** triggered automatically when spending grows intense, keeping users mindful of their sparkle fund.

## Architecture

The project follows a lightweight MVVM approach:

- `ExpenseViewModel` orchestrates business logic, handles storage, and evaluates when to trigger reminders.
- `ExpenseStorage` persists expenses on-device.
- `ReminderService` wraps notification scheduling and budget publishing.
- `DynamicIslandController` manages ActivityKit live activities for the Dynamic Island.
- `FinanceToToWidget` renders the live activity and Dynamic Island regions.

## Requirements

- Xcode 15+
- iOS 17+ (ActivityKit v2 for Dynamic Island customizations)

## Getting Started

1. Open the project in Xcode.
2. Ensure the app target has the `ActivityKit` and `UserNotifications` capabilities enabled.
3. Run on a physical device with Dynamic Island support (iPhone 14 Pro or newer) to experience the live activity prompts.

## Customization Ideas

- Adjust the default monthly budget in `BudgetReminderService`.
- Extend `ExpenseCategory` with additional categories or icons.
- Enhance analytics by syncing with CloudKit or integrating charts.
- Localize the whimsical copy to match regional vibes.
