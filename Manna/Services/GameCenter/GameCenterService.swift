import Foundation
import GameKit
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
                            id: GKLocalPlayer.local.playerID,
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
                        id: GKLocalPlayer.local.playerID,
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
        guard isAuthenticated else { return }
        isLoadingLeaderboard = true

        GKLeaderboard.loadLeaderboards(IDs: [LeaderboardID.weeklyXP.rawValue]) { [weak self] leaderboards, error in
            guard let leaderboard = leaderboards?.first else {
                DispatchQueue.main.async { self?.isLoadingLeaderboard = false }
                return
            }

            leaderboard.timeScope = timeScope
            leaderboard.loadEntries(for: .global, timeScope: .week, range: NSRange(location: 1, length: 50)) { [weak self] entries, yourEntry, error in
                DispatchQueue.main.async {
                    self?.isLoadingLeaderboard = false
                    guard let entries = entries else { return }
                    self?.weeklyLeaderboard = entries.enumerated().map { index, entry in
                        GameCenterPlayer(
                            id: entry.player.playerID,
                            displayName: entry.player.displayName,
                            weeklyXP: entry.score,
                            rank: index + 1
                        )
                    }
                }
            }
        }
    }

    func loadFriendsWeeklyLeaderboard() {
        guard isAuthenticated else { return }
        isLoadingLeaderboard = true

        GKLeaderboard.loadLeaderboards(IDs: [LeaderboardID.weeklyXP.rawValue]) { [weak self] leaderboards, error in
            guard let leaderboard = leaderboards?.first else {
                DispatchQueue.main.async { self?.isLoadingLeaderboard = false }
                return
            }

            leaderboard.timeScope = .week
            leaderboard.loadEntries(for: .friendsOnly, timeScope: .week, range: NSRange(location: 1, length: 50)) { [weak self] entries, yourEntry, error in
                DispatchQueue.main.async {
                    self?.isLoadingLeaderboard = false
                    guard let entries = entries else { return }
                    self?.weeklyLeaderboard = entries.enumerated().map { index, entry in
                        GameCenterPlayer(
                            id: entry.player.playerID,
                            displayName: entry.player.displayName,
                            weeklyXP: entry.score,
                            rank: index + 1
                        )
                    }
                }
            }
        }
    }

    // MARK: - Amigos

    func loadFriends() {
        guard isAuthenticated else { return }

        // iOS 17+ requer verificação de status de autorização
        let authStatus = GKLocalPlayer.local.loadFriendsAuthorizationStatus()
        guard authStatus == .authorized else { return }

        GKLocalPlayer.local.loadFriends { [weak self] friends, error in
            guard let friends = friends else {
                if let error = error {
                    print("Friends load error: \(error.localizedDescription)")
                }
                return
            }

            var friendPlayers: [GameCenterPlayer] = []
            let group = DispatchGroup()

            for friend in friends {
                group.enter()
                friend.loadPhotoAsync { [weak self] _ in
                    friendPlayers.append(GameCenterPlayer(
                        id: friend.playerID,
                        displayName: friend.displayName
                    ))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self?.friends = friendPlayers
            }
        }
    }

    func showAddFriendsPanel() {
        guard isAuthenticated else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = scene.windows.first?.rootViewController else { return }

        if #available(iOS 17, *) {
            GKLocalPlayer.local.presentFriendRequestCreator(from: viewController) { _ in }
        } else if #available(iOS 15, *) {
            if let composeVC = GKFriendRequestComposeViewController.request() {
                viewController.present(composeVC, animated: true)
            }
        }
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
