import SwiftUI

@main
struct MannaApp: App {
    @State private var game = GameState.load()
    @State private var content = ContentStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(game)
                .environment(content)
                .environment(AchievementStore.shared)
                .environment(AvatarStore.shared)
                .environment(LeagueStore.shared)
                .environment(GameCenterService.shared)
                .tint(Theme.wheat)
        }
    }
}

struct RootView: View {
    @Environment(GameState.self) private var game
    @Environment(\.scenePhase) private var scenePhase
    private let subscriptions = SubscriptionStore.shared

    var body: some View {
        Group {
            if game.hasOnboarded {
                MainTabView()
                    .achievementUnlockOverlay()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            game.refreshForToday()
            SoundFX.isEnabled = game.soundEnabled
            Haptics.isEnabled = game.hapticsEnabled
            _ = GameCenterService.shared   // inicia o login do Game Center
            subscriptions.sync(game: game)
            syncOnline()
        }
        .onChange(of: game.soundEnabled) { _, on in SoundFX.isEnabled = on }
        .onChange(of: game.hapticsEnabled) { _, on in Haptics.isEnabled = on }
        .onChange(of: subscriptions.isPlus) { _, _ in subscriptions.sync(game: game) }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                game.refreshForToday()
                syncOnline()
            case .background:
                WidgetBridge.reload()
                syncOnline()
            default:
                break
            }
        }
    }

    /// Envia o progresso para Game Center (ligas) e iCloud (grupos). Falhas são silenciosas.
    private func syncOnline() {
        guard game.hasOnboarded else { return }
        LeagueStore.shared.rollOverIfNeeded(game: game)
        GameCenterService.shared.submitWeeklyXP(game.weeklyXP)
        GameCenterService.shared.submitTotalXP(game.xpTotal)
        Task { await GroupsService.shared.sync(game: game) }
    }
}
