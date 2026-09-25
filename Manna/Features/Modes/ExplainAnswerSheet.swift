import SwiftUI

/// Sheet que explica a resposta de um exercício em detalhes.
struct ExplainAnswerSheet: View {
    let exercise: Exercise
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Cabeçalho
                    HStack {
                        Text("Entenda a Resposta")
                            .font(Theme.font(20, .heavy))
                            .foregroundStyle(Theme.ink)

                        Spacer()

                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    ScrollView {
                        VStack(spacing: 20) {
                            // Resposta correta
                            VStack(spacing: 12) {
                                Text("A resposta correta")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.olive)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(exercise.answer ?? "N/A")
                                    .font(Theme.font(17, .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Theme.oliveLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }

                            Divider()

                            // Explicação
                            if let explanation = exercise.explanation {
                                VStack(spacing: 12) {
                                    Text("Por que?")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.wheat)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(explanation)
                                        .font(Theme.font(15, .regular))
                                        .foregroundStyle(Theme.ink)
                                        .lineLimit(nil)
                                }
                            }

                            Divider()

                            // Referência bíblica
                            if let reference = exercise.reference {
                                VStack(spacing: 12) {
                                    Text("Referência Bíblica")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.oil)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(reference)
                                            .font(Theme.font(14, .heavy))
                                            .foregroundStyle(Theme.ink)

                                        Button {
                                            Narrator.speak(reference, slow: true)
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "speaker.wave.2.fill")
                                                    .foregroundStyle(Theme.oil)
                                                Text("Ouvir versículo")
                                                    .font(Theme.font(14, .semibold))
                                                    .foregroundStyle(Theme.oil)
                                                Spacer()
                                            }
                                            .padding(8)
                                            .background(Theme.oil.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                        }
                                    }
                                }
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(16)
                    }

                    // Botão fechar
                    Button(action: onDismiss) {
                        Text("ENTENDI")
                            .font(Theme.font(17, .heavy))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.chunky)
                    .padding(16)
                    .background(Theme.cream)
                }
            }
        }
    }
}

#Preview {
    ExplainAnswerSheet(
        exercise: Exercise(
            id: "test",
            kind: .multipleChoice,
            prompt: "Qual é a capital da Israel?",
            speaker: nil,
            text: nil,
            reference: "Deuteronômio 16:16",
            options: ["Cairo", "Jerusalém", "Tel Aviv"],
            answer: "Jerusalém",
            tokens: nil,
            distractors: nil,
            pairs: nil,
            statement: nil,
            isTrue: nil,
            explanation: "Jerusalém é a capital histórica e espiritual de Israel, centro religioso para judeus, cristãos e muçulmanos."
        ),
        onDismiss: {}
    )
}
