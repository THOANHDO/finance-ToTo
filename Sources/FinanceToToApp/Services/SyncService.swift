import Foundation
import CloudKit

@MainActor
final class SyncService: ObservableObject {
    @Published private(set) var lastSyncDate: Date?
    private weak var financeStore: FinanceDataStore?
    private var isSyncing = false

    func configure(with financeStore: FinanceDataStore) {
        self.financeStore = financeStore
    }

    func syncIfNeeded() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        // Placeholder for CloudKit synchronization logic.
        try? await Task.sleep(nanoseconds: 200_000_000)
        lastSyncDate = .now
    }
}
