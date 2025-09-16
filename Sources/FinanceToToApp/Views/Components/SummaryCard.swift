import SwiftUI

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let systemImage: String
    var gradient: LinearGradient = AppTheme.gradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                Spacer()
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(gradient)
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
    }
}
