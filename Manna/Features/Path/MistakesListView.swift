import SwiftUI

/// Lista de erros: todos os exercícios em game.mistakeIds com resposta certa e explicação.
/// Botão "Revisar agora" abre a lição.
struct MistakesListView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMistakeId: String?
    @State private var showLessonView = false
    @State private var reviewLesson: Lesson?
    @State private var showCelebration = false
    @State private var lastResult: LessonResult?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        Text("Seus Erros")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                    }
                    .padding(16)

                    ScrollView {
                        VStack(spacing: 12) {
                            if game.mistakeIds.isEmpty {
                                VStack(spacing: 12) {
                                    SheepView(mood: .cheering, size: 100)
                                    Text("Nenhum erro para revisar!")
                                        .font(Theme.font(20, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Você está indo muito bem 🎉")
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(32)
                            } else {
                                VStack(spacing: 10) {
                                    Text("Você errou \(game.mistakeIds.count) exercício\(game.mistakeIds.count == 1 ? "" : "s"). Revise para não errar de novo!")
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom, 8)

                                    ForEach(game.mistakeIds, id: \.self) { exerciseId in
                                        if let exercise = content.exercise(id: exerciseId) {
                                            mistakeCard(exercise)
                                        }
                                    }
                                }
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(16)
                    }

                    // Botão "Revisar Agora" (como em PracticeHubView)
                    if !game.mistakeIds.isEmpty {
                        Button(action: createReviewLesson) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Revisar Agora")
                            }
                            .font(Theme.font(16, .heavy))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(Theme.terracotta)
                            .cornerRadius(12)
                        }
                        .padding(16)
                    }
                }
            }
        }
        .sheet(isPresented: $showLessonView) {
            if let lesson = reviewLesson {
                LessonView(
                    lesson: lesson,
                    mode: .practice,
                    onFinish: { outcome in
                        lastResult = game.completeActivity(outcome, kind: .practice, baseXP: min(30, outcome.correctCount))
                        showLessonView = false
                        showCelebration = true
                    },
                    onQuit: { showLessonView = false }
                )
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let result = lastResult {
                CelebrationFlowView(result: result) {
                    showCelebration = false
                }
            }
        }
    }

    @ViewBuilder
    private func mistakeCard(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tipo de exercício + prompt
            HStack(spacing: 8) {
                Image(systemName: exerciseIcon(exercise.kind))
                    .foregroundStyle(Theme.terracotta)
                    .font(.system(size: 14, weight: .bold))

                Text(exercise.prompt)
                    .font(Theme.font(13, .heavy))
                    .foregroundStyle(Theme.ink)

                Spacer()
            }

            // Resposta esperada
            if let answer = exercise.answer {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resposta correta")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.olive)

                    Text(answer)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Theme.cream)
                .cornerRadius(6)
            }

            // Referência bíblica se houver
            if let ref = exercise.reference {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text(ref)
                        .font(Theme.font(12, .semibold))
                }
                .foregroundStyle(Theme.oil)
            }
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }

    private func exerciseIcon(_ kind: ExerciseKind) -> String {
        switch kind {
        case .multipleChoice: return "list.bullet"
        case .buildVerse: return "square.grid.2x2"
        case .matchPairs: return "link"
        case .trueFalse: return "checkmark.circle"
        case .listen: return "speaker.wave.2"
        case .typeAnswer: return "keyboard"
        case .orderEvents: return "list.number"
        case .speak: return "mic"
        }
    }

    private func createReviewLesson() {
        let exercises = game.mistakeIds.prefix(10).compactMap { content.exercise(id: $0) }
        guard !exercises.isEmpty else { return }

        let today = GameState.dayKey(Date())
        let lesson = Lesson(
            id: "mistakes-review-\(today)",
            title: "Revisar Erros",
            icon: "arrow.counterclockwise",
            exercises: exercises
        )
        reviewLesson = lesson
        showLessonView = true
    }
}

#Preview {
    MistakesListView()
        .environment(GameState())
        .environment(ContentStore())
}
