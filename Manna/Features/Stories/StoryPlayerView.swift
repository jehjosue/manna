import SwiftUI

/// Player de histórias: exibe linhas uma a uma, perguntas com opções, áudio opcional.
struct StoryPlayerView: View {
    let story: Story
    let onFinish: (LessonOutcome) -> Void
    let onQuit: () -> Void

    @Environment(GameState.self) private var game
    @State private var currentStepIndex = 0
    @State private var answerFeedback: StoryFeedback?
    @State private var totalQuestions = 0
    @State private var correctAnswers = 0
    @State private var showFeedback = false

    private var currentStep: StoryStep? {
        guard currentStepIndex < story.steps.count else { return nil }
        return story.steps[currentStepIndex]
    }

    private var isQuestionStep: Bool {
        currentStep?.kind == .question
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top bar com progresso e botões
                HStack(spacing: 12) {
                    Button(action: onQuit) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }

                    // Barra de progresso
                    ProgressView(value: Double(currentStepIndex) / Double(story.steps.count))
                        .tint(Theme.wheat)

                    Spacer()
                }
                .padding(16)
                .background(Theme.card)

                // MARK: - Conteúdo principal
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 20)

                        if let step = currentStep {
                            switch step.kind {
                            case .line:
                                StoryLineView(
                                    step: step,
                                    soundEnabled: game.soundEnabled
                                )

                            case .question:
                                StoryQuestionView(
                                    step: step,
                                    feedback: answerFeedback,
                                    onSelect: handleAnswer,
                                    soundEnabled: game.soundEnabled
                                )
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }

                // MARK: - Botão de continuação
                VStack(spacing: 0) {
                    if !showFeedback && !isQuestionStep {
                        Divider()

                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    } else if showFeedback && isQuestionStep {
                        Divider()

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
        .onAppear {
            // Contar perguntas totais
            totalQuestions = story.steps.filter { $0.kind == .question }.count
        }
    }

    private func handleAnswer(_ selectedOption: String, isCorrect: Bool) {
        let feedback: StoryFeedback = isCorrect ? .correct : .wrong
        answerFeedback = feedback
        showFeedback = true

        if isCorrect {
            correctAnswers += 1
            SoundFX.play(.correct)
            Haptics.success()
        } else {
            SoundFX.play(.wrong)
            Haptics.error()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Auto-avança após feedback
            goNext()
        }
    }

    private func goNext() {
        if currentStepIndex < story.steps.count - 1 {
            currentStepIndex += 1
            answerFeedback = nil
            showFeedback = false
        } else {
            // Fim da história
            let outcome = LessonOutcome(
                lessonId: story.id,
                correctCount: correctAnswers,
                totalCount: totalQuestions,
                mistakes: totalQuestions - correctAnswers
            )
            onFinish(outcome)
        }
    }
}

// MARK: - Story Line View

struct StoryLineView: View {
    let step: StoryStep
    let soundEnabled: Bool

    @State private var isSpeaking = false

    var body: some View {
        VStack(spacing: 16) {
            // Avatar do personagem
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.2))
                    .frame(width: 90, height: 90)

                if let speaker = step.speaker, speaker != "Narrador" {
                    Text(String(speaker.prefix(1)))
                        .font(Theme.font(36, .heavy))
                        .foregroundStyle(avatarColor)
                } else {
                    Image(systemName: "book.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(avatarColor)
                }
            }

            // Nome do personagem
            if let speaker = step.speaker {
                Text(speaker)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .uppercase()
            }

            // Balão de fala
            SpeechBubble(text: step.text)

            // Botão de áudio
            if soundEnabled {
                Button(action: { playAudio(step.text) }) {
                    HStack(spacing: 8) {
                        Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                        Text("Ouvir")
                            .font(Theme.font(14, .heavy))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.chunkyNight)
            }
        }
    }

    private var avatarColor: Color {
        guard let speaker = step.speaker else { return Theme.night }
        // Cores diferentes por personagem
        let colors: [Color] = [Theme.wheat, Theme.olive, Theme.night, Theme.terracotta, Theme.rest]
        let hash = speaker.hashValue % colors.count
        return colors[abs(hash)]
    }

    private func playAudio(_ text: String) {
        isSpeaking = true
        Narrator.speak(text, slow: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.05) {
            isSpeaking = false
        }
    }
}

// MARK: - Story Question View

struct StoryQuestionView: View {
    let step: StoryStep
    let feedback: StoryFeedback?
    let onSelect: (String, Bool) -> Void
    let soundEnabled: Bool

    @State private var selectedOption: String?

    var body: some View {
        VStack(spacing: 16) {
            // Ícone de pergunta
            ZStack {
                Circle()
                    .fill(Theme.night.opacity(0.2))
                    .frame(width: 90, height: 90)

                Image(systemName: "questionmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.night)
            }

            // Texto da pergunta
            SpeechBubble(text: step.text)

            // Opções de resposta
            if let options = step.options {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        ChoiceOptionButton(
                            text: option,
                            isSelected: selectedOption == option,
                            feedback: feedback,
                            isCorrect: option == step.answer,
                            isDisabled: feedback != nil,
                            onTap: {
                                selectedOption = option
                                onSelect(option, option == step.answer)
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Choice Option Button

struct ChoiceOptionButton: View {
    let text: String
    let isSelected: Bool
    let feedback: StoryFeedback?
    let isCorrect: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(Theme.font(15, .semibold))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(
            StoryChoiceButtonStyle(
                isSelected: isSelected,
                feedback: feedback,
                isCorrect: isCorrect
            )
        )
        .disabled(isDisabled)
    }
}

struct StoryChoiceButtonStyle: ButtonStyle {
    let isSelected: Bool
    let feedback: StoryFeedback?
    let isCorrect: Bool

    func makeBody(configuration: Configuration) -> some View {
        let background: Color
        let border: Color

        if let feedback = feedback {
            if isCorrect {
                background = Theme.oliveLight
                border = Theme.olive
            } else if isSelected {
                background = Theme.terracottaLight
                border = Theme.terracotta
            } else {
                background = Theme.card
                border = Theme.line
            }
        } else if isSelected {
            background = Theme.night.opacity(0.12)
            border = Theme.night
        } else {
            background = Theme.card
            border = Theme.line
        }

        return configuration.label
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(background))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(border, lineWidth: 2)
            )
            .offset(y: configuration.isPressed ? 2 : 0)
    }
}

// MARK: - Feedback enum

enum StoryFeedback: Equatable {
    case correct
    case wrong
}

#Preview {
    StoryPlayerView(
        story: Story(
            id: "preview-story",
            title: "A Multiplicação dos Pães",
            subtitle: "Um milagre de Jesus",
            icon: "book.fill",
            reference: "João 6:1-14",
            steps: [
                StoryStep(kind: .line, speaker: "Narrador", text: "Uma multidão de cinco mil pessoas seguia Jesus para ouvir seus ensinamentos.", options: nil, answer: nil),
                StoryStep(kind: .line, speaker: "Jesus", text: "Tenho compaixão desta multidão.", options: nil, answer: nil),
                StoryStep(kind: .question, speaker: nil, text: "Quantos pães e peixes havia disponíveis?", options: ["2 peixes e 5 pães", "5 peixes e 2 pães", "10 peixes e 10 pães"], answer: "2 peixes e 5 pães"),
            ]
        ),
        onFinish: { _ in },
        onQuit: { }
    )
    .environment(GameState())
}
