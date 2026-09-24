import Foundation
import Observation

// MARK: - Conteúdo (carregado de JSON no bundle)

/// Uma jornada = um curso completo (ex.: "Vida de Jesus"). Arquivos `jornada-*.json` no bundle.
struct Journey: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    /// Frase curta para o seletor de cursos.
    let subtitle: String?
    /// SF Symbol do curso no seletor.
    let icon: String?
    /// Ordem no seletor (menor primeiro).
    let order: Int?
    let units: [JourneyUnit]

    var allLessons: [Lesson] { units.flatMap(\.lessons) }
}

/// Uma unidade da jornada (cartão colorido no topo da trilha).
struct JourneyUnit: Codable, Identifiable, Hashable {
    let id: String
    let title: String        // ex.: "Unidade 1"
    let subtitle: String     // ex.: "O nascimento de Jesus"
    let lessons: [Lesson]
    /// Guia da unidade (botão de caderno no cartão da unidade).
    let guide: UnitGuide?
}

/// Guia de estudo da unidade: resumo + versículos-chave.
struct UnitGuide: Codable, Hashable {
    let summary: String
    let keyVerses: [KeyVerse]
}

struct KeyVerse: Codable, Hashable {
    let reference: String
    let text: String
}

/// Uma lição = um círculo da trilha.
struct Lesson: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    /// SF Symbol do círculo da trilha (ex.: "star.fill", "book.fill", "person.2.fill").
    let icon: String
    let exercises: [Exercise]
}

enum ExerciseKind: String, Codable, CaseIterable {
    /// Escolher 1 entre 2–4 opções. Usa `options` + `answer`.
    case multipleChoice
    /// Montar o versículo tocando nos blocos. Usa `tokens` (ordem correta) + `distractors`.
    case buildVerse
    /// Associar pares em duas colunas. Usa `pairs`.
    case matchPairs
    /// Verdadeiro ou falso. Usa `statement` + `isTrue`.
    case trueFalse
    /// Ouvir (voz sintetizada lê `text`) e escolher. Usa `text` (lido em voz alta, não mostrado) + `options` + `answer`.
    case listen
    /// Digitar a palavra/trecho que falta. Usa `text` (com "___") + `answer`; `options` opcional = respostas alternativas aceitas.
    case typeAnswer
    /// Colocar acontecimentos em ordem. Usa `tokens` (ordem correta, 3–5 itens).
    case orderEvents
    /// Ler o versículo em voz alta (reconhecimento de fala). Usa `text` (versículo) + `reference`.
    case speak
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

    // multipleChoice / listen / typeAnswer
    let options: [String]?
    let answer: String?

    // buildVerse / orderEvents
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

// MARK: - Histórias (estilo "Stories": leitura curta com perguntas no meio)

struct Story: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    /// SF Symbol da capa.
    let icon: String
    let reference: String
    let steps: [StoryStep]
}

/// Passo de uma história: uma fala (`line`) ou uma pergunta (`question`).
struct StoryStep: Codable, Hashable {
    enum Kind: String, Codable { case line, question }
    let kind: Kind
    /// Quem fala (line) — "Narrador" para narração.
    let speaker: String?
    /// Fala (line) ou pergunta (question).
    let text: String
    /// Só em `question`.
    let options: [String]?
    let answer: String?
}

// MARK: - Carregamento

@Observable
final class ContentStore {
    private(set) var journeys: [Journey] = []
    private(set) var stories: [Story] = []
    private(set) var loadError: String?

    /// Curso escolhido no seletor (persistido).
    var selectedJourneyId: String {
        didSet { UserDefaults.standard.set(selectedJourneyId, forKey: Self.selectedKey) }
    }

    static let defaultJourneyId = "vida-de-jesus"
    private static let selectedKey = "manna.selectedJourneyId"

    /// Curso atual (o que a trilha mostra).
    var journey: Journey? {
        journeys.first { $0.id == selectedJourneyId } ?? journeys.first
    }

    init(bundle: Bundle = .main) {
        selectedJourneyId = UserDefaults.standard.string(forKey: Self.selectedKey) ?? Self.defaultJourneyId

        let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        var errors: [String] = []
        var loaded: [Journey] = []
        for url in urls where url.lastPathComponent.hasPrefix("jornada-") {
            do {
                loaded.append(try JSONDecoder().decode(Journey.self, from: Data(contentsOf: url)))
            } catch {
                errors.append("\(url.lastPathComponent): \(error)")
            }
        }
        journeys = loaded.sorted { ($0.order ?? 99, $0.title) < ($1.order ?? 99, $1.title) }

        if let url = bundle.url(forResource: "historias", withExtension: "json") {
            do {
                stories = try JSONDecoder().decode([Story].self, from: Data(contentsOf: url))
            } catch {
                errors.append("historias.json: \(error)")
            }
        }

        if journeys.isEmpty {
            loadError = errors.isEmpty ? "Nenhuma jornada encontrada no app." : errors.joined(separator: "\n")
        } else if !errors.isEmpty {
            print("⚠️ Conteúdo com erro:\n" + errors.joined(separator: "\n"))
        }
    }

    func journey(id: String) -> Journey? { journeys.first { $0.id == id } }

    func unit(containing lessonId: String) -> JourneyUnit? {
        for journey in journeys {
            if let unit = journey.units.first(where: { $0.lessons.contains { $0.id == lessonId } }) { return unit }
        }
        return nil
    }

    func lesson(id: String) -> Lesson? {
        journeys.lazy.flatMap(\.allLessons).first { $0.id == id }
    }

    /// Procura um exercício em qualquer jornada (usado pela revisão de erros).
    func exercise(id: String) -> Exercise? {
        for journey in journeys {
            for lesson in journey.allLessons {
                if let ex = lesson.exercises.first(where: { $0.id == id }) { return ex }
            }
        }
        return nil
    }
}
