import SwiftUI

/// Faixa de feedback (acerto/erro) que sobe de baixo com animação.
struct FeedbackBanner: View {
    let isCorrect: Bool
    let title: String
    let explanation: String?
    let correctAnswer: String?
    var exercise: Exercise? = nil
    let onContinue: () -> Void

    @State private var showExplainSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Conteúdo
            VStack(spacing: 12) {
                // Ícone de sucesso/erro
                Group {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.olive)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.terracotta)
                    }
                }
                .transition(.scale)

                // Título
                Text(title)
                    .font(Theme.font(18, .heavy))
                    .foregroundStyle(isCorrect ? Theme.olive : Theme.terracotta)

                // Se erro, mostrar a resposta correta
                if !isCorrect, let correctAnswer = correctAnswer {
                    VStack(spacing: 6) {
                        Text("Resposta correta:")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                        Text(correctAnswer)
                            .font(Theme.font(16, .heavy))
                            .foregroundStyle(Theme.ink)
                    }
                    .padding(.top, 4)
                }

                // Explicação
                if let explanation = explanation {
                    Text(explanation)
                        .font(Theme.font(15, .regular))
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.center)
                }

                // Botão Entenda a Resposta (se houver exercise)
                if let exercise = exercise, !isCorrect {
                    Button(action: { showExplainSheet = true }) {
                        Text("Entenda a Resposta")
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.oil)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Theme.oil.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(isCorrect ? Theme.oliveLight : Theme.terracottaLight)
            .frame(maxWidth: .infinity)

            // Botão CONTINUAR
            Button(action: onContinue) {
                Text("CONTINUAR")
            }
            .buttonStyle(
                isCorrect
                    ? ChunkyButtonStyle(fill: Theme.olive, shadow: Theme.oliveDark)
                    : ChunkyButtonStyle(fill: Theme.terracotta, shadow: Theme.terracottaDark)
            )
            .padding(16)
            .background(isCorrect ? Theme.oliveLight : Theme.terracottaLight)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(isPresented: $showExplainSheet) {
            if let exercise = exercise {
                ExplainAnswerSheet(exercise: exercise) {
                    showExplainSheet = false
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FeedbackBanner(
            isCorrect: true,
            title: "Muito bem!",
            explanation: "Transformar água em vinho foi o primeiro milagre de Jesus.",
            correctAnswer: nil,
            onContinue: {}
        )

        FeedbackBanner(
            isCorrect: false,
            title: "Resposta correta:",
            explanation: "Jesus calma a tempestade mostrando poder sobre a natureza.",
            correctAnswer: "Acalmar a tempestade",
            onContinue: {}
        )
    }
    .padding()
}
