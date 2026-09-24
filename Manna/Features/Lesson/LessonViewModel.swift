import Foundation
import Observation

/// Resultado mostrado na faixa de acerto/erro.
struct LessonFeedback: Equatable {
    let isCorrect: Bool
    let title: String
    let correctAnswer: String?
    let explanation: String?
}

/// Toda a lógica de uma lição: fila de exercícios, respostas, verificação e contagem.
@Observable
final class LessonViewModel {
    let lesson: Lesson

    // Fila: o exercício atual é sempre o primeiro.
    private(set) var queue: [Exercise]
    private var retried: Set<String> = []
    private var wrongIds: [String] = []
    private var rightIds: [String] = []

    // Contagem
    private(set) var finishedCount = 0          // exercícios resolvidos (para a barra de progresso)
    private(set) var firstTryCorrect = 0
    private(set) var mistakes = 0
    private(set) var streak = 0                 // acertos seguidos ("N SEGUIDAS")
    let totalCount: Int

    // Estado da tela
    private(set) var feedback: LessonFeedback?
    var showIncentive = false
    private var incentiveShown = false

    // Resposta atual — múltipla escolha / verdadeiro ou falso
    var selectedOption: String?
    var selectedBool: Bool?

    // Resposta atual — montar versículo (índices dentro de `bank`, para aceitar palavras repetidas)
    private(set) var bank: [String] = []
    private(set) var built: [Int] = []

    // Resposta atual — associar pares
    private(set) var leftItems: [String] = []
    private(set) var rightItems: [String] = []
    private(set) var leftSelected: Int?
    private(set) var rightSelected: Int?
    private(set) var matchedLeft: Set<Int> = []
    private(set) var matchedRight: Set<Int> = []
    private(set) var wrongFlash: (left: Int, right: Int)?
    private var mistakesInCurrentMatch = 0

    private static let praise = ["Muito bem!", "Isso mesmo!", "Glória a Deus!", "Excelente!", "Perfeito!"]

    init(lesson: Lesson) {
        self.lesson = lesson
        self.queue = lesson.exercises
        self.totalCount = lesson.exercises.count
        prepareCurrent()
    }

    var current: Exercise? { queue.first }
    var isFinished: Bool { queue.isEmpty }
    var progress: Double { totalCount == 0 ? 0 : Double(finishedCount) / Double(totalCount) }
    var isShowingFeedback: Bool { feedback != nil }

    var canCheck: Bool {
        guard let exercise = current, feedback == nil else { return false }
        switch exercise.kind {
        case .multipleChoice: return selectedOption != nil
        case .trueFalse: return selectedBool != nil
        case .buildVerse: return !built.isEmpty
        case .matchPairs: return false   // termina sozinho
        }
    }

    var outcome: LessonOutcome {
        LessonOutcome(
            lessonId: lesson.id, correctCount: firstTryCorrect, totalCount: totalCount, mistakes: mistakes,
            wrongExerciseIds: wrongIds, correctExerciseIds: rightIds.filter { !wrongIds.contains($0) }
        )
    }

    // MARK: Montar versículo

    func isUsed(bankIndex: Int) -> Bool { built.contains(bankIndex) }

    func tapBank(_ index: Int) {
        guard feedback == nil, !built.contains(index) else { return }
        built.append(index)
    }

    func tapBuilt(at position: Int) {
        guard feedback == nil, built.indices.contains(position) else { return }
        built.remove(at: position)
    }

    // MARK: Associar pares

    func tapLeft(_ index: Int) {
        guard feedback == nil, wrongFlash == nil, !matchedLeft.contains(index) else { return }
        leftSelected = leftSelected == index ? nil : index
        evaluatePairIfReady()
    }

    func tapRight(_ index: Int) {
        guard feedback == nil, wrongFlash == nil, !matchedRight.contains(index) else { return }
        rightSelected = rightSelected == index ? nil : index
        evaluatePairIfReady()
    }

    private func evaluatePairIfReady() {
        guard let l = leftSelected, let r = rightSelected, let pairs = current?.pairs else { return }
        let isMatch = pairs.contains { $0.left == leftItems[l] && $0.right == rightItems[r] }
        leftSelected = nil
        rightSelected = nil
        if isMatch {
            matchedLeft.insert(l)
            matchedRight.insert(r)
            if matchedLeft.count == pairs.count { finishMatchPairs() }
        } else {
            // Erro em par conta como erro, mas não gasta óleo.
            mistakes += 1
            mistakesInCurrentMatch += 1
            wrongFlash = (l, r)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.wrongFlash = nil
            }
        }
    }

    private func finishMatchPairs() {
        if mistakesInCurrentMatch == 0 { firstTryCorrect += 1 }
        streak = mistakesInCurrentMatch == 0 ? streak + 1 : 0
        feedback = LessonFeedback(
            isCorrect: true,
            title: Self.praise.randomElement() ?? "Muito bem!",
            correctAnswer: nil,
            explanation: current?.explanation
        )
    }

    // MARK: Verificar / continuar

    /// Verifica a resposta atual. Retorna `true` se acertou. Erros gastam óleo.
    @discardableResult
    func check(game: GameState) -> Bool {
        guard canCheck, let exercise = current else { return false }
        let isCorrect: Bool
        switch exercise.kind {
        case .multipleChoice: isCorrect = selectedOption == exercise.answer
        case .trueFalse: isCorrect = selectedBool == exercise.isTrue
        case .buildVerse: isCorrect = built.map { bank[$0] } == (exercise.tokens ?? [])
        case .matchPairs: return false
        }

        if isCorrect {
            if !retried.contains(exercise.id) { firstTryCorrect += 1 }
            streak += 1
            rightIds.append(exercise.id)
        } else {
            mistakes += 1
            streak = 0
            if !wrongIds.contains(exercise.id) { wrongIds.append(exercise.id) }
            game.loseOil()
        }

        feedback = LessonFeedback(
            isCorrect: isCorrect,
            title: isCorrect ? (Self.praise.randomElement() ?? "Muito bem!") : "Não foi dessa vez",
            correctAnswer: isCorrect ? nil : Self.correctAnswer(for: exercise),
            explanation: exercise.explanation
        )
        return isCorrect
    }

    /// Fecha a faixa e avança. Exercício errado volta uma vez para o fim da fila.
    func continueAfterFeedback() {
        guard let feedback, let exercise = current else { return }
        queue.removeFirst()
        if !feedback.isCorrect && !retried.contains(exercise.id) {
            retried.insert(exercise.id)
            queue.append(exercise)
        } else {
            finishedCount += 1
        }
        self.feedback = nil

        if !incentiveShown && totalCount >= 6 && finishedCount == totalCount / 2 && !queue.isEmpty {
            incentiveShown = true
            showIncentive = true
        }
        prepareCurrent()
    }

    private func prepareCurrent() {
        selectedOption = nil
        selectedBool = nil
        built = []
        bank = []
        leftSelected = nil
        rightSelected = nil
        matchedLeft = []
        matchedRight = []
        wrongFlash = nil
        mistakesInCurrentMatch = 0

        guard let exercise = current else { return }
        switch exercise.kind {
        case .buildVerse:
            bank = ((exercise.tokens ?? []) + (exercise.distractors ?? [])).shuffled()
        case .matchPairs:
            let pairs = exercise.pairs ?? []
            leftItems = pairs.map(\.left).shuffled()
            rightItems = pairs.map(\.right).shuffled()
        case .multipleChoice, .trueFalse:
            break
        }
    }

    static func correctAnswer(for exercise: Exercise) -> String? {
        switch exercise.kind {
        case .multipleChoice: exercise.answer
        case .buildVerse: (exercise.tokens ?? []).joined(separator: " ")
        case .trueFalse: (exercise.isTrue ?? false) ? "Verdadeiro" : "Falso"
        case .matchPairs: nil
        }
    }
}
