import Foundation
import Observation

/// Identidade pública do usuário: @usuário, status e bio.
/// Usada pelo perfil (editar/completar perfil) e pelo social (busca de amigos, perfil público).
@Observable
final class ProfileIdentityStore {
    static let shared = ProfileIdentityStore()

    /// @usuário único (só letras minúsculas, números e "_", 3–20 caracteres). Vazio = ainda não escolhido.
    var username: String { didSet { save() } }
    /// Status curto com emoji (ex.: "📖 Lendo Salmos"). Vazio = sem status.
    var status: String { didSet { save() } }
    /// Frase curta do perfil.
    var bio: String { didSet { save() } }
    /// Data em que o usuário entrou no app (mostrada como "Desde set. 2026").
    let joinedAt: Date

    private static let key = "manna.identity.v1"

    private struct Snapshot: Codable {
        var username: String
        var status: String
        var bio: String
        var joinedAt: Date
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            username = snap.username
            status = snap.status
            bio = snap.bio
            joinedAt = snap.joinedAt
        } else {
            username = ""
            status = ""
            bio = ""
            joinedAt = Date()
            save()
        }
    }

    var hasUsername: Bool { !username.isEmpty }

    /// Normaliza o texto digitado para um @usuário válido.
    static func sanitize(_ raw: String) -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789_")
        let folded = raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        return String(folded.filter { allowed.contains($0) }.prefix(20))
    }

    static func isValid(_ username: String) -> Bool {
        username.count >= 3 && username == sanitize(username)
    }

    private func save() {
        let snap = Snapshot(username: username, status: status, bio: bio, joinedAt: joinedAt)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}
