import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct SpendingDistributionView: View {
    let categories: [CategorySpending]

    var body: some View {
        #if canImport(Charts)
        Chart(categories) { category in
            SectorMark(
                angle: .value("Amount", category.total.doubleValue),
                innerRadius: .ratio(0.55)
            )
            .foregroundStyle(category.category.color)
            .annotation(position: .overlay) {
                Text(category.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.white)
            }
        }
        .frame(minHeight: 220)
        #else
        VStack(alignment: .leading) {
            ForEach(categories) { category in
                HStack {
                    Circle()
                        .fill(category.category.color)
                        .frame(width: 10, height: 10)
                    Text(category.category.rawValue)
                    Spacer()
                    Text(category.total.currencyString)
                }
            }
        }
        #endif
    }
}
