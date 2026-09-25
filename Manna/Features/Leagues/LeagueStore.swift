import Foundation
import SwiftUI
import Observation

// MARK: - Divisões de Ligas

enum LeagueDivision: String, CaseIterable, Codable {
    case mustardSeed      // Grão de Mostarda
    case wheat            // Trigo
    case olive            // Oliveira
    case vine             // Videira
    case cedarOfLebanon   // Cedro do Líbano
    case pearl            // Pérola
    case goldOfOphir      // Ouro de Ofir

    var displayName: String {
        switch self {
        case .mustardSeed: "Grão de Mostarda"
        case .wheat: "Trigo"
        case .olive: "Oliveira"
        case .vine: "Videira"
        case .cedarOfLebanon: "Cedro do Líbano"
        case .pearl: "Pérola"
        case .goldOfOphir: "Ouro de Ofir"
        }
    }

    var icon: String {
        switch self {
        case .mustardSeed: "leaf.arrow.triangle.circlepath"
        case .wheat: "leaf.fill"
        case .olive: "tree.fill"
        case .vine: "grapeseed.fill"
        case .cedarOfLebanon: "tree.fill"
        case .pearl: "star.circle.fill"
        case .goldOfOphir: "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .mustardSeed: Color(hex: 0xF4D03F)
        case .wheat: Color(hex: 0xD4A23D)
        case .olive: Color(hex: 0x7A9A3A)
        case .vine: Color(hex: 0x8B4789)
        case .cedarOfLebanon: Color(hex: 0x654321)
        case .pearl: Color(hex: 0xD3D3D3)
        case .goldOfOphir: Color(hex: 0xFFD700)
        }
    }

    var order: Int {
        switch self {
        case .mustardSeed: 1
        case .wheat: 2
        case .olive: 3
        case .vine: 4
        case .cedarOfLebanon: 5
        case .pearl: 6
        case .goldOfOphir: 7
        }
    }

    /// Threshold de XP semanal para ser promovido (manter ou subir de divisão).
    var promotionThreshold: Int {
        switch self {
        case .mustardSeed: 50
        case .wheat: 100
        case .olive: 150
        case .vine: 250
        case .cedarOfLebanon: 400
        case .pearl: 600
        case .goldOfOphir: 800
        }
    }

    /// Threshold de XP para não descer de divisão (menos de 1/3 do promotionThreshold).
    var retentionThreshold: Int {
        max(0, promotionThreshold / 3)
    }

    var next: LeagueDivision? {
        let allDivisions = LeagueDivision.allCases
        guard let currentIndex = allDivisions.firstIndex(of: self) else { return nil }
        let nextIndex = currentIndex + 1
        return nextIndex < allDivisions.count ? allDivisions[nextIndex] : nil
    }

    var previous: LeagueDivision? {
        let allDivisions = LeagueDivision.allCases
        guard let currentIndex = allDivisions.firstIndex(of: self) else { return nil }
        return currentIndex > 0 ? allDivisions[currentIndex - 1] : nil
    }
}

// MARK: - Store Observable

@Observable
final class LeagueStore {
    static let shared = LeagueStore()

    private(set) var currentDivision: LeagueDivision = .mustardSeed { didSet { save() } }
    private(set) var lastWeeklyXP: Int = 0 { didSet { save() } }
    private(set) var lastWeekStart: Date = Date() { didSet { save() } }
    private(set) var promotionNotice: LeagueDivision? { didSet { save() } }

    private let storageKey = "manna.league.v1"

    init() {
        loadProgress()
        checkWeeklyTransition()
    }

    /// Avalia a posição do jogador no fim da semana e atualiza a divisão.
    func evaluateWeeklyProgress(weeklyXP: Int) {
        let promotionThreshold = currentDivision.promotionThreshold
        let retentionThreshold = currentDivision.retentionThreshold

        if weeklyXP >= promotionThreshold, let nextDivision = currentDivision.next {
            // Promover
            currentDivision = nextDivision
            promotionNotice = nextDivision
        } else if weeklyXP < retentionThreshold, let prevDivision = currentDivision.previous {
            // Descer
            currentDivision = prevDivision
            promotionNotice = nil
        }

        lastWeeklyXP = weeklyXP
        lastWeekStart = Date()
        save()
    }

    func clearPromotionNotice() {
        promotionNotice = nil
        save()
    }

    // MARK: - Privadas

    private func checkWeeklyTransition() {
        // A avaliação real acontece em `rollOverIfNeeded(game:)`, que conhece o XP de cada dia.
    }

    /// Na virada da semana (segunda-feira), avalia o XP da semana que terminou:
    /// sobe de divisão se bateu a meta, desce se ficou abaixo de 1/3 dela.
    func rollOverIfNeeded(game: GameState) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        guard let lastStart = calendar.dateInterval(of: .weekOfYear, for: lastWeekStart)?.start,
              let currentStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
              lastStart < currentStart else { return }
        // XP da semana registrada por último (7 dias a partir do início dela).
        let xp = (0..<7).reduce(0) { sum, offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: lastStart) else { return sum }
            return sum + game.xp(on: day)
        }
        evaluateWeeklyProgress(weeklyXP: xp)
    }

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        currentDivision = snapshot.currentDivision
        lastWeeklyXP = snapshot.lastWeeklyXP
        lastWeekStart = snapshot.lastWeekStart
        promotionNotice = snapshot.promotionNotice
    }

    private func save() {
        let snapshot = Snapshot(
            currentDivision: currentDivision,
            lastWeeklyXP: lastWeeklyXP,
            lastWeekStart: lastWeekStart,
            promotionNotice: promotionNotice
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private struct Snapshot: Codable {
        var currentDivision: LeagueDivision
        var lastWeeklyXP: Int
        var lastWeekStart: Date
        var promotionNotice: LeagueDivision?
    }
}
