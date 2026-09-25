import SwiftUI

struct ProfileJourneysView: View {
    @Environment(GameState.self) var game
    @Environment(ContentStore.self) var content
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    Spacer()
                    Text("Jornadas")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Color.clear.frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(content.journeys) { journey in
                            JourneyProgressRow(journey: journey)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ProfileJourneysPreview: View {
    @Environment(GameState.self) var game
    @Environment(ContentStore.self) var content

    var body: some View {
        VStack(spacing: 8) {
            ForEach(content.journeys.prefix(2)) { journey in
                JourneyProgressRow(journey: journey)
            }
        }
    }
}

struct JourneyProgressRow: View {
    let journey: Journey
    @Environment(GameState.self) var game

    var progress: (completed: Int, total: Int) {
        let completed = game.completedCount(in: journey)
        let total = journey.allLessons.count
        return (completed, total)
    }

    var progressPercent: Double {
        guard progress.total > 0 else { return 0 }
        return Double(progress.completed) / Double(progress.total)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(Theme.font(14, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("\(progress.completed)/\(progress.total) lições")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                Text("\(Int(progressPercent * 100))%")
                    .font(Theme.font(12, .bold))
                    .foregroundStyle(Theme.wheat)
            }

            ProgressView(value: progressPercent)
                .tint(Theme.wheat)
                .frame(height: 6)
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(10)
    }
}

#Preview {
    ProfileJourneysView()
        .environment(GameState.load())
        .environment(ContentStore.shared)
}
