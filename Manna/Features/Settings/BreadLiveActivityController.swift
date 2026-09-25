import ActivityKit
import Foundation

enum BreadLiveActivityController {
    static func update(game: GameState) {
        Task {
            let authorized = ActivityAuthorizationInfo().areActivitiesEnabled
            guard authorized else { return }

            let shouldShowActivity = game.bread > 0 &&
                                    !game.studiedToday &&
                                    isAfter6PM()

            if shouldShowActivity {
                // Verificar se há uma atividade existente
                let existingActivities = Activity<BreadActivityAttributes>.activities
                if existingActivities.isEmpty {
                    await startActivity(game: game)
                }
            } else {
                // Encerrar todas as atividades
                let activities = Activity<BreadActivityAttributes>.activities
                for activity in activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    private static func startActivity(game: GameState) async {
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let attributes = BreadActivityAttributes()
        let initialState = BreadActivityAttributes.ContentState(
            breadDays: game.bread,
            deadline: midnight,
            studied: false
        )
        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            _ = try Activity<BreadActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Erro ao iniciar Live Activity: \(error.localizedDescription)")
        }
    }

    private static func isAfter6PM() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour > 18
    }
}
