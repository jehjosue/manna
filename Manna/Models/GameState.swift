import Foundation
import Observation

// MARK: - Tipos de apoio

/// O que a tela de lição devolve ao terminar (sem ter desistido).
struct LessonOutcome: Hashable {
    let lessonId: String
    let correctCount: Int
    let totalCount: Int
    let mistakes: Int
}

/// Resultado calculado pelo GameState — alimenta a sequência de telas de celebração.
struct LessonResult: Hashable {
    let lessonId: String
    let xpEarned: Int
    let mannaEarned: Int
    let accuracy: Double           // 0...1
    let isPerfect: Bool
    let breadBefore: Int           // sequência antes
    let breadAfter: Int            // sequência depois
    let breadExtendedToday: Bool   // true = primeira lição do dia (mostrar tela do pão diário)
    let completedMissions: [DailyMission]
    let dailyGoalReachedNow: Bool
    let lastSevenDays: [Bool]      // do mais antigo para hoje: estudou naquele dia?
}

struct DailyMission: Codable, Identifiable, Hashable {
    enum Kind: String, Codable { case completeLessons, earnXP, perfectLessons }
    let id: String
    let kind: Kind
    let target: Int
    var progress: Int
    var rewardManna: Int = 10

    var title: String {
        switch kind {
        case .completeLessons: target == 1 ? "Complete 1 lição" : "Complete \(target) lições"
        case .earnXP: "Ganhe \(target) XP"
        case .perfectLessons: target == 1 ? "Faça 1 lição sem erros" : "Faça \(target) lições sem erros"
        }
    }
    var isDone: Bool { progress >= target }
}

struct LessonRecord: Codable, Hashable {
    var completions: Int
    var bestAccuracy: Double
}

// MARK: - Estado do jogo

/// Todo o progresso do usuário, salvo localmente (UserDefaults).
@Observable
final class GameState {
    // Perfil / onboarding
    var hasOnboarded = false
    var userName = ""
    var dailyGoalXP = 20                  // 10 casual · 20 regular · 30 sério · 50 intenso
    var knowledgeLevel = "iniciante"      // "iniciante" | "conheco-um-pouco" | "conheco-bem"
    var reminderHour: Int? = 20           // hora do lembrete diário (nil = sem lembrete)

    // Progresso
    private(set) var xpTotal = 0
    private(set) var xpByDay: [String: Int] = [:]
    private(set) var studiedDays: Set<String> = []
    private(set) var lessons: [String: LessonRecord] = [:]

    // Pão diário (sequência)
    private(set) var bread = 0
    private(set) var lastStudyDay: String?
    private(set) var restDays = 1                     // dias de descanso guardados (máx. 2)
    /// Preenchido quando um dia de descanso salvou a sequência; a UI mostra um aviso e chama `clearRestNotice()`.
    private(set) var restUsedNotice: Int?

    // Maná (moeda) e óleo (vidas)
    private(set) var manna = 50
    private(set) var oil = GameState.maxOil
    private(set) var oilLastRefill = Date()

    // Missões do dia
    private(set) var missions: [DailyMission] = []
    private(set) var missionsDay: String?

    static let maxOil = 5
    static let oilRefillInterval: TimeInterval = 30 * 60   // 1 gota a cada 30 min
    static let maxRestDays = 2
    static let refillOilCost = 50
    static let restDayCost = 100

    // MARK: Consultas

    var xpToday: Int { xpByDay[Self.dayKey(Date())] ?? 0 }
    var studiedToday: Bool { studiedDays.contains(Self.dayKey(Date())) }
    var hasOil: Bool { oil > 0 }

    func isCompleted(_ lessonId: String) -> Bool { lessons[lessonId] != nil }

    /// Primeira lição não concluída da jornada (a "atual" na trilha).
    func currentLessonId(in journey: Journey) -> String? {
        journey.allLessons.first { !isCompleted($0.id) }?.id
    }

    /// Lição liberada = concluída ou a atual.
    func isUnlocked(_ lessonId: String, in journey: Journey) -> Bool {
        isCompleted(lessonId) || currentLessonId(in: journey) == lessonId
    }

    /// Tempo até a próxima gota de óleo (nil se cheio).
    var nextOilIn: TimeInterval? {
        guard oil < Self.maxOil else { return nil }
        return max(0, Self.oilRefillInterval - Date().timeIntervalSince(oilLastRefill))
    }

    /// Últimos 7 dias (mais antigo → hoje): estudou?
    var lastSevenDays: [Bool] {
        (0..<7).reversed().map { offset in
            let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            return studiedDays.contains(Self.dayKey(day))
        }
    }

    // MARK: Ações

    func finishOnboarding(name: String, dailyGoalXP: Int, knowledgeLevel: String, reminderHour: Int?) {
        userName = name
        self.dailyGoalXP = dailyGoalXP
        self.knowledgeLevel = knowledgeLevel
        self.reminderHour = reminderHour
        hasOnboarded = true
        refreshForToday()
        save()
    }

    /// Chamar ao abrir o app / voltar do segundo plano: repõe óleo, verifica a sequência, gera missões do dia.
    func refreshForToday() {
        regenerateOil()
        checkBread()
        if missionsDay != Self.dayKey(Date()) { generateMissions() }
        save()
    }

    /// Chamar a cada resposta errada.
    func loseOil() {
        regenerateOil()
        guard oil > 0 else { return }
        if oil == Self.maxOil { oilLastRefill = Date() }
        oil -= 1
        save()
    }

    /// Revisão/prática devolve 1 gota.
    func gainOil(_ amount: Int = 1) {
        oil = min(Self.maxOil, oil + amount)
        if oil == Self.maxOil { oilLastRefill = Date() }
        save()
    }

    @discardableResult
    func refillOilWithManna() -> Bool {
        guard manna >= Self.refillOilCost, oil < Self.maxOil else { return false }
        manna -= Self.refillOilCost
        oil = Self.maxOil
        oilLastRefill = Date()
        save()
        return true
    }

    @discardableResult
    func buyRestDay() -> Bool {
        guard manna >= Self.restDayCost, restDays < Self.maxRestDays else { return false }
        manna -= Self.restDayCost
        restDays += 1
        save()
        return true
    }

    func clearRestNotice() {
        restUsedNotice = nil
        save()
    }

    /// Registra a lição concluída e devolve tudo que a celebração precisa mostrar.
    func completeLesson(_ outcome: LessonOutcome) -> LessonResult {
        refreshForToday()
        let today = Self.dayKey(Date())
        let accuracy = outcome.totalCount == 0 ? 1 : Double(outcome.correctCount) / Double(outcome.totalCount)
        let isPerfect = outcome.mistakes == 0
        let xp = 10 + (isPerfect ? 5 : 0)
        let goalBefore = xpToday >= dailyGoalXP

        // XP
        xpTotal += xp
        xpByDay[today, default: 0] += xp

        // Pão diário
        let breadBefore = bread
        let extended = !studiedDays.contains(today)
        if extended {
            bread += 1
            studiedDays.insert(today)
            lastStudyDay = today
        }

        // Registro da lição
        var record = lessons[outcome.lessonId] ?? LessonRecord(completions: 0, bestAccuracy: 0)
        record.completions += 1
        record.bestAccuracy = max(record.bestAccuracy, accuracy)
        lessons[outcome.lessonId] = record

        // Missões
        var justCompleted: [DailyMission] = []
        for i in missions.indices {
            let wasDone = missions[i].isDone
            switch missions[i].kind {
            case .completeLessons: missions[i].progress += 1
            case .earnXP: missions[i].progress += xp
            case .perfectLessons: if isPerfect { missions[i].progress += 1 }
            }
            missions[i].progress = min(missions[i].progress, missions[i].target)
            if !wasDone && missions[i].isDone { justCompleted.append(missions[i]) }
        }

        // Maná
        let earned = 5 + justCompleted.reduce(0) { $0 + $1.rewardManna }
        manna += earned

        save()
        return LessonResult(
            lessonId: outcome.lessonId,
            xpEarned: xp,
            mannaEarned: earned,
            accuracy: accuracy,
            isPerfect: isPerfect,
            breadBefore: breadBefore,
            breadAfter: bread,
            breadExtendedToday: extended,
            completedMissions: justCompleted,
            dailyGoalReachedNow: !goalBefore && xpToday >= dailyGoalXP,
            lastSevenDays: lastSevenDays
        )
    }

    // MARK: Regras internas

    private func regenerateOil() {
        guard oil < Self.maxOil else { oilLastRefill = Date(); return }
        let elapsed = Date().timeIntervalSince(oilLastRefill)
        let drops = Int(elapsed / Self.oilRefillInterval)
        guard drops > 0 else { return }
        oil = min(Self.maxOil, oil + drops)
        oilLastRefill = oil == Self.maxOil
            ? Date()
            : oilLastRefill.addingTimeInterval(Double(drops) * Self.oilRefillInterval)
    }

    /// Se passou dia(s) sem estudar: gasta dias de descanso; se não houver suficientes, zera o pão.
    private func checkBread() {
        guard let last = lastStudyDay, let lastDate = Self.date(from: last) else { return }
        let cal = Calendar.current
        let gap = cal.dateComponents([.day], from: cal.startOfDay(for: lastDate), to: cal.startOfDay(for: Date())).day ?? 0
        let missed = gap - 1
        guard missed > 0 else { return }
        if restDays >= missed {
            restDays -= missed
            restUsedNotice = missed
            // Os dias protegidos contam como "estudados" para não quebrar de novo amanhã.
            for offset in 1...missed {
                let day = cal.date(byAdding: .day, value: -offset, to: Date())!
                studiedDays.insert(Self.dayKey(day))
            }
            lastStudyDay = Self.dayKey(cal.date(byAdding: .day, value: -1, to: Date())!)
        } else {
            bread = 0
            lastStudyDay = nil
        }
    }

    private func generateMissions() {
        let day = Self.dayKey(Date())
        missionsDay = day
        missions = [
            DailyMission(id: "\(day)-lessons", kind: .completeLessons, target: 2, progress: 0),
            DailyMission(id: "\(day)-xp", kind: .earnXP, target: dailyGoalXP, progress: 0),
            DailyMission(id: "\(day)-perfect", kind: .perfectLessons, target: 1, progress: 0),
        ]
    }

    // MARK: Datas

    static func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    static func date(from key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    // MARK: Persistência

    private struct Snapshot: Codable {
        var hasOnboarded: Bool
        var userName: String
        var dailyGoalXP: Int
        var knowledgeLevel: String
        var reminderHour: Int?
        var xpTotal: Int
        var xpByDay: [String: Int]
        var studiedDays: Set<String>
        var lessons: [String: LessonRecord]
        var bread: Int
        var lastStudyDay: String?
        var restDays: Int
        var restUsedNotice: Int?
        var manna: Int
        var oil: Int
        var oilLastRefill: Date
        var missions: [DailyMission]
        var missionsDay: String?
    }

    private static let storageKey = "manna.gameState.v1"

    static func load() -> GameState {
        let state = GameState()
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let s = try? JSONDecoder().decode(Snapshot.self, from: data) else { return state }
        state.hasOnboarded = s.hasOnboarded
        state.userName = s.userName
        state.dailyGoalXP = s.dailyGoalXP
        state.knowledgeLevel = s.knowledgeLevel
        state.reminderHour = s.reminderHour
        state.xpTotal = s.xpTotal
        state.xpByDay = s.xpByDay
        state.studiedDays = s.studiedDays
        state.lessons = s.lessons
        state.bread = s.bread
        state.lastStudyDay = s.lastStudyDay
        state.restDays = s.restDays
        state.restUsedNotice = s.restUsedNotice
        state.manna = s.manna
        state.oil = s.oil
        state.oilLastRefill = s.oilLastRefill
        state.missions = s.missions
        state.missionsDay = s.missionsDay
        return state
    }

    func save() {
        let s = Snapshot(
            hasOnboarded: hasOnboarded, userName: userName, dailyGoalXP: dailyGoalXP,
            knowledgeLevel: knowledgeLevel, reminderHour: reminderHour, xpTotal: xpTotal,
            xpByDay: xpByDay, studiedDays: studiedDays, lessons: lessons, bread: bread,
            lastStudyDay: lastStudyDay, restDays: restDays, restUsedNotice: restUsedNotice,
            manna: manna, oil: oil, oilLastRefill: oilLastRefill, missions: missions,
            missionsDay: missionsDay
        )
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    #if DEBUG
    /// Apaga todo o progresso (útil em testes).
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        let fresh = GameState()
        hasOnboarded = fresh.hasOnboarded; userName = ""; xpTotal = 0; xpByDay = [:]
        studiedDays = []; lessons = [:]; bread = 0; lastStudyDay = nil; restDays = 1
        restUsedNotice = nil; manna = 50; oil = Self.maxOil; oilLastRefill = Date()
        missions = []; missionsDay = nil
    }
    #endif
}
