import SwiftUI

/// Navegação principal: 4 abas (Início, Missões, Grupos, Perfil).
/// Obrigatório ser chamado de MainTabView — RootView o procura com esse nome.
struct MainTabView: View {
    @Environment(GameState.self) private var game
    @State private var selectedTab: TabSelection = .home

    enum TabSelection {
        case home
        case missions
        case groups
        case profile
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Aba: Início (trilha)
                HomeView()
                    .tag(TabSelection.home)
                    .tabItem {
                        Label("Início", systemImage: "house.fill")
                    }

                // Aba: Missões
                MissionsView()
                    .tag(TabSelection.missions)
                    .tabItem {
                        Label("Missões", systemImage: "checklist")
                    }

                // Aba: Grupos (placeholder)
                GroupsPlaceholderView()
                    .tag(TabSelection.groups)
                    .tabItem {
                        Label("Grupos", systemImage: "person.3.fill")
                    }

                // Aba: Perfil
                ProfileView()
                    .tag(TabSelection.profile)
                    .tabItem {
                        Label("Perfil", systemImage: "person.crop.circle.fill")
                    }
            }
            .tint(Theme.wheat)
        }
    }
}

/// Missões diárias: lista com barra de progresso, pão diário, loja.
struct MissionsView: View {
    @Environment(GameState.self) private var game

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                TopStatsBar()
                    .padding(16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Missões do dia
                        VStack(spacing: 12) {
                            Text("Missões de hoje")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(game.missions, id: \.id) { mission in
                                MissionCard(mission: mission)
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Pão diário (últimos 7 dias)
                        VStack(spacing: 12) {
                            Text("Pão diário")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 8) {
                                ForEach(game.lastSevenDays.indices, id: \.self) { i in
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(game.lastSevenDays[i] ? Theme.bread : Theme.line)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Theme.line, lineWidth: 2)
                                            )

                                        Text(dayLabel(i))
                                            .font(Theme.font(10, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(12)
                            .background(Theme.card)
                            .cornerRadius(12)
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Loja
                        VStack(spacing: 12) {
                            Text("Loja")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ShopItem(
                                icon: .oil,
                                title: "Encher óleo",
                                description: "Enche sua lamparina até o máximo",
                                cost: GameState.refillOilCost,
                                action: {
                                    _ = game.refillOilWithManna()
                                }
                            )

                            ShopItem(
                                icon: .rest,
                                title: "Dia de descanso",
                                description: "Protege seu pão diário por 1 dia",
                                cost: GameState.restDayCost,
                                action: {
                                    _ = game.buyRestDay()
                                }
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    /// Abreviação do dia da semana; o índice 6 é hoje.
    private func dayLabel(_ index: Int) -> String {
        let days = ["dom", "seg", "ter", "qua", "qui", "sex", "sáb"]
        let date = Calendar.current.date(byAdding: .day, value: index - 6, to: Date()) ?? Date()
        let weekday = Calendar.current.component(.weekday, from: date)   // 1 = domingo
        return days[weekday - 1]
    }
}

/// Card individual de missão com barra de progresso.
struct MissionCard: View {
    let mission: DailyMission

    var progress: Double {
        Double(mission.progress) / Double(mission.target)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text("\(mission.progress)/\(mission.target)")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                HStack(spacing: 4) {
                    GameIconView(icon: .manna, size: 16)
                    Text("+\(mission.rewardManna)")
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.manna)
                }
            }

            // Barra de progresso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.line)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(mission.isDone ? Theme.olive : Theme.wheat)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 12)
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(12)
    }
}

/// Item da loja (compra com maná).
struct ShopItem: View {
    let icon: GameIcon
    let title: String
    let description: String
    let cost: Int
    let action: () -> Void

    @Environment(GameState.self) private var game

    var canAfford: Bool { game.manna >= cost }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                GameIconView(icon: icon, size: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text(description)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(cost)")
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.manna)
                    GameIconView(icon: .manna, size: 16)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(canAfford ? Theme.card : Theme.cream)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(canAfford ? Theme.line : Theme.lineDark, lineWidth: 1)
            )
        }
        .disabled(!canAfford)
        .opacity(canAfford ? 1 : 0.6)
    }
}

/// Placeholder para grupos (em breve).
struct GroupsPlaceholderView: View {
    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 20) {
                SheepView(mood: .happy, size: 100)

                VStack(spacing: 8) {
                    Text("Em breve")
                        .font(Theme.font(24, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text("Estude junto com sua igreja e amigos")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
        }
    }
}

/// Perfil do usuário: nome, XP, pão, lições, meta diária.
struct ProfileView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content

    var totalLessonsCompleted: Int {
        game.lessons.count
    }

    var totalLessonsAvailable: Int {
        content.journey?.allLessons.count ?? 0
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                TopStatsBar()
                    .padding(16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Nome
                        VStack(spacing: 8) {
                            Text(game.userName.isEmpty ? "Bem-vindo" : game.userName)
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)

                            Text("Nível \(game.xpTotal / 100 + 1)")
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .padding(.vertical, 8)

                        // Estatísticas em grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ProfileStatCard(
                                    icon: .xp,
                                    title: "XP Total",
                                    value: "\(game.xpTotal)"
                                )

                                ProfileStatCard(
                                    icon: .bread,
                                    title: "Sequência",
                                    value: "\(game.bread)"
                                )
                            }

                            HStack(spacing: 12) {
                                ProfileStatCard(
                                    icon: .xp,
                                    title: "Lições",
                                    value: "\(totalLessonsCompleted)/\(totalLessonsAvailable)"
                                )

                                ProfileStatCard(
                                    icon: .xp,
                                    title: "Meta diária",
                                    value: "\(game.xpToday)/\(game.dailyGoalXP)"
                                )
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Debug: botão apagar progresso
                        #if DEBUG
                        VStack(spacing: 8) {
                            Button(action: {
                                game.resetAll()
                            }) {
                                Text("🔴 Apagar progresso (DEBUG)")
                            }
                            .buttonStyle(.chunkyWrong)
                        }
                        #endif

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }
}

/// Cartão de estatística pequeno.
struct ProfileStatCard: View {
    let icon: GameIcon
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            GameIconView(icon: icon, size: 24)

            Text(title)
                .font(Theme.font(12, .semibold))
                .foregroundStyle(Theme.inkMuted)

            Text(value)
                .font(Theme.font(18, .heavy))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.card)
        .cornerRadius(12)
    }
}

#Preview {
    MainTabView()
        .environment(GameState.load())
        .environment(ContentStore())
}
