import Foundation
import Observation

/// Versículo aprendido pelo usuário (de guias, exercícios buildVerse/speak com reference).
struct SavedVerse: Codable, Hashable, Identifiable {
    let id: String  // = "\(reference)-\(text.prefix(20))"
    let reference: String
    let text: String
    var savedAt: Date = Date()
    var memorized: Bool = false

    init(reference: String, text: String, id: String? = nil) {
        self.reference = reference
        self.text = text
        self.id = id ?? "\(reference)-\(text.prefix(20)).hashValue"
        self.savedAt = Date()
    }
}

/// Store para gerenciar versículos aprendidos.
/// Salvo em UserDefaults com chave "manna.verses.v1".
@Observable
final class VersesStore {
    static let shared = VersesStore()

    private(set) var verses: [SavedVerse] = [] { didSet { save() } }

    private let key = "manna.verses.v1"
    @ObservationIgnored private var isLoading = false

    init() {
        load()
    }

    /// Adiciona um versículo (evita duplicatas por reference + text).
    func addVerse(_ reference: String, text: String) {
        let verse = SavedVerse(reference: reference, text: text)
        // Verifica se já existe (por reference e text)
        guard !verses.contains(where: { $0.reference == reference && $0.text == text }) else { return }
        verses.append(verse)
        save()
    }

    /// Marca um versículo como "memorizado".
    func toggleMemorized(_ verseId: String) {
        if let index = verses.firstIndex(where: { $0.id == verseId }) {
            verses[index].memorized.toggle()
            save()
        }
    }

    /// Remove um versículo da lista.
    func removeVerse(_ verseId: String) {
        verses.removeAll { $0.id == verseId }
        save()
    }

    /// Ordena versículos por recentes, A-Z ou livro.
    func sorted(by: SortOption) -> [SavedVerse] {
        switch by {
        case .recent:
            return verses.sorted { $0.savedAt > $1.savedAt }
        case .alphabetical:
            return verses.sorted { $0.text < $1.text }
        case .book:
            return verses.sorted { $0.reference < $1.reference }
        }
    }

    enum SortOption: String, CaseIterable {
        case recent = "Recentes"
        case alphabetical = "A–Z"
        case book = "Livro"
    }

    private func save() {
        guard !isLoading else { return }
        do {
            let data = try JSONEncoder().encode(verses)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("VersesStore.save error: \(error)")
        }
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            verses = try JSONDecoder().decode([SavedVerse].self, from: data)
        } catch {
            print("VersesStore.load error: \(error)")
            verses = []
        }
    }
}
