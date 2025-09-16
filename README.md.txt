# FinanceToTo

FinanceToTo is a multiplatform SwiftUI personal finance manager designed for iOS, iPadOS, and macOS. It helps you capture daily transactions, monitor budgets, plan savings, and visualize your overall financial health with a unified experience inspired by Apple's Human Interface Guidelines.

## Features

- **Income & Expense Tracking** – Quick entry forms, Siri Shortcuts hooks, search, filters, and swipe actions across platforms.
- **Receipt Scanning** – Receipt ingestion powered by Vision/VisionKit with automated merchant, total, and date detection.
- **Budget Planning** – Category-based budgets with progress rings, alerts when approaching limits, and configurable periods.
- **Analytics & Reports** – Swift Charts visualizations for trends, spending distribution, and forecasts with support for iPad multi-column layouts and macOS toolbars.
- **Assets & Debts** – Net worth history, asset/debt breakdowns, and multi-account tracking.
- **Reminders & Notifications** – UNUserNotificationCenter integration for bill reminders and budget overruns.
- **Security & Sync** – Biometric authentication, CloudKit-ready sync scaffolding, and export/backup hooks.
- **Platform Enhancements** – Dynamic navigation that adapts to iPhone tabs, iPad split view, macOS menus/menu bar extras, and menu commands.

## Architecture Overview

- **State Management** – `FinanceDataStore` is a shared observable model responsible for persistence (JSON placeholder with CloudKit hook), analytics, and sample data bootstrapping.
- **View Models** – Dedicated view models per feature (`Dashboard`, `Transactions`, `Budget`, `Reports`, `Assets`, `Settings`, `AddTransaction`) encapsulate bindings, filtering, and background work.
- **Services** – Modular services for notifications, analytics, budgets, net worth calculations, security, synchronization, and receipt scanning.
- **Views** – Adaptive SwiftUI views and reusable components (summary cards, charts, progress rings, reminder lists) that respond to size class and platform differences.

## Getting Started

1. Open the package in Xcode 15+ on macOS 13 or later.
2. Select the **FinanceToToApp** scheme for iOS, iPadOS, or macOS and run.
3. The app boots with sample data; add transactions, tweak budgets, or scan receipts to explore workflows.

> **Note:** CloudKit synchronization and receipt OCR require real device entitlements. The sample project ships with placeholder implementations that can be extended with production credentials.

## Testing & Extensibility

- Extend `FinanceDataStore` to connect to Core Data / CloudKit by replacing the JSON persistence helper.
- Configure Live Activities & widgets by leveraging the exposed analytics and budget services.
- Integrate bank aggregation providers within the `SyncService` stub.

