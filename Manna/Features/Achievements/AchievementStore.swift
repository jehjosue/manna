import Foundation
import Observation
import SwiftUI

// MARK: - Tipos de Conquistas

enum AchievementTier: String, CaseIterable, Codable {
    case bronze, silver, gold, platinum, diamond

    var displayName: String {
        switch self {
        case .bronze: "Bronze"
        case .silver: "Prata"
        case .gold: "Ouro"
        case .platinum: "Platina"
        case .diamond: "Diamante"
        }
    }

    var color: Color {
        switch self {
        case .bronze: Color(hex: 0xCD7F32)
        case .silver: Color(hex: 0xC0C0C0)
        case .gold: Color(hex: 0xFFD700)
        case .platinum: Color(hex: 0xE5E4E2)
        case .diamond: Color(hex: 0xB9F2FF)
        }
    }

    var mannaReward: Int {
        switch self {
        case .bronze: 10
        case .silver: 25
        case .gold: 50
        case .platinum: 100
        case .diamond: 200
        }
    }
}

struct AchievementLevel: Codable, Hashable {
    let tier: AchievementTier
    let threshold: Int
    let description: String
}

struct Achievement: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String  // SF Symbol
    let levels: [AchievementLevel]

    var color: Color {
        switch id {
        case "pao-diario": Color(hex: 0xD98E3A)
        case "semeador": Color(hex: 0x7A9A3A)
        case "perfeito": Color(hex: 0xD0643F)
        case "discipulo": Color(hex: 0x3B5BA9)
        case "contador": Color(hex: 0xE8A33D)
        case "vigilante": Color(hex: 0x7FA7D9)
        case "relampago": Color(hex: 0xC9A227)
        case "peregrino": Color(hex: 0x8C4F3E)
        default: Color(hex: 0x6B5B4F)
        }
    }
}

struct AchievementUnlock: Identifiable {
    let id: String
    let achievement: Achievement
    let tier: AchievementTier
    let mannaReward: Int
}

// MARK: - Store Observable

@Observable
final class AchievementStore {
    static let shared = AchievementStore()

    private(set) var achievements: [Achievement] = []
    private(set) var unlockedLevels: [String: String] = [:]  // [achievementId: tierName]
    private(set) var claimedRewards: Set<String> = []  // [achievementId-tier]

    private let storageKey = "manna.achievements.v1"

    init() {
        loadAchievements()
        loadProgress()
    }

    private func loadAchievements() {
        achievements = [
            Achievement(
                id: "pao-diario",
                title: "Pão de cada dia",
                description: "Mantenha uma sequência de dias estudando",
                icon: "calendar.badge.checkmark",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 3, description: "3 dias seguidos"),
                    AchievementLevel(tier: .silver, threshold: 7, description: "1 semana perfeita"),
                    AchievementLevel(tier: .gold, threshold: 30, description: "30 dias seguidos"),
                    AchievementLevel(tier: .platinum, threshold: 100, description: "100 dias seguidos"),
                    AchievementLevel(tier: .diamond, threshold: 365, description: "1 ano completo"),
                ]
            ),
            Achievement(
                id: "semeador",
                title: "Semeador",
                description: "Acumule experiência como sementes plantadas",
                icon: "sparkles",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 100, description: "100 XP"),
                    AchievementLevel(tier: .silver, threshold: 500, description: "500 XP"),
                    AchievementLevel(tier: .gold, threshold: 2000, description: "2.000 XP"),
                    AchievementLevel(tier: .platinum, threshold: 10000, description: "10.000 XP"),
                    AchievementLevel(tier: .diamond, threshold: 50000, description: "50.000 XP"),
                ]
            ),
            Achievement(
                id: "perfeito",
                title: "Perfeito como a pérola",
                description: "Complete lições sem erros",
                icon: "star.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 3, description: "3 lições perfeitas"),
                    AchievementLevel(tier: .silver, threshold: 10, description: "10 lições perfeitas"),
                    AchievementLevel(tier: .gold, threshold: 25, description: "25 lições perfeitas"),
                    AchievementLevel(tier: .platinum, threshold: 50, description: "50 lições perfeitas"),
                    AchievementLevel(tier: .diamond, threshold: 100, description: "100 lições perfeitas"),
                ]
            ),
            Achievement(
                id: "discipulo",
                title: "Discípulo fiel",
                description: "Complete lições da sua trilha de estudo",
                icon: "book.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 5, description: "5 lições concluídas"),
                    AchievementLevel(tier: .silver, threshold: 20, description: "20 lições concluídas"),
                    AchievementLevel(tier: .gold, threshold: 50, description: "50 lições concluídas"),
                    AchievementLevel(tier: .platinum, threshold: 100, description: "100 lições concluídas"),
                    AchievementLevel(tier: .diamond, threshold: 250, description: "250 lições concluídas"),
                ]
            ),
            Achievement(
                id: "contador",
                title: "Contador de histórias",
                description: "Leia histórias bíblicas complementares",
                icon: "book.circle.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 1, description: "1 história lida"),
                    AchievementLevel(tier: .silver, threshold: 5, description: "5 histórias lidas"),
                    AchievementLevel(tier: .gold, threshold: 15, description: "15 histórias lidas"),
                    AchievementLevel(tier: .platinum, threshold: 30, description: "30 histórias lidas"),
                    AchievementLevel(tier: .diamond, threshold: 60, description: "60 histórias lidas"),
                ]
            ),
            Achievement(
                id: "vigilante",
                title: "Vigilante",
                description: "Pratique e revise lições aprendidas",
                icon: "eye.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 5, description: "5 práticas"),
                    AchievementLevel(tier: .silver, threshold: 20, description: "20 práticas"),
                    AchievementLevel(tier: .gold, threshold: 50, description: "50 práticas"),
                    AchievementLevel(tier: .platinum, threshold: 100, description: "100 práticas"),
                    AchievementLevel(tier: .diamond, threshold: 250, description: "250 práticas"),
                ]
            ),
            Achievement(
                id: "relampago",
                title: "Relâmpago",
                description: "Complete desafios contra o relógio",
                icon: "bolt.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 3, description: "3 desafios"),
                    AchievementLevel(tier: .silver, threshold: 10, description: "10 desafios"),
                    AchievementLevel(tier: .gold, threshold: 25, description: "25 desafios"),
                    AchievementLevel(tier: .platinum, threshold: 50, description: "50 desafios"),
                    AchievementLevel(tier: .diamond, threshold: 100, description: "100 desafios"),
                ]
            ),
            Achievement(
                id: "peregrino",
                title: "Peregrino",
                description: "Complete jornadas de estudo inteiras",
                icon: "mappin.circle.fill",
                levels: [
                    AchievementLevel(tier: .bronze, threshold: 1, description: "1 jornada"),
                    AchievementLevel(tier: .silver, threshold: 3, description: "3 jornadas"),
                    AchievementLevel(tier: .gold, threshold: 5, description: "5 jornadas"),
                    AchievementLevel(tier: .platinum, threshold: 8, description: "8 jornadas"),
                    AchievementLevel(tier: .diamond, threshold: 12, description: "12 jornadas"),
                ]
            ),
        ]
    }

    /// Calcula conquistas desbloqueadas comparando contadores do GameState.
    func checkForNewUnlocks(game: GameState) -> [AchievementUnlock] {
        var unlocks: [AchievementUnlock] = []

        for achievement in achievements {
            let currentValue = valueForAchievement(achievement.id, game: game)

            // Itera pelos níveis em ordem crescente
            for level in achievement.levels {
                let tierName = level.tier.rawValue
                let key = "\(achievement.id)-\(tierName)"

                // Se o contador >= limite do nível E ainda não foi resgatado...
                if currentValue >= level.threshold && !claimedRewards.contains(key) {
                    // Marcar como desbloqueado (não resgatado ainda)
                    unlockedLevels[achievement.id] = tierName
                    unlocks.append(AchievementUnlock(
                        id: key,
                        achievement: achievement,
                        tier: level.tier,
                        mannaReward: level.tier.mannaReward
                    ))
                }
            }
        }

        return unlocks
    }

    /// Retorna o nível máximo desbloqueado para uma conquista.
    func maxUnlockedTier(for achievementId: String) -> AchievementTier? {
        guard let tierName = unlockedLevels[achievementId],
              let tier = AchievementTier(rawValue: tierName) else { return nil }
        return tier
    }

    /// Retorna o progresso (valor atual, limite próximo nível).
    func progress(for achievementId: String, game: GameState) -> (current: Int, nextThreshold: Int)? {
        guard let achievement = achievements.first(where: { $0.id == achievementId }) else { return nil }
        let current = valueForAchievement(achievementId, game: game)
        let nextLevel = achievement.levels.first { $0.threshold > current }
        return (current, nextLevel?.threshold ?? achievement.levels.last?.threshold ?? 0)
    }

    /// Resgate de maná para um nível desbloqueado.
    func claimReward(achievementId: String, tier: AchievementTier, game: GameState) -> Int {
        let key = "\(achievementId)-\(tier.rawValue)"
        guard !claimedRewards.contains(key) else { return 0 }
        claimedRewards.insert(key)
        let manna = tier.mannaReward
        game.addManna(manna)
        save()
        return manna
    }

    // MARK: - Privadas

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

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        unlockedLevels = snapshot.unlockedLevels
        claimedRewards = snapshot.claimedRewards
    }

    private func save() {
        let snapshot = Snapshot(
            unlockedLevels: unlockedLevels,
            claimedRewards: claimedRewards
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private struct Snapshot: Codable {
        var unlockedLevels: [String: String]
        var claimedRewards: Set<String>
    }
}
