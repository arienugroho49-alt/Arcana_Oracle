import SwiftUI

// MARK: - Oracle main screen

struct OracleView: View {
    @EnvironmentObject var store: OracleStore
    @State private var btnPressed = false
    @State private var pulse      = false

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header.padding(.top, 24)
                Spacer()
                oracleRow.padding(.horizontal, 20)
                Spacer()
                resultArea.padding(.horizontal, 28).frame(minHeight: 110)
                Spacer()
                revealButton.padding(.horizontal, 32).padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    // MARK: Background

    private var background: some View {
        ZStack {
            Color(hex: "07060F").ignoresSafeArea()
            Circle()
                .fill(Color(hex: "3D1060").opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -200)
            Circle()
                .fill(Color(hex: "0E2A60").opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 110, y: 230)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("✦  O R A C L E  ✦")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "A080FF").opacity(0.7))
                .tracking(5)
            Text("Circles of Fate")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "E8D5FF"), Color(hex: "B090FF")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "8B5CF6").opacity(0.5), radius: 10)
            Text("Three symbols reveal your sign")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.28))
        }
    }

    // MARK: Oracle circles row

    private var oracleRow: some View {
        ZStack {
            // Ambient ring
            Circle()
                .stroke(Color(hex: "8B5CF6").opacity(pulse ? 0.18 : 0.06), lineWidth: 1)
                .frame(width: 318, height: 318)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)

            HStack(spacing: 14) {
                ForEach(Array(store.displaySymbols.enumerated()), id: \.offset) { idx, name in
                    OracleCircle(symbolName: name,
                                 isRevealed: idx < store.revealProgress)
                }
            }
        }
        .frame(height: 200)
    }

    // MARK: Result area

    @ViewBuilder
    private var resultArea: some View {
        if store.showResult, let r = store.lastResult {
            ReadingCard(result: r)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        } else if store.isRevealing {
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(hex: "8B5CF6"))
                        .frame(width: 8, height: 8)
                        .opacity(pulse ? 1 : 0.25)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(i) * 0.18),
                            value: pulse
                        )
                }
            }
        } else {
            VStack(spacing: 6) {
                Text("The circles await your call")
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(.white.opacity(0.28))
                Text("· · ·")
                    .foregroundStyle(Color(hex: "8B5CF6").opacity(0.45))
            }
        }
    }

    // MARK: Reveal button

    private var revealButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.08)) { btnPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.3)) { btnPressed = false }
                store.reveal()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(store.isRevealing
                          ? AnyShapeStyle(Color.white.opacity(0.05))
                          : AnyShapeStyle(LinearGradient(
                              colors: [Color(hex: "7C3AED"), Color(hex: "4C1D95")],
                              startPoint: .topLeading, endPoint: .bottomTrailing
                          )))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                Color(hex: "A78BFA").opacity(store.isRevealing ? 0.1 : 0.45),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: store.isRevealing
                            ? .clear : Color(hex: "7C3AED").opacity(0.55),
                            radius: 20, y: 6)

                Text(store.isRevealing ? "Reading the signs…" : "Consult the Oracle")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(store.isRevealing
                                     ? Color.white.opacity(0.3)
                                     : .white)
            }
            .frame(height: 60)
        }
        .scaleEffect(btnPressed ? 0.95 : 1.0)
        .disabled(store.isRevealing)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: btnPressed)
    }
}

// MARK: - Oracle circle (SF Symbol — always renders)

struct OracleCircle: View {
    let symbolName: String
    let isRevealed: Bool

    @State private var breathe = false

    private var sym: OracleSymbol { OracleStore.symbol(for: symbolName) }

    var body: some View {
        ZStack {
            // Soft glow once the symbol has surfaced
            Circle()
                .fill(sym.color.opacity(isRevealed ? 0.18 : 0))
                .blur(radius: 14)

            // Background fill
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "1E1040"), Color(hex: "0A0618")],
                        center: .center,
                        startRadius: 0,
                        endRadius: 52
                    )
                )

            // Border ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [(isRevealed ? sym.color : Color(hex: "4A3A82")).opacity(0.8),
                                 Color(hex: "3B1D8A")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )

            // Veiled state — a faint, gently breathing glyph
            if !isRevealed {
                Image(systemName: "sparkle")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color(hex: "7A68B8").opacity(breathe ? 0.55 : 0.22))
            }

            // Revealed symbol — fades and scales softly into place
            if isRevealed {
                Image(systemName: symbolName)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(sym.color)
                    .symbolRenderingMode(.hierarchical)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
        .frame(width: 98, height: 98)
        .scaleEffect(isRevealed ? 1.0 : 0.97)
        .animation(.spring(response: 0.6, dampingFraction: 0.72), value: isRevealed)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

// MARK: - Reading result card

struct ReadingCard: View {
    let result: Reading

    private var symbols: [OracleSymbol] {
        result.symbolNames.map { OracleStore.symbol(for: $0) }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Symbol icons mini row
            HStack(spacing: 10) {
                ForEach(Array(symbols.enumerated()), id: \.offset) { _, sym in
                    Image(systemName: sym.sfName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(sym.color)
                        .symbolRenderingMode(.hierarchical)
                }
            }

            if result.isPerfectAlign {
                Text("✦  Perfect Alignment  ✦")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "FFD060"))
                    .tracking(2)
            } else if result.hasDouble {
                Text("Double Sign")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: "C4B5FD").opacity(0.8))
                    .tracking(2)
            }

            Text(result.message)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 24) {
                Label(result.element, systemImage: "sparkles")
                Label("\(result.signNumber)", systemImage: "number.circle")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color(hex: "A78BFA"))
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "100A22"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color(hex: "7C3AED").opacity(0.7),
                                         Color(hex: "3B1D8A").opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                )
        )
    }
}
