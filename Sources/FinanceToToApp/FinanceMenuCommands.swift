import SwiftUI

struct FinanceMenuCommands: Commands {
    @ObservedObject var financeStore: FinanceDataStore
    @ObservedObject var syncService: SyncService

    var body: some Commands {
        CommandMenu(String(localized: "Finance")) {
            Button(String(localized: "New Transaction")) {
                // Hook for command handling
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button(String(localized: "Sync Now")) {
                Task { await syncService.syncIfNeeded() }
            }

            Divider()
            Text("Transactions: \(financeStore.transactions.count)")
        }
    }
}
