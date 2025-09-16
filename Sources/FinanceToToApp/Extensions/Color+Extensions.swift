import SwiftUI

extension Color {
    init?(hex: String) {
        var sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if sanitized.count == 6 { sanitized.append("FF") }

        var int: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        a = int & 0xFF
        b = (int >> 8) & 0xFF
        g = (int >> 16) & 0xFF
        r = (int >> 24) & 0xFF

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static var financeBackground: Color {
    #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
    #else
        return Color(UIColor.secondarySystemBackground)
    #endif
    }
}
