import SwiftUI

// MARK: - Finished books timeline

struct FinishedView: View {
    @EnvironmentObject var store: LibraryStore

    private let fmt: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    var body: some View {
        ZStack {
            Color(hex: "0B0B12").ignoresSafeArea()

            if store.finished.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.finished) { book in
                            NavigationLink(value: book.id) {
                                FinishedRow(book: book,
                                            dateStr: book.dateFinished.map { fmt.string(from: $0) } ?? "")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Finished")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: UUID.self) { id in
            BookDetailView(bookID: id)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 46))
                .foregroundStyle(Color(hex: "5BD58A").opacity(0.6))
            Text("No finished books yet")
                .font(.headline).foregroundStyle(.white.opacity(0.5))
            Text("Books you complete will appear here.")
                .font(.subheadline).foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct FinishedRow: View {
    let book: Book
    let dateStr: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [book.color, book.color.opacity(0.5)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 40, height: 56)
                .overlay(Image(systemName: "book.closed.fill")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.9)))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white).lineLimit(1)
                Text(book.author.isEmpty ? "Unknown author" : book.author)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45)).lineLimit(1)
                HStack(spacing: 8) {
                    RatingStars(rating: book.rating, size: 10)
                    if !dateStr.isEmpty {
                        Text(dateStr).font(.system(size: 10)).foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "15151F")))
    }
}
