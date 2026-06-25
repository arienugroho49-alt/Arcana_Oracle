import SwiftUI

// MARK: - Today screen (currently reading + quick logging)

struct TodayView: View {
    @EnvironmentObject var store: LibraryStore

    var body: some View {
        ZStack {
            Color(hex: "0B0B12").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    summary
                    if store.currentlyReading.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.currentlyReading) { book in
                            NowReadingRow(book: book)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var summary: some View {
        HStack(spacing: 12) {
            TodayStat(value: "\(store.pagesRead(on: Date()))",
                      label: "Pages today", color: Color(hex: "7C6CF0"))
            TodayStat(value: "\(store.currentStreak)",
                      label: "Day streak", color: Color(hex: "FFB454"))
            TodayStat(value: "\(store.booksReading)",
                      label: "In progress", color: Color(hex: "5AA9FF"))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book")
                .font(.system(size: 46))
                .foregroundStyle(Color(hex: "7C6CF0").opacity(0.6))
            Text("No book in progress")
                .font(.headline).foregroundStyle(.white.opacity(0.5))
            Text("Start a book from your Shelf to track it here.")
                .font(.subheadline).foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }
}

struct TodayStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1).minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "15151F")))
    }
}

struct NowReadingRow: View {
    @EnvironmentObject var store: LibraryStore
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [book.color, book.color.opacity(0.5)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 60)
                    .overlay(Image(systemName: "book.closed.fill")
                        .font(.system(size: 16)).foregroundStyle(.white.opacity(0.9)))
                VStack(alignment: .leading, spacing: 3) {
                    Text(book.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white).lineLimit(1)
                    Text(book.author.isEmpty ? "Unknown author" : book.author)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.45)).lineLimit(1)
                    Text("\(book.currentPage) / \(book.totalPages) p · \(Int(book.progress * 100))%")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            }
            ProgressView(value: book.progress).tint(book.color)
            HStack(spacing: 10) {
                ForEach([10, 25, 50], id: \.self) { n in
                    Button("+\(n)") {
                        store.logProgress(for: book, to: book.currentPage + n)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 9).fill(book.color.opacity(0.18)))
                    .foregroundStyle(book.color)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "15151F")))
    }
}
