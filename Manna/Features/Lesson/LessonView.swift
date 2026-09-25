import SwiftUI

/// Tela de uma lição: cabeçalho, exercício atual, botão VERIFICAR e faixa de acerto/erro.
struct LessonView: View {
    @Environment(GameState.self) private var game
    @State private var vm: LessonViewModel
    @State private var showOutOfOil = false
    @State private var showLegendaryLost = false
    @State private var didFinish = false

    let lesson: Lesson
    var mode: LessonMode = .normal
    let onFinish: (LessonOutcome) -> Void
    let onQuit: () -> Void

    init(lesson: Lesson, mode: LessonMode = .normal, onFinish: @escaping (LessonOutcome) -> Void, onQuit: @escaping () -> Void) {
        self.lesson = lesson
        self.mode = mode
        self.onFinish = onFinish
        self.onQuit = onQuit
        self._vm = State(initialValue: LessonViewModel(lesson: lesson))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.card.ignoresSafeArea()

            VStack(spacing: 0) {
                LessonHeader(
                    progress: vm.progress,
                    oil: game.oil,
                    consecutiveCorrect: vm.streak,
                    mode: mode,
                    onQuit: onQuit
                )

                if let exercise = vm.current {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            Text(exercise.prompt)
                                .font(Theme.font(24, .heavy))
                                .foregroundStyle(Theme.ink)
                                .fixedSize(horizontal: false, vertical: true)

                            ExerciseBody(exercise: exercise, vm: vm)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                    .id("\(exercise.id)-\(vm.finishedCount)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .allowsHitTesting(!vm.isShowingFeedback)

                    if exercise.kind != .matchPairs && exercise.kind != .speak {
                        Button("Verificar") { check() }
                            .buttonStyle(.chunky)
                            .disabled(!vm.canCheck)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .opacity(vm.isShowingFeedback ? 0 : 1)
                    }
                } else {
                    Spacer()
                }
            }

            if let feedback = vm.feedback {
                FeedbackBanner(
                    isCorrect: feedback.isCorrect,
                    title: feedback.title,
                    explanation: feedback.explanation,
                    correctAnswer: feedback.correctAnswer,
                    exercise: vm.current,
                    onContinue: advance
                )
                .transition(.move(edge: .bottom))
            }

            if vm.showIncentive {
                IncentiveOverlay { vm.showIncentive = false }
                    .transition(.opacity)
            }

            if showOutOfOil {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    OutOfOilSheet(onQuit: onQuit)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 60)
                }
                .transition(.opacity)
            }

            if showLegendaryLost {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 24) {
                        SheepView(mood: .sad, size: 140)
                        Text("Quase lá!")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)
                        Text("Você cometeu 3 erros. Tente de novo!")
                            .font(Theme.font(16, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .multilineTextAlignment(.center)
                        Button("Voltar") { onQuit() }
                            .buttonStyle(.chunky)
                            .padding(.horizontal, 16)
                    }
                    .padding(24)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 12)
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.feedback)
        .animation(.easeInOut(duration: 0.25), value: vm.showIncentive)
        .animation(.easeInOut(duration: 0.25), value: showOutOfOil)
        .onChange(of: game.oil) { _, oil in
            // Encheu a lamparina com maná: volta para a lição.
            if oil > 0 { showOutOfOil = false }
        }
        .onChange(of: vm.speechAttempt) { _, attempt in
            // Fala: o reconhecimento terminou → verifica automaticamente (certo ou errado).
            if attempt != nil && vm.current?.kind == .speak && !vm.isShowingFeedback {
                check()
            }
        }
        .onChange(of: vm.isFinished) { _, finished in
            // Termina tanto ao continuar depois do último exercício quanto ao pular o último.
            if finished && !didFinish {
                didFinish = true
                onFinish(vm.outcome)
            }
        }
    }

    private func check() {
        let shouldLoseOil = mode == .normal  // apenas modo normal gasta óleo
        let correct = vm.check(game: game, shouldLoseOil: shouldLoseOil)

        if correct {
            Haptics.success()
            SoundFX.play(.correct)
        } else {
            Haptics.error()
            SoundFX.play(.wrong)
        }

        // Modo legendário: máx. 2 erros (no 3º, mostrar derrota)
        if mode == .legendary && vm.mistakes > 2 {
            showLegendaryLost = true
        } else if !correct && game.oil == 0 && mode == .normal {
            showOutOfOil = true
        }
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.3)) {
            vm.continueAfterFeedback()
        }
    }
}

/// Escolhe a view certa para o tipo de exercício.
private struct ExerciseBody: View {
    let exercise: Exercise
    let vm: LessonViewModel

    var body: some View {
        switch exercise.kind {
        case .multipleChoice: MultipleChoiceExerciseView(exercise: exercise, vm: vm)
        case .buildVerse: BuildVerseExerciseView(exercise: exercise, vm: vm)
        case .matchPairs: MatchPairsExerciseView(vm: vm)
        case .trueFalse: TrueFalseExerciseView(exercise: exercise, vm: vm)
        case .listen: ListenExerciseView(exercise: exercise, vm: vm)
        case .typeAnswer: TypeAnswerExerciseView(exercise: exercise, vm: vm)
        case .orderEvents: OrderEventsExerciseView(exercise: exercise, vm: vm)
        case .speak: SpeakExerciseView(exercise: exercise, vm: vm)
        }
    }
}

/// Pausa de incentivo no meio da lição.
private struct IncentiveOverlay: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            SpeechBubble(text: "Você está indo muito bem! Continue assim 🐑")
            SheepView(mood: .cheering, size: 160)
            Spacer()
            Button("Continuar", action: onContinue)
                .buttonStyle(.chunky)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.card.ignoresSafeArea())
    }
}

/// Personagem que "fala" num exercício (avatar com a inicial + balão).
struct SpeakerLine: View {
    let speaker: String
    let text: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(Theme.night.opacity(0.15))
                    Text(String(speaker.prefix(1)))
                        .font(Theme.font(24, .heavy))
                        .foregroundStyle(Theme.night)
                }
                .frame(width: 56, height: 56)
                Text(speaker)
                    .font(Theme.font(12, .bold))
                    .foregroundStyle(Theme.inkMuted)
                    .lineLimit(1)
                    .frame(width: 72)
            }
            SpeechBubble(text: text)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    LessonView(lesson: Lesson.sampleLesson, onFinish: { print($0) }, onQuit: {})
        .environment(GameState())
}
