import Foundation
import LocalAuthentication

@MainActor
final class SecurityService: ObservableObject {
    @Published private(set) var isUnlocked = false

    func authenticateIfNeeded() async {
        guard !isUnlocked else { return }
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = String(localized: "Authenticate to access FinanceToTo")
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                isUnlocked = success
            } catch {
                print("Biometric auth failed: \(error)")
            }
        } else {
            isUnlocked = true
        }
    }
}
