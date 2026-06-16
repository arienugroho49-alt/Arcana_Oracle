import SwiftUI

// MARK: - Statistics Screen

struct StatsView: View {
    @EnvironmentObject var store: OracleStore

    var body: some View {
        ZStack {
            Color(hex: "07060F").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection.padding(.top, 24)
                    topCardsRow.padding(.horizontal, 16)
                    streakSection.padding(.horizontal, 16)
                    heatmapSection.padding(.horizontal, 16)
                    topElementsSection.padding(.horizontal, 16)
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("✦  S T A T S  ✦")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "A080FF").opacity(0.7))
                .tracking(5)
            Text("Your Oracle Journey")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "E8D5FF"), Color(hex: "B090FF")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: Top metric cards

    private var topCardsRow: some View {
        HStack(spacing: 12) {
            MetricCard(
                icon: "moon.stars.fill",
                value: "\(store.totalReadings)",
                label: "Total Reads",
                color: Color(hex: "A78BFA")
            )
            MetricCard(
                icon: "flame.fill",
                value: "\(store.currentStreak)",
                label: "Day Streak",
                color: Color(hex: "FF7040")
            )
            MetricCard(
                icon: "sparkles",
                value: "\(perfectAligns)",
                label: "Alignments",
                color: Color(hex: "FFD060")
            )
        }
    }

    private var perfectAligns: Int {
        store.history.filter { $0.isPerfectAlign }.count
    }

    // MARK: Streak section

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Current Streak", icon: "flame.fill", color: Color(hex: "FF7040"))

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date())!
                    let active = store.hasReading(on: date)
                    VStack(spacing: 6) {
                        Circle()
                            .fill(active
                                  ? Color(hex: "7C3AED")
                                  : Color(hex: "1A0E35"))
                            .overlay(
                                Circle().strokeBorder(
                                    Color(hex: "7C3AED").opacity(active ? 0 : 0.25),
                                    lineWidth: 1
                                )
                            )
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: active ? "checkmark" : "")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                        Text(dayLabel(for: date))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white.opacity(active ? 0.6 : 0.2))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private func dayLabel(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    // MARK: 28-day Heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("28-Day Activity", icon: "calendar", color: Color(hex: "A78BFA"))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(0..<28, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(27 - offset), to: Date())!
                    let count = readingCount(on: date)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(cellColor(count: count))
                        .frame(height: 26)
                        .overlay(
                            Text(count > 0 ? "\(count)" : "")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                        )
                }
            }
            .padding(16)
            .background(cardBackground)

            HStack(spacing: 8) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.25))
                ForEach([0, 1, 3, 6, 10], id: \.self) { n in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor(count: n))
                        .frame(width: 14, height: 14)
                }
                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .padding(.horizontal, 4)
        }
    }

    private func readingCount(on date: Date) -> Int {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        return store.history.filter { fmt.string(from: $0.date) == key }.count
    }

    private func cellColor(count: Int) -> Color {
        switch count {
        case 0:        return Color(hex: "1A0E35")
        case 1:        return Color(hex: "4C1D95").opacity(0.6)
        case 2...4:    return Color(hex: "7C3AED").opacity(0.75)
        case 5...9:    return Color(hex: "8B5CF6")
        default:       return Color(hex: "A78BFA")
        }
    }

    // MARK: Top elements

    private var topElementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Top Elements", icon: "chart.bar.fill", color: Color(hex: "60D080"))

            if store.topElements.isEmpty {
                Text("No readings yet")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.25))
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(cardBackground)
            } else {
                let maxCount = store.topElements.first?.count ?? 1
                VStack(spacing: 10) {
                    ForEach(Array(store.topElements.enumerated()), id: \.offset) { idx, item in
                        ElementStatRow(
                            rank: idx + 1,
                            symbol: item.symbol,
                            count: item.count,
                            maxCount: maxCount
                        )
                    }
                }
                .padding(16)
                .background(cardBackground)
            }
        }
    }

    // MARK: Helpers

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "0D0A1E"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(hex: "7C3AED").opacity(0.15), lineWidth: 1)
            )
    }

    private func sectionTitle(_ text: String, icon: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .symbolRenderingMode(.hierarchical)
    }
}

// MARK: - Metric card

struct MetricCard: View {
    let icon:  String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .symbolRenderingMode(.hierarchical)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(0.5)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "0D0A1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Element stat row

struct ElementStatRow: View {
    let rank:     Int
    let symbol:   OracleSymbol
    let count:    Int
    let maxCount: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.25))
                .frame(width: 16)

            // Symbol icon
            Image(systemName: symbol.sfName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(symbol.color)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 24)

            // Name
            Text(symbol.label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 62, alignment: .leading)

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "1A0E35"))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [symbol.color.opacity(0.6), symbol.color],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * CGFloat(count) / CGFloat(max(maxCount, 1)),
                            height: 6
                        )
                }
            }
            .frame(height: 6)

            // Count
            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(symbol.color.opacity(0.8))
                .frame(width: 28, alignment: .trailing)
        }
    }
}
