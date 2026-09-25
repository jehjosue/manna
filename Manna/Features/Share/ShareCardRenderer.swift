import SwiftUI

/// ShareCardRenderer cria cartões visuais para compartilhamento de conquistas e retrospectiva.
/// Usa ImageRenderer para converter SwiftUI em UIImage (iOS 16+).
struct ShareCardRenderer {
    /// Gera um cartão de conquista pronto para compartilhar.
    static func achievementCard(
        achievement: Achievement,
        tier: AchievementTier,
        gameName: String
    ) -> Image? {
        let card = AchievementShareCard(
            achievement: achievement,
            tier: tier,
            gameName: gameName
        )

        guard let uiImage = ImageRenderer(content: card).uiImage else { return nil }
        return Image(uiImage: uiImage)
    }

    /// Gera um cartão da retrospectiva anual pronto para compartilhar.
    static func yearInReviewCard(
        gameName: String,
        year: Int,
        xpTotal: Int,
        studiedDaysCount: Int,
        bestBread: Int,
        completedLessons: Int,
        completedStories: Int,
        perfectLessons: Int
    ) -> Image? {
        let card = YearInReviewShareCard(
            gameName: gameName,
            year: year,
            xpTotal: xpTotal,
            studiedDaysCount: studiedDaysCount,
            bestBread: bestBread,
            completedLessons: completedLessons,
            completedStories: completedStories,
            perfectLessons: perfectLessons
        )

        guard let uiImage = ImageRenderer(content: card).uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Achievement Share Card

struct AchievementShareCard: View {
    let achievement: Achievement
    let tier: AchievementTier
    let gameName: String

    var body: some View {
        VStack(spacing: 24) {
            // Header com logo/nome
            HStack {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.wheat)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Manna")
                        .font(Theme.font(16, .bold))
                        .foregroundStyle(Theme.ink)
                    Text("Estude a Bíblia")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()
            }

            // Ícone da conquista
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
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(achievement.color)
            }
            .frame(height: 140)

            // Título e tier
            VStack(spacing: 8) {
                Text(achievement.title)
                    .font(Theme.font(24, .bold))
                    .foregroundStyle(Theme.ink)

                HStack(spacing: 6) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 12))
                    Text(tier.displayName)
                        .font(Theme.font(14, .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(tier.color)
                .cornerRadius(16)
            }

            // Nome do jogador
            VStack(spacing: 4) {
                Text(gameName)
                    .font(Theme.font(18, .bold))
                    .foregroundStyle(Theme.ink)

                Text("Conquistou no Manna")
                    .font(Theme.font(12, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 320, height: 420)
        .background(Theme.card)
        .cornerRadius(20)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Year In Review Share Card

struct YearInReviewShareCard: View {
    let gameName: String
    let year: Int
    let xpTotal: Int
    let studiedDaysCount: Int
    let bestBread: Int
    let completedLessons: Int
    let completedStories: Int
    let perfectLessons: Int

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 2) {
                HStack {
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.wheat)

                    Text("Manna")
                        .font(Theme.font(14, .bold))
                        .foregroundStyle(Theme.ink)

                    Spacer()
                }

                Text("Retrospectiva \(year)")
                    .font(Theme.font(20, .bold))
                    .foregroundStyle(Theme.ink)
            }

            // Stats
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    StatTile(
                        icon: "bolt.fill",
                        value: String(xpTotal),
                        label: "XP"
                    )
                    StatTile(
                        icon: "calendar",
                        value: String(studiedDaysCount),
                        label: "Dias"
                    )
                }

                HStack(spacing: 16) {
                    StatTile(
                        icon: "book.fill",
                        value: String(completedLessons),
                        label: "Lições"
                    )
                    StatTile(
                        icon: "star.fill",
                        value: String(bestBread),
                        label: "Sequência"
                    )
                }
            }

            // Nome do jogador
            VStack(spacing: 2) {
                Text(gameName)
                    .font(Theme.font(16, .bold))
                    .foregroundStyle(Theme.ink)
                Text("Meu ano no Manna")
                    .font(Theme.font(11, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 320, height: 420)
        .background(Theme.card)
        .cornerRadius(20)
        .environment(\.colorScheme, .light)
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.wheat)

            Text(value)
                .font(Theme.font(18, .bold))
                .foregroundStyle(Theme.ink)

            Text(label)
                .font(Theme.font(10, .semibold))
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.wheat.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        AchievementShareCard(
            achievement: Achievement(
                id: "pao-diario",
                title: "Pão de cada dia",
                description: "Mantenha uma sequência",
                icon: "calendar.badge.checkmark",
                levels: []
            ),
            tier: .gold,
            gameName: "João"
        )

        YearInReviewShareCard(
            gameName: "Maria",
            year: 2024,
            xpTotal: 15000,
            studiedDaysCount: 287,
            bestBread: 95,
            completedLessons: 342,
            completedStories: 28,
            perfectLessons: 156
        )
    }
}
