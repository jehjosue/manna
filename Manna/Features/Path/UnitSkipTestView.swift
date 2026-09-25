import SwiftUI

/// Teste para pular uma unidade: ~12 exercícios modo .legendary.
/// Se passar, marca todas as lições da unidade como concluídas.
struct UnitSkipTestView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content

    let unit: JourneyUnit
    let onDone: () -> Void

    @State private var showLessonView = false
    @State private var skipLesson: Lesson?
    @State private var showCelebration = false
    @State private var lastResult: LessonResult?
    @State private var showFailed = false

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            if let lesson = skipLesson, showLessonView {
                LessonView(
                    lesson: lesson,
                    mode: .legendary,
                    onFinish: { outcome in
                        showLessonView = false
                        // Passa com pelo menos 80% de acerto na primeira tentativa.
                        let total = max(outcome.totalCount, 1)
                        guard Double(outcome.correctCount) / Double(total) >= 0.8 else {
                            showFailed = true
                            return
                        }
                        lastResult = game.completeActivity(outcome, kind: .practice, baseXP: 40)
                        game.markLessonsCompleted(unit.lessons.map { $0.id })
                        showCelebration = true
                    },
                    onQuit: {
                        showLessonView = false
                        onDone()
                    }
                )
            } else {
                VStack(spacing: 20) {
                    SheepView(mood: .thinking, size: 100)

                    VStack(spacing: 8) {
                        Text("Teste para Pular")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)

                        Text("Complete 12 exercícios para pular esta unidade inteira!")
                            .font(Theme.font(16, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: { prepareSkipTest() }) {
                            Text("Começar Teste")
                        }
                        .buttonStyle(.chunky)

                        Button(action: onDone) {
                            Text("Voltar")
                        }
                        .buttonStyle(.chunkyNight)
                    }
                }
                .padding(24)
            }
        }
        .alert("Quase lá!", isPresented: $showFailed) {
            Button("Tentar de novo") { prepareSkipTest() }
            Button("Voltar", role: .cancel) { onDone() }
        } message: {
            Text("Você precisa acertar 80% para pular esta unidade.")
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let result = lastResult {
                CelebrationFlowView(result: result) {
                    showCelebration = false
                    onDone()
                }
            }
        }
    }

    private func prepareSkipTest() {
        // Seleciona até 12 exercícios aleatórios das lições da unidade
        var allExercises: [Exercise] = []
        for lesson in unit.lessons {
            allExercises.append(contentsOf: lesson.exercises)
        }
        guard !allExercises.isEmpty else { return }

        let selectedExercises = Array(allExercises.shuffled().prefix(min(12, allExercises.count)))
        let lesson = Lesson(
            id: "skip-test-\(unit.id)",
            title: "Teste para Pular",
            icon: "star.fill",
            exercises: selectedExercises
        )

        skipLesson = lesson
        showLessonView = true
    }
}

#Preview {
    UnitSkipTestView(
        unit: JourneyUnit(
            id: "u1",
            title: "Unidade 1",
            subtitle: "O Nascimento",
            lessons: [],
            guide: nil
        ),
        onDone: {}
    )
    .environment(GameState())
    .environment(ContentStore())
}
