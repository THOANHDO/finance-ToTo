import SwiftUI

enum AppTheme {
    static let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.accentColor.opacity(0.85), Color.green.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color.financeBackground

    static func shadow(radius: CGFloat = 12) -> ShadowStyle {
        ShadowStyle(radius: radius, x: 0, y: 6, opacity: 0.15)
    }
}

struct ShadowStyle {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

extension View {
    func themedCard() -> some View {
        self
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(18)
            .shadow(
                color: Color.black.opacity(AppTheme.shadow().opacity),
                radius: AppTheme.shadow().radius,
                x: AppTheme.shadow().x,
                y: AppTheme.shadow().y
            )
    }
}
