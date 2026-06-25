import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { ShelfView() }
                .tabItem { Label("Shelf", systemImage: "books.vertical.fill") }

            NavigationStack { TodayView() }
                .tabItem { Label("Today", systemImage: "book.fill") }

            NavigationStack { StatsView() }
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }

            NavigationStack { FinishedView() }
                .tabItem { Label("Finished", systemImage: "checkmark.seal.fill") }
        }
        .tint(Color(hex: "7C6CF0"))
    }
}
