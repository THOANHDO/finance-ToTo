import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore

    var body: some View {
        #if os(macOS)
        DesktopRootView()
            .environmentObject(financeStore)
        #elseif os(iOS)
        iOSRootView()
            .environmentObject(financeStore)
        #else
        iOSRootView()
            .environmentObject(financeStore)
        #endif
    }
}

struct iOSRootView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: Tab = .overview
    @State private var sidebarSelection: SidebarItem? = .overview

    enum Tab: Hashable {
        case overview, transactions, budget, reports, settings
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                List(SidebarItem.allCases, selection: $sidebarSelection) { item in
                    Label(item.title, systemImage: item.icon)
                }
                .listStyle(.sidebar)
            } detail: {
                switch sidebarSelection ?? .overview {
                case .overview:
                    DashboardView()
                case .transactions:
                    TransactionsView()
                case .budget:
                    BudgetView()
                case .reports:
                    ReportsView()
                case .assets:
                    AssetsView()
                case .settings:
                    SettingsView()
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                NavigationStack { DashboardView() }
                    .tabItem { Label(String(localized: "Overview"), systemImage: "chart.pie.fill") }
                    .tag(Tab.overview)

                NavigationStack { TransactionsView() }
                    .tabItem { Label(String(localized: "Transactions"), systemImage: "list.bullet") }
                    .tag(Tab.transactions)

                NavigationStack { BudgetView() }
                    .tabItem { Label(String(localized: "Budget"), systemImage: "target") }
                    .tag(Tab.budget)

                NavigationStack { ReportsView() }
                    .tabItem { Label(String(localized: "Reports"), systemImage: "chart.bar.xaxis") }
                    .tag(Tab.reports)

                NavigationStack { SettingsView() }
                    .tabItem { Label(String(localized: "Settings"), systemImage: "gearshape") }
                    .tag(Tab.settings)
            }
            .overlay(alignment: .bottomTrailing) {
                AddTransactionButton()
                    .padding()
            }
        }
    }
}

struct DesktopRootView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @State private var selection: SidebarItem? = .overview

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.icon)
            }
            .listStyle(.sidebar)
        } detail: {
            switch selection ?? .overview {
            case .overview:
                DashboardView()
            case .transactions:
                TransactionsView()
            case .budget:
                BudgetView()
            case .reports:
                ReportsView()
            case .assets:
                AssetsView()
            case .settings:
                SettingsView()
            }
        }
    }
}

enum SidebarItem: CaseIterable, Hashable, Identifiable {
    case overview, transactions, budget, reports, assets, settings

    var id: Self { self }

    var title: String {
        switch self {
        case .overview: return String(localized: "Overview")
        case .transactions: return String(localized: "Transactions")
        case .budget: return String(localized: "Budget")
        case .reports: return String(localized: "Reports")
        case .assets: return String(localized: "Assets")
        case .settings: return String(localized: "Settings")
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .transactions: return "list.bullet"
        case .budget: return "target"
        case .reports: return "chart.bar.xaxis"
        case .assets: return "banknote"
        case .settings: return "gearshape"
        }
    }
}

struct AddTransactionButton: View {
    @State private var presentingAddSheet = false

    var body: some View {
        Button {
            presentingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .sheet(isPresented: $presentingAddSheet) {
            NavigationStack {
                AddTransactionView()
            }
            .presentationDetents([.fraction(0.6), .large])
        }
    }
}
