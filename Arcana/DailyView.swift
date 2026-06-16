import SwiftUI

// MARK: - Daily Reading Screen

struct DailyView: View {
    @EnvironmentObject var store: OracleStore
    @State private var sealPulse   = false
    @State private var revealScale = 1.0
    @State private var now         = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header.padding(.top, 24)
                Spacer()

                if store.hasDailyReading, let reading = store.dailyReading {
                    readingContent(reading)
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    sealButton
                }

                Spacer()

                if store.hasDailyReading {
                    nextReadingFooter
                        .padding(.bottom, 36)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                sealPulse = true
            }
        }
        .onReceive(timer) { _ in now = Date() }
    }

    // MARK: Background

    private var background: some View {
        ZStack {
            Color(hex: "07060F").ignoresSafeArea()
            Circle()
                .fill(Color(hex: "1A3060").opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 100, y: -180)
            Circle()
                .fill(Color(hex: "3D1060").opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -110, y: 200)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("✦  D A I L Y  S I G N  ✦")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "A080FF").opacity(0.7))
                .tracking(5)
            Text("Your Day's Oracle")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "E8D5FF"), Color(hex: "B090FF")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "8B5CF6").opacity(0.45), radius: 10)
            Text("One reading per day, sealed at midnight")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.28))
        }
    }

    // MARK: Seal button (unrevealed state)

    private var sealButton: some View {
        Button { revealReading() } label: {
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color(hex: "6D28D9").opacity(sealPulse ? 0.22 : 0.08))
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)

                // Ring 1
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "A78BFA"), Color(hex: "4C1D95")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 170, height: 170)
                    .opacity(sealPulse ? 1 : 0.4)

                // Ring 2 (rotated)
                Circle()
                    .stroke(Color(hex: "7C3AED").opacity(sealPulse ? 0.5 : 0.15), lineWidth: 1)
                    .frame(width: 148, height: 148)

                // Seal icon
                VStack(spacing: 8) {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "C4B5FD"), Color(hex: "7C3AED")],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .symbolRenderingMode(.hierarchical)
                    Text("Unseal Today")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(hex: "C4B5FD").opacity(0.9))
                }
            }
            .scaleEffect(revealScale)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: sealPulse)
    }

    // MARK: Reveal action

    private func revealReading() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { revealScale = 1.15 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                revealScale = 1.0
                store.revealDailyReading()
            }
        }
    }

    // MARK: Reading content (revealed state)

    @ViewBuilder
    private func readingContent(_ reading: DailyReading) -> some View {
        let sym = OracleStore.symbol(for: reading.symbolName)

        VStack(spacing: 20) {
            // Large symbol
            ZStack {
                Circle()
                    .fill(sym.color.opacity(0.12))
                    .frame(width: 130, height: 130)
                    .blur(radius: 20)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1E1040"), Color(hex: "0A0618")],
                            center: .center, startRadius: 0, endRadius: 64
                        )
                    )
                    .frame(width: 110, height: 110)
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [sym.color.opacity(0.85), Color(hex: "3B1D8A")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 110, height: 110)
                Image(systemName: sym.sfName)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(sym.color)
                    .symbolRenderingMode(.hierarchical)
            }

            // Symbol name + meaning
            VStack(spacing: 6) {
                Text(sym.label)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(sym.meaning)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Energy bar
            VStack(spacing: 8) {
                HStack {
                    Text("Energy")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1)
                    Spacer()
                    Text("\(reading.energy) / 10")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(sym.color)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "1A0E35"))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [sym.color.opacity(0.6), sym.color],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(reading.energy) / 10, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 4)

            // Focus + number
            HStack(spacing: 12) {
                tagView(icon: "scope", text: reading.focusArea, color: sym.color)
                tagView(icon: "number.circle", text: "#\(reading.signNumber)", color: Color(hex: "FFD060"))
            }

            // Message
            Text("\u{201C}\(reading.message)\u{201D}")
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "0D0A1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [sym.color.opacity(0.5), Color(hex: "3B1D8A").opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private func tagView(icon: String, text: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(color.opacity(0.1))
                    .overlay(Capsule().strokeBorder(color.opacity(0.25), lineWidth: 1))
            )
    }

    // MARK: Countdown footer

    private var nextReadingFooter: some View {
        VStack(spacing: 4) {
            Text("Next reading in")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.25))
            Text(countdownString)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: "A78BFA").opacity(0.7))
        }
    }

    private var countdownString: String {
        let cal = Calendar.current
        guard let midnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return "--:--:--" }
        let secs = Int(midnight.timeIntervalSince(now))
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
