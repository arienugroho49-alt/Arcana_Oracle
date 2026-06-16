import SwiftUI

// MARK: - Elements Encyclopedia Screen

struct ElementsView: View {
    @State private var selected: OracleSymbol? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            Color(hex: "07060F").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection.padding(.top, 24).padding(.bottom, 20)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(OracleStore.symbols, id: \.sfName) { sym in
                            ElementCard(symbol: sym, isSelected: selected?.sfName == sym.sfName)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        selected = (selected?.sfName == sym.sfName) ? nil : sym
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)

                    if let sym = selected {
                        DetailPanel(symbol: sym)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("The Elements")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("✦  E L E M E N T S  ✦")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "A080FF").opacity(0.7))
                .tracking(5)
            Text("Tap a symbol to learn its nature")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.28))
        }
    }
}

// MARK: - Element card

struct ElementCard: View {
    let symbol:     OracleSymbol
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(symbol.color.opacity(isSelected ? 0.18 : 0.08))
                    .frame(width: 64, height: 64)
                    .blur(radius: isSelected ? 10 : 6)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1E1040"), Color(hex: "0A0618")],
                            center: .center, startRadius: 0, endRadius: 36
                        )
                    )
                    .frame(width: 60, height: 60)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                symbol.color.opacity(isSelected ? 0.9 : 0.5),
                                Color(hex: "3B1D8A").opacity(isSelected ? 0.7 : 0.3),
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: symbol.sfName)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(symbol.color)
                    .symbolRenderingMode(.hierarchical)
            }

            Text(symbol.label)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(isSelected ? symbol.color : .white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: isSelected ? "150D2E" : "0D0A1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            symbol.color.opacity(isSelected ? 0.45 : 0.1),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
    }
}

// MARK: - Detail panel

struct DetailPanel: View {
    let symbol: OracleSymbol

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Title row
            HStack(spacing: 12) {
                Image(systemName: symbol.sfName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(symbol.color)
                    .symbolRenderingMode(.hierarchical)
                VStack(alignment: .leading, spacing: 2) {
                    Text(symbol.label)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text("Oracle Element")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.3))
                        .tracking(1)
                }
            }

            Divider()
                .background(symbol.color.opacity(0.2))

            // Description
            Text(symbol.description)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)

            // Meaning
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 13))
                    .foregroundStyle(symbol.color.opacity(0.6))
                Text(symbol.meaning)
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .foregroundStyle(symbol.color.opacity(0.9))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Affinities
            VStack(alignment: .leading, spacing: 8) {
                Text("AFFINITIES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.3))
                    .tracking(2)
                HStack(spacing: 8) {
                    ForEach(symbol.affinity, id: \.self) { label in
                        AffinityChip(label: label)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "100A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [symbol.color.opacity(0.5), Color(hex: "3B1D8A").opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct AffinityChip: View {
    let label: String

    private var sym: OracleSymbol? {
        OracleStore.symbols.first { $0.label == label }
    }

    var body: some View {
        if let s = sym {
            HStack(spacing: 4) {
                Image(systemName: s.sfName)
                    .font(.system(size: 10))
                    .foregroundStyle(s.color)
                    .symbolRenderingMode(.hierarchical)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(s.color.opacity(0.9))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(s.color.opacity(0.08))
                    .overlay(Capsule().strokeBorder(s.color.opacity(0.25), lineWidth: 1))
            )
        }
    }
}
