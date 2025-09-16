import Foundation
import Combine

@MainActor
final class AssetsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var assets: [Asset] = []
    @Published var debts: [Debt] = []
    @Published var netWorthHistory: [NetWorthSnapshot] = []
    @Published var currentSnapshot: NetWorthSnapshot = NetWorthSnapshot(date: .now, totalAssets: 0, totalDebts: 0)

    private var financeStore: FinanceDataStore?
    private var netWorthService: NetWorthService?
    private var cancellables = Set<AnyCancellable>()

    func configure(with financeStore: FinanceDataStore) {
        guard self.financeStore !== financeStore else { return }
        self.financeStore = financeStore
        self.netWorthService = NetWorthService(financeStore: financeStore)
        bind()
        refresh()
    }

    private func bind() {
        cancellables.removeAll()
        guard let financeStore else { return }
        financeStore.$accounts
            .sink { [weak self] in
                self?.accounts = $0
            }
            .store(in: &cancellables)

        financeStore.$assets
            .sink { [weak self] in
                self?.assets = $0
                self?.refresh()
            }
            .store(in: &cancellables)

        financeStore.$debts
            .sink { [weak self] in
                self?.debts = $0
                self?.refresh()
            }
            .store(in: &cancellables)
    }

    private func refresh() {
        netWorthHistory = netWorthService?.history() ?? []
        currentSnapshot = netWorthService?.currentSnapshot() ?? NetWorthSnapshot(date: .now, totalAssets: 0, totalDebts: 0)
    }
}
