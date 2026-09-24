import SwiftUI

/// Barra do topo mostrando: pão diário, maná e óleo.
/// Tocar no óleo abre sheet com explicação sobre a lamparina e opção de encher.
struct TopStatsBar: View {
    @Environment(GameState.self) private var game
    @State private var showOilSheet = false

    var body: some View {
        HStack(spacing: 16) {
            // Pão diário
            StatBadge(
                icon: .bread,
                value: "\(game.bread)",
                dimmed: !game.studiedToday
            )

            Spacer()

            // Maná
            StatBadge(icon: .manna, value: "\(game.manna)")

            Spacer()

            // Óleo (tocável)
            Button(action: { showOilSheet = true }) {
                StatBadge(icon: .oil, value: "\(game.oil)")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.card)
        .cornerRadius(12)
        .shadow(color: Theme.line.opacity(0.3), radius: 4, y: 2)
        .sheet(isPresented: $showOilSheet) {
            OilExplanationSheet(isPresented: $showOilSheet)
        }
    }
}

/// Sheet que explica a lamparina (parábola das 10 virgens, Mateus 25).
struct OilExplanationSheet: View {
    @Environment(GameState.self) private var game
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Óleo da lamparina")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)

                Text("Como as virgens prudentes da parábola (Mateus 25:1–13), mantenha sua lamparina com óleo. Cada erro gasta uma gota, e uma gota volta a cada 30 minutos.")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Status atual
            VStack(alignment: .leading, spacing: 8) {
                Text("\(game.oil) de \(GameState.maxOil) gotas")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(game.hasOil ? Theme.olive : Theme.terracotta)

                if let nextOilIn = game.nextOilIn {
                    let minutes = max(1, Int((nextOilIn / 60).rounded(.up)))
                    Text("Próxima gota em \(minutes) minuto\(minutes == 1 ? "" : "s")")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.cream)
            .cornerRadius(12)

            Spacer()

            // Botões de ação
            VStack(spacing: 12) {
                if game.oil < GameState.maxOil {
                    Button(action: {
                        _ = game.refillOilWithManna()
                        isPresented = false
                    }) {
                        Text("Encher com \(GameState.refillOilCost) maná")
                    }
                    .buttonStyle(.chunky)
                    .disabled(game.manna < GameState.refillOilCost)
                }

                Button(action: { isPresented = false }) {
                    Text("Voltar")
                }
                .buttonStyle(.chunkyNight)
            }
        }
        .padding(20)
        .background(Theme.cream)
        .presentationDetents([.medium])
    }
}

#Preview {
    TopStatsBar()
        .environment(GameState.load())
        .background(Theme.cream)
}
