import SwiftUI

extension View {
    @ViewBuilder
    func platformNavigationTitle(_ title: String) -> some View {
        #if os(macOS)
        self
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.automatic)
        #else
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @ViewBuilder
    func ifLet<Value, Content: View>(_ value: Value?, transform: (Self, Value) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

    func cardBackground() -> some View {
        self
            .padding()
            .background(Color.financeBackground)
            .cornerRadius(16)
    }
}
