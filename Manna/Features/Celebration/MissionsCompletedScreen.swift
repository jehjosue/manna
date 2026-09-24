import SwiftUI

/// Tela 4: Missões concluídas com recompensas.
struct MissionsCompletedScreen: View {
    let result: LessonResult

    var body: some View {
        VStack(spacing: 24) {
            SheepView(mood: .happy, size: 100)

            let missionCount = result.completedMissions.count
            Text(missionCount == 1 ? "+\(missionCount) missão concluída!" : "+\(missionCount) missões concluídas!")
                .font(Theme.font(22, .heavy))
                .foregroundStyle(Theme.ink)

            VStack(spacing: 12) {
                ForEach(result.completedMissions) { mission in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mission.title)
                                .font(Theme.font(15, .heavy))
                                .foregroundStyle(Theme.ink)

                            HStack(spacing: 4) {
                                GameIconView(icon: .manna, size: 16)
                                Text("+\(mission.rewardManna) maná")
                                    .font(Theme.font(13, .semibold))
                                    .foregroundStyle(Theme.manna)
                            }
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.olive)
                    }
                    .padding(12)
                    .background(Theme.oliveLight)
                    .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let sampleMissions = [
        DailyMission(id: "m1", kind: .completeLessons, target: 2, progress: 2, rewardManna: 10),
        DailyMission(id: "m2", kind: .earnXP, target: 20, progress: 20, rewardManna: 15),
    ]

    let sampleResult = LessonResult(
        lessonId: "lesson-1",
        xpEarned: 15,
        mannaEarned: 35,
        accuracy: 0.9,
        isPerfect: false,
        breadBefore: 3,
        breadAfter: 4,
        breadExtendedToday: false,
        completedMissions: sampleMissions,
        dailyGoalReachedNow: false,
        lastSevenDays: [true, true, true, true, true, true, true]
    )

    ZStack {
        Theme.cream.ignoresSafeArea()
        MissionsCompletedScreen(result: sampleResult)
    }
}
