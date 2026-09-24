import SwiftUI

@main
struct MannaApp: App {
    @State private var game = GameState.load()
    @State private var content = ContentStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(game)
                .environment(content)
                .tint(Theme.wheat)
        }
    }
}

struct RootView: View {
    @Environment(GameState.self) private var game
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if game.hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            game.refreshForToday()
            SoundFX.isEnabled = game.soundEnabled
            Haptics.isEnabled = game.hapticsEnabled
        }
        .onChange(of: game.soundEnabled) { _, on in SoundFX.isEnabled = on }
        .onChange(of: game.hapticsEnabled) { _, on in Haptics.isEnabled = on }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { game.refreshForToday() }
        }
    }
}
