import SwiftUI

// MARK: - ReadingStatus

enum ReadingStatus: String, Codable, CaseIterable, Identifiable {
    case wantToRead = "Want to Read"
    case reading    = "Reading"
    case finished   = "Finished"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .reading:    return "book"
        case .finished:   return "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .wantToRead: return Color(hex: "FFB454")
        case .reading:    return Color(hex: "5AA9FF")
        case .finished:   return Color(hex: "5BD58A")
        }
    }
}

// MARK: - Book

struct Book: Identifiable, Codable {
    var id            = UUID()
    var title:        String
    var author:       String
    var totalPages:   Int
    var currentPage:  Int           = 0
    var status:       ReadingStatus = .wantToRead
    var rating:       Int           = 0     // 0 = unrated, 1...5
    var colorHex:     String        = "7C6CF0"
    var dateAdded:    Date          = Date()
    var dateFinished: Date?         = nil

    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return min(1, Double(currentPage) / Double(totalPages))
    }
    var color: Color { Color(hex: colorHex) }
}

// MARK: - ReadingSession

struct ReadingSession: Identifiable, Codable {
    var id        = UUID()
    let bookID:    UUID
    let date:      Date
    let pagesRead: Int
}

// MARK: - LibraryStore

final class LibraryStore: ObservableObject {
    @Published var books:    [Book]           = []
    @Published var sessions: [ReadingSession] = []

    /// Cover colours offered when adding a book.
    static let palette = ["7C6CF0", "5AA9FF", "5BD58A", "FFB454",
                          "FF7A8A", "E879F9", "2DD4BF", "F4A259"]

    private let booksKey    = "library_books_v1"
    private let sessionsKey = "library_sessions_v1"

    init() { load() }

    // MARK: Derived collections

    var currentlyReading: [Book] {
        books.filter { $0.status == .reading }.sorted { $0.dateAdded > $1.dateAdded }
    }
    var wantToRead: [Book] {
        books.filter { $0.status == .wantToRead }.sorted { $0.dateAdded > $1.dateAdded }
    }
    var finished: [Book] {
        books.filter { $0.status == .finished }
            .sorted { ($0.dateFinished ?? .distantPast) > ($1.dateFinished ?? .distantPast) }
    }

    func books(in status: ReadingStatus) -> [Book] {
        switch status {
        case .reading:    return currentlyReading
        case .wantToRead: return wantToRead
        case .finished:   return finished
        }
    }

    // MARK: Mutations

    func add(_ book: Book) {
        books.insert(book, at: 0)
        save()
    }

    func delete(_ book: Book) {
        books.removeAll { $0.id == book.id }
        sessions.removeAll { $0.bookID == book.id }
        save()
    }

    /// Move the reading position; logs a session for any pages gained and
    /// advances the status automatically.
    func logProgress(for book: Book, to newPage: Int) {
        guard let i = books.firstIndex(where: { $0.id == book.id }) else { return }
        let clamped = max(0, min(newPage, books[i].totalPages))
        let delta = clamped - books[i].currentPage
        books[i].currentPage = clamped

        if clamped >= books[i].totalPages && books[i].totalPages > 0 {
            books[i].status = .finished
            if books[i].dateFinished == nil { books[i].dateFinished = Date() }
        } else if clamped > 0 {
            books[i].status = .reading
            books[i].dateFinished = nil
        }

        if delta > 0 {
            sessions.append(ReadingSession(bookID: book.id, date: Date(), pagesRead: delta))
        }
        save()
    }

    func setRating(_ rating: Int, for book: Book) {
        guard let i = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[i].rating = rating
        save()
    }

    // MARK: Stats

    private static let dayFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    private func dayKey(_ d: Date) -> String { Self.dayFmt.string(from: d) }

    var totalPagesRead: Int { sessions.reduce(0) { $0 + $1.pagesRead } }
    var booksFinished:  Int { books.filter { $0.status == .finished }.count }
    var booksReading:   Int { currentlyReading.count }

    func pagesRead(on date: Date) -> Int {
        let key = dayKey(date)
        return sessions.filter { dayKey($0.date) == key }.reduce(0) { $0 + $1.pagesRead }
    }

    func hasSession(on date: Date) -> Bool {
        let key = dayKey(date)
        return sessions.contains { dayKey($0.date) == key }
    }

    /// Consecutive days with at least one logged session, counting back from
    /// today (or yesterday, so the streak survives a day not yet read).
    var currentStreak: Int {
        let days = Set(sessions.map { dayKey($0.date) })
        guard !days.isEmpty else { return 0 }
        let cal = Calendar.current
        var date = Date()
        if !days.contains(dayKey(date)) {
            guard let y = cal.date(byAdding: .day, value: -1, to: date) else { return 0 }
            if !days.contains(dayKey(y)) { return 0 }
            date = y
        }
        var streak = 0
        while days.contains(dayKey(date)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    // MARK: Persistence

    private func save() {
        let enc = JSONEncoder()
        if let d = try? enc.encode(books)    { UserDefaults.standard.set(d, forKey: booksKey) }
        if let d = try? enc.encode(sessions) { UserDefaults.standard.set(d, forKey: sessionsKey) }
    }
    private func load() {
        let dec = JSONDecoder()
        if let d = UserDefaults.standard.data(forKey: booksKey),
           let b = try? dec.decode([Book].self, from: d) { books = b }
        if let d = UserDefaults.standard.data(forKey: sessionsKey),
           let s = try? dec.decode([ReadingSession].self, from: d) { sessions = s }
    }
}
