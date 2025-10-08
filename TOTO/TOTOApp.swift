import SwiftUI

@main
struct TOTOApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            guard newPhase == .inactive else { return }
            if #available(iOS 16.1, *) {
                LiveActivityBridge.shared.endActivity()
            }
        }
    }
}
