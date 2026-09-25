import Foundation
import Observation

/// Armazena boosts consumíveis: +15s no desafio relâmpago.
@Observable
final class BoostInventoryStore {
    static let shared = BoostInventoryStore()

    private(set) var timerBoosts = 0 {
        didSet { save() }
    }

    private static let key = "manna.boosts.v1"

    init() {
        load()
    }

    func addTimerBoost(_ count: Int = 1) {
        timerBoosts += count
    }

    func consumeTimerBoost() -> Bool {
        guard timerBoosts > 0 else { return false }
        timerBoosts -= 1
        return true
    }

    private func save() {
        let data = ["timerBoosts": timerBoosts]
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return
        }
        timerBoosts = decoded["timerBoosts"] ?? 0
    }
}
