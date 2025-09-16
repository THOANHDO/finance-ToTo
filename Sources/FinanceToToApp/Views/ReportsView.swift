import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var financeStore: FinanceDataStore
    @StateObject private var viewModel = ReportsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker(String(localized: "Period"), selection: $viewModel.period) {
                    Text(String(localized: "Monthly")).tag(Calendar.Component.month)
                    Text(String(localized: "Quarterly")).tag(Calendar.Component.quarter)
                    Text(String(localized: "Yearly")).tag(Calendar.Component.year)
                }
                .pickerStyle(.segmented)

                GroupBox(String(localized: "Trend")) {
                    TrendChartView(points: viewModel.trend)
                        .frame(height: 220)
                }

                GroupBox(String(localized: "Distribution")) {
                    SpendingDistributionView(categories: viewModel.distribution)
                        .frame(height: 240)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.configure(with: financeStore)
        }
        .platformNavigationTitle(String(localized: "Reports"))
    }
}
