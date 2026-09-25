import SwiftUI

/// Tela 3: Meta diária atingida.
struct DailyGoalScreen: View {
    let result: LessonResult
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 24) {
            CharacterView(character: .juda, mood: .cheering, size: 120)
                .characterReaction(.cheering)
                .transition(.scale.combined(with: .opacity))

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Theme.wheat)
                        .scaleEffect(1.2)

                    Text("Meta do dia cumprida!")
                        .font(Theme.font(22, .heavy))
                        .foregroundStyle(Theme.ink)
                }

                Text("Você atingiu sua meta diária de XP.")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
            .transition(.opacity)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatCard(icon: .xp, label: "XP ganho", finalValue: result.xpEarned, unit: "XP")
                        .transition(.scale.combined(with: .opacity))
                    StatCard(icon: .manna, label: "Recompensa", finalValue: result.mannaEarned, unit: "")
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let sampleResult = LessonResult(
        lessonId: "lesson-1",
        xpEarned: 30,
        mannaEarned: 50,
        accuracy: 0.95,
        isPerfect: false,
        breadBefore: 3,
        breadAfter: 4,
        breadExtendedToday: false,
        completedMissions: [],
        dailyGoalReachedNow: true,
        lastSevenDays: [true, true, true, true, true, true, true]
    )

    ZStack {
        Theme.cream.ignoresSafeArea()
        DailyGoalScreen(result: sampleResult)
    }
}
