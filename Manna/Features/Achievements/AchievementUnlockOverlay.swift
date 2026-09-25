import SwiftUI

struct AchievementUnlockModifier: ViewModifier {
    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store

    @State private var pendingUnlock: AchievementUnlock?
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onChange(of: game.xpTotal) { _, _ in
                checkForUnlocks()
            }
            .onChange(of: game.perfectLessonCount) { _, _ in
                checkForUnlocks()
            }
            .onChange(of: game.practiceCount) { _, _ in
                checkForUnlocks()
            }
            .onChange(of: game.challengeCount) { _, _ in
                checkForUnlocks()
            }
            .onChange(of: game.bestBread) { _, _ in
                checkForUnlocks()
            }
            .onChange(of: game.storiesCompleted) { _, _ in
                checkForUnlocks()
            }
            .sheet(isPresented: $isPresented, content: {
                if let unlock = pendingUnlock {
                    AchievementUnlockPopup(unlock: unlock, isPresented: $isPresented)
                }
            })
    }

    private func checkForUnlocks() {
        let unlocks = store.checkForNewUnlocks(game: game)
        if let firstUnlock = unlocks.first {
            pendingUnlock = firstUnlock
            isPresented = true
        }
    }
}

struct AchievementUnlockPopup: View {
    let unlock: AchievementUnlock
    @Binding var isPresented: Bool

    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Medalha animada
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    unlock.tier.color.opacity(0.3),
                                    unlock.tier.color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 4) {
                        Image(systemName: "medal.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(unlock.tier.color)

                        Text(unlock.tier.displayName)
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(unlock.tier.color)
                    }
                }
                .frame(width: 140, height: 140)
                .scaleEffect(1)

                VStack(spacing: 8) {
                    Text("Conquista Desbloqueada!")
                        .font(Theme.font(20, .bold))
                        .foregroundStyle(Theme.ink)

                    Text(unlock.achievement.title)
                        .font(Theme.font(16, .bold))
                        .foregroundStyle(unlock.achievement.color)

                    Text(unlock.achievement.description)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }

                // Recompensa
                HStack(spacing: 8) {
                    GameIconView(icon: .manna, size: 28)
                    Text("+\(unlock.mannaReward) Maná")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.manna)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Theme.manna.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.manna, lineWidth: 2)
                )

                Spacer()

                Button(action: {
                    let _ = store.claimReward(achievementId: unlock.achievement.id, tier: unlock.tier, game: game)
                    SoundFX.play(.levelUp)
                    Haptics.success()
                    isPresented = false
                }) {
                    Text("Resgatar \(unlock.mannaReward) Maná")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.chunky)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

extension View {
    func achievementUnlockOverlay() -> some View {
        modifier(AchievementUnlockModifier())
    }
}

#Preview {
    AchievementUnlockPopup(
        unlock: AchievementUnlock(
            id: "test",
            achievement: AchievementStore.shared.achievements.first ?? Achievement(id: "", title: "", description: "", icon: "", levels: []),
            tier: .gold,
            mannaReward: 50
        ),
        isPresented: .constant(true)
    )
    .environment(GameState.load())
    .environment(AchievementStore.shared)
}
