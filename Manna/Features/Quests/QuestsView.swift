import SwiftUI

/// Aba de Missões: missões do dia, desafio do mês, pão diário (últimos 7 dias).
struct QuestsView: View {
    @Environment(GameState.self) private var game
    @Environment(\.selectAppTab) private var selectTab
    @State private var showRewardAnimation = false
    @State private var rewardAmount = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Missões")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Conclua desafios diários")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        StatBadge(icon: .manna, value: String(game.manna))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                    // MARK: - Scroll com seções
                    ScrollView {
                        VStack(spacing: 24) {
                            // Seção: Missões do dia
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Missões do dia")
                                        .font(Theme.font(18, .heavy))
                                        .foregroundStyle(Theme.ink)

                                    let nextReset = nextResetTime()
                                    Text("Novas missões em \(nextReset.hours)h \(nextReset.minutes)m")
                                        .font(Theme.font(13, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(.horizontal, 16)

                                VStack(spacing: 12) {
                                    ForEach(game.missions) { mission in
                                        MissionCard(mission: mission)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            // Seção: Desafio do mês
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Desafio do mês")
                                    .font(Theme.font(18, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                MonthlyChallengeView()
                                    .padding(.horizontal, 16)
                            }

                            // Seção: Pão diário
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Pão diário")
                                        .font(Theme.font(18, .heavy))
                                        .foregroundStyle(Theme.ink)

                                    Text("Sua sequência de \(game.bread) dia\(game.bread == 1 ? "" : "s")")
                                        .font(Theme.font(13, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(.horizontal, 16)

                                BreadStreakView()
                                    .padding(.horizontal, 16)
                            }

                            // Seção: Ir para a loja
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Precisa de mais maná?")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                Button(action: { selectTab(.shop) }) {
                                    HStack {
                                        GameIconView(icon: .manna, size: 28)
                                        Text("Ir para a Loja")
                                            .font(Theme.font(16, .heavy))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.chunky)
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 24)
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    private func nextResetTime() -> (hours: Int, minutes: Int) {
        let now = Date()
        let cal = Calendar.current

        // Próxima meia-noite
        let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now))!
        let diff = tomorrow.timeIntervalSince(now)

        let hours = Int(diff / 3600)
        let minutes = Int((diff.truncatingRemainder(dividingBy: 3600)) / 60)
        return (hours, minutes)
    }
}

// MARK: - Mission Card

// MARK: - Mission Card

/// Cartão de uma missão diária com ícone, nome, barra de progresso e recompensa.
struct MissionCard: View {
    let mission: DailyMission

    var progress: Double {
        Double(mission.progress) / Double(mission.target)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Ícone da missão
                ZStack {
                    Circle()
                        .fill(missionColor.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: missionIcon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(missionColor)
                }

                // Detalhes
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text("\(mission.progress) de \(mission.target)")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                // Recompensa
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        GameIconView(icon: .manna, size: 20)
                        Text(String(mission.rewardManna))
                            .font(Theme.font(14, .heavy))
                            .foregroundStyle(Theme.manna)
                    }
                }
            }

            // Barra de progresso
            ProgressView(value: min(1, progress))
                .tint(missionColor)
                .frame(height: 8)
        }
        .padding(14)
        .background(Theme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }

    private var missionColor: Color {
        switch mission.kind {
        case .completeLessons: Theme.wheat
        case .earnXP: Theme.wheat
        case .perfectLessons: Theme.olive
        case .practice: Theme.night
        case .story: Theme.terracotta
        }
    }

    private var missionIcon: String {
        switch mission.kind {
        case .completeLessons: "book.fill"
        case .earnXP: "bolt.fill"
        case .perfectLessons: "star.fill"
        case .practice: "dumbbell.fill"
        case .story: "text.book.closed.fill"
        }
    }
}

// MARK: - Monthly Challenge View

// MARK: - Monthly Challenge View

struct MonthlyChallengeView: View {
    @Environment(GameState.self) private var game
    private let monthlyStore = MonthlyChallengeStore.shared
    @State private var showRewardAnimation = false

    var body: some View {
        let completed = monthlyStore.completedMissionsThisMonth()
        let target = 30
        let progress = Double(min(completed, target)) / Double(target)

        VStack(spacing: 16) {
            // Cabeçalho com mês e medalha
            HStack(spacing: 12) {
                // Medalha do mês
                ZStack {
                    Circle()
                        .fill(
                            monthlyStore.monthlyRewardClaimed
                                ? LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xFFA500)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Theme.wheat, Theme.wheatDark]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 56, height: 56)

                    if monthlyStore.monthlyRewardClaimed {
                        Image(systemName: "star.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(hex: 0x8B4513))
                    } else {
                        Text("\(completed)")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Desafio de \(monthName(Date()))")
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text("Complete \(target) missões diárias")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()
            }

            // Barra de progresso
            VStack(spacing: 6) {
                ProgressView(value: progress)
                    .tint(monthlyStore.monthlyRewardClaimed ? Color(hex: 0xFFD700) : Theme.wheat)
                    .frame(height: 12)

                HStack {
                    Text("\(completed)/\(target)")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                    Spacer()
                    if completed >= target && !monthlyStore.monthlyRewardClaimed {
                        Text("Recompensa: 100 maná")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.olive)
                    } else if monthlyStore.monthlyRewardClaimed {
                        Text("✓ Concluído!")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.olive)
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }

    private func monthName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date).capitalized
    }
}

// MARK: - Bread Streak View

struct BreadStreakView: View {
    @Environment(GameState.self) private var game

    var body: some View {
        let lastSeven = game.lastSevenDays

        VStack(spacing: 12) {
            // Últimos 7 dias (segunda a domingo)
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    let studied = lastSeven[index]
                    VStack(spacing: 4) {
                        Text(dayName(offset: index - 6))
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.inkMuted)

                        ZStack {
                            Circle()
                                .fill(studied ? Theme.wheat.opacity(0.2) : Theme.line.opacity(0.3))

                            if studied {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Theme.wheat)
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                }
            }

            // Dias de descanso disponíveis
            HStack(spacing: 8) {
                GameIconView(icon: .rest, size: 24)
                Text("\(game.restDays) dia\(game.restDays == 1 ? "" : "s") de descanso")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }
            .padding(12)
            .background(Theme.rest.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(14)
        .background(Theme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }

    private func dayName(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date).uppercased()
    }
}

#Preview {
    QuestsView()
        .environment(GameState())
        .environment(ContentStore())
}
