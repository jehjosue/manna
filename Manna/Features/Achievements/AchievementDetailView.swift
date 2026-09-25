import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // Ícone grande
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
                                .font(.system(size: 60, weight: .semibold))
                                .foregroundStyle(achievement.color)
                        }
                        .frame(height: 140)
                        .padding(.horizontal, 40)

                        // Título e descrição
                        VStack(spacing: 8) {
                            Text(achievement.title)
                                .font(Theme.font(22, .bold))
                                .foregroundStyle(Theme.ink)

                            Text(achievement.description)
                                .font(Theme.font(15, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Níveis
                        VStack(spacing: 12) {
                            ForEach(achievement.levels, id: \.tier) { level in
                                LevelRow(achievement: achievement, level: level)
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 30)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func valueForAchievement(_ id: String, game: GameState) -> Int {
        switch id {
        case "pao-diario": return game.bestBread
        case "semeador": return game.xpTotal
        case "perfeito": return game.perfectLessonCount
        case "discipulo": return game.completedLessonCount
        case "contador": return game.storiesCompleted.count
        case "vigilante": return game.practiceCount
        case "relampago": return game.challengeCount
        case "peregrino": return ContentStore.shared.journeys.filter { journey in
            !journey.allLessons.isEmpty && game.completedCount(in: journey) == journey.allLessons.count
        }.count
        default: return 0
        }
    }
}

struct LevelRow: View {
    let achievement: Achievement
    let level: AchievementLevel

    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store

    var body: some View {
        let current = valueForAchievement(achievement.id, game: game)
        let isUnlocked = store.maxUnlockedTier(for: achievement.id) == level.tier
        let isFullyClaimed = store.claimedRewards.contains("\(achievement.id)-\(level.tier.rawValue)")

        HStack(spacing: 12) {
            VStack(spacing: 4) {
                HStack {
                    Text(level.tier.displayName)
                        .font(Theme.font(14, .bold))
                        .foregroundStyle(isUnlocked ? .white : Theme.inkMuted)

                    Spacer()

                    Text(level.description)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(isUnlocked ? .white : Theme.inkMuted)
                }

                HStack {
                    ProgressView(value: Double(current), total: Double(level.threshold))
                        .tint(level.tier.color)

                    if isUnlocked {
                        HStack(spacing: 4) {
                            GameIconView(icon: .manna, size: 16)
                            Text("+\(level.tier.mannaReward)")
                                .font(Theme.font(12, .bold))
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                isUnlocked && !isFullyClaimed
                    ? Color(hex: 0xFFD700).opacity(0.2)
                    : Theme.card
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isUnlocked ? level.tier.color : Theme.line,
                        lineWidth: isUnlocked ? 2 : 1
                    )
            )
            .cornerRadius(12)

            if isUnlocked && !isFullyClaimed {
                Button(action: {
                    let manna = store.claimReward(achievement.id, tier: level.tier, game: game)
                    SoundFX.play(.levelUp)
                    Haptics.success()
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(level.tier.color)
                }
            } else if isFullyClaimed {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.line)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementDetailView(achievement: AchievementStore.shared.achievements.first ?? Achievement(id: "", title: "", description: "", icon: "", levels: []))
            .environment(GameState.load())
            .environment(AchievementStore.shared)
    }
}
