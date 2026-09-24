import SwiftUI

/// Topo da lição: botão ✕, barra de progresso com "N SEGUIDAS", e óleo.
struct LessonHeader: View {
    let progress: Double
    let oil: Int
    let consecutiveCorrect: Int
    let onQuit: () -> Void

    @State private var showQuitConfirm = false

    var body: some View {
        VStack(spacing: 12) {
            // Linha: botão ✕ à esquerda, óleo à direita
            HStack {
                Button(action: { showQuitConfirm = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 40, height: 40)
                }

                Spacer()

                StatBadge(icon: .oil, value: "\(oil)")
            }
            .padding(.horizontal, 16)

            // Barra de progresso com "N SEGUIDAS"
            VStack(spacing: 8) {
                if consecutiveCorrect >= 3 {
                    Text("\(consecutiveCorrect) SEGUIDAS")
                        .font(Theme.font(13, .heavy))
                        .foregroundStyle(Theme.wheat)
                        .transition(.scale.combined(with: .opacity))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.line)

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                consecutiveCorrect >= 3
                                    ? Theme.wheat.opacity(0.8)
                                    : Theme.wheat
                            )
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 12)
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
    LessonHeader(progress: 0.5, oil: 3, consecutiveCorrect: 3, onQuit: {})
        .environment(GameState())
}
