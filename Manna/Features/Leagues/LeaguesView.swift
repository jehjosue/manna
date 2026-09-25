import SwiftUI

struct LeaguesView: View {
    @Environment(GameState.self) var game
    @Environment(GameCenterService.self) var gameCenter
    @Environment(LeagueStore.self) var leagueStore

    @State private var selectedTab: Int = 0
    @State private var showPromotionAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Banner sem conexão
                    OfflineBanner()
                        .padding(.vertical, 12)

                    // Cabeçalho da Liga
                    LeagueHeaderView()
                        .environment(game)
                        .environment(leagueStore)

                    // Abas
                    Picker("Seção", selection: $selectedTab) {
                        Text("Ligas").tag(0)
                        Text("Grupos").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Conteúdo
                    ZStack {
                        if selectedTab == 0 {
                            LeagueLeaderboardView()
                                .environment(game)
                                .environment(gameCenter)
                        } else {
                            GroupsView()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Enviar XP semanal ao abrir
                gameCenter.submitWeeklyXP(game.weeklyXP)
                gameCenter.submitTotalXP(game.xpTotal)
                gameCenter.loadWeeklyLeaderboard()
            }
            .sheet(isPresented: Binding(
                get: { leagueStore.promotionNotice != nil },
                set: { if !$0 { leagueStore.clearPromotionNotice() } }
            )) {
                if let notice = leagueStore.promotionNotice {
                    LeaguePromotionSheet(division: notice)
                }
            }
        }
    }
}

struct LeagueHeaderView: View {
    @Environment(GameState.self) var game
    @Environment(LeagueStore.self) var leagueStore

    var body: some View {
        VStack(spacing: 16) {
            // Emblema da divisão
            VStack(spacing: 8) {
                Image(systemName: leagueStore.currentDivision.icon)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(leagueStore.currentDivision.color)

                Text(leagueStore.currentDivision.displayName)
                    .font(Theme.font(18, .bold))
                    .foregroundStyle(Theme.ink)

                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                    Text("\(leagueStore.currentDivision.order)")
                        .font(Theme.font(12, .semibold))
                }
                .foregroundStyle(leagueStore.currentDivision.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(leagueStore.currentDivision.color.opacity(0.1))
            .cornerRadius(12)

            // Tempo até o fim da semana
            VStack(spacing: 4) {
                Text("A semana termina em:")
                    .font(Theme.font(11, .semibold))
                    .foregroundStyle(Theme.inkMuted)

                HStack(spacing: 4) {
                    let weekEnd = weekEndDate
                    let timeLeft = weekEnd.timeIntervalSince(Date())
                    let days = Int(timeLeft / 86400)
                    let hours = Int((timeLeft.truncatingRemainder(dividingBy: 86400)) / 3600)

                    Text("\(days)d \(hours)h")
                        .font(Theme.font(14, .bold))
                        .foregroundStyle(Theme.ink)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Theme.card)
            .cornerRadius(12)

            // Barra de meta de promoção
            PromotionProgressView()
                .environment(game)
                .environment(leagueStore)
        }
        .padding(16)
    }

    private var weekEndDate: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        guard let weekEnd = calendar.dateInterval(of: .weekOfYear, for: Date())?.end else { return Date() }
        return weekEnd
    }
}

struct PromotionProgressView: View {
    @Environment(GameState.self) var game
    @Environment(LeagueStore.self) var leagueStore

    var body: some View {
        let current = game.weeklyXP
        let target = leagueStore.currentDivision.promotionThreshold
        let progress = Double(current) / Double(target)

        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meta de Promoção")
                        .font(Theme.font(12, .bold))
                        .foregroundStyle(Theme.ink)
                    Text("\(current) / \(target) XP")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if current >= target, let nextDiv = leagueStore.currentDivision.next {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Promovível")
                            .font(Theme.font(11, .bold))
                            .foregroundStyle(Theme.olive)
                        Text("Para: \(nextDiv.displayName)")
                            .font(Theme.font(10, .semibold))
                            .foregroundStyle(nextDiv.color)
                    }
                }
            }

            ProgressView(value: min(progress, 1))
                .tint(leagueStore.currentDivision.color)
                .frame(height: 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Theme.card)
        .cornerRadius(10)
    }
}

struct LeagueLeaderboardView: View {
    @Environment(GameState.self) var game
    @Environment(GameCenterService.self) var gameCenter

    @State private var showFriendsList = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Segmentado: Global vs Amigos
                Picker("Escopo", selection: $showFriendsList) {
                    Text("Global").tag(false)
                    Text("Amigos").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                let leaderboard = showFriendsList ? gameCenter.weeklyLeaderboard : gameCenter.globalLeaderboard

                if gameCenter.isLoadingLeaderboard {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if leaderboard.isEmpty {
                    VStack(spacing: 8) {
                        Text("Sem dados de ranking ainda")
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.inkMuted)
                        Text("Continue estudando para aparecer no ranking!")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(leaderboard) { player in
                        LeaderboardRow(player: player, isCurrentPlayer: player.id == game.userName)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
    }
}

struct LeaderboardRow: View {
    let player: GameCenterPlayer
    let isCurrentPlayer: Bool

    var body: some View {
        HStack(spacing: 12) {
            if let rank = player.rank {
                Text("\(rank)")
                    .font(Theme.font(14, .bold))
                    .foregroundStyle(Theme.inkMuted)
                    .frame(width: 30)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName)
                    .font(Theme.font(14, .bold))
                    .foregroundStyle(Theme.ink)

                if player.weeklyXP > 0 {
                    Text("\(player.weeklyXP) XP essa semana")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                GameIconView(icon: .xp, size: 16)
                Text("\(player.weeklyXP)")
                    .font(Theme.font(14, .bold))
                    .foregroundStyle(Theme.wheat)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(isCurrentPlayer ? Theme.wheat.opacity(0.1) : Theme.card)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isCurrentPlayer ? Theme.wheat : Theme.line, lineWidth: isCurrentPlayer ? 2 : 1)
        )
    }
}

struct LeaguePromotionSheet: View {
    let division: LeagueDivision
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "star.burst.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(division.color)

                Text("Parabéns!")
                    .font(Theme.font(24, .bold))
                    .foregroundStyle(Theme.ink)

                Text("Você subiu para \(division.displayName)")
                    .font(Theme.font(16, .bold))
                    .foregroundStyle(division.color)

                Text("Continue estudando para manter sua posição!")
                    .font(Theme.font(13, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Continuar estudando")
            }
            .buttonStyle(.chunky)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LeaguesView()
        .environment(GameState.load())
        .environment(GameCenterService.shared)
        .environment(LeagueStore.shared)
}
