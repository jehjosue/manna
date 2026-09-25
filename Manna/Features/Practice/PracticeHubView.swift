import SwiftUI

/// Hub de prática: revisão de erros, treino de versículos, desafio relâmpago, histórias.
struct PracticeHubView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @State private var selectedCard: PracticeCard?
    @State private var showLessonView = false
    @State private var syntethicLesson: Lesson?
    @State private var showChallenge = false
    @State private var challengePairs: [(left: String, right: String)] = []
    @State private var showCelebration = false
    @State private var lastOutcome: LessonOutcome?

    enum PracticeCard {
        case reviewErrors, verseTraining, challenge, stories
    }

    var canReviewErrors: Bool { !game.mistakeIds.isEmpty }
    var canTrainVerses: Bool { game.completedLessonCount > 0 }
    @State private var showMyVerses = false
    @State private var showMistakesList = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Cabeçalho
                    VStack(spacing: 8) {
                        HStack {
                            Text("Praticar")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        Text("Melhore suas habilidades com exercícios adicionais")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)

                    ScrollView {
                        VStack(spacing: 16) {
                            // Card 1: Revisar erros
                            CardButton(
                                isEnabled: canReviewErrors,
                                icon: GameIconView(icon: .xp, size: 40),
                                title: "Revisar Erros",
                                subtitle: canReviewErrors ? "\(game.mistakeIds.count) exercícios" : "Nenhum erro",
                                onTap: { selectedCard = .reviewErrors }
                            )

                            // Card 2: Treino de versículos
                            CardButton(
                                isEnabled: canTrainVerses,
                                icon: Image(systemName: "book.fill").font(.system(size: 28)).foregroundStyle(Theme.oil),
                                title: "Treino de Versículos",
                                subtitle: canTrainVerses ? "Exercícios aleatórios" : "Complete uma lição primeiro",
                                onTap: { selectedCard = .verseTraining }
                            )

                            // Card 3: Desafio relâmpago
                            CardButton(
                                isEnabled: canTrainVerses,
                                icon: Image(systemName: "bolt.fill").font(.system(size: 28)).foregroundStyle(Theme.manna),
                                title: "Desafio Relâmpago",
                                subtitle: "60 segundos, associar pares",
                                onTap: { selectedCard = .challenge }
                            )

                            // Card 4: Histórias
                            NavigationLink(destination: StoriesListView()) {
                                HStack(spacing: 16) {
                                    Image(systemName: "book.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Theme.rest)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Histórias")
                                            .font(Theme.font(18, .heavy))
                                            .foregroundStyle(Theme.ink)
                                        Text("Leia histórias bíblicas curtas")
                                            .font(Theme.font(14, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(16)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            // Card 5: Meus versículos
                            CardButton(
                                isEnabled: game.completedLessonCount > 0,
                                icon: Image(systemName: "book.pages.fill").font(.system(size: 28)).foregroundStyle(Theme.bread),
                                title: "Meus Versículos",
                                subtitle: game.completedLessonCount > 0 ? "Coleção de versículos" : "Complete uma lição primeiro",
                                onTap: { showMyVerses = true }
                            )

                            // Card 6: Lista de erros
                            CardButton(
                                isEnabled: canReviewErrors,
                                icon: Image(systemName: "list.bullet").font(.system(size: 28)).foregroundStyle(Theme.terracotta),
                                title: "Lista de Erros",
                                subtitle: canReviewErrors ? "\(game.mistakeIds.count) exercício\(game.mistakeIds.count == 1 ? "" : "s")" : "Nenhum erro",
                                onTap: { showMistakesList = true }
                            )

                            // PracticeModesSection
                            PracticeModesSection()

                            // Info card
                            HStack(spacing: 12) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Theme.oil)
                                Text("Praticar devolve 1 gota de óleo 🪔")
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                            }
                            .padding(16)
                            .background(Theme.oil.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(16)
                    }
                }
            }
        }
        .onChange(of: selectedCard) { _, newCard in
            handleCardSelection(newCard)
        }
        .sheet(isPresented: $showLessonView) {
            if let lesson = syntethicLesson {
                LessonView(
                    lesson: lesson,
                    mode: .practice,
                    onFinish: { outcome in
                        lastOutcome = outcome
                        showLessonView = false
                        showCelebration = true
                    },
                    onQuit: { showLessonView = false }
                )
            }
        }
        .sheet(isPresented: $showChallenge) {
            ChallengeView(pairs: challengePairs) { score in
                let outcome = LessonOutcome(
                    lessonId: "challenge",
                    correctCount: score,
                    totalCount: challengePairs.count,
                    mistakes: challengePairs.count - score
                )
                lastOutcome = outcome
                showChallenge = false
                showCelebration = true
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let outcome = lastOutcome {
                let kind: ActivityKind = (outcome.lessonId == "challenge") ? .challenge : .practice
                let result = game.completeActivity(outcome, kind: kind, baseXP: min(30, outcome.correctCount))
                CelebrationFlowView(result: result) {
                    showCelebration = false
                    selectedCard = nil
                }
            }
        }
        .sheet(isPresented: $showMyVerses) {
            MyVersesView()
        }
        .sheet(isPresented: $showMistakesList) {
            MistakesListView()
        }
    }

    private func handleCardSelection(_ card: PracticeCard?) {
        guard let card = card else { return }

        switch card {
        case .reviewErrors:
            createReviewErrorsLesson()

        case .verseTraining:
            createVerseTrainingLesson()

        case .challenge:
            prepareChallenge()

        case .stories:
            break  // NavigationLink já cuida
        }
    }

    private func createReviewErrorsLesson() {
        let exercises = game.mistakeIds.prefix(10).compactMap { content.exercise(id: $0) }
        guard !exercises.isEmpty else { return }

        let today = GameState.dayKey(Date())
        let lesson = Lesson(
            id: "practice-mistakes-\(today)",
            title: "Revisar Erros",
            icon: "arrow.counterclockwise",
            exercises: exercises
        )
        syntethicLesson = lesson
        showLessonView = true
    }

    private func createVerseTrainingLesson() {
        guard let journey = content.journey else { return }

        // Pegar até 10 exercícios aleatórios de lições concluídas
        let verseKinds: Set<ExerciseKind> = [.buildVerse, .typeAnswer, .listen, .speak]
        let completedLessons = journey.allLessons.filter { game.isCompleted($0.id) }
        let verseExercises: [Exercise] = completedLessons.flatMap { $0.exercises }.filter { verseKinds.contains($0.kind) }
        let completedExercises = verseExercises.shuffled().prefix(10)

        guard !completedExercises.isEmpty else { return }

        let lesson = Lesson(
            id: "practice-verses",
            title: "Treino de Versículos",
            icon: "book.fill",
            exercises: Array(completedExercises)
        )
        syntethicLesson = lesson
        showLessonView = true
    }

    private func prepareChallenge() {
        guard let journey = content.journey else { return }

        // Pegar até 5 exercícios matchPairs de lições concluídas
        let matchPairExercises = journey.allLessons
            .filter { game.isCompleted($0.id) }
            .flatMap { $0.exercises }
            .filter { $0.kind == .matchPairs }
            .shuffled()
            .prefix(5)

        var pairs: [(String, String)] = []
        for exercise in matchPairExercises {
            if let exercisePairs = exercise.pairs {
                pairs.append(contentsOf: exercisePairs.map { ($0.left, $0.right) })
            }
        }

        guard !pairs.isEmpty else { return }
        challengePairs = Array(pairs.prefix(10))
        showChallenge = true
    }
}

/// Cartão de uma opção de prática.
struct CardButton<Icon: View>: View {
    let isEnabled: Bool
    let icon: Icon
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                icon
                    .frame(width: 60, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.font(18, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if isEnabled {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .padding(16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    PracticeHubView()
        .environment(GameState())
        .environment(ContentStore())
}
