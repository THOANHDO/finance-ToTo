import SwiftUI
import ActivityKit

@available(iOS 16.1, *)
@main
struct FinanceToToApp: App {
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var dynamicIslandController = DynamicIslandController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(expenseViewModel)
                .environmentObject(dynamicIslandController)
        }
        .commands {
            SidebarCommands()
        }
    }
}
