import SwiftUI

@main
struct ArcanaApp: App {
    @StateObject private var store = OracleStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
