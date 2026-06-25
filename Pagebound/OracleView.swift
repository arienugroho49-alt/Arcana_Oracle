import SwiftUI

// MARK: - Shelf (library) screen

struct ShelfView: View {
    @EnvironmentObject var store: LibraryStore
    @State private var filter: ReadingStatus = .reading
    @State private var showAdd = false

    private let columns = [GridItem(.flexible(), spacing: 14),
                           GridItem(.flexible(), spacing: 14)]

    private var items: [Book] { store.books(in: filter) }

    var body: some View {
        ZStack {
            Color(hex: "0B0B12").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    filterBar.padding(.top, 6)

                    if items.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(items) { book in
                                NavigationLink(value: book.id) {
                                    BookCard(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("My Shelf")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                }
                .tint(Color(hex: "7C6CF0"))
            }
        }
        .navigationDestination(for: UUID.self) { id in
            BookDetailView(bookID: id)
        }
        .sheet(isPresented: $showAdd) { AddBookView() }
    }

    private var filterBar: some View {
        Picker("Filter", selection: $filter) {
            ForEach(ReadingStatus.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 50))
                .foregroundStyle(Color(hex: "7C6CF0").opacity(0.7))
            Text(emptyTitle)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.5))
            Text("Tap + to add a book.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var emptyTitle: String {
        switch filter {
        case .reading:    return "Nothing in progress"
        case .wantToRead: return "Your wishlist is empty"
        case .finished:   return "No finished books yet"
        }
    }
}

// MARK: - Book cover card

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [book.color, book.color.opacity(0.55)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 150)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1))
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(12)
            }

            Text(book.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(book.author.isEmpty ? "Unknown author" : book.author)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)

            if book.status == .reading {
                ProgressView(value: book.progress).tint(book.color)
                Text("\(book.currentPage)/\(book.totalPages) p")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            } else if book.status == .finished {
                RatingStars(rating: book.rating, size: 11)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "15151F")))
    }
}

// MARK: - Reusable rating stars

struct RatingStars: View {
    let rating: Int
    var size: CGFloat = 14
    var onTap: ((Int) -> Void)? = nil

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(i <= rating ? Color(hex: "FFB454") : .white.opacity(0.25))
                    .onTapGesture { onTap?(i) }
            }
        }
    }
}
