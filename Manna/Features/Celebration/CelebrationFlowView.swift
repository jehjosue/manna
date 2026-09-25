import SwiftUI

/// Máquina de estados para a sequência de celebração pós-lição.
private enum CelebrationStep: Equatable {
    case lessonComplete
    case breadStreak
    case dailyGoal
    case missions
    case done
}

/// Fluxo de celebração pós-lição com sequência de telas inspirada no Duolingo.
/// Assinatura obrigatória: `CelebrationFlowView(result:onDone:)`
struct CelebrationFlowView: View {
    let result: LessonResult
    let onDone: () -> Void

    @State private var step = CelebrationStep.lessonComplete

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Conteúdo da tela atual
                Group {
                    switch step {
                    case .lessonComplete:
                        LessonCompleteScreen(result: result)
                    case .breadStreak:
                        BreadStreakScreen(result: result)
                    case .dailyGoal:
                        DailyGoalScreen(result: result)
                    case .missions:
                        MissionsCompletedScreen(result: result)
                    case .done:
                        EmptyView()
                    }
                }
                .padding(.top, 24)
                .frame(maxHeight: .infinity, alignment: .top)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

                // Botão de continuação
                if step != .done {
                    VStack(spacing: 0) {
                        Divider()

                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    }
                    .background(Theme.cream)
                }
            }
        }
        .overlay {
            // Maná caindo do céu durante a celebração
            MannaConfetti()
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            // Som e haptics de sucesso
            SoundFX.play(.lessonComplete)
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }

    private func goNext() {
        // Haptics de clique
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()

        withAnimation(.default) {
            switch step {
            case .lessonComplete:
                if result.breadExtendedToday {
                    step = .breadStreak
                } else if result.dailyGoalReachedNow {
                    step = .dailyGoal
                } else if !result.completedMissions.isEmpty {
                    step = .missions
                } else {
                    step = .done
                    onDone()
                }
            case .breadStreak:
                if result.dailyGoalReachedNow {
                    step = .dailyGoal
                } else if !result.completedMissions.isEmpty {
                    step = .missions
                } else {
                    step = .done
                    onDone()
                }
            case .dailyGoal:
                if !result.completedMissions.isEmpty {
                    step = .missions
                } else {
                    step = .done
                    onDone()
                }
            case .missions:
                step = .done
                onDone()
            case .done:
                break
            }
        }
    }
}

#Preview {
    let sampleMissions = [
        DailyMission(id: "m1", kind: .completeLessons, target: 2, progress: 2, rewardManna: 10),
    ]

    let sampleResult = LessonResult(
        lessonId: "lesson-1",
        xpEarned: 15,
        mannaEarned: 35,
        accuracy: 1.0,
        isPerfect: true,
        breadBefore: 3,
        breadAfter: 4,
        breadExtendedToday: true,
        completedMissions: sampleMissions,
        dailyGoalReachedNow: true,
        lastSevenDays: [true, true, false, true, true, true, true]
    )

    CelebrationFlowView(result: sampleResult) {
        print("Celebração finalizada!")
    }
    .environment(GameState())
}
