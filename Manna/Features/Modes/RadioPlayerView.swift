import SwiftUI
import AVFoundation

/// Player de episódios de rádio com perguntas de compreensão.
struct RadioPlayerView: View {
    @Environment(GameState.self) private var game
    let episode: RadioEpisode
    let onClose: () -> Void

    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timeElapsed = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback: (isCorrect: Bool, message: String)?
    @State private var correctAnswers = 0
    @State private var totalQuestions = 0
    @State private var showCelebration = false
    @State private var celebrationResult: LessonResult?

    private var currentStep: RadioStep? {
        guard currentStepIndex < episode.steps.count else { return nil }
        return episode.steps[currentStepIndex]
    }

    private var isQuestionStep: Bool {
        currentStep?.kind == .question
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Cabeçalho com progresso
                HStack(spacing: 12) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }

                    ProgressView(value: Double(currentStepIndex) / Double(episode.steps.count))
                        .tint(Theme.wheat)

                    Spacer()
                }
                .padding(16)
                .background(Theme.card)

                // Conteúdo
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)

                        // Ícone e título
                        VStack(spacing: 12) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(Theme.wheat)

                            Text(episode.title)
                                .font(Theme.font(20, .heavy))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.center)
                        }

                        Spacer(minLength: 12)

                        // Passo atual
                        if let step = currentStep {
                            if isQuestionStep {
                                // Pergunta
                                VStack(spacing: 16) {
                                    Text(step.text)
                                        .font(Theme.font(18, .heavy))
                                        .foregroundStyle(Theme.ink)
                                        .multilineTextAlignment(.center)

                                    VStack(spacing: 8) {
                                        ForEach(step.options ?? [], id: \.self) { option in
                                            Button {
                                                selectedAnswer = option
                                                checkAnswer(option, correctAnswer: step.answer ?? "")
                                            } label: {
                                                Text(option)
                                                    .font(Theme.font(16, .semibold))
                                                    .foregroundStyle(Theme.ink)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(12)
                                                    .background(
                                                        selectedAnswer == option
                                                            ? Theme.wheat.opacity(0.3)
                                                            : Theme.card
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Narração
                                VStack(spacing: 12) {
                                    Text(step.speaker ?? "Narrador")
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.wheat)

                                    Text(step.text)
                                        .font(Theme.font(16, .semibold))
                                        .foregroundStyle(Theme.ink)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                }
                                .padding(16)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            // Feedback
                            if let feedback = showFeedback {
                                VStack(spacing: 8) {
                                    Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(feedback.isCorrect ? Theme.olive : Theme.terracotta)

                                    Text(feedback.message)
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(feedback.isCorrect ? Theme.olive : Theme.terracotta)
                                }
                                .padding(12)
                                .background(feedback.isCorrect ? Theme.oliveLight : Theme.terracottaLight)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }

                // Botões
                VStack(spacing: 0) {
                    Divider()

                    if showFeedback != nil && isQuestionStep {
                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    } else if !isQuestionStep && showFeedback == nil {
                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    }
                }
                .background(Theme.cream)
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let result = celebrationResult {
                CelebrationFlowView(result: result) {
                    showCelebration = false
                    onClose()
                }
            }
        }
        .onDisappear { Narrator.stop() }
        .onAppear {
            // Falar primeira narração
            if let step = currentStep, step.kind == .narration {
                Narrator.speak(step.text, slow: false)
            }
        }
    }

    private func checkAnswer(_ selected: String, correctAnswer: String) {
        let isCorrect = selected.lowercased() == correctAnswer.lowercased()

        totalQuestions += 1
        if isCorrect {
            correctAnswers += 1
            showFeedback = (true, "Correto! 🎉")
            SoundFX.play(.correct)
        } else {
            showFeedback = (false, "Errado. A resposta era: \(correctAnswer)")
            SoundFX.play(.wrong)
        }
    }

    private func goNext() {
        showFeedback = nil
        selectedAnswer = nil

        if currentStepIndex < episode.steps.count - 1 {
            currentStepIndex += 1

            // Falar novo passo se for narração
            if let step = currentStep, step.kind == .narration {
                Narrator.speak(step.text, slow: false)
            }
        } else {
            // Terminou o episódio
            finishEpisode()
        }
    }

    private func finishEpisode() {
        let outcome = LessonOutcome(
            lessonId: episode.id,
            correctCount: correctAnswers,
            totalCount: totalQuestions,
            mistakes: max(0, totalQuestions - correctAnswers)
        )

        Narrator.stop()
        celebrationResult = game.completeActivity(outcome, kind: .story, baseXP: max(10, min(40, correctAnswers * 10)))
        showCelebration = true
    }
}

#Preview {
    RadioPlayerView(
        episode: RadioEpisode(
            id: "test",
            title: "Teste",
            subtitle: "Episódio Teste",
            icon: "mic.fill",
            duration: 240,
            steps: [
                RadioStep(kind: .narration, speaker: "Narrador", text: "Bem-vindo!", options: nil, answer: nil)
            ]
        ),
        onClose: {}
    )
    .environment(GameState())
}
