import Foundation
import CloudKit
import Observation

// MARK: - CloudKit Schema Documentation
//
// Create these Record Types in CloudKit Dashboard (iCloud.app.manna.ios public database):
//
// 1. MannaGroup
//    Fields:
//      - name (String, required)
//      - code (String, required, indexed for query)
//      - weeklyGoal (Int64, required)
//      - createdBy (String, required, user recordName)
//      - createdAt (DateTime, required)
//    Indices: code (sortable: true)
//    Notes: Record names are auto-generated UUIDs by CloudKit
//
// 2. MannaMember
//    Fields:
//      - groupCode (String, required, indexed for query)
//      - memberId (String, required, user recordName)
//      - displayName (String, required)
//      - weekKey (String, required, ISO format YYYY-Www for filtering)
//      - weeklyXP (Int64, required, default 0)
//      - bread (Int64, required, default 0)
//      - updatedAt (DateTime, required)
//    Indices: groupCode (sortable: false)
//    Notes: recordName is deterministic "\(groupCode)-\(memberId)" for upsert pattern
//
// 3. MannaCheer
//    Fields:
//      - groupCode (String, required, indexed for query)
//      - memberId (String, required, user recordName)
//      - displayName (String, required)
//      - message (String, required, pre-defined values only)
//      - createdAt (DateTime, required, indexed for sorting)
//    Indices: groupCode (sortable: false), createdAt (sortable: true)
//    Notes: Record names are auto-generated UUIDs
//

// MARK: - Tipos de Dados Locais

/// Representa um grupo cooperativo na nuvem.
/// Record type: `MannaGroup` { name: String, code: String, weeklyGoal: Int64, createdBy: String, createdAt: Date }
struct MannaGroup: Identifiable, Hashable {
    let id: String         // recordName
    var name: String
    var code: String       // 6 caracteres maiúsculos
    var weeklyGoal: Int64
    var createdBy: String  // userRecordID.recordName
    var createdAt: Date

    /// XP total da semana atual para o grupo (soma dos membros que estudaram esta semana).
    var weeklyXP: Int64 = 0
    /// Membros carregados (dados locais).
    var members: [MannaMember] = []
    /// Incentivos recentes (dados locais).
    var cheers: [MannaCheer] = []
}

/// Um membro do grupo.
/// Record type: `MannaMember` { groupCode: String, memberId: String, displayName: String, weekKey: String, weeklyXP: Int64, bread: Int64, updatedAt: Date }
/// recordName: determinístico "\(groupCode)-\(memberId)"
struct MannaMember: Identifiable, Hashable {
    let id: String         // "\(groupCode)-\(memberId)"
    var groupCode: String
    var memberId: String   // userRecordID.recordName
    var displayName: String
    var weekKey: String    // ano-semana ISO (YYYY-Www)
    var weeklyXP: Int64
    var bread: Int64
    var updatedAt: Date
}

/// Um incentivo postado por um membro para outro.
/// Record type: `MannaCheer` { groupCode: String, memberId: String, displayName: String, message: String, createdAt: Date }
struct MannaCheer: Identifiable, Hashable {
    let id: String         // recordName (UUID gerado pela CloudKit)
    var groupCode: String
    var memberId: String   // quem enviou o incentivo
    var displayName: String
    var message: String    // lista fixa de incentivos pré-definidos
    var createdAt: Date
}

// MARK: - Service Principal (CloudKit)

/// Gerencia grupos cooperativos com CloudKit.
/// Contrato estável: @Observable final class com métodos sync/async (await).
/// Detecta preview mode automaticamente.
@Observable
final class GroupsService: @unchecked Sendable {
    static let shared = GroupsService()

    // MARK: - Estado

    /// Estado da conta iCloud do usuário.
    private(set) var accountStatus: CKAccountStatus = .unknown

    /// ID do usuário atual (ou nil se não autenticado).
    private(set) var userRecordID: CKRecordID?

    /// Grupos do usuário (códigos dos grupos em que está, com dados carregados).
    private(set) var myGroups: [MannaGroup] = []

    /// Armazenar grupos localmente (UserDefaults "manna.groups.v1").
    private var localGroupCodes: [String] {
        get { UserDefaults.standard.stringArray(forKey: "manna.groups.v1") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "manna.groups.v1") }
    }

    /// Em preview/teste, não chamar CloudKit.
    private let isPreview: Bool

    private let container: CKContainer
    private let publicDB: CKDatabase

    private init() {
        self.isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        self.container = CKContainer.default()
        self.publicDB = container.publicCloudDatabase

        if !isPreview {
            Task {
                await checkAccountStatus()
                await loadUserRecordID()
            }
        }
    }

    // MARK: - Operações Públicas

    /// Sincroniza o GameState atual (weeklyXP e bread) para todos os grupos do usuário.
    func sync(game: GameState) async {
        guard !isPreview, let userId = userRecordID?.recordName else { return }

        let weekKey = gameWeekKey()
        let codes = localGroupCodes

        for code in codes {
            let recordName = "\(code)-\(userId)"
            var record = CKRecord(recordType: "MannaMember", recordName: recordName)
            record["groupCode"] = code
            record["memberId"] = userId
            record["displayName"] = game.userName
            record["weekKey"] = weekKey
            record["weeklyXP"] = Int64(game.weeklyXP)
            record["bread"] = Int64(game.bread)
            record["updatedAt"] = Date()

            do {
                _ = try await publicDB.save(record)
            } catch {
                debugPrint("[GroupsService] Erro ao sincronizar membro para \(code): \(error)")
            }
        }

        // Recarregar dados após sync
        await refresh()
    }

    /// Cria um novo grupo. Retorna o grupo criado com seu código.
    func createGroup(name: String, weeklyGoal: Int) async -> MannaGroup? {
        guard !isPreview, let userId = userRecordID else { return nil }

        let code = generateCode()
        var record = CKRecord(recordType: "MannaGroup")
        record["name"] = name
        record["code"] = code
        record["weeklyGoal"] = Int64(weeklyGoal)
        record["createdBy"] = userId.recordName
        record["createdAt"] = Date()

        do {
            let saved = try await publicDB.save(record)

            // Adicionar à lista local
            var codes = localGroupCodes
            if !codes.contains(code) {
                codes.append(code)
                localGroupCodes = codes
            }

            // Criar membro para o criador
            let memberRecord = CKRecord(recordType: "MannaMember", recordName: "\(code)-\(userId.recordName)")
            memberRecord["groupCode"] = code
            memberRecord["memberId"] = userId.recordName
            memberRecord["displayName"] = ""  // será sincronizado depois via sync(game:)
            memberRecord["weekKey"] = gameWeekKey()
            memberRecord["weeklyXP"] = 0
            memberRecord["bread"] = 0
            memberRecord["updatedAt"] = Date()
            _ = try await publicDB.save(memberRecord)

            return MannaGroup(
                id: saved.recordName,
                name: name,
                code: code,
                weeklyGoal: Int64(weeklyGoal),
                createdBy: userId.recordName,
                createdAt: Date()
            )
        } catch {
            debugPrint("[GroupsService] Erro ao criar grupo: \(error)")
            return nil
        }
    }

    /// Entra em um grupo usando seu código (6 caracteres).
    func joinGroup(code: String) async -> Bool {
        guard !isPreview, let userId = userRecordID else { return false }

        let upperCode = code.uppercased()

        do {
            // Buscar o grupo pelo código
            let predicate = NSPredicate(format: "code == %@", upperCode)
            let query = CKQuery(recordType: "MannaGroup", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            guard !records.isEmpty else {
                debugPrint("[GroupsService] Grupo com código \(upperCode) não encontrado")
                return false
            }

            // Criar membro para este usuário no grupo
            let memberRecord = CKRecord(recordType: "MannaMember", recordName: "\(upperCode)-\(userId.recordName)")
            memberRecord["groupCode"] = upperCode
            memberRecord["memberId"] = userId.recordName
            memberRecord["displayName"] = ""
            memberRecord["weekKey"] = gameWeekKey()
            memberRecord["weeklyXP"] = 0
            memberRecord["bread"] = 0
            memberRecord["updatedAt"] = Date()

            _ = try await publicDB.save(memberRecord)

            // Adicionar à lista local
            var codes = localGroupCodes
            if !codes.contains(upperCode) {
                codes.append(upperCode)
                localGroupCodes = codes
            }

            await refresh()
            return true
        } catch {
            debugPrint("[GroupsService] Erro ao entrar no grupo: \(error)")
            return false
        }
    }

    /// Sai de um grupo.
    func leaveGroup(code: String) async -> Bool {
        guard !isPreview, let userId = userRecordID else { return false }

        do {
            let recordName = "\(code)-\(userId.recordName)"
            let id = CKRecord.ID(recordName: recordName)
            try await publicDB.deleteRecord(withID: id)

            // Remover da lista local
            var codes = localGroupCodes
            codes.removeAll { $0 == code }
            localGroupCodes = codes

            myGroups.removeAll { $0.code == code }
            return true
        } catch {
            debugPrint("[GroupsService] Erro ao sair do grupo: \(error)")
            return false
        }
    }

    /// Recarrega dados de todos os grupos do usuário a partir da CloudKit.
    func refresh() async {
        guard !isPreview else { return }

        var updated: [MannaGroup] = []
        let codes = localGroupCodes

        for code in codes {
            if let group = await loadGroup(code: code) {
                updated.append(group)
            }
        }

        self.myGroups = updated
    }

    /// Envia um incentivo para o grupo.
    func sendCheer(groupCode: String, message: String) async -> Bool {
        guard !isPreview, let userId = userRecordID else { return false }

        var record = CKRecord(recordType: "MannaCheer")
        record["groupCode"] = groupCode
        record["memberId"] = userId.recordName
        record["displayName"] = ""  // será preenchido pela sincronização
        record["message"] = message
        record["createdAt"] = Date()

        do {
            _ = try await publicDB.save(record)

            // Recarregar incentivos do grupo
            if let index = myGroups.firstIndex(where: { $0.code == groupCode }) {
                myGroups[index].cheers = await loadCheers(groupCode: groupCode)
            }

            return true
        } catch {
            debugPrint("[GroupsService] Erro ao enviar incentivo: \(error)")
            return false
        }
    }

    // MARK: - Operações Internas

    private func checkAccountStatus() async {
        do {
            self.accountStatus = try await container.accountStatus()
        } catch {
            self.accountStatus = .noAccount
            debugPrint("[GroupsService] Erro ao verificar status da conta: \(error)")
        }
    }

    private func loadUserRecordID() async {
        do {
            self.userRecordID = try await container.userRecordID()
        } catch {
            self.userRecordID = nil
            debugPrint("[GroupsService] Erro ao carregar userRecordID: \(error)")
        }
    }

    private func loadGroup(code: String) async -> MannaGroup? {
        do {
            let predicate = NSPredicate(format: "code == %@", code)
            let query = CKQuery(recordType: "MannaGroup", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            guard let record = records.first else { return nil }

            let name = record["name"] as? String ?? ""
            let weeklyGoal = record["weeklyGoal"] as? Int64 ?? 0
            let createdBy = record["createdBy"] as? String ?? ""
            let createdAt = record["createdAt"] as? Date ?? Date()

            var group = MannaGroup(
                id: record.recordID.recordName,
                name: name,
                code: code,
                weeklyGoal: weeklyGoal,
                createdBy: createdBy,
                createdAt: createdAt
            )

            // Carregar membros e cheers
            group.members = await loadMembers(groupCode: code)
            group.cheers = await loadCheers(groupCode: code)

            // Calcular XP semanal
            let currentWeek = gameWeekKey()
            group.weeklyXP = group.members
                .filter { $0.weekKey == currentWeek }
                .reduce(0) { $0 + $1.weeklyXP }

            return group
        } catch {
            debugPrint("[GroupsService] Erro ao carregar grupo \(code): \(error)")
            return nil
        }
    }

    private func loadMembers(groupCode: String) async -> [MannaMember] {
        do {
            let predicate = NSPredicate(format: "groupCode == %@", groupCode)
            let query = CKQuery(recordType: "MannaMember", predicate: predicate)
            let matchResults = try await publicDB.records(matching: query)

            let records = matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                let memberId = record["memberId"] as? String ?? ""
                let displayName = record["displayName"] as? String ?? ""
                let weekKey = record["weekKey"] as? String ?? ""
                let weeklyXP = record["weeklyXP"] as? Int64 ?? 0
                let bread = record["bread"] as? Int64 ?? 0
                let updatedAt = record["updatedAt"] as? Date ?? Date()

                return MannaMember(
                    id: record.recordID.recordName,
                    groupCode: groupCode,
                    memberId: memberId,
                    displayName: displayName,
                    weekKey: weekKey,
                    weeklyXP: weeklyXP,
                    bread: bread,
                    updatedAt: updatedAt
                )
            }
        } catch {
            debugPrint("[GroupsService] Erro ao carregar membros de \(groupCode): \(error)")
            return []
        }
    }

    private func loadCheers(groupCode: String) async -> [MannaCheer] {
        do {
            let predicate = NSPredicate(format: "groupCode == %@", groupCode)
            let query = CKQuery(recordType: "MannaCheer", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let matchResults = try await publicDB.records(matching: query, resultsLimit: 20)

            let records = matchResults.compactMap { _, result -> CKRecord? in
                try? result.get()
            }

            return records.compactMap { record in
                let memberId = record["memberId"] as? String ?? ""
                let displayName = record["displayName"] as? String ?? ""
                let message = record["message"] as? String ?? ""
                let createdAt = record["createdAt"] as? Date ?? Date()

                return MannaCheer(
                    id: record.recordID.recordName,
                    groupCode: groupCode,
                    memberId: memberId,
                    displayName: displayName,
                    message: message,
                    createdAt: createdAt
                )
            }
        } catch {
            debugPrint("[GroupsService] Erro ao carregar cheers de \(groupCode): \(error)")
            return []
        }
    }

    private func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ23456789"  // sem 0, O, 1, I para evitar confusão
        return String((0..<6).map { _ in chars.randomElement()! })
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
