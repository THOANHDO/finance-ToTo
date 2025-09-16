import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isBiometricEnabled: Bool = true
    @Published var syncStatus: String = String(localized: "Not synced")
    @Published var lastBackupDate: Date?

    private var securityService: SecurityService?
    private var syncService: SyncService?
    private var cancellables = Set<AnyCancellable>()

    func configure(securityService: SecurityService, syncService: SyncService) {
        guard self.syncService !== syncService else { return }
        self.securityService = securityService
        self.syncService = syncService
        cancellables.removeAll()

        syncService.$lastSyncDate
            .sink { [weak self] date in
                guard let date else {
                    self?.syncStatus = String(localized: "Not synced")
                    return
                }
                self?.syncStatus = String(localized: "Last synced: \(date.formatted(date: .numeric, time: .shortened))")
            }
            .store(in: &cancellables)
    }

    func toggleBiometric() {
        isBiometricEnabled.toggle()
    }

    func backupNow() {
        lastBackupDate = .now
    }
}
