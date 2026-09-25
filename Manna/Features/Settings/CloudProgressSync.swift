import Foundation
import Observation

/// Guarda uma cópia do progresso no iCloud (NSUbiquitousKeyValueStore, até 1 MB).
/// Espelha todas as chaves "manna.*" do UserDefaults. Num aparelho novo, o progresso volta sozinho
/// na primeira abertura (`restoreIfFreshInstall`); em Configurações dá para restaurar manualmente.
@Observable
final class CloudProgressSync {
    static let shared = CloudProgressSync()

    private(set) var isAvailable = false
    private(set) var lastSyncDate: Date?
    private(set) var hasPendingChanges = false

    @ObservationIgnored private let kvStore = NSUbiquitousKeyValueStore.default

    private static let prefix = "manna."
    private static let syncDateKey = "cloud.syncDate"
    private static let xpKey = "cloud.xpTotal"
    /// Chave principal do GameState (se não existir localmente, é instalação nova).
    private static let gameStateKey = "manna.gameState.v1"

    private init() {
        isAvailable = FileManager.default.ubiquityIdentityToken != nil
        kvStore.synchronize()
        lastSyncDate = kvStore.object(forKey: Self.syncDateKey) as? Date
    }

    /// Chamado antes de carregar o GameState: se o aparelho não tem progresso e o iCloud tem, restaura.
    static func restoreIfFreshInstall() {
        guard UserDefaults.standard.object(forKey: gameStateKey) == nil else { return }
        let store = NSUbiquitousKeyValueStore.default
        store.synchronize()
        guard store.object(forKey: gameStateKey) != nil else { return }
        copyCloudToLocal(store)
    }

    /// Envia todas as chaves "manna.*" para o iCloud.
    func syncToCloud(gameState: GameState? = nil) {
        guard isAvailable else { return }
        let local = UserDefaults.standard.dictionaryRepresentation()
        for (key, value) in local where key.hasPrefix(Self.prefix) {
            kvStore.set(value, forKey: key)
        }
        let now = Date()
        kvStore.set(now, forKey: Self.syncDateKey)
        if let gameState {
            kvStore.set(Int64(gameState.xpTotal), forKey: Self.xpKey)
        }
        kvStore.synchronize()
        lastSyncDate = now
        hasPendingChanges = false
    }

    /// Informa se o iCloud tem um progresso com mais XP do que o aparelho (e a data da cópia).
    func checkForRemoteProgress(completion: @escaping (Bool, Date?) -> Void) {
        guard isAvailable else {
            completion(false, nil)
            return
        }
        kvStore.synchronize()
        let remoteDate = kvStore.object(forKey: Self.syncDateKey) as? Date
        let remoteXP = kvStore.longLong(forKey: Self.xpKey)
        let localXP = Int64(GameState.load().xpTotal)
        completion(remoteDate != nil && remoteXP > localXP, remoteDate)
    }

    /// Copia o progresso do iCloud para o aparelho. O app mostra o progresso restaurado na próxima abertura.
    func restoreFromCloud(gameState: GameState) {
        guard isAvailable else { return }
        kvStore.synchronize()
        Self.copyCloudToLocal(kvStore)
        lastSyncDate = kvStore.object(forKey: Self.syncDateKey) as? Date
        hasPendingChanges = false
    }

    func markPendingChanges() {
        hasPendingChanges = true
    }

    private static func copyCloudToLocal(_ store: NSUbiquitousKeyValueStore) {
        for (key, value) in store.dictionaryRepresentation where key.hasPrefix(prefix) {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}
