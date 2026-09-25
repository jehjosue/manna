import SwiftUI

/// Animação e seleção de recompensa ao abrir um baú.
struct TreasureRewardView: View {
    let unitId: String
    let onDone: () -> Void

    @Environment(GameState.self) private var game
    @State private var showAnimation = false
    @State private var selectedReward: TreasureRewardType?

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Animação do baú
                if showAnimation {
                    VStack(spacing: 24) {
                        Spacer()

                        // Baú desenhado em SwiftUI
                        ZStack {
                            // Corpo do baú
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: 0x8B6F47))
                                .frame(width: 140, height: 100)

                            // Tampa aberta
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: 0xA0826D))
                                .frame(width: 120, height: 20)
                                .offset(y: -50)
                                .rotationEffect(.degrees(-45), anchor: UnitPoint(x: 0.5, y: 0.9))

                            // Moedas/luzes saindo
                            ForEach(0..<5, id: \.self) { i in
                                Circle()
                                    .fill(Color(hex: 0xFFD700).opacity(0.8))
                                    .frame(width: 12, height: 12)
                                    .offset(
                                        x: CGFloat.random(in: -80...80),
                                        y: showAnimation ? -150 : 0
                                    )
                                    .animation(
                                        .easeOut(duration: 1.5)
                                            .delay(Double(i) * 0.1),
                                        value: showAnimation
                                    )
                            }
                        }

                        Spacer()

                        // Texto e opções de recompensa
                        VStack(spacing: 16) {
                            Text("Parabéns!")
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)

                            Text("Escolha sua recompensa")
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.inkMuted)

                            VStack(spacing: 12) {
                                TreasureOptionButton(
                                    type: .manna(25),
                                    onSelect: { selectReward(.manna(25)) }
                                )

                                TreasureOptionButton(
                                    type: .xpBoost,
                                    onSelect: { selectReward(.xpBoost) }
                                )

                                TreasureOptionButton(
                                    type: .restDay,
                                    onSelect: { selectReward(.restDay) }
                                )
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 24) {
                        Spacer()
                        SheepView(mood: .cheering, size: 120)
                        Text("Descobrindo recompensa...")
                            .font(Theme.font(18, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showAnimation = true
                }
                SoundFX.play(.reward)
            }
        }
    }

    private func selectReward(_ type: TreasureRewardType) {
        switch type {
        case .manna(let amount):
            game.addManna(amount)
        case .xpBoost:
            game.activateXPBoost(minutes: 15)
        case .restDay:
            game.grantRestDay()
        }

        PathRewardsStore.shared.openTreasure(unitId)
        SoundFX.play(.reward)
        Haptics.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDone()
        }
    }
}

enum TreasureRewardType {
    case manna(Int)
    case xpBoost
    case restDay
}

// MARK: - Treasure Option Button

struct TreasureOptionButton: View {
    let type: TreasureRewardType
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Ícone
                ZStack {
                    Circle()
                        .fill(rewardColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    GameIconView(icon: rewardIcon, size: 28)
                }

                // Texto
                VStack(alignment: .leading, spacing: 2) {
                    Text(rewardTitle)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text(rewardDescription)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
        }
    }

    private var rewardColor: Color {
        switch type {
        case .manna: Theme.manna
        case .xpBoost: Theme.wheat
        case .restDay: Theme.rest
        }
    }

    private var rewardIcon: GameIcon {
        switch type {
        case .manna: .manna
        case .xpBoost: .xp
        case .restDay: .rest
        }
    }

    private var rewardTitle: String {
        switch type {
        case .manna(let amount): "\(amount) Maná"
        case .xpBoost: "XP em Dobro"
        case .restDay: "Dia de Descanso"
        }
    }

    private var rewardDescription: String {
        switch type {
        case .manna: "Moeda para comprar poderes"
        case .xpBoost: "15 minutos de pontos dobrados"
        case .restDay: "Protege sua sequência"
        }
    }
}

#Preview {
    TreasureRewardView(unitId: "unit-1", onDone: {})
        .environment(GameState())
}
