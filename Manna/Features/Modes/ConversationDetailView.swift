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

                        // Balão de diálogo
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

                            // Opções (se for turno do usuário)
                            if turn.isUserTurn, let options = turn.options {
                                VStack(spacing: 8) {
                                    ForEach(options, id: \.self) { option in
                                        Button {
                                            selectedAnswer = option
                                            goNext()
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
                                    }
                                }
                            }

                            // Feedback
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

                    if !currentTurn?.isUserTurn ?? false, showFeedback == nil {
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
        .onAppear {
            // Falar a fala do personagem
            if let turn = currentTurn, !turn.isUserTurn {
                Narrator.speak(turn.text, slow: false)
            }
        }
    }

    private func goNext() {
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
