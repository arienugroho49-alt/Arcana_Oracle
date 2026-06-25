import SwiftUI

// MARK: - Add Book sheet

struct AddBookView: View {
    @EnvironmentObject var store: LibraryStore
    @Environment(\.dismiss) private var dismiss

    @State private var title      = ""
    @State private var author     = ""
    @State private var totalPages = ""
    @State private var status: ReadingStatus = .wantToRead
    @State private var colorHex   = LibraryStore.palette[0]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && (Int(totalPages) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Book") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Total pages", text: $totalPages)
                        .keyboardType(.numberPad)
                }
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(ReadingStatus.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Cover colour") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(LibraryStore.palette, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 34, height: 34)
                                    .overlay(Circle().strokeBorder(.white,
                                                                   lineWidth: colorHex == hex ? 2 : 0))
                                    .onTapGesture { colorHex = hex }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0B0B12").ignoresSafeArea())
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        let pages = Int(totalPages) ?? 0
        let book = Book(title: title.trimmingCharacters(in: .whitespaces),
                        author: author.trimmingCharacters(in: .whitespaces),
                        totalPages: pages,
                        status: status,
                        colorHex: colorHex)
        store.add(book)
        dismiss()
    }
}

// MARK: - Book detail / progress logger

struct BookDetailView: View {
    @EnvironmentObject var store: LibraryStore
    let bookID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var showDelete = false

    private var book: Book? { store.books.first { $0.id == bookID } }

    var body: some View {
        ZStack {
            Color(hex: "0B0B12").ignoresSafeArea()
            if let book {
                content(book)
            } else {
                Text("Book not found").foregroundStyle(.white.opacity(0.4))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) { showDelete = true } label: {
                    Image(systemName: "trash")
                }
                .tint(Color(hex: "FF7A8A"))
            }
        }
        .alert("Delete this book?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) {
                if let book { store.delete(book); dismiss() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This also removes its logged reading sessions.")
        }
    }

    @ViewBuilder
    private func content(_ book: Book) -> some View {
        ScrollView {
            VStack(spacing: 22) {
                header(book)
                progressSection(book)
                if book.status == .finished { ratingSection(book) }
            }
            .padding(20)
        }
    }

    private func header(_ book: Book) -> some View {
        VStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [book.color, book.color.opacity(0.5)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 170)
                .overlay(Image(systemName: "book.closed.fill")
                    .font(.system(size: 40)).foregroundStyle(.white.opacity(0.9)))

            Text(book.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            if !book.author.isEmpty {
                Text(book.author).font(.subheadline).foregroundStyle(.white.opacity(0.5))
            }
            Label(book.status.rawValue, systemImage: book.status.icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(book.status.tint)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(book.status.tint.opacity(0.12)))
        }
    }

    private func progressSection(_ book: Book) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress").font(.headline).foregroundStyle(.white)
                Spacer()
                Text("\(Int(book.progress * 100))%")
                    .font(.subheadline.weight(.bold).monospaced())
                    .foregroundStyle(book.color)
            }
            ProgressView(value: book.progress).tint(book.color)

            Stepper(value: Binding(get: { book.currentPage },
                                   set: { store.logProgress(for: book, to: $0) }),
                    in: 0...max(book.totalPages, 1)) {
                HStack {
                    Text("Current page").font(.subheadline).foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text("\(book.currentPage) / \(book.totalPages)")
                        .font(.subheadline.monospaced()).foregroundStyle(.white)
                }
            }

            HStack(spacing: 10) {
                ForEach([10, 25, 50], id: \.self) { n in
                    Button("+\(n)") {
                        store.logProgress(for: book, to: book.currentPage + n)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(book.color.opacity(0.18)))
                    .foregroundStyle(book.color)
                }
                Button("Finish") {
                    store.logProgress(for: book, to: book.totalPages)
                }
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "5BD58A").opacity(0.18)))
                .foregroundStyle(Color(hex: "5BD58A"))
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "15151F")))
    }

    private func ratingSection(_ book: Book) -> some View {
        VStack(spacing: 12) {
            Text("Your rating").font(.headline).foregroundStyle(.white)
            RatingStars(rating: book.rating, size: 26) { store.setRating($0, for: book) }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "15151F")))
    }
}
