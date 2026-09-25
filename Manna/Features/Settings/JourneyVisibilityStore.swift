import Foundation
import Observation

/// Controla quais jornadas são visíveis (ocultar uma jornada = equivalente a "remover curso").
@Observable
final class JourneyVisibilityStore {
    static let shared = JourneyVisibilityStore()

    private(set) var hiddenJourneys: Set<String> = []

    private let userDefaultsKey = "manna.journeyVisibility.v1"

    init() {
        load()
    }

    func isHidden(_ journeyId: String) -> Bool {
        hiddenJourneys.contains(journeyId)
    }

    func toggleVisibility(_ journeyId: String) {
        if hiddenJourneys.contains(journeyId) {
            hiddenJourneys.remove(journeyId)
        } else {
            hiddenJourneys.insert(journeyId)
        }
        save()
    }

    func show(_ journeyId: String) {
        hiddenJourneys.remove(journeyId)
        save()
    }

    func hide(_ journeyId: String) {
        hiddenJourneys.insert(journeyId)
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(hiddenJourneys), forKey: userDefaultsKey)
    }

    private func load() {
        if let saved = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            hiddenJourneys = Set(saved)
        }
    }
}
