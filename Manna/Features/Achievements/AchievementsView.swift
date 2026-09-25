import SwiftUI

struct AchievementsView: View {
    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store
    @State private var animateCards = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(store.achievements.enumerated()), id: \.element.id) { index, achievement in
                                NavigationLink(destination: AchievementDetailView(achievement: achievement)) {
                                    AchievementCard(achievement: achievement)
                                        .opacity(animateCards ? 1 : 0)
                                        .offset(y: animateCards ? 0 : 20)
                                        .animation(
                                            reduceMotion ? .none : .easeOut(duration: 0.4).delay(Double(index) * 0.05),
                                            value: animateCards
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Conquistas")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !reduceMotion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            animateCards = true
                        }
                    }
                } else {
                    animateCards = true
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @Environment(GameState.self) var game
    @Environment(AchievementStore.self) var store

    var body: some View {
        let maxTier = store.maxUnlockedTier(for: achievement.id)

        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                achievement.color.opacity(0.3),
                                achievement.color.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: achievement.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(achievement.color)

                if let tier = maxTier {
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 12))
                                Text(tier.displayName)
                                    .font(Theme.font(9, .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(tier.color)
                            .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .frame(height: 100)
            .cornerRadius(12)

            Text(achievement.title)
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if let (current, next) = store.progress(for: achievement.id, game: game) {
                ProgressView(value: Double(current), total: Double(next))
                    .tint(achievement.color)
                    .frame(height: 6)

                Text("\(current)/\(next)")
                    .font(Theme.font(11, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    maxTier != nil ? achievement.color : Theme.line,
                    lineWidth: maxTier != nil ? 2 : 1
                )
        )
    }
}

#Preview {
    AchievementsView()
        .environment(GameState.load())
        .environment(AchievementStore.shared)
}
