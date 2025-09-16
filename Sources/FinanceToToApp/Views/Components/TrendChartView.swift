import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct TrendChartView: View {
    let points: [TrendPoint]

    var body: some View {
        #if canImport(Charts)
        Chart(points) { point in
            AreaMark(
                x: .value("Date", point.periodStart, unit: .month),
                y: .value("Net", point.net.doubleValue)
            )
            .foregroundStyle(point.net.doubleValue >= 0 ? .green.gradient : .red.gradient)
            LineMark(
                x: .value("Date", point.periodStart, unit: .month),
                y: .value("Net", point.net.doubleValue)
            )
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                if let dateValue = value.as(Date.self) {
                    AxisValueLabel(dateValue.formatted(.dateTime.month(.abbreviated)))
                }
            }
        }
        .frame(minHeight: 200)
        #else
        VStack(alignment: .leading) {
            Text(String(localized: "Trend chart requires iOS 16+"))
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 200)
        #endif
    }
}
