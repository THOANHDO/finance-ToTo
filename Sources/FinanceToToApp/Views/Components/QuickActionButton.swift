import SwiftUI

struct QuickActionButton: View {
    let action: QuickAction

    var body: some View {
        Button(action: action.action) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.headline)
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.accentColor.opacity(0.15))
            .foregroundColor(.accentColor)
            .clipShape(Capsule())
        }
    }
}
