import Foundation
import Observation

// MARK: - Conteúdo (carregado de JSON no bundle)

/// Uma jornada = um curso completo (ex.: "Vida de Jesus").
struct Journey: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let units: [JourneyUnit]

    var allLessons: [Lesson] { units.flatMap(\.lessons) }
}

/// Uma unidade da jornada (cartão colorido no topo da trilha).
struct JourneyUnit: Codable, Identifiable, Hashable {
    let id: String
    let title: String        // ex.: "Unidade 1"
    let subtitle: String     // ex.: "O nascimento de Jesus"
    let lessons: [Lesson]
}

/// Uma lição = um círculo da trilha.
struct Lesson: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    /// SF Symbol do círculo da trilha (ex.: "star.fill", "book.fill", "person.2.fill").
    let icon: String
    let exercises: [Exercise]
}

enum ExerciseKind: String, Codable {
    /// Escolher 1 entre 2–4 opções. Usa `options` + `answer`.
    case multipleChoice
    /// Montar o versículo tocando nos blocos. Usa `tokens` (ordem correta) + `distractors`.
    case buildVerse
    /// Associar pares em duas colunas. Usa `pairs`.
    case matchPairs
    /// Verdadeiro ou falso. Usa `statement` + `isTrue`.
    case trueFalse
}

struct MatchPair: Codable, Hashable {
    let left: String
    let right: String
}

/// Exercício genérico: campos opcionais conforme `kind`.
struct Exercise: Codable, Identifiable, Hashable {
    let id: String
    let kind: ExerciseKind
    /// Instrução no topo (ex.: "Complete o versículo").
    let prompt: String
    /// Personagem bíblico que "fala" no balão (opcional, ex.: "Pedro").
    let speaker: String?
    /// Texto no balão / enunciado principal (ex.: o versículo com lacuna "Porque Deus amou o ___").
    let text: String?
    /// Referência bíblica (ex.: "João 3:16").
    let reference: String?

    // multipleChoice
    let options: [String]?
    let answer: String?

    // buildVerse
    let tokens: [String]?
    let distractors: [String]?

    // matchPairs
    let pairs: [MatchPair]?

    // trueFalse
    let statement: String?
    let isTrue: Bool?

    /// Explicação curta mostrada na faixa de erro/acerto.
    let explanation: String?
}

// MARK: - Carregamento

@Observable
final class ContentStore {
    private(set) var journey: Journey?
    private(set) var loadError: String?

    static let defaultJourneyFile = "jornada-vida-de-jesus"

    init(file: String = ContentStore.defaultJourneyFile) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            loadError = "Arquivo \(file).json não encontrado no app."
            return
        }
        do {
            journey = try JSONDecoder().decode(Journey.self, from: Data(contentsOf: url))
        } catch {
            loadError = "Erro ao ler \(file).json: \(error)"
        }
    }

    func unit(containing lessonId: String) -> JourneyUnit? {
        journey?.units.first { $0.lessons.contains { $0.id == lessonId } }
    }
}
