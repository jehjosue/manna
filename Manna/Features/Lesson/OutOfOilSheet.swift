import SwiftUI

/// Sheet que mostra quando o óleo acaba durante a lição.
struct OutOfOilSheet: View {
    @Environment(GameState.self) private var game
    let refillCost = GameState.refillOilCost
    let onQuit: () -> Void

    var canRefill: Bool { game.manna >= refillCost }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Ovelhinha triste
            SheepView(mood: .sad, size: 100)

            // Título
            Text("Sua lamparina apagou 🪔")
                .font(Theme.font(24, .heavy))
                .foregroundStyle(Theme.ink)

            // Explicação (parábola das 10 virgens)
            VStack(spacing: 8) {
                Text("Como as dez virgens da parábola, tenha sempre óleo de reserva para quando a noite chegar.")
                    .font(Theme.font(15, .regular))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)

                Text("O maná pode ajudar a encher a lamparina.")
                    .font(Theme.font(14, .regular))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)

            Spacer()

            // Botões
            VStack(spacing: 12) {
                if canRefill {
                    Button(action: {
                        if game.refillOilWithManna() {
                            // Continua a lição automaticamente
                        }
                    }) {
                        HStack(spacing: 6) {
                            GameIconView(icon: .manna, size: 20)
                            Text("Encher com \(refillCost) maná")
                        }
                    }
                    .buttonStyle(.chunky)
                } else {
                    HStack(spacing: 6) {
                        GameIconView(icon: .manna, size: 20, dimmed: true)
                        Text("Maná insuficiente")
                    }
                    .font(Theme.font(17, .heavy))
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .foregroundStyle(Theme.inkMuted)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                            .fill(Theme.line)
                    )
                }

                Button(action: onQuit) {
                    Text("Sair da lição")
                }
                .buttonStyle(.chunkyNight)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.card)
        .presentationDetents([.fraction(0.6)])
        .presentationBackground(Color.black.opacity(0.4))
    }
}

#Preview {
    OutOfOilSheet(onQuit: {})
        .environment(GameState())
}
