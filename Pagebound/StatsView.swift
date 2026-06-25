import SwiftUI

// MARK: - Reading statistics

struct StatsView: View {
    @EnvironmentObject var store: LibraryStore

    var body: some View {
        ZStack {
            Color(hex: "0B0B12").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    topCards
                    weekSection
                    heatmapSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: Top metric cards

    private var topCards: some View {
        HStack(spacing: 12) {
            StatCard(icon: "checkmark.seal.fill", value: "\(store.booksFinished)",
                     label: "Finished", color: Color(hex: "5BD58A"))
            StatCard(icon: "flame.fill", value: "\(store.currentStreak)",
                     label: "Day streak", color: Color(hex: "FFB454"))
            StatCard(icon: "doc.text.fill", value: "\(store.totalPagesRead)",
                     label: "Pages read", color: Color(hex: "7C6CF0"))
        }
    }

    // MARK: This week

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("This week", systemImage: "calendar")
                .font(.headline).foregroundStyle(.white)

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date())!
                    let active = store.hasSession(on: date)
                    VStack(spacing: 6) {
                        Circle()
                            .fill(active ? Color(hex: "7C6CF0") : Color(hex: "1C1C28"))
                            .frame(width: 30, height: 30)
                            .overlay(Image(systemName: active ? "book.fill" : "")
                                .font(.system(size: 11)).foregroundStyle(.white))
                        Text(dayLabel(date))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(active ? 0.6 : 0.25))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(card)
        }
    }

    // MARK: 28-day heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Last 28 days", systemImage: "square.grid.3x3.fill")
                .font(.headline).foregroundStyle(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
                      spacing: 6) {
                ForEach(0..<28, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(27 - offset), to: Date())!
                    let pages = store.pagesRead(on: date)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(cellColor(pages))
                        .frame(height: 28)
                        .overlay(Text(pages > 0 ? "\(pages)" : "")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7)))
                }
            }
            .padding(16)
            .background(card)

            HStack(spacing: 8) {
                Text("Less").font(.system(size: 10)).foregroundStyle(.white.opacity(0.25))
                ForEach([0, 10, 25, 60], id: \.self) { n in
                    RoundedRectangle(cornerRadius: 3).fill(cellColor(n)).frame(width: 14, height: 14)
                }
                Text("More").font(.system(size: 10)).foregroundStyle(.white.opacity(0.25))
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: Helpers

    private func cellColor(_ pages: Int) -> Color {
        switch pages {
        case 0:      return Color(hex: "1C1C28")
        case 1...15: return Color(hex: "7C6CF0").opacity(0.4)
        case 16...40: return Color(hex: "7C6CF0").opacity(0.7)
        default:     return Color(hex: "7C6CF0")
        }
    }

    private func dayLabel(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: d).uppercased()
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 16).fill(Color(hex: "15151F"))
    }
}

// MARK: - Metric card

struct StatCard: View {
    let icon:  String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1).minimumScaleFactor(0.5)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "15151F")))
    }
}
