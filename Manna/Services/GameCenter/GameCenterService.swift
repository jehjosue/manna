import Foundation
import GameKit
import UIKit
import Observation

// MARK: - Tipos Game Center

struct GameCenterPlayer: Identifiable, Hashable {
    let id: String
    let displayName: String
    var weeklyXP: Int = 0
    var totalXP: Int = 0
    var rank: Int?
}

// MARK: - Leaderboard IDs

enum LeaderboardID: String {
    case weeklyXP = "app.manna.weekly.xp"
    case totalXP = "app.manna.total.xp"
}

// MARK: - Service Observable

@Observable
final class GameCenterService: NSObject {
    static let shared = GameCenterService()

    private(set) var isAuthenticated = false
    private(set) var localPlayer: GameCenterPlayer?
    private(set) var friends: [GameCenterPlayer] = []
    private(set) var weeklyLeaderboard: [GameCenterPlayer] = []
    private(set) var globalLeaderboard: [GameCenterPlayer] = []
    private(set) var isLoadingLeaderboard = false

    override init() {
        super.init()
        authenticateIfNeeded()
    }

    // MARK: - Autenticação

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Game Center auth error: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                if let controller = viewController {
                    self?.presentViewController(controller)
                } else {
                    self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                    if self?.isAuthenticated == true {
                        self?.localPlayer = GameCenterPlayer(
                            id: GKLocalPlayer.local.gamePlayerID,
                            displayName: GKLocalPlayer.local.displayName
                        )
                    }
                }
            }
        }
    }

    private func authenticateIfNeeded() {
        // Autenticação não-bloqueante ao iniciar
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if self?.isAuthenticated == true {
                    self?.localPlayer = GameCenterPlayer(
                        id: GKLocalPlayer.local.gamePlayerID,
                        displayName: GKLocalPlayer.local.displayName
                    )
                }
            }
        }
    }

    // MARK: - Submissão de pontuações

    func submitWeeklyXP(_ xp: Int) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(xp, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [LeaderboardID.weeklyXP.rawValue]) { error in
            if let error = error {
                print("Weekly XP submit error: \(error.localizedDescription)")
            }
        }
    }

    func submitTotalXP(_ xp: Int) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(xp, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [LeaderboardID.totalXP.rawValue]) { error in
            if let error = error {
                print("Total XP submit error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Carregamento de Leaderboards

    func loadWeeklyLeaderboard(timeScope: GKLeaderboard.TimeScope = .week) {
        loadLeaderboard(playerScope: .global, timeScope: timeScope)
    }

    func loadFriendsWeeklyLeaderboard() {
        loadLeaderboard(playerScope: .friendsOnly, timeScope: .week)
    }

    private func loadLeaderboard(playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope) {
        guard isAuthenticated else { return }
        isLoadingLeaderboard = true

        Task { @MainActor in
            defer { isLoadingLeaderboard = false }
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [LeaderboardID.weeklyXP.rawValue])
                guard let leaderboard = leaderboards.first else { return }
                let (_, entries, _) = try await leaderboard.loadEntries(
                    for: playerScope, timeScope: timeScope, range: NSRange(location: 1, length: 50)
                )
                weeklyLeaderboard = entries.map { entry in
                    GameCenterPlayer(
                        id: entry.player.gamePlayerID,
                        displayName: entry.player.displayName,
                        weeklyXP: entry.score,
                        rank: entry.rank
                    )
                }
            } catch {
                print("Leaderboard load error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Amigos

    func loadFriends() {
        guard isAuthenticated else { return }

        Task { @MainActor in
            do {
                let status = try await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
                guard status == .authorized else { return }
                let loaded = try await GKLocalPlayer.local.loadFriends()
                friends = loaded.map { GameCenterPlayer(id: $0.gamePlayerID, displayName: $0.displayName) }
            } catch {
                print("Friends load error: \(error.localizedDescription)")
            }
        }
    }

    func showAddFriendsPanel() {
        guard isAuthenticated else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = scene.windows.first?.rootViewController else { return }
        try? GKLocalPlayer.local.presentFriendRequestCreator(from: viewController)
    }

    // MARK: - Game Center Panel

    func showGameCenterDashboard() {
        guard isAuthenticated else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = scene.windows.first?.rootViewController else { return }

        if #available(iOS 14, *) {
            let gcController = GKGameCenterViewController(state: .dashboard)
            gcController.gameCenterDelegate = self
            viewController.present(gcController, animated: true)
        }
    }

    // MARK: - Achievements

    func reportAchievement(id: String, percent: Double) {
        guard isAuthenticated else { return }
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = min(max(percent, 0), 100)
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Achievement report error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Privada

    private func presentViewController(_ viewController: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.rootViewController?.present(viewController, animated: true)
    }
}

extension GameCenterService: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
