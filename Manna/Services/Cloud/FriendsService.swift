import Foundation
import CloudKit
import Observation

// MARK: - CloudKit Schema Documentation
//
// Create these Record Types in CloudKit Dashboard (iCloud.app.manna.ios public database):
//
// 1. MannaProfile
//    Fields:
//      - recordName = userRecordID.recordName
//      - username (String, required, indexed for query)
//      - displayName (String, required)
//      - bread (Int64, required, default 0)
//      - weeklyXP (Int64, required, default 0)
//      - xpTotal (Int64, required, default 0)
//      - avatar (String, optional, JSON encoded)
//      - status (String, optional, emoji + text)
//      - updatedAt (DateTime, required)
//    Indices: username (sortable: false)
//    Notes: Record name is deterministic userRecordID.recordName
//
// 2. MannaFollow
//    Fields:
//      - followerId (String, required, user recordName)
//      - followeeId (String, required, user recordName)
//      - createdAt (DateTime, required)
//    Notes: recordName = "\(followerId)_\(followeeId)"
//
// 3. MannaFeedEvent
//    Fields:
//      - authorId (String, required, user recordName, indexed for query)
//      - authorName (String, required)
//      - kind (String, required: "achievement"|"bread"|"journey"|"league")
//      - text (String, required)
//      - createdAt (DateTime, required, indexed for sorting)
//    Indices: authorId (sortable: false), createdAt (sortable: true)
//
// 4. MannaReaction
//    Fields:
//      - eventId (String, required, indexed for query)
//      - authorId (String, required, user recordName)
//      - emoji (String, required, single emoji)
//      - createdAt (DateTime, required)
//
// 5. MannaNudge
//    Fields:
//      - fromId (String, required, user recordName)
//      - fromName (String, required)
//      - toId (String, required, user recordName, indexed for query)
//      - message (String, required, pre-defined values only)
//      - createdAt (DateTime, required)
//    Indices: toId (sortable: false)
//
// 6. MannaFriendStreak
//    Fields:
//      - userA (String, required, user recordName, lexicographically smaller)
//      - userB (String, required, user recordName, lexicographically larger)
//      - status (String, required: "pending"|"active")
//      - days (Int64, required, default 0)
//      - lastDayA (DateTime, optional)
//      - lastDayB (DateTime, optional)
//      - createdAt (DateTime, required)
//    Notes: recordName = "\(userA)_\(userB)" (deterministic)
//
// 7. MannaDuoQuest
//    Fields:
//      - userA (String, required, user recordName)
//      - userB (String, required, user recordName)
//      - weekKey (String, required, ISO format YYYY-Www)
//      - goalXP (Int64, required)
//      - userAXP (Int64, required, default 0)
//      - userBXP (Int64, required, default 0)
//      - status (String, required: "active"|"completed"|"failed")
//      - createdAt (DateTime, required)
//
// 8. MannaReport
//    Fields:
//      - reporterId (String, required, user recordName)
//      - reportedId (String, required, user recordName)
//      - reason (String, required: "spam"|"harassment"|"inappropriate"|"impersonation"|"other")
//      - createdAt (DateTime, required)
//

// MARK: - Tipos de Dados Locais

/// Perfil público de um usuário.
/// Record type: `MannaProfile` { username, displayName, bread, weeklyXP, xpTotal, avatar, status, updatedAt }
struct MannaPublicProfile: Identifiable, Hashable {
    let id: String         // userRecordID.recordName
    var username: String   // @username, deve ser único
    var displayName: String
    var bread: Int64
    var weeklyXP: Int64
    var xpTotal: Int64
    var avatar: String?    // JSON encoded AvatarState
    var status: String?    // emoji + texto ou nil
    var updatedAt: Date

    /// Calcula a liga baseada no xpTotal (mesmo padrão do LeagueStore).
    var currentLeague: String {
        switch xpTotal {
        case 0..<300: return "Bronze"
        case 300..<900: return "Prata"
        case 900..<2100: return "Ouro"
        case 2100..<4200: return "Diamante"
        case 4200..<7500: return "Campeão"
        case 7500..<12000: return "Lenda"
        default: return "Titã"
        }
    }
}

/// Um evento no mural de amigos (conquista desbloqueada, pão compartilhado atingido, etc).
/// Record type: `MannaFeedEvent` { authorId, authorName, kind, text, createdAt }
struct MannaFeedEvent: Identifiable, Hashable {
    let id: String         // recordName (UUID)
    var authorId: String   // userRecordID.recordName
    var authorName: String
    var kind: String       // "achievement" | "bread" | "journey" | "league"
    var text: String       // descrição do evento
    var createdAt: Date

    /// Reações neste evento (carregadas separadamente).
    var reactions: [MannaReaction] = []

    /// Se o usuário atual já reagiu com este emoji.
    var myReaction: String? = nil
}

/// Uma reação a um evento (emoji fixo).
/// Record type: `MannaReaction` { eventId, authorId, emoji, createdAt }
struct MannaReaction: Identifiable, Hashable {
    let id: String         // recordName (UUID)
    var eventId: String
    var authorId: String
    var emoji: String      // single emoji
    var createdAt: Date
}

/// Um "cutucão" de um amigo (mensagem pré-definida).
/// Record type: `MannaNudge` { fromId, fromName, toId, message, createdAt }
struct MannaNudge: Identifiable, Hashable {
    let id: String
    var fromId: String
    var fromName: String
    var toId: String
    var message: String
    var createdAt: Date
}

/// Uma missão compartilhada entre dois amigos (estudar juntos).
/// Record type: `MannaFriendStreak` { userA, userB, status, days, lastDayA, lastDayB, createdAt }
struct MannaFriendStreak: Identifiable, Hashable {
    let id: String         // "\(userA)_\(userB)"
    var userA: String
    var userB: String
    var status: String     // "pending" (convidado) | "active" (ambos aceitaram)
    var days: Int64
    var lastDayA: Date?
    var lastDayB: Date?
    var createdAt: Date
}

/// Uma missão em dupla (estudar X XP juntos nesta semana).
/// Record type: `MannaDuoQuest` { userA, userB, weekKey, goalXP, userAXP, userBXP, status, createdAt }
struct MannaDuoQuest: Identifiable, Hashable {
    let id: String
    var userA: String
    var userB: String
    var weekKey: String    // "YYYY-Www"
    var goalXP: Int64
    var userAXP: Int64
    var userBXP: Int64
    var status: String     // "active" | "completed" | "failed"
    var createdAt: Date
}

/// Uma denúncia de usuário.
/// Record type: `MannaReport` { reporterId, reportedId, reason, createdAt }
struct MannaReport: Identifiable, Hashable {
    let id: String
    var reporterId: String
    var reportedId: String
    var reason: String     // "spam" | "harassment" | "inappropriate" | "impersonation" | "other"
    var createdAt: Date
}

// MARK: - Mensagens pré-definidas (sem moderação de texto)

let NUDGE_MESSAGES = [
    "😴 Estudar é mais divertido juntos! Bora começar?",
    "🙏 Fé é melhor quando compartilhada. Vamo estudar?",
    "☕ Bora estudar? Você faz, eu faço, a gente cresce junto!",
    "🌟 Você está indo bem! Que tal estudar comigo hoje?",
    "💪 Vem cá! Estou estudando e seria legal você também!",
    "🎯 Faltam poucos XP pro meu objetivo. Me ajuda?",
]

let EMOJI_REACTIONS = ["❤️", "🔥", "😂", "🙏", "⭐", "🎉", "🚀", "💪"]

// MARK: - Service Principal (CloudKit)

/// Gerencia amigos, feed social, reações e nudges com CloudKit.
/// Contrato estável: @Observable final class com métodos sync/async (await).
/// Detecta preview mode automaticamente.
@Observable
final class FriendsService: @unchecked Sendable {
    static let shared = FriendsService()

    // MARK: - Estado

    /// Estado da conta iCloud do usuário.
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine

    /// ID do usuário atual (ou nil se não autenticado).
    private(set) var userRecordID: CKRecord.ID?

    /// Perfil publicado do usuário atual.
    private(set) var myProfile: MannaPublicProfile?

    /// Usuários que sigo.
    private(set) var following: [MannaPublicProfile] = []

    /// Meus seguidores.
    private(set) var followers: [MannaPublicProfile] = []

    /// Mural: eventos dos usuários que sigo, em ordem decrescente de data.
    private(set) var feed: [MannaFeedEvent] = []

    /// Nudges recebidos.
    private(set) var nudges: [MannaNudge] = []

    /// Pão compartilhado com amigos.
    private(set) var friendStreaks: [MannaFriendStreak] = []

    /// Missões em dupla desta semana.
    private(set) var duoQuests: [MannaDuoQuest] = []

    /// Usuários bloqueados (armazenado localmente em UserDefaults).
    private(set) var blockedUsers: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: "manna.friends.blocked.v1") ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: "manna.friends.blocked.v1") }
    }

    /// Em preview/teste, não chamar CloudKit.
    private let isPreview: Bool

    // Criados só quando o iCloud está disponível: sem o entitlement, CKContainer derruba o app.
    @ObservationIgnored private lazy var container = CKContainer(identifier: "iCloud.app.manna.ios")
    @ObservationIgnored private lazy var publicDB = container.publicCloudDatabase

    private init() {
        let inPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        self.isPreview = inPreview || !Self.hasCloudKitEntitlement

        if !isPreview {
            Task {
                await checkAccountStatus()
                await loadUserRecordID()
            }
        }
    }

    /// Simulador e instalações sem perfil com iCloud não têm CloudKit.
    private static var hasCloudKitEntitlement: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
              let data = FileManager.default.contents(atPath: path) else { return true }
        return String(decoding: data, as: UTF8.self).contains("iCloud.app.manna.ios")
        #endif
    }

    // MARK: - Operações Públicas

    /// Publica o perfil do usuário atual na CloudKit.
    /// Chamado de MannaApp.syncOnline() após cada atualização.
    func publishMyProfile(username: String, displayName: String, game: GameState, avatar: String? = nil, status: String? = nil) async {
        guard !isPreview, let userId = userRecordID?.recordName else { return }

        let record = CKRecord(recordType: "MannaProfile", recordID: CKRecord.ID(recordName: userId))
        record["username"] = username
        record["displayName"] = displayName
        record["bread"] = Int64(game.bread)
        record["weeklyXP"] = Int64(game.weeklyXP)
        record["xpTotal"] = Int64(game.xpTotal)
        record["avatar"] = avatar
        record["status"] = status
        record["updatedAt"] = Date()

        do {
            _ = try await publicDB.save(record)
        } catch {
            debugPrint("[FriendsService] Erro ao publicar perfil: \(error)")
        }
    }

    /// Busca usuários por @username.
    func search(username: String) async -> [MannaPublicProfile] {
        guard !isPreview, !username.isEmpty else { return [] }

        do {
            let predicate = NSPredicate(format: "username CONTAINS[cd] %@", username)
            let query = CKQuery(recordType: "MannaProfile", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query, resultsLimit: 20)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                parseMannaProfile(record)
            }
        } catch {
            debugPrint("[FriendsService] Erro ao buscar usuários: \(error)")
            return []
        }
    }

    /// Segue um usuário.
    func follow(userId: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName, myId != userId else { return false }

        let recordName = "\(myId)_\(userId)"
        let record = CKRecord(recordType: "MannaFollow", recordID: CKRecord.ID(recordName: recordName))
        record["followerId"] = myId
        record["followeeId"] = userId
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao seguir usuário: \(error)")
            return false
        }
    }

    /// Para de seguir um usuário.
    func unfollow(userId: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        let recordName = "\(myId)_\(userId)"
        let id = CKRecord.ID(recordName: recordName)

        do {
            try await publicDB.deleteRecord(withID: id)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao deixar de seguir: \(error)")
            return false
        }
    }

    /// Carrega usuários que sigo.
    func loadFollowing() async -> [MannaPublicProfile] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        do {
            let predicate = NSPredicate(format: "followerId == %@", myId)
            let query = CKQuery(recordType: "MannaFollow", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let followRecords = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            var profiles: [MannaPublicProfile] = []
            for followRecord in followRecords {
                if let followeeId = followRecord["followeeId"] as? String {
                    if let profile = await loadProfile(userId: followeeId) {
                        profiles.append(profile)
                    }
                }
            }

            return profiles
        } catch {
            debugPrint("[FriendsService] Erro ao carregar following: \(error)")
            return []
        }
    }

    /// Carrega meus seguidores.
    func loadFollowers() async -> [MannaPublicProfile] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        do {
            let predicate = NSPredicate(format: "followeeId == %@", myId)
            let query = CKQuery(recordType: "MannaFollow", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let followRecords = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            var profiles: [MannaPublicProfile] = []
            for followRecord in followRecords {
                if let followerId = followRecord["followerId"] as? String {
                    if let profile = await loadProfile(userId: followerId) {
                        profiles.append(profile)
                    }
                }
            }

            return profiles
        } catch {
            debugPrint("[FriendsService] Erro ao carregar followers: \(error)")
            return []
        }
    }

    /// Carrega o mural (eventos dos usuários que sigo).
    func loadFeed() async -> [MannaFeedEvent] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        do {
            let followingIds = await loadFollowing().map { $0.id }

            guard !followingIds.isEmpty else { return [] }

            let predicate = NSPredicate(format: "authorId IN %@", followingIds)
            let query = CKQuery(recordType: "MannaFeedEvent", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let matchResults = try await publicDB.records(matching: query, resultsLimit: 50)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            var events: [MannaFeedEvent] = []
            for record in records {
                let authorId = record["authorId"] as? String ?? ""
                let authorName = record["authorName"] as? String ?? ""
                let kind = record["kind"] as? String ?? ""
                let text = record["text"] as? String ?? ""
                let createdAt = record["createdAt"] as? Date ?? Date()

                var event = MannaFeedEvent(
                    id: record.recordID.recordName,
                    authorId: authorId,
                    authorName: authorName,
                    kind: kind,
                    text: text,
                    createdAt: createdAt
                )

                // Carregar reações para este evento
                event.reactions = await loadReactions(eventId: event.id)
                event.myReaction = event.reactions.first(where: { $0.authorId == myId })?.emoji

                // Filtrar bloqueados
                if !blockedUsers.contains(authorId) {
                    events.append(event)
                }
            }

            return events
        } catch {
            debugPrint("[FriendsService] Erro ao carregar feed: \(error)")
            return []
        }
    }

    /// Publica um evento no mural (chamado de MannaApp.syncOnline()).
    func postEvent(kind: String, text: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName, let profile = myProfile else { return false }

        let record = CKRecord(recordType: "MannaFeedEvent")
        record["authorId"] = myId
        record["authorName"] = profile.displayName
        record["kind"] = kind
        record["text"] = text
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao postar evento: \(error)")
            return false
        }
    }

    /// Reage a um evento com emoji.
    func react(eventId: String, emoji: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        // Verificar se não excelentes já reagiu
        let reactionId = "\(eventId)_\(myId)_\(emoji)"
        let record = CKRecord(recordType: "MannaReaction", recordID: CKRecord.ID(recordName: reactionId))
        record["eventId"] = eventId
        record["authorId"] = myId
        record["emoji"] = emoji
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao reagir: \(error)")
            return false
        }
    }

    /// Remove uma reação.
    func removeReaction(eventId: String, emoji: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        let reactionId = "\(eventId)_\(myId)_\(emoji)"
        let id = CKRecord.ID(recordName: reactionId)

        do {
            try await publicDB.deleteRecord(withID: id)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao remover reação: \(error)")
            return false
        }
    }

    /// Envia um "cutucão" com uma das mensagens pré-definidas.
    func sendNudge(toUserId: String, messageIndex: Int) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName, let profile = myProfile,
              messageIndex >= 0, messageIndex < NUDGE_MESSAGES.count else { return false }

        let message = NUDGE_MESSAGES[messageIndex]
        let record = CKRecord(recordType: "MannaNudge")
        record["fromId"] = myId
        record["fromName"] = profile.displayName
        record["toId"] = toUserId
        record["message"] = message
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao enviar nudge: \(error)")
            return false
        }
    }

    /// Carrega nudges recebidos.
    func loadNudges() async -> [MannaNudge] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        do {
            let predicate = NSPredicate(format: "toId == %@", myId)
            let query = CKQuery(recordType: "MannaNudge", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let matchResults = try await publicDB.records(matching: query, resultsLimit: 50)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            var nudges: [MannaNudge] = []
            for record in records {
                let fromId = record["fromId"] as? String ?? ""

                // Filtrar bloqueados
                guard !blockedUsers.contains(fromId) else { continue }

                let fromName = record["fromName"] as? String ?? ""
                let toId = record["toId"] as? String ?? ""
                let message = record["message"] as? String ?? ""
                let createdAt = record["createdAt"] as? Date ?? Date()

                nudges.append(MannaNudge(
                    id: record.recordID.recordName,
                    fromId: fromId,
                    fromName: fromName,
                    toId: toId,
                    message: message,
                    createdAt: createdAt
                ))
            }

            return nudges
        } catch {
            debugPrint("[FriendsService] Erro ao carregar nudges: \(error)")
            return []
        }
    }

    /// Convida um amigo para pão compartilhado (friend streak).
    func inviteFriendStreak(toUserId: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName, myId != toUserId else { return false }

        // Determinístico: sempre lexicograficamente menor primeiro
        let userA = min(myId, toUserId)
        let userB = max(myId, toUserId)
        let recordName = "\(userA)_\(userB)"

        let record = CKRecord(recordType: "MannaFriendStreak", recordID: CKRecord.ID(recordName: recordName))
        record["userA"] = userA
        record["userB"] = userB
        record["status"] = "pending"
        record["days"] = 0
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao convidar para pão compartilhado: \(error)")
            return false
        }
    }

    /// Aceita um convite de pão compartilhado.
    func acceptFriendStreak(streakId: String) async -> Bool {
        guard !isPreview else { return false }

        let id = CKRecord.ID(recordName: streakId)

        do {
            let record = try await publicDB.fetch(withID: id)
            record["status"] = "active"
            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao aceitar pão compartilhado: \(error)")
            return false
        }
    }

    /// Remove um pão compartilhado.
    func removeFriendStreak(streakId: String) async -> Bool {
        guard !isPreview else { return false }

        let id = CKRecord.ID(recordName: streakId)

        do {
            try await publicDB.deleteRecord(withID: id)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao remover pão compartilhado: \(error)")
            return false
        }
    }

    /// Marca que estudei hoje no pão compartilhado.
    func markFriendStreakToday(streakId: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        let id = CKRecord.ID(recordName: streakId)

        do {
            let record = try await publicDB.fetch(withID: id)
            let userA = record["userA"] as? String ?? ""
            let userB = record["userB"] as? String ?? ""

            if myId == userA {
                record["lastDayA"] = Date()
            } else if myId == userB {
                record["lastDayB"] = Date()
            }

            // Incrementar days se ambos estudaram hoje
            let lastDayA = record["lastDayA"] as? Date
            let lastDayB = record["lastDayB"] as? Date

            if let dayA = lastDayA, let dayB = lastDayB {
                if Calendar.current.isDateInToday(dayA) && Calendar.current.isDateInToday(dayB) {
                    let currentDays = record["days"] as? Int64 ?? 0
                    record["days"] = currentDays + 1
                }
            }

            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao marcar dia do pão compartilhado: \(error)")
            return false
        }
    }

    /// Cria uma missão em dupla (estudar juntos esta semana).
    func createDuoQuest(withUserId: String, goalXP: Int64) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        let weekKey = gameWeekKey()
        let record = CKRecord(recordType: "MannaDuoQuest")
        record["userA"] = myId
        record["userB"] = withUserId
        record["weekKey"] = weekKey
        record["goalXP"] = goalXP
        record["userAXP"] = 0
        record["userBXP"] = 0
        record["status"] = "active"
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            await refresh()
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao criar missão em dupla: \(error)")
            return false
        }
    }

    /// Bloqueia um usuário (local + cloud report).
    func blockUser(userId: String) async {
        var blocked = blockedUsers
        blocked.insert(userId)
        blockedUsers = blocked

        // Opcional: reportar na cloud
        await report(userId: userId, reason: "harassment")
    }

    /// Desbloqueia um usuário.
    func unblockUser(userId: String) {
        var blocked = blockedUsers
        blocked.remove(userId)
        blockedUsers = blocked
    }

    /// Denuncia um usuário.
    func report(userId: String, reason: String) async -> Bool {
        guard !isPreview, let myId = userRecordID?.recordName else { return false }

        let record = CKRecord(recordType: "MannaReport")
        record["reporterId"] = myId
        record["reportedId"] = userId
        record["reason"] = reason
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)
            return true
        } catch {
            debugPrint("[FriendsService] Erro ao denunciar usuário: \(error)")
            return false
        }
    }

    /// Recarrega todos os dados (following, followers, feed, nudges, streaks).
    func refresh() async {
        guard !isPreview else { return }

        async let newFollowing = loadFollowing()
        async let newFollowers = loadFollowers()
        async let newFeed = loadFeed()
        async let newNudges = loadNudges()
        async let newStreaks = loadFriendStreaks()
        async let newQuests = loadDuoQuests()

        self.following = await newFollowing
        self.followers = await newFollowers
        self.feed = await newFeed
        self.nudges = await newNudges
        self.friendStreaks = await newStreaks
        self.duoQuests = await newQuests
    }

    // MARK: - Operações Internas

    private func checkAccountStatus() async {
        do {
            self.accountStatus = try await container.accountStatus()
        } catch {
            self.accountStatus = .noAccount
            debugPrint("[FriendsService] Erro ao verificar status da conta: \(error)")
        }
    }

    private func loadUserRecordID() async {
        do {
            self.userRecordID = try await container.userRecordID()

            // Carregar perfil próprio
            if let id = self.userRecordID {
                self.myProfile = await loadProfile(userId: id.recordName)
            }
        } catch {
            self.userRecordID = nil
            debugPrint("[FriendsService] Erro ao carregar userRecordID: \(error)")
        }
    }

    private func loadProfile(userId: String) async -> MannaPublicProfile? {
        do {
            let id = CKRecord.ID(recordName: userId)
            let record = try await publicDB.fetch(withID: id)
            return parseMannaProfile(record)
        } catch {
            debugPrint("[FriendsService] Erro ao carregar perfil \(userId): \(error)")
            return nil
        }
    }

    private func parseMannaProfile(_ record: CKRecord) -> MannaPublicProfile? {
        let username = record["username"] as? String ?? ""
        let displayName = record["displayName"] as? String ?? ""
        let bread = record["bread"] as? Int64 ?? 0
        let weeklyXP = record["weeklyXP"] as? Int64 ?? 0
        let xpTotal = record["xpTotal"] as? Int64 ?? 0
        let avatar = record["avatar"] as? String
        let status = record["status"] as? String
        let updatedAt = record["updatedAt"] as? Date ?? Date()

        return MannaPublicProfile(
            id: record.recordID.recordName,
            username: username,
            displayName: displayName,
            bread: bread,
            weeklyXP: weeklyXP,
            xpTotal: xpTotal,
            avatar: avatar,
            status: status,
            updatedAt: updatedAt
        )
    }

    private func loadReactions(eventId: String) async -> [MannaReaction] {
        do {
            let predicate = NSPredicate(format: "eventId == %@", eventId)
            let query = CKQuery(recordType: "MannaReaction", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                let eventId = record["eventId"] as? String ?? ""
                let authorId = record["authorId"] as? String ?? ""
                let emoji = record["emoji"] as? String ?? ""
                let createdAt = record["createdAt"] as? Date ?? Date()

                return MannaReaction(
                    id: record.recordID.recordName,
                    eventId: eventId,
                    authorId: authorId,
                    emoji: emoji,
                    createdAt: createdAt
                )
            }
        } catch {
            debugPrint("[FriendsService] Erro ao carregar reações de \(eventId): \(error)")
            return []
        }
    }

    private func loadFriendStreaks() async -> [MannaFriendStreak] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        do {
            let predicate = NSPredicate(format: "userA == %@ OR userB == %@", myId, myId)
            let query = CKQuery(recordType: "MannaFriendStreak", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                let userA = record["userA"] as? String ?? ""
                let userB = record["userB"] as? String ?? ""
                let status = record["status"] as? String ?? "pending"
                let days = record["days"] as? Int64 ?? 0
                let lastDayA = record["lastDayA"] as? Date
                let lastDayB = record["lastDayB"] as? Date
                let createdAt = record["createdAt"] as? Date ?? Date()

                return MannaFriendStreak(
                    id: record.recordID.recordName,
                    userA: userA,
                    userB: userB,
                    status: status,
                    days: days,
                    lastDayA: lastDayA,
                    lastDayB: lastDayB,
                    createdAt: createdAt
                )
            }
        } catch {
            debugPrint("[FriendsService] Erro ao carregar friend streaks: \(error)")
            return []
        }
    }

    private func loadDuoQuests() async -> [MannaDuoQuest] {
        guard !isPreview, let myId = userRecordID?.recordName else { return [] }

        let weekKey = gameWeekKey()

        do {
            let predicate = NSPredicate(format: "(userA == %@ OR userB == %@) AND weekKey == %@", myId, myId, weekKey)
            let query = CKQuery(recordType: "MannaDuoQuest", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                let userA = record["userA"] as? String ?? ""
                let userB = record["userB"] as? String ?? ""
                let weekKey = record["weekKey"] as? String ?? ""
                let goalXP = record["goalXP"] as? Int64 ?? 0
                let userAXP = record["userAXP"] as? Int64 ?? 0
                let userBXP = record["userBXP"] as? Int64 ?? 0
                let status = record["status"] as? String ?? "active"
                let createdAt = record["createdAt"] as? Date ?? Date()

                return MannaDuoQuest(
                    id: record.recordID.recordName,
                    userA: userA,
                    userB: userB,
                    weekKey: weekKey,
                    goalXP: goalXP,
                    userAXP: userAXP,
                    userBXP: userBXP,
                    status: status,
                    createdAt: createdAt
                )
            }
        } catch {
            debugPrint("[FriendsService] Erro ao carregar duo quests: \(error)")
            return []
        }
    }

    /// Semana ISO atual (YYYY-Www), ex: "2025-W38"
    private func gameWeekKey() -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        guard let weekOfYear = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date()).weekOfYear,
              let yearForWeek = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date()).yearForWeekOfYear else {
            return ""
        }
        return String(format: "%04d-W%02d", yearForWeek, weekOfYear)
    }
}
