import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OracleView()
                .tabItem {
                    Label("Oracle", systemImage: "moon.stars.fill")
                }

            DailyView()
                .tabItem {
                    Label("Daily", systemImage: "sun.and.horizon.fill")
                }

            NavigationStack {
                ElementsView()
            }
            .tabItem {
                Label("Elements", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Readings", systemImage: "scroll.fill")
            }
        }
        .tint(Color(hex: "A78BFA"))
    }
}
