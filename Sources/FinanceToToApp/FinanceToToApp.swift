import SwiftUI
import Combine

@main
struct FinanceToToApp: App {
    @StateObject private var financeStore = FinanceDataStore()
    @StateObject private var securityService = SecurityService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var syncService = SyncService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(financeStore)
                .environmentObject(notificationService)
                .environmentObject(syncService)
                .environmentObject(securityService)
                .task {
                    await securityService.authenticateIfNeeded()
                    await financeStore.load()
                    await notificationService.requestAuthorization()
                    syncService.configure(with: financeStore)
                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .background:
                        Task { await financeStore.persist() }
                        Task { await syncService.syncIfNeeded() }
                    default:
                        break
                    }
                }
        }
        .commands {
            FinanceMenuCommands(financeStore: financeStore, syncService: syncService)
        }

#if os(macOS)
        MenuBarExtra("FinanceToTo", systemImage: "creditcard") {
            MenuBarDashboard()
                .environmentObject(financeStore)
        }
#endif
    }
}
