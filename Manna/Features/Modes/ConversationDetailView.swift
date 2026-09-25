import SwiftUI

/// Detalhe de uma conversa com personagem bíblico.
struct ConversationDetailView: View {
    @Environment(GameState.self) private var game
    let conversation: Conversation
    let onClose: () -> Void

    @State private var currentTurnIndex = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback: String?
    @State private var correctCount = 0
    @State private var totalTurns = 0
    @State private var wasAnswerCorrect = false
    @State private var animateContent = false
    @State private var characterMood: CharacterMood = .happy
    @StateObject private var narratorState = Narrator.state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentTurn: ConversationTurn? {
        guard currentTurnIndex < conversation.turns.count else { return nil }
        return conversation.turns[currentTurnIndex]
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Cabeçalho
                HStack(spacing: 12) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }

                    ProgressView(value: Double(currentTurnIndex) / Double(conversation.turns.count))
                        .tint(Theme.olive)

                    Spacer()
                }
                .padding(16)
                .background(Theme.card)

                // Conteúdo
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 20)

                        // Personagem grande falando
                        CharacterView(
                            character: findCharacterForConversation(),
                            mood: characterMood,
                            size: 160,
                            isTalking: narratorState.isSpeaking && !(currentTurn?.isUserTurn ?? false)
                        )
                        .characterBreathing(size: 160)
                        .characterReaction(characterMood)

                        // Título
                        VStack(spacing: 8) {
                            Text(conversation.title)
                                .font(Theme.font(20, .heavy))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.center)

                            Text(conversation.reference)
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }

                        Spacer(minLength: 12)

                        // Balão de diálogo com animação
                        if let turn = currentTurn {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(turn.speaker)
                                        .font(Theme.font(14, .heavy))
                                        .foregroundStyle(Theme.wheat)
                                    Spacer()
                                }

                                Text(turn.text)
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .opacity(animateContent ? 1 : 0)
                            .scale(animateContent ? 1 : 0.8, anchor: .center)
                            .animation(
                                reduceMotion ? .none : .easeOut(duration: 0.4),
                                value: animateContent
                            )

                            // Opções (se for turno do usuário) com animação escalonada
                            if turn.isUserTurn, let options = turn.options {
                                VStack(spacing: 8) {
                                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                                        Button {
                                            selectedAnswer = option
                                            showFeedback = "Ótimo!"
                                            characterMood = .cheering
                                            markAnswerCorrect()
                                        } label: {
                                            Text(option)
                                                .font(Theme.font(14, .semibold))
                                                .foregroundStyle(Theme.ink)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                                .background(
                                                    selectedAnswer == option
                                                        ? Theme.olive.opacity(0.2)
                                                        : Theme.card
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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

                            // Feedback com animação
                            if let feedback = showFeedback {
                                VStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(Theme.olive)

                                    Text(feedback)
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.olive)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(12)
                                .background(Theme.oliveLight)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .transition(.scale.combined(with: .opacity))
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                }

                // Botão continuar
                VStack(spacing: 0) {
                    Divider()

                    if !(currentTurn?.isUserTurn ?? false), showFeedback == nil {
                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    } else if currentTurn?.isUserTurn ?? false, selectedAnswer != nil {
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
        .onChange(of: currentTurnIndex) { _, _ in
            animateContent = false
            characterMood = .happy
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
        .onAppear {
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        animateContent = true
                    }
                }
            } else {
                animateContent = true
            }

            if let turn = currentTurn, !turn.isUserTurn {
                Narrator.speak(turn.text, slow: false)
            }
        }
    }

    private func findCharacterForConversation() -> MannaCharacter {
        // Tenta encontrar um personagem por nome na conversa
        for character in MannaCharacter.cast {
            if conversation.title.lowercased().contains(character.displayName.lowercased()) {
                return character
            }
        }
        return .bee // Fallback
    }

    private func goNext() {
        // Contabilizar se a pergunta anterior foi respondida corretamente
        if wasAnswerCorrect {
            correctCount += 1
            wasAnswerCorrect = false
        }

        if currentTurnIndex < conversation.turns.count - 1 {
            showFeedback = nil
            selectedAnswer = nil
            currentTurnIndex += 1

            if let turn = currentTurn, !turn.isUserTurn {
                Narrator.speak(turn.text, slow: false)
            }
        } else {
            finishConversation()
        }
    }

    private func markAnswerCorrect() {
        wasAnswerCorrect = true
        totalTurns += 1
    }

    private func finishConversation() {
        let outcome = LessonOutcome(
            lessonId: conversation.id,
            correctCount: correctCount,
            totalCount: totalTurns,
            mistakes: max(0, totalTurns - correctCount)
        )

        let result = game.completeActivity(outcome, kind: .story, baseXP: 35)
        onClose()
    }
}

#Preview {
    ConversationDetailView(
        conversation: Conversation(
            id: "test",
            title: "Conversa Teste",
            subtitle: "Com um personagem",
            icon: "person.fill",
            reference: "Mateus 1",
            turns: [
                ConversationTurn(speaker: "Personagem", text: "Olá!", isUserTurn: false, options: nil)
            ]
        ),
        onClose: {}
    )
    .environment(GameState())
}
