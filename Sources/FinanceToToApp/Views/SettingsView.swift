import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var securityService: SecurityService
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section(String(localized: "Security")) {
                Toggle(String(localized: "Enable Biometric Login"), isOn: $viewModel.isBiometricEnabled)
                Button(String(localized: "Re-authenticate")) {
                    Task { await securityService.authenticateIfNeeded() }
                }
            }

            Section(String(localized: "Synchronization")) {
                HStack {
                    Text(String(localized: "Status"))
                    Spacer()
                    Text(viewModel.syncStatus)
                        .foregroundStyle(.secondary)
                }
                Button(String(localized: "Sync Now")) {
                    Task { await syncService.syncIfNeeded() }
                }
            }

            Section(String(localized: "Backup")) {
                Button(String(localized: "Create Local Backup")) {
                    viewModel.backupNow()
                }
                if let lastBackup = viewModel.lastBackupDate {
                    Text(String(localized: "Last backup: \(lastBackup.formatted(date: .numeric, time: .shortened))"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            viewModel.configure(securityService: securityService, syncService: syncService)
        }
        .platformNavigationTitle(String(localized: "Settings"))
    }
}
