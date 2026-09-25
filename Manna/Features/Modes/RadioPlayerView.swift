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
    @State private var animateContent = false
    private let narratorState = Narrator.state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

                        // Apresentadores animados (Béé e Pastor Davi)
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                CharacterView(
                                    character: .bee,
                                    mood: .happy,
                                    size: 100,
                                    isTalking: narratorState.isSpeaking && (currentStep?.speaker ?? "Béé").contains("Béé")
                                )
                                .characterBreathing(size: 100)
                                .scaleEffect(narratorState.isSpeaking && (currentStep?.speaker ?? "Béé").contains("Béé") ? 1.05 : 1)
                                .animation(.easeInOut(duration: 0.3), value: narratorState.isSpeaking)

                                Text("Béé")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.wheat)
                            }

                            VStack(spacing: 8) {
                                CharacterView(
                                    character: .pastorDavi,
                                    mood: .happy,
                                    size: 100,
                                    isTalking: narratorState.isSpeaking && (currentStep?.speaker ?? "").contains("Davi")
                                )
                                .characterBreathing(size: 100)
                                .scaleEffect(narratorState.isSpeaking && (currentStep?.speaker ?? "").contains("Davi") ? 1.05 : 1)
                                .animation(.easeInOut(duration: 0.3), value: narratorState.isSpeaking)

                                Text("Pastor Davi")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.night)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // Onda sonora animada
                        if narratorState.isSpeaking {
                            SoundWaveView()
                                .frame(height: 40)
                                .padding(.horizontal, 16)
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
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 10)

                                    VStack(spacing: 8) {
                                        ForEach(Array((step.options ?? []).enumerated()), id: \.element) { index, option in
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
                                            .opacity(animateContent ? 1 : 0)
                                            .offset(y: animateContent ? 0 : 10)
                                            .animation(
                                                reduceMotion ? .none : .easeOut(duration: 0.4).delay(Double(index + 1) * 0.08),
                                                value: animateContent
                                            )
                                        }
                                    }
                                }
                            } else {
                                // Narração com balão animado
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
                                .opacity(animateContent ? 1 : 0)
                                .scaleEffect(animateContent ? 1 : 0.8, anchor: .center)
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
                                .transition(.scale.combined(with: .opacity))
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
        .onChange(of: currentStepIndex) { _, _ in
            animateContent = false
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        animateContent = true
                    }
                }
            } else {
                animateContent = true
            }
        }
        .onDisappear { Narrator.stop() }
        .onAppear {
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        animateContent = true
                    }
                }
            } else {
                animateContent = true
            }

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
