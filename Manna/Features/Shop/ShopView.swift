import SwiftUI
import StoreKit

/// Loja gamificada com poderes, baú diário e pacotes de maná.
struct ShopView: View {
    @Environment(GameState.self) private var game
    @Environment(\.selectAppTab) private var selectTab
    @State private var showPaywall = false
    @State private var selectedPower: PowerType?
    @State private var treasureOpened = false
    @State private var lastTreasureDate: String?
    @State private var showPowerConfirmation = false
    @State private var confirmationPower: PowerType?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header com saldo de maná
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Loja")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Compre poderes com maná")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        StatBadge(icon: .manna, value: String(game.manna))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: - Banner Manna Plus
                            if !game.isPlus {
                                PaywallBannerView(showPaywall: $showPaywall)
                            }

                            // MARK: - Seção Poderes
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Poderes")
                                    .font(Theme.font(18, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                VStack(spacing: 12) {
                                    // Encher lamparina
                                    if !game.isPlus {
                                        PowerCardView(
                                            power: .refillOil,
                                            game: game,
                                            isDisabled: game.oil == GameState.maxOil,
                                            onTap: { showPowerConfirmation = true; confirmationPower = .refillOil }
                                        )
                                    }

                                    // Dia de descanso
                                    PowerCardView(
                                        power: .restDay,
                                        game: game,
                                        isDisabled: game.restDays >= GameState.maxRestDays,
                                        onTap: { showPowerConfirmation = true; confirmationPower = .restDay }
                                    )

                                    // XP em dobro
                                    PowerCardView(
                                        power: .xpBoost,
                                        game: game,
                                        isDisabled: game.isXPBoostActive,
                                        onTap: { showPowerConfirmation = true; confirmationPower = .xpBoost }
                                    )

                                    // Mais tempo no desafio
                                    PowerCardView(
                                        power: .timerBoost,
                                        game: game,
                                        isDisabled: false,
                                        onTap: { showPowerConfirmation = true; confirmationPower = .timerBoost }
                                    )
                                }
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Baú diário grátis
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Baú Diário")
                                    .font(Theme.font(18, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                DailyTreasureView(
                                    opened: $treasureOpened,
                                    lastDate: $lastTreasureDate,
                                    game: game
                                )
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 20)
                        }
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Confirmar compra?", isPresented: $showPowerConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Comprar", role: .destructive) {
                    if let power = confirmationPower {
                        buyPower(power)
                    }
                }
            } message: {
                if let power = confirmationPower {
                    Text(power.confirmationMessage)
                }
            }
            .onAppear {
                lastTreasureDate = UserDefaults.standard.string(forKey: "lastTreasureDate")
            }
        }
    }

    private func buyPower(_ power: PowerType) {
        switch power {
        case .refillOil:
            if game.refillOilWithManna() {
                SoundFX.play(.reward)
                Haptics.success()
            } else {
                Haptics.error()
            }
        case .restDay:
            if game.buyRestDay() {
                SoundFX.play(.reward)
                Haptics.success()
            } else {
                Haptics.error()
            }
        case .xpBoost:
            if game.buyXPBoost() {
                SoundFX.play(.reward)
                Haptics.success()
            } else {
                Haptics.error()
            }
        case .timerBoost:
            if game.spendManna(30) {
                BoostInventoryStore.shared.addTimerBoost(1)
                SoundFX.play(.reward)
                Haptics.success()
            } else {
                Haptics.error()
            }
        }
    }
}

// MARK: - Componentes auxiliares

enum PowerType {
    case refillOil, restDay, xpBoost, timerBoost

    var cost: Int {
        switch self {
        case .refillOil: GameState.refillOilCost
        case .restDay: GameState.restDayCost
        case .xpBoost: GameState.xpBoostCost
        case .timerBoost: 30
        }
    }

    var title: String {
        switch self {
        case .refillOil: "Encher Lamparina"
        case .restDay: "Dia de Descanso"
        case .xpBoost: "XP em Dobro (15 min)"
        case .timerBoost: "Mais Tempo (+15s)"
        }
    }

    var description: String {
        switch self {
        case .refillOil: "Recupera todas as 5 gotas de óleo para continuar estudando"
        case .restDay: "Protege sua sequência de pão diário por 1 dia"
        case .xpBoost: "Ganha o dobro de XP nos próximos 15 minutos"
        case .timerBoost: "Adiciona 15 segundos ao próximo Desafio Relâmpago"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .refillOil: "Gastar \(cost) maná para encher a lamparina?"
        case .restDay: "Gastar \(cost) maná para comprar 1 dia de descanso?"
        case .xpBoost: "Gastar \(cost) maná para ativar XP em dobro?"
        case .timerBoost: "Gastar \(cost) maná para adicionar +15s ao desafio?"
        }
    }
}

struct PowerCardView: View {
    let power: PowerType
    let game: GameState
    var isDisabled: Bool = false
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(power.title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(power.description)
                        .font(Theme.font(12, .medium))
                        .foregroundStyle(Theme.inkMuted)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        GameIconView(icon: .manna, size: 20)
                        Text(String(power.cost))
                            .font(Theme.font(16, .heavy))
                            .foregroundStyle(Theme.manna)
                    }
                    if power == .restDay {
                        Text("x/\(GameState.maxRestDays) guardados")
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    } else if power == .xpBoost, game.isXPBoostActive {
                        Text(timeRemaining)
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.wheat)
                    }
                }
            }

            Button {
                onTap()
            } label: {
                Text(buttonLabel)
                    .font(Theme.font(14, .heavy))
                    .textCase(.uppercase)
            }
            .buttonStyle(.chunky)
            .disabled(isDisabled)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.card)
        )
    }

    private var buttonLabel: String {
        if isDisabled {
            return power == .refillOil ? "Lamparina cheia" : power == .restDay ? "Máximo guardado" : "Já ativo"
        }
        return "Comprar"
    }

    private var timeRemaining: String {
        guard let until = game.xpBoostUntil else { return "" }
        let remaining = until.timeIntervalSince(Date())
        let minutes = Int(remaining / 60)
        return minutes > 0 ? "\(minutes)m restante" : "Expirando…"
    }
}

struct PaywallBannerView: View {
    @Binding var showPaywall: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manna Plus")
                        .font(Theme.font(18, .heavy))
                        .foregroundStyle(.white)
                    Text("Óleo ilimitado, sem anúncios")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.yellow)
            }
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Theme.wheat, Theme.wheatDark]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)

            Button {
                showPaywall = true
            } label: {
                Text("Assinar Agora")
                    .font(Theme.font(14, .heavy))
            }
            .buttonStyle(.chunky)
        }
        .padding(16)
        .background(Theme.oliveLight)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
}

struct DailyTreasureView: View {
    @Binding var opened: Bool
    @Binding var lastDate: String?
    @State private var showReward = false
    @State private var rewardText = ""
    let game: GameState

    var canOpenToday: Bool {
        lastDate != GameState.dayKey(Date())
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if !opened {
                    // Baú fechado
                    VStack(spacing: 8) {
                        TreasureChestView(opened: false)
                            .frame(height: 100)

                        Text("1 baú por dia")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.inkMuted)

                        if canOpenToday {
                            Text("Toque para abrir")
                                .font(Theme.font(11, .medium))
                                .foregroundStyle(Theme.wheat)
                        } else {
                            Text("Voltará amanhã")
                                .font(Theme.font(11, .medium))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.card)
                    )
                    .onTapGesture {
                        if canOpenToday {
                            openTreasure()
                        }
                    }
                } else {
                    // Baú aberto com recompensa
                    VStack(spacing: 12) {
                        TreasureChestView(opened: true)
                            .frame(height: 100)

                        Text("Parabéns!")
                            .font(Theme.font(16, .heavy))
                            .foregroundStyle(Theme.ink)

                        Text(rewardText)
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.wheat)
                            .multilineTextAlignment(.center)

                        Button {
                            opened = false
                            showReward = false
                        } label: {
                            Text("Fechar")
                                .font(Theme.font(12, .heavy))
                        }
                        .buttonStyle(.chunkyCorrect)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Theme.oliveLight)
                    )
                }
            }
        }
    }

    private func openTreasure() {
        // Escolher recompensa aleatória
        let rewardType = Int.random(in: 0..<3)
        switch rewardType {
        case 0:
            // 10-30 maná
            let manaReward = Int.random(in: 10...30)
            game.addManna(manaReward)
            rewardText = "Recebeu \(manaReward) maná! ✨"
        case 1:
            // 1 dia de descanso
            game.grantRestDay()
            rewardText = "Recebeu 1 dia de descanso! 🌙"
        case 2:
            // XP em dobro 15 min
            game.activateXPBoost(minutes: 15)
            rewardText = "XP em dobro por 15 minutos! ⚡"
        default:
            break
        }

        lastDate = GameState.dayKey(Date())
        UserDefaults.standard.set(lastDate, forKey: "lastTreasureDate")
        opened = true
        SoundFX.play(.reward)
        Haptics.success()
    }
}

struct TreasureChestView: View {
    let opened: Bool

    var body: some View {
        ZStack {
            // Corpo do baú
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(hex: 0x8B6914))
                .frame(height: 60)

            // Tampas
            if !opened {
                VStack(spacing: 1) {
                    // Tampa fechada (topo)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: 0xA0791C))
                        .frame(height: 30)

                    Spacer()
                }
            } else {
                // Tampa aberta (rotacionada)
                VStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(hex: 0xA0791C))
                        .frame(height: 20)
                        .rotationEffect(.degrees(-45), anchor: .top)
                        .offset(y: -5)

                    Spacer()
                }
            }

            // Brilho dentro (quando aberto)
            if opened {
                Circle()
                    .fill(Theme.manna.opacity(0.5))
                    .frame(width: 40, height: 40)
            }
        }
    }
}

#Preview {
    ShopView()
        .environment(GameState.load())
}
