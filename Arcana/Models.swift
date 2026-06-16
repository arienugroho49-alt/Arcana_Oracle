import SwiftUI

// MARK: - OracleSymbol

struct OracleSymbol {
    let sfName:      String
    let label:       String
    let color:       Color
    let description: String
    let meaning:     String        // what it means in a reading
    let affinity:    [String]      // compatible element labels
}

// MARK: - DailyReading

struct DailyReading: Codable {
    let dateKey:    String
    let symbolName: String
    let energy:     Int        // 1–10
    let focusArea:  String
    let message:    String
    let signNumber: Int
}

// MARK: - Reading

struct Reading: Identifiable, Codable {
    var id           = UUID()
    let symbolNames: [String]
    let message:     String
    let element:     String
    let signNumber:  Int
    let date:        Date

    var isPerfectAlign: Bool { Set(symbolNames).count == 1 }
    var hasDouble: Bool {
        Dictionary(grouping: symbolNames, by: { $0 }).values.contains { $0.count >= 2 }
    }
}

// MARK: - OracleStore

class OracleStore: ObservableObject {
    // ── Oracle screen ────────────────────────────────────────────────────
    @Published var history:        [Reading] = []
    @Published var isRevealing     = false
    @Published var displaySymbols: [String]     = ["moon.fill", "star.fill", "sparkles"]
    @Published var revealProgress: Int          = 3   // how many of the 3 symbols are unveiled
    @Published var lastResult:     Reading?
    @Published var showResult      = false

    // ── Daily screen ─────────────────────────────────────────────────────
    @Published var dailyReading:   DailyReading?

    var hasDailyReading: Bool {
        dailyReading?.dateKey == todayKey()
    }

    // MARK: Symbol catalogue

    static let symbols: [OracleSymbol] = [
        OracleSymbol(
            sfName: "moon.fill", label: "Moon", color: Color(hex: "C4B5FD"),
            description: "The Moon governs mystery, intuition and the cycles of the subconscious mind.",
            meaning: "Trust your inner voice today. Hidden truths are surfacing.",
            affinity: ["Water", "Crystal", "Wind"]
        ),
        OracleSymbol(
            sfName: "sun.max.fill", label: "Sun", color: Color(hex: "FFD060"),
            description: "The Sun radiates vitality, clarity and outward expression of your true self.",
            meaning: "A moment of clarity arrives. Act with confidence.",
            affinity: ["Fire", "Star", "Thunder"]
        ),
        OracleSymbol(
            sfName: "star.fill", label: "Star", color: Color(hex: "FFA040"),
            description: "Stars guide travellers and dreamers alike. They represent distant goals and inspiration.",
            meaning: "Your aspirations are valid. A guiding sign appears.",
            affinity: ["Sun", "Moon", "Wind"]
        ),
        OracleSymbol(
            sfName: "sparkles", label: "Crystal", color: Color(hex: "80DFFF"),
            description: "Crystal channels pure perception and mental acuity, cutting through illusion.",
            meaning: "See past the surface. The real picture becomes clear.",
            affinity: ["Moon", "Ice", "Wind"]
        ),
        OracleSymbol(
            sfName: "flame.fill", label: "Fire", color: Color(hex: "FF7040"),
            description: "Fire transforms everything it touches — passion, courage and purification in one.",
            meaning: "Your energy peaks. Take bold action without hesitation.",
            affinity: ["Sun", "Thunder", "Earth"]
        ),
        OracleSymbol(
            sfName: "drop.fill", label: "Water", color: Color(hex: "50AFFF"),
            description: "Water flows around every obstacle, representing adaptability, depth and healing.",
            meaning: "Go with the current. Emotional clarity brings resolution.",
            affinity: ["Moon", "Earth", "Ice"]
        ),
        OracleSymbol(
            sfName: "leaf.fill", label: "Earth", color: Color(hex: "60D080"),
            description: "Earth grounds and nourishes, embodying patience, stability and quiet abundance.",
            meaning: "Build steadily. Lasting foundations are being laid.",
            affinity: ["Water", "Fire", "Wind"]
        ),
        OracleSymbol(
            sfName: "bolt.fill", label: "Thunder", color: Color(hex: "FFE840"),
            description: "Thunder signals sudden revelation — the breakthrough that cuts through stagnation.",
            meaning: "An unexpected shift is coming. Stay open and alert.",
            affinity: ["Fire", "Sun", "Star"]
        ),
        OracleSymbol(
            sfName: "snowflake", label: "Ice", color: Color(hex: "A8EEFF"),
            description: "Ice preserves and clarifies. In stillness it reflects the world perfectly.",
            meaning: "Pause before acting. Reflection reveals the wisest path.",
            affinity: ["Water", "Crystal", "Moon"]
        ),
        OracleSymbol(
            sfName: "wind", label: "Wind", color: Color(hex: "C0C8FF"),
            description: "Wind carries new ideas, messages and the freedom of uncharted directions.",
            meaning: "Change of scene or perspective opens a fresh chapter.",
            affinity: ["Star", "Earth", "Crystal"]
        ),
    ]

    private static let byName: [String: OracleSymbol] = {
        Dictionary(uniqueKeysWithValues: symbols.map { ($0.sfName, $0) })
    }()

    static func symbol(for name: String) -> OracleSymbol { byName[name] ?? symbols[0] }
    static let allNames = symbols.map { $0.sfName }

    // MARK: Messages

    static let messages: [String] = [
        "A hidden path becomes clear today.",
        "Your instincts are your compass right now.",
        "Something you've been waiting for draws near.",
        "Quiet moments bring the loudest clarity.",
        "An old question finally finds its answer.",
        "The energy around you is shifting — welcome it.",
        "A small act of courage changes everything.",
        "What you seek is also seeking you.",
        "Rest is productive. Your next step will be lighter.",
        "The right people are already in your orbit.",
        "Let go of what no longer serves you.",
        "Your perspective holds the key today.",
        "Creativity unlocks a door you thought was closed.",
        "Slow down — the answer lives in the details.",
        "Something unexpected arrives with perfect timing.",
        "Your calm is your greatest strength right now.",
        "A new beginning disguised as an ending approaches.",
        "Trust the process even when you can't see the end.",
        "Your actions today echo further than you imagine.",
        "The obstacle in your path IS the path.",
    ]

    static let alignMessages: [String] = [
        "✦ Perfect Alignment — a rare and powerful omen.",
        "✦ All forces converge in your favor today.",
        "✦ The cosmos speaks clearly: this is your moment.",
        "✦ All three align — the universe is listening.",
    ]

    static let focusAreas: [String] = [
        "Creativity", "Relationships", "Career", "Inner Peace",
        "Health", "Learning", "Finances", "Adventure", "Communication", "Gratitude"
    ]

    // MARK: Stats helpers

    var totalReadings: Int { history.count }

    var currentStreak: Int {
        let fmt = Self.dateFmt
        let keys = Set(history.map { fmt.string(from: $0.date) })
        var streak = 0
        var date = Date()
        let cal = Calendar.current
        while keys.contains(fmt.string(from: date)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    var topElements: [(symbol: OracleSymbol, count: Int)] {
        var counts: [String: Int] = [:]
        history.flatMap { $0.symbolNames }.forEach { counts[$0, default: 0] += 1 }
        return counts
            .map { (symbol: OracleStore.symbol(for: $0.key), count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }

    func hasReading(on date: Date) -> Bool {
        let key = Self.dateFmt.string(from: date)
        return history.contains { Self.dateFmt.string(from: $0.date) == key }
    }

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    func todayKey() -> String { Self.dateFmt.string(from: Date()) }

    // MARK: Persistence keys
    private let histKey  = "arcana_history_v3"
    private let dailyKey = "arcana_daily_v1"

    init() { load() }

    // MARK: Oracle reveal

    func reveal() {
        guard !isRevealing else { return }
        isRevealing = true; showResult = false; lastResult = nil

        // Draw the three symbols up front, then unveil them one at a time
        // with a calm, contemplative pacing — no rapid cycling.
        let drawn = (0..<3).map { _ in Self.allNames.randomElement()! }
        withAnimation(.easeOut(duration: 0.35)) {
            displaySymbols = drawn
            revealProgress = 0
        }

        let pause   = 0.6      // initial moment of stillness
        let stagger = 0.55     // gap between each symbol surfacing
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + pause + Double(i) * stagger) { [weak self] in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.72)) {
                    self?.revealProgress = i + 1
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + pause + 3 * stagger + 0.3) { [weak self] in
            self?.finalize(names: drawn)
        }
    }

    private func finalize(names: [String]) {
        let isPerfect = Set(names).count == 1
        let message = isPerfect ? Self.alignMessages.randomElement()! : Self.messages.randomElement()!
        let result = Reading(
            symbolNames: names,
            message: message,
            element: Self.symbol(for: names.first ?? names[0]).label,
            signNumber: Int.random(in: 1...99),
            date: Date()
        )
        revealProgress = 3
        history.insert(result, at: 0)
        lastResult = result; isRevealing = false
        withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) { showResult = true }
        save()
    }

    // MARK: Daily reveal

    func revealDailyReading() {
        let reading = DailyReading(
            dateKey: todayKey(),
            symbolName: Self.allNames.randomElement()!,
            energy: Int.random(in: 5...10),
            focusArea: Self.focusAreas.randomElement()!,
            message: Self.messages.randomElement()!,
            signNumber: Int.random(in: 1...99)
        )
        dailyReading = reading
        if let d = try? JSONEncoder().encode(reading) {
            UserDefaults.standard.set(d, forKey: dailyKey)
        }
    }

    func clearHistory() { history.removeAll(); save() }

    // MARK: Persistence

    private func save() {
        if let d = try? JSONEncoder().encode(history) { UserDefaults.standard.set(d, forKey: histKey) }
    }
    private func load() {
        if let d = UserDefaults.standard.data(forKey: histKey),
           let h = try? JSONDecoder().decode([Reading].self, from: d) { history = h }
        if let d = UserDefaults.standard.data(forKey: dailyKey),
           let dr = try? JSONDecoder().decode(DailyReading.self, from: d) { dailyReading = dr }
    }
}
