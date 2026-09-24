import Foundation
import Observation

// MARK: - Tipos de apoio

/// O que uma atividade (lição, prática, história, desafio) devolve ao terminar sem desistir.
struct LessonOutcome: Hashable {
    let lessonId: String
    let correctCount: Int
    let totalCount: Int
    let mistakes: Int
    /// Exercícios errados (vão para "Revisar erros").
    var wrongExerciseIds: [String] = []
    /// Exercícios acertados (saem de "Revisar erros" se estavam lá).
    var correctExerciseIds: [String] = []
}

/// Tipos de atividade que dão XP.
enum ActivityKind: String, Codable, Hashable {
    case lesson       // lição da trilha (marca a lição como concluída)
    case practice     // revisão / treino (não altera a trilha)
    case story        // história
    case challenge    // desafio cronometrado
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
    let breadExtendedToday: Bool   // true = primeira atividade do dia (mostrar tela do pão diário)
    let completedMissions: [DailyMission]
    let dailyGoalReachedNow: Bool
    let lastSevenDays: [Bool]      // do mais antigo para hoje: estudou naquele dia?
    var kind: ActivityKind = .lesson
    var boosted: Bool = false      // XP em dobro ativo
}

struct DailyMission: Codable, Identifiable, Hashable {
    enum Kind: String, Codable { case completeLessons, earnXP, perfectLessons, practice, story }
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
        case .practice: "Faça 1 revisão ou treino"
        case .story: "Leia 1 história"
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
/// Recursos com estado próprio (conquistas, avatar, loja, Game Center...) ficam em stores separados
/// e leem daqui os contadores de que precisam.
@Observable
final class GameState {
    // Perfil / onboarding
    var hasOnboarded = false { didSet { save() } }
    var userName = "" { didSet { save() } }
    var dailyGoalXP = 20 { didSet { save() } }                 // 10 leve · 20 regular · 30 firme · 50 intenso
    var knowledgeLevel = "iniciante" { didSet { save() } }     // "iniciante" | "conheco-um-pouco" | "conheco-bem"
    var reminderHour: Int? = 20 { didSet { save() } }          // hora do lembrete diário (nil = sem lembrete)
    private(set) var joinedAt = Date()

    // Configurações
    var soundEnabled = true { didSet { save() } }
    var hapticsEnabled = true { didSet { save() } }

    // Progresso
    private(set) var xpTotal = 0
    private(set) var xpByDay: [String: Int] = [:]
    private(set) var studiedDays: Set<String> = []
    private(set) var lessons: [String: LessonRecord] = [:]

    // Contadores (conquistas / perfil)
    private(set) var perfectLessonCount = 0
    private(set) var practiceCount = 0
    private(set) var challengeCount = 0
    private(set) var storiesCompleted: Set<String> = []
    private(set) var bestBread = 0
    /// Exercícios errados aguardando revisão (mais recentes no fim, sem repetição).
    private(set) var mistakeIds: [String] = []

    // Pão diário (sequência)
    private(set) var bread = 0
    private(set) var lastStudyDay: String?
    private(set) var restDays = 1                     // dias de descanso guardados (máx. 2)
    /// Preenchido quando um dia de descanso salvou a sequência; a UI mostra um aviso e chama `clearRestNotice()`.
    private(set) var restUsedNotice: Int?

    // Maná (moeda), óleo (vidas), bônus e assinatura
    private(set) var manna = 50
    private(set) var oil = GameState.maxOil
    private(set) var oilLastRefill = Date()
    private(set) var xpBoostUntil: Date?
    /// Assinante do Manna Plus (óleo ilimitado etc.). Definido pelo módulo de assinatura.
    var isPlus = false { didSet { save() } }

    // Missões do dia
    private(set) var missions: [DailyMission] = []
    private(set) var missionsDay: String?

    static let maxOil = 5
    static let oilRefillInterval: TimeInterval = 30 * 60   // 1 gota a cada 30 min
    static let maxRestDays = 2
    static let refillOilCost = 50
    static let restDayCost = 100
    static let xpBoostCost = 80
    static let xpBoostMinutes = 15
    static let maxMistakes = 60

    // MARK: Consultas

    var xpToday: Int { xpByDay[Self.dayKey(Date())] ?? 0 }
    var studiedToday: Bool { studiedDays.contains(Self.dayKey(Date())) }
    var hasOil: Bool { isPlus || oil > 0 }
    var isXPBoostActive: Bool { (xpBoostUntil ?? .distantPast) > Date() }
    var completedLessonCount: Int { lessons.count }
    var dailyGoalReached: Bool { xpToday >= dailyGoalXP }

    /// XP da semana atual (segunda a domingo) — usado nas ligas.
    var weeklyXP: Int {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let start = cal.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return (0..<7).reduce(0) { sum, offset in
            let day = cal.date(byAdding: .day, value: offset, to: start)!
            return sum + (xpByDay[Self.dayKey(day)] ?? 0)
        }
    }

    func xp(on date: Date) -> Int { xpByDay[Self.dayKey(date)] ?? 0 }
    func studied(on date: Date) -> Bool { studiedDays.contains(Self.dayKey(date)) }
    func isCompleted(_ lessonId: String) -> Bool { lessons[lessonId] != nil }

    /// Primeira lição não concluída da jornada (a "atual" na trilha).
    func currentLessonId(in journey: Journey) -> String? {
        journey.allLessons.first { !isCompleted($0.id) }?.id
    }

    /// Lição liberada = concluída ou a atual.
    func isUnlocked(_ lessonId: String, in journey: Journey) -> Bool {
        isCompleted(lessonId) || currentLessonId(in: journey) == lessonId
    }

    func completedCount(in journey: Journey) -> Int {
        journey.allLessons.filter { isCompleted($0.id) }.count
    }

    /// Tempo até a próxima gota de óleo (nil se cheio).
    var nextOilIn: TimeInterval? {
        guard oil < Self.maxOil, !isPlus else { return nil }
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
        joinedAt = Date()
        hasOnboarded = true
        refreshForToday()
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
        guard !isPlus else { return }
        regenerateOil()
        guard oil > 0 else { return }
        if oil == Self.maxOil { oilLastRefill = Date() }
        oil -= 1
        save()
    }

    /// Revisão/prática devolve óleo.
    func gainOil(_ amount: Int = 1) {
        oil = min(Self.maxOil, oil + amount)
        if oil == Self.maxOil { oilLastRefill = Date() }
        save()
    }

    func addManna(_ amount: Int) {
        manna += max(0, amount)
        save()
    }

    /// Gasta maná se houver saldo. Retorna `false` se não der.
    @discardableResult
    func spendManna(_ amount: Int) -> Bool {
        guard amount >= 0, manna >= amount else { return false }
        manna -= amount
        save()
        return true
    }

    @discardableResult
    func refillOilWithManna() -> Bool {
        guard oil < Self.maxOil, spendManna(Self.refillOilCost) else { return false }
        oil = Self.maxOil
        oilLastRefill = Date()
        save()
        return true
    }

    @discardableResult
    func buyRestDay() -> Bool {
        guard restDays < Self.maxRestDays, spendManna(Self.restDayCost) else { return false }
        restDays += 1
        save()
        return true
    }

    /// Dá um dia de descanso sem custo (recompensas de baú/conquista).
    func grantRestDay() {
        restDays = min(Self.maxRestDays, restDays + 1)
        save()
    }

    @discardableResult
    func buyXPBoost() -> Bool {
        guard !isXPBoostActive, spendManna(Self.xpBoostCost) else { return false }
        activateXPBoost(minutes: Self.xpBoostMinutes)
        return true
    }

    /// XP em dobro por alguns minutos (loja, baús, conquistas).
    func activateXPBoost(minutes: Int) {
        let base = isXPBoostActive ? (xpBoostUntil ?? Date()) : Date()
        xpBoostUntil = base.addingTimeInterval(TimeInterval(minutes * 60))
        save()
    }

    func clearRestNotice() {
        restUsedNotice = nil
        save()
    }

    /// Registra uma lição da trilha concluída e devolve tudo que a celebração precisa mostrar.
    func completeLesson(_ outcome: LessonOutcome) -> LessonResult {
        completeActivity(outcome, kind: .lesson)
    }

    /// Registra qualquer atividade (lição, prática, história, desafio).
    /// Toda atividade conta para o pão diário, XP, missões e maná.
    func completeActivity(_ outcome: LessonOutcome, kind: ActivityKind, baseXP: Int? = nil) -> LessonResult {
        refreshForToday()
        let today = Self.dayKey(Date())
        let accuracy = outcome.totalCount == 0 ? 1 : Double(outcome.correctCount) / Double(outcome.totalCount)
        let isPerfect = outcome.mistakes == 0
        let boosted = isXPBoostActive
        let base = baseXP ?? (10 + (isPerfect ? 5 : 0))
        let xp = boosted ? base * 2 : base
        let goalBefore = dailyGoalReached

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
            bestBread = max(bestBread, bread)
        }

        // Registro por tipo
        switch kind {
        case .lesson:
            var record = lessons[outcome.lessonId] ?? LessonRecord(completions: 0, bestAccuracy: 0)
            record.completions += 1
            record.bestAccuracy = max(record.bestAccuracy, accuracy)
            lessons[outcome.lessonId] = record
            if isPerfect { perfectLessonCount += 1 }
        case .practice:
            practiceCount += 1
            gainOil()   // praticar devolve 1 gota
        case .story:
            storiesCompleted.insert(outcome.lessonId)
        case .challenge:
            challengeCount += 1
        }

        // Revisar erros
        let fixed = Set(outcome.correctExerciseIds)
        mistakeIds.removeAll { fixed.contains($0) }
        for id in outcome.wrongExerciseIds where !mistakeIds.contains(id) { mistakeIds.append(id) }
        if mistakeIds.count > Self.maxMistakes { mistakeIds.removeFirst(mistakeIds.count - Self.maxMistakes) }

        // Missões
        var justCompleted: [DailyMission] = []
        for i in missions.indices {
            let wasDone = missions[i].isDone
            switch missions[i].kind {
            case .completeLessons: if kind == .lesson { missions[i].progress += 1 }
            case .earnXP: missions[i].progress += xp
            case .perfectLessons: if kind == .lesson && isPerfect { missions[i].progress += 1 }
            case .practice: if kind == .practice || kind == .challenge { missions[i].progress += 1 }
            case .story: if kind == .story { missions[i].progress += 1 }
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
            dailyGoalReachedNow: !goalBefore && dailyGoalReached,
            lastSevenDays: lastSevenDays,
            kind: kind,
            boosted: boosted
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
        // Missão variável: alterna entre prática, história e lição perfeita conforme o dia.
        let dayNumber = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let rotating: DailyMission = switch dayNumber % 3 {
        case 0: DailyMission(id: "\(day)-practice", kind: .practice, target: 1, progress: 0)
        case 1: DailyMission(id: "\(day)-story", kind: .story, target: 1, progress: 0)
        default: DailyMission(id: "\(day)-perfect", kind: .perfectLessons, target: 1, progress: 0)
        }
        missions = [
            DailyMission(id: "\(day)-lessons", kind: .completeLessons, target: 2, progress: 0),
            DailyMission(id: "\(day)-xp", kind: .earnXP, target: dailyGoalXP, progress: 0),
            rotating,
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
        var joinedAt: Date?
        var soundEnabled: Bool?
        var hapticsEnabled: Bool?
        var xpTotal: Int
        var xpByDay: [String: Int]
        var studiedDays: Set<String>
        var lessons: [String: LessonRecord]
        var perfectLessonCount: Int?
        var practiceCount: Int?
        var challengeCount: Int?
        var storiesCompleted: Set<String>?
        var bestBread: Int?
        var mistakeIds: [String]?
        var bread: Int
        var lastStudyDay: String?
        var restDays: Int
        var restUsedNotice: Int?
        var manna: Int
        var oil: Int
        var oilLastRefill: Date
        var xpBoostUntil: Date?
        var isPlus: Bool?
        var missions: [DailyMission]
        var missionsDay: String?
    }

    private static let storageKey = "manna.gameState.v1"
    /// App Group compartilhado com o widget.
    static let appGroup = "group.app.manna.ios"
    private var isLoading = false

    static func load() -> GameState {
        let state = GameState()
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let s = try? JSONDecoder().decode(Snapshot.self, from: data) else { return state }
        state.isLoading = true
        defer { state.isLoading = false }
        state.hasOnboarded = s.hasOnboarded
        state.userName = s.userName
        state.dailyGoalXP = s.dailyGoalXP
        state.knowledgeLevel = s.knowledgeLevel
        state.reminderHour = s.reminderHour
        state.joinedAt = s.joinedAt ?? Date()
        state.soundEnabled = s.soundEnabled ?? true
        state.hapticsEnabled = s.hapticsEnabled ?? true
        state.xpTotal = s.xpTotal
        state.xpByDay = s.xpByDay
        state.studiedDays = s.studiedDays
        state.lessons = s.lessons
        state.perfectLessonCount = s.perfectLessonCount ?? 0
        state.practiceCount = s.practiceCount ?? 0
        state.challengeCount = s.challengeCount ?? 0
        state.storiesCompleted = s.storiesCompleted ?? []
        state.bestBread = s.bestBread ?? s.bread
        state.mistakeIds = s.mistakeIds ?? []
        state.bread = s.bread
        state.lastStudyDay = s.lastStudyDay
        state.restDays = s.restDays
        state.restUsedNotice = s.restUsedNotice
        state.manna = s.manna
        state.oil = s.oil
        state.oilLastRefill = s.oilLastRefill
        state.xpBoostUntil = s.xpBoostUntil
        state.isPlus = s.isPlus ?? false
        state.missions = s.missions
        state.missionsDay = s.missionsDay
        return state
    }

    func save() {
        guard !isLoading else { return }
        let s = Snapshot(
            hasOnboarded: hasOnboarded, userName: userName, dailyGoalXP: dailyGoalXP,
            knowledgeLevel: knowledgeLevel, reminderHour: reminderHour, joinedAt: joinedAt,
            soundEnabled: soundEnabled, hapticsEnabled: hapticsEnabled, xpTotal: xpTotal,
            xpByDay: xpByDay, studiedDays: studiedDays, lessons: lessons,
            perfectLessonCount: perfectLessonCount, practiceCount: practiceCount,
            challengeCount: challengeCount, storiesCompleted: storiesCompleted, bestBread: bestBread,
            mistakeIds: mistakeIds, bread: bread, lastStudyDay: lastStudyDay, restDays: restDays,
            restUsedNotice: restUsedNotice, manna: manna, oil: oil, oilLastRefill: oilLastRefill,
            xpBoostUntil: xpBoostUntil, isPlus: isPlus, missions: missions, missionsDay: missionsDay
        )
        if let data = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
        writeWidgetSnapshot()
    }

    /// Resumo lido pelo widget (App Group). Chaves estáveis: ver `WidgetSnapshot`.
    private func writeWidgetSnapshot() {
        guard let shared = UserDefaults(suiteName: Self.appGroup) else { return }
        let snapshot = WidgetSnapshot(
            bread: bread, studiedToday: studiedToday, xpToday: xpToday,
            dailyGoalXP: dailyGoalXP, manna: manna, userName: userName, updatedAt: Date()
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            shared.set(data, forKey: WidgetSnapshot.key)
        }
    }

    #if DEBUG
    /// Apaga todo o progresso (útil em testes).
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        isLoading = true
        hasOnboarded = false; userName = ""; xpTotal = 0; xpByDay = [:]
        studiedDays = []; lessons = [:]; perfectLessonCount = 0; practiceCount = 0; challengeCount = 0
        storiesCompleted = []; bestBread = 0; mistakeIds = []; bread = 0; lastStudyDay = nil; restDays = 1
        restUsedNotice = nil; manna = 50; oil = Self.maxOil; oilLastRefill = Date(); xpBoostUntil = nil
        isPlus = false; missions = []; missionsDay = nil
        isLoading = false
        save()
    }
    #endif
}

/// Dados mínimos compartilhados com o widget da tela inicial.
struct WidgetSnapshot: Codable {
    static let key = "manna.widget.snapshot"
    let bread: Int
    let studiedToday: Bool
    let xpToday: Int
    let dailyGoalXP: Int
    let manna: Int
    let userName: String
    let updatedAt: Date
}
