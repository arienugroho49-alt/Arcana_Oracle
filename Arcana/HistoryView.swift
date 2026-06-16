import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: OracleStore
    @State private var showClearAlert = false

    private let fmt: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .short; return f
    }()

    var body: some View {
        ZStack {
            Color(hex: "07060F").ignoresSafeArea()

            if store.history.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(store.history) { result in
                        HistoryRow(result: result, dateStr: fmt.string(from: result.date))
                            .listRowBackground(Color(hex: "0D0A1E"))
                            .listRowSeparatorTint(Color(hex: "7C3AED").opacity(0.15))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Past Readings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if !store.history.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { showClearAlert = true }
                        .foregroundStyle(Color(hex: "A78BFA"))
                }
            }
        }
        .alert("Clear History", isPresented: $showClearAlert) {
            Button("Clear All", role: .destructive) { withAnimation { store.clearHistory() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All past readings will be removed.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color(hex: "8B5CF6"))
                .symbolRenderingMode(.hierarchical)
            Text("No readings yet")
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.38))
            Text("Visit the Oracle tab and reveal your first sign")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.2))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Row

struct HistoryRow: View {
    let result:  Reading
    let dateStr: String

    private var symbols: [OracleSymbol] {
        result.symbolNames.map { OracleStore.symbol(for: $0) }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Icons box
            HStack(spacing: 6) {
                ForEach(Array(symbols.enumerated()), id: \.offset) { _, sym in
                    Image(systemName: sym.sfName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(sym.color)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "1A0E35"))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color(hex: "7C3AED")
                            .opacity(result.isPerfectAlign ? 0.85 : 0.2),
                                      lineWidth: 1))
            )

            VStack(alignment: .leading, spacing: 3) {
                if result.isPerfectAlign {
                    Text("✦ Perfect Alignment")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "FFD060"))
                        .tracking(1)
                }
                Text(result.message)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
                Text("\(result.element)  ·  #\(result.signNumber)  ·  \(dateStr)")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.26))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
    }
}
