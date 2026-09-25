import SwiftUI

struct ProfileView: View {
    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var achievementStore

    @State private var isShowingSettings = false
    @State private var isShowingAvatarEditor = false
    @State private var isShowingEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Card de completar perfil (se não estiver completo)
                        ProfileCompletionCard()

                        // Cabeçalho com Avatar
                        VStack(spacing: 12) {
                            ZStack(alignment: .topTrailing) {
                                SheepAvatarView(size: 140)

                                Button(action: { isShowingEditProfile = true }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Theme.wheat)
                                        .background(Circle().fill(Theme.card))
                                }
                            }

                            Text(game.userName)
                                .font(Theme.font(22, .bold))
                                .foregroundStyle(Theme.ink)

                            Text("Membro desde \(formatDate(game.joinedAt))")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .padding(.vertical, 20)

                        // Botão Configurações
                        HStack(spacing: 0) {
                            Spacer()
                            Button(action: { isShowingSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Theme.ink)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Estatísticas (grade 2x2)
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ProfileStatCard(
                                    icon: .bread,
                                    title: "Sequência Atual",
                                    value: "\(game.bread)",
                                    subtitle: "Máximo: \(game.bestBread)"
                                )

                                ProfileStatCard(
                                    icon: .xp,
                                    title: "XP Total",
                                    value: "\(game.xpTotal)",
                                    subtitle: ""
                                )
                            }

                            HStack(spacing: 12) {
                                ProfileStatCard(
                                    icon: .manna,
                                    title: "Lições",
                                    value: "\(game.completedLessonCount)",
                                    subtitle: "concluídas"
                                )

                                ProfileStatCard(
                                    icon: .oil,
                                    title: "Taxa de Acertos",
                                    value: game.completedLessonCount > 0
                                        ? "\(game.perfectLessonCount)/\(game.completedLessonCount)"
                                        : "—",
                                    subtitle: "perfeitas"
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Pão Diário (Calendário)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pão Diário")
                                .font(Theme.font(16, .bold))
                                .foregroundStyle(Theme.ink)
                                .padding(.horizontal, 20)

                            StreakCalendarView()
                                .environment(game)
                        }

                        // Jornadas
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Jornadas")
                                    .font(Theme.font(16, .bold))
                                    .foregroundStyle(Theme.ink)

                                Spacer()

                                NavigationLink(destination: ProfileJourneysView()) {
                                    Text("Ver todas")
                                        .font(Theme.font(12, .bold))
                                        .foregroundStyle(Theme.wheat)
                                }
                            }
                            .padding(.horizontal, 20)

                            ProfileJourneysPreview()
                                .padding(.horizontal, 20)
                        }

                        // Conquistas (3 destaques + Ver Todas)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Conquistas")
                                    .font(Theme.font(16, .bold))
                                    .foregroundStyle(Theme.ink)

                                Spacer()

                                NavigationLink(destination: AchievementsView()) {
                                    Text("Ver todas")
                                        .font(Theme.font(12, .bold))
                                        .foregroundStyle(Theme.wheat)
                                }
                            }
                            .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(achievementStore.achievements.prefix(3)) { achievement in
                                        let maxTier = achievementStore.maxUnlockedTier(for: achievement.id)

                                        NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    achievement.color.opacity(0.3),
                                                                    achievement.color.opacity(0.1)
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )

                                                    Image(systemName: achievement.icon)
                                                        .font(.system(size: 24))
                                                        .foregroundStyle(achievement.color)

                                                    if let tier = maxTier {
                                                        VStack {
                                                            HStack {
                                                                Spacer()
                                                                Image(systemName: "star.fill")
                                                                    .font(.system(size: 10))
                                                                    .foregroundStyle(tier.color)
                                                            }
                                                            Spacer()
                                                        }
                                                        .padding(6)
                                                    }
                                                }
                                                .frame(width: 70, height: 70)

                                                Text(achievement.title)
                                                    .font(Theme.font(11, .bold))
                                                    .foregroundStyle(Theme.ink)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(width: 90)
                                            .padding(8)
                                            .background(Theme.card)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Amigos (Game Center / Social)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Amigos")
                                    .font(Theme.font(16, .bold))
                                    .foregroundStyle(Theme.ink)

                                Spacer()
                            }
                            .padding(.horizontal, 20)

                            FriendsProfileSection()
                        }

                        // Botões de ação
                        VStack(spacing: 12) {
                            NavigationLink(destination: YearInReviewView()) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Retrospectiva do Ano")
                                        .font(Theme.font(15, .bold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)

                            NavigationLink(destination: MonthlyBadgesView()) {
                                HStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Insígnias Mensais")
                                        .font(Theme.font(15, .bold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)

                            Button(action: shareProgress) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Compartilhar meu progresso")
                                        .font(Theme.font(15, .bold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileView()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM 'de' yyyy"
        return formatter.string(from: date)
    }

    private func shareProgress() {
        let progressCard = ProgressShareCard()
            .environment(game)

        DispatchQueue.main.async {
            guard let image = ImageRenderer(content: progressCard).uiImage else { return }
            let sheet = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first?
                .rootViewController?
                .present(sheet, animated: true)
        }
    }
}

struct ProfileStatCard: View {
    let icon: GameIcon
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GameIconView(icon: icon, size: 20)
                Text(title)
                    .font(Theme.font(12, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                Spacer()
            }

            Text(value)
                .font(Theme.font(24, .bold))
                .foregroundStyle(icon.color)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(Theme.font(11, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .cornerRadius(12)
    }
}


struct ProgressShareCard: View {
    @Environment(GameState.self) var game

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                SheepAvatarView(size: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.userName)
                        .font(Theme.font(18, .bold))
                    Text("Estudando no Manna")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()
            }

            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    GameIconView(icon: .bread, size: 24)
                    Text("\(game.bread)")
                        .font(Theme.font(14, .bold))
                }

                VStack(alignment: .center, spacing: 4) {
                    GameIconView(icon: .xp, size: 24)
                    Text("\(game.xpTotal)")
                        .font(Theme.font(14, .bold))
                }

                VStack(alignment: .center, spacing: 4) {
                    GameIconView(icon: .manna, size: 24)
                    Text("\(game.manna)")
                        .font(Theme.font(14, .bold))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.line.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(20)
        .frame(width: 320, height: 200)
        .background(Theme.card)
        .cornerRadius(16)
    }
}

#Preview {
    ProfileView()
        .environment(GameState.load())
        .environment(AchievementStore.shared)
        .environment(AvatarStore.shared)
        .environment(ContentStore.shared)
}
