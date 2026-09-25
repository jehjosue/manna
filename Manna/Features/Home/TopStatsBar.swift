import SwiftUI

/// Barra do topo mostrando: seletor de curso, pão diário, maná/XP dobro, óleo, e Plus.
struct TopStatsBar: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @Environment(\.selectAppTab) private var selectTab
    @State private var showCourseSheet = false
    @State private var showOilSheet = false
    @State private var showBibleLevel = false

    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Seletor de curso (à esquerda)
            Button(action: { showCourseSheet = true }) {
                HStack(spacing: 6) {
                    if let journey = content.journey, let icon = journey.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(content.journey?.title ?? "Curso")
                        .font(Theme.font(12, .heavy))
                        .lineLimit(1)
                }
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.cream)
                .cornerRadius(8)
            }

            Spacer(minLength: 8)

            // MARK: - Pão diário
            StatBadge(
                icon: .bread,
                value: "\(game.bread)",
                dimmed: !game.studiedToday
            )

            Spacer(minLength: 8)

            // MARK: - Maná ou XP dobro (tocável)
            Button(action: { selectTab(.shop) }) {
                if game.isXPBoostActive {
                    HStack(spacing: 4) {
                        GameIconView(icon: .xp, size: 20)
                        VStack(spacing: 0) {
                            Text("2x")
                                .font(Theme.font(12, .heavy))
                            Text("XP")
                                .font(Theme.font(10, .semibold))
                        }
                        .foregroundStyle(Theme.wheat)
                    }
                } else {
                    StatBadge(icon: .manna, value: "\(game.manna)")
                }
            }

            Spacer(minLength: 8)

            // MARK: - Óleo (tocável)
            Button(action: { showOilSheet = true }) {
                StatBadge(icon: .oil, value: "\(game.oil)")
            }

            // MARK: - Badge Plus (se ativo)
            if game.isPlus {
                VStack(spacing: 1) {
                    Text("Plus")
                        .font(Theme.font(10, .heavy))
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(Color(hex: 0xFFD700))
                .padding(4)
                .background(Color(hex: 0xFFD700).opacity(0.1))
                .cornerRadius(4)
            }

            // MARK: - Nível bíblico (touchable)
            Button(action: { showBibleLevel = true }) {
                VStack(spacing: 1) {
                    Text("Nível")
                        .font(Theme.font(10, .heavy))
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(Theme.oil)
                .padding(4)
                .background(Theme.oil.opacity(0.1))
                .cornerRadius(4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.card)
        .cornerRadius(12)
        .shadow(color: Theme.line.opacity(0.3), radius: 4, y: 2)
        .sheet(isPresented: $showCourseSheet) {
            CourseSwitcherSheet()
        }
        .sheet(isPresented: $showOilSheet) {
            OilExplanationSheet(isPresented: $showOilSheet)
        }
        .sheet(isPresented: $showBibleLevel) {
            BibleLevelView()
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
