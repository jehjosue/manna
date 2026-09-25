import Foundation
import Observation

/// Guarda recompensas de baús na trilha (uma vez) e se uma unidade alcançou lendária.
/// Persistido em UserDefaults.
@Observable
final class PathRewardsStore {
    static let shared = PathRewardsStore()

    /// Baús abertos (unitId -> true).
    private(set) var treasuresOpened: Set<String> = [] { didSet { save() } }

    /// Unidades alcançadas em lendário (unitId -> true).
    private(set) var legendaryUnitsCompleted: Set<String> = [] { didSet { save() } }

    private static let treasuresKey = "manna.pathRewards.treasures.v1"
    private static let legendaryKey = "manna.pathRewards.legendary.v1"

    init() {
        load()
    }

    func hasTreasureOpened(_ unitId: String) -> Bool {
        treasuresOpened.contains(unitId)
    }

    func openTreasure(_ unitId: String) {
        treasuresOpened.insert(unitId)
    }

    func isUnitLegendary(_ unitId: String) -> Bool {
        legendaryUnitsCompleted.contains(unitId)
    }

    func markUnitLegendary(_ unitId: String) {
        legendaryUnitsCompleted.insert(unitId)
    }

    @ObservationIgnored private var isLoading = false

    private func load() {
        isLoading = true
        defer { isLoading = false }
        if let data = UserDefaults.standard.data(forKey: Self.treasuresKey),
           let set = try? JSONDecoder().decode(Set<String>.self, from: data) {
            treasuresOpened = set
        }
        if let data = UserDefaults.standard.data(forKey: Self.legendaryKey),
           let set = try? JSONDecoder().decode(Set<String>.self, from: data) {
            legendaryUnitsCompleted = set
        }
    }

    private func save() {
        guard !isLoading else { return }
        if let data = try? JSONEncoder().encode(treasuresOpened) {
            UserDefaults.standard.set(data, forKey: Self.treasuresKey)
        }
        if let data = try? JSONEncoder().encode(legendaryUnitsCompleted) {
            UserDefaults.standard.set(data, forKey: Self.legendaryKey)
        }
    }
}

/// Guarda o progresso do desafio mensal: quantas missões completadas este mês.
@Observable
final class MonthlyChallengeStore {
    static let shared = MonthlyChallengeStore()

    /// Evita que os didSet gravem valores vazios enquanto o load() ainda está lendo.
    @ObservationIgnored private var isLoading = false

    /// Mês da última contagem ("YYYY-MM").
    private(set) var monthKey: String = "" { didSet { save() } }

    /// IDs de missões já contadas neste mês.
    private(set) var countedMissionIds: Set<String> = [] { didSet { save() } }

    /// Se o desafio foi concluído neste mês (para mostrar a medalha e não contar de novo).
    private(set) var monthlyRewardClaimed: Bool = false { didSet { save() } }

    private static let monthKey_key = "manna.monthlyChallenge.month.v1"
    private static let countedIds_key = "manna.monthlyChallenge.counted.v1"
    private static let claimed_key = "manna.monthlyChallenge.claimed.v1"
    private static let history_key = "manna.monthlyChallenge.history.v1"

    init() {
        load()
        checkMonthRollover()
    }

    /// Mata a contagem se mudou de mês.
    private func checkMonthRollover() {
        let today = Self.monthKey(Date())
        if monthKey != today {
            monthKey = today
            countedMissionIds = []
            monthlyRewardClaimed = false
        }
    }

    func canCountMission(_ missionId: String) -> Bool {
        checkMonthRollover()
        return !countedMissionIds.contains(missionId)
    }

    func countMission(_ missionId: String) {
        checkMonthRollover()
        countedMissionIds.insert(missionId)
    }

    func completedMissionsThisMonth() -> Int {
        checkMonthRollover()
        return countedMissionIds.count
    }

    func claimMonthlyReward() {
        monthlyRewardClaimed = true
        completedMonths.insert(monthKey)
    }

    /// Histórico de meses com o desafio concluído ("YYYY-MM"), para as insígnias mensais.
    private(set) var completedMonths: Set<String> = [] { didSet { save() } }

    /// Meses concluídos, mais recentes primeiro.
    func completedMonthsList() -> [String] {
        completedMonths.sorted(by: >)
    }

    static func monthKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", c.year!, c.month!)
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }
        monthKey = UserDefaults.standard.string(forKey: Self.monthKey_key) ?? ""
        if let data = UserDefaults.standard.data(forKey: Self.countedIds_key),
           let set = try? JSONDecoder().decode(Set<String>.self, from: data) {
            countedMissionIds = set
        }
        monthlyRewardClaimed = UserDefaults.standard.bool(forKey: Self.claimed_key)
        completedMonths = Set(UserDefaults.standard.stringArray(forKey: Self.history_key) ?? [])
        if monthlyRewardClaimed && !monthKey.isEmpty { completedMonths.insert(monthKey) }
    }

    private func save() {
        guard !isLoading else { return }
        UserDefaults.standard.set(monthKey, forKey: Self.monthKey_key)
        if let data = try? JSONEncoder().encode(countedMissionIds) {
            UserDefaults.standard.set(data, forKey: Self.countedIds_key)
        }
        UserDefaults.standard.set(monthlyRewardClaimed, forKey: Self.claimed_key)
        UserDefaults.standard.set(Array(completedMonths), forKey: Self.history_key)
    }
}
