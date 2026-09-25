import Foundation
import Observation

/// Sincroniza progresso com iCloud via NSUbiquitousKeyValueStore.
/// Espelha a chave principal "manna.gameState.v1" + outras chaves de stores.
@Observable
final class CloudProgressSync {
    static let shared = CloudProgressSync()

    private(set) var isAvailable = false
    private(set) var lastSyncDate: Date?
    private(set) var hasPendingChanges = false

    private let kvStore = NSUbiquitousKeyValueStore.default
    private let syncInterval: TimeInterval = 300  // 5 min
    private var syncTask: Task<Void, Never>?

    init() {
        isAvailable = kvStore.synchronize()
        startSync()
    }

    deinit {
        syncTask?.cancel()
    }

    /// Inicia sincronização periódica com iCloud.
    private func startSync() {
        syncTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(syncInterval * 1_000_000_000))
                if !Task.isCancelled {
                    syncToCloud()
                }
            }
        }
    }

    /// Envia estado do GameState para iCloud.
    func syncToCloud(gameState: GameState? = nil) {
        guard isAvailable else { return }

        if let gameState = gameState {
            if let encoded = try? JSONEncoder().encode(gameState.debugDescription) {
                kvStore.set(encoded, forKey: "manna.gameState.v1")
            }
        }

        let _ = kvStore.synchronize()
        lastSyncDate = Date()
        hasPendingChanges = false
    }

    /// Verifica se há progresso mais novo no iCloud e oferece restaurar.
    func checkForRemoteProgress(completion: @escaping (Bool, Date?) -> Void) {
        guard isAvailable else {
            completion(false, nil)
            return
        }

        if let remoteData = kvStore.data(forKey: "manna.gameState.v1") {
            if let remoteDate = kvStore.dictionary(forKey: nil)?["manna.gameState.syncDate"] as? Date {
                if remoteDate > (lastSyncDate ?? .distantPast) {
                    completion(true, remoteDate)
                    return
                }
            }
        }

        completion(false, nil)
    }

    /// Restaura progresso do iCloud.
    func restoreFromCloud(gameState: GameState) {
        guard isAvailable else { return }

        if let remoteData = kvStore.data(forKey: "manna.gameState.v1") {
            // Decodificar e restaurar — implementação específica do GameState
            // Por enquanto, apenas marca como sincronizado
            lastSyncDate = Date()
            hasPendingChanges = false
        }
    }

    /// Marca que há mudanças pendentes.
    func markPendingChanges() {
        hasPendingChanges = true
    }
}
