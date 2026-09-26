import SwiftUI

/// Topo da lição: botão ✕, barra de progresso com "N SEGUIDAS", e óleo/haltere/coroa.
struct LessonHeader: View {
    let progress: Double
    let oil: Int
    let consecutiveCorrect: Int
    var mode: LessonMode = .normal
    let onQuit: () -> Void

    @State private var showQuitConfirm = false

    var body: some View {
        VStack(spacing: 12) {
            // Linha: botão ✕ à esquerda, ícone de modo à direita
            HStack {
                Button(action: { showQuitConfirm = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 40, height: 40)
                }

                Spacer()

                if mode == .practice {
                    StatBadge(icon: .xp, value: "🏋️")  // representar treino com haltere
                } else if mode == .legendary {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.wheat)
                        Text("LENDÁRIO")
                            .font(Theme.font(13, .heavy))
                            .foregroundStyle(Theme.wheat)
                    }
                } else {
                    StatBadge(icon: .oil, value: "\(oil)")
                }
            }
            .padding(.horizontal, 16)

            // Barra de progresso com "N SEGUIDAS"
            VStack(spacing: 12) {
                AnimatedProgressBar(progress: progress, isCorrect: nil)

                if consecutiveCorrect >= 3 {
                    StreakBadge(count: consecutiveCorrect, isVisible: true)
                        .frame(height: 100)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Theme.cream)
        .confirmationDialog(
            "Sair da lição?",
            isPresented: $showQuitConfirm,
            actions: {
                Button("Sair", role: .destructive) { onQuit() }
                Button("Continuar estudando", role: .cancel) {}
            },
            message: { Text("Seu progresso nesta lição será perdido.") }
        )
    }
}

#Preview {
    VStack {
        LessonHeader(progress: 0.5, oil: 3, consecutiveCorrect: 3, mode: .normal, onQuit: {})
        Spacer()
    }
    .environment(GameState())
}
