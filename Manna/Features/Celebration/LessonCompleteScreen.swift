import SwiftUI

/// Tela 1: Lição concluída com cartões de estatísticas animadas.
struct LessonCompleteScreen: View {
    let result: LessonResult

    var body: some View {
        VStack(spacing: 24) {
            SheepView(mood: .cheering, size: 120)

            VStack(spacing: 8) {
                Text(result.isPerfect ? "Perfeito! Nenhum erro!" : "Lição concluída!")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)

                Text(String(format: "Acerto: %.0f%%", result.accuracy * 100))
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            VStack(spacing: 12) {
                StatCard(icon: .xp, label: "Pontos", finalValue: result.xpEarned, unit: "XP")

                HStack(spacing: 12) {
                    StatCard(icon: .manna, label: "Maná", finalValue: result.mannaEarned, unit: "")
                    VStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.wheat)

                        Text(String(format: "%.0f%%", result.accuracy * 100))
                            .font(Theme.font(20, .heavy))
                            .foregroundStyle(Theme.wheat)

                        Text("Precisão")
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Theme.card)
                    .cornerRadius(Theme.corner)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.corner)
                            .strokeBorder(Theme.line, lineWidth: 2)
                    )
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
        xpEarned: 15,
        mannaEarned: 35,
        accuracy: 1.0,
        isPerfect: true,
        breadBefore: 3,
        breadAfter: 4,
        breadExtendedToday: true,
        completedMissions: [],
        dailyGoalReachedNow: false,
        lastSevenDays: [true, true, false, true, true, true, false]
    )

    ZStack {
        Theme.cream.ignoresSafeArea()
        LessonCompleteScreen(result: sampleResult)
    }
}
