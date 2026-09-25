import SwiftUI

/// "Nível bíblico": pontuação por jornada calculada de lições concluídas, precisão e lendários.
/// Explicação "o que é o nível", marcos e barra de progresso.
struct BibleLevelView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @Environment(\.dismiss) private var dismiss

    @State private var selectedJourney: Journey?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        Text("Nível Bíblico")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                    }
                    .padding(16)

                    ScrollView {
                        VStack(spacing: 20) {
                            // Explicação
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(Theme.oil)
                                    Text("O que é o Nível Bíblico?")
                                        .font(Theme.font(14, .heavy))
                                        .foregroundStyle(Theme.ink)
                                }

                                Text("Seu nível em cada jornada reflete quanto você aprendeu. É calculado a partir de:")
                                    .font(Theme.font(13, .semibold))
                                    .foregroundStyle(Theme.inkMuted)

                                VStack(alignment: .leading, spacing: 8) {
                                    levelItem("Lições concluídas", icon: "checkmark.circle.fill")
                                    levelItem("Precisão (acertos/total)", icon: "target")
                                    levelItem("Desafios lendários", icon: "crown.fill")
                                }
                            }
                            .padding(16)
                            .background(Theme.card)
                            .cornerRadius(12)

                            // Níveis por jornada
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Suas Jornadas")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)

                                VStack(spacing: 12) {
                                    ForEach(content.journeys, id: \.id) { journey in
                                        journeyLevelCard(journey)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Theme.card)
                            .cornerRadius(12)

                            Spacer(minLength: 40)
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func levelItem(_ text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.wheat)
            Text(text)
                .font(Theme.font(12, .semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.leading, 8)
    }

    @ViewBuilder
    private func journeyLevelCard(_ journey: Journey) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(journey.subtitle ?? "")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                let level = calculateLevel(for: journey)
                VStack(alignment: .center, spacing: 4) {
                    Text("\(level)")
                        .font(Theme.font(24, .heavy))
                        .foregroundStyle(Theme.oil)
                    Text("Nível")
                        .font(Theme.font(10, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }

            // Barra de progresso
            let progress = calculateProgress(for: journey)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Theme.cream)
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Theme.wheat, Theme.olive]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progress * 160, height: 12)
                    }
                    .frame(maxWidth: .infinity)

                    Text("\(Int(progress * 100))%")
                        .font(Theme.font(12, .heavy))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 40)
                }

                // Estatísticas
                let completed = game.completedCount(in: journey)
                let total = journey.allLessons.count
                Text("\(completed)/\(total) lições · Precisão média: \(calculateAccuracy(for: journey))%")
                    .font(Theme.font(11, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(12)
        .background(Theme.cream)
        .cornerRadius(8)
    }

    /// Calcula o nível (0–100) baseado em lições concluídas, precisão e lendários.
    private func calculateLevel(for journey: Journey) -> Int {
        let completed = game.completedCount(in: journey)
        let total = journey.allLessons.count
        let lessonsScore = Double(completed) / Double(total) * 50

        let accuracy = calculateAccuracy(for: journey)
        let accuracyScore = Double(accuracy) / 100.0 * 30

        // Lendários: +10 por cada (máx. 5 unidades = máx. 50 pontos, capped a 20)
        var legendaryScore: Int = 0
        for unit in journey.units {
            if PathRewardsStore.shared.isUnitLegendary(unit.id) {
                legendaryScore += 10
            }
        }
        legendaryScore = min(20, legendaryScore)

        let total_score = Int(lessonsScore + accuracyScore) + legendaryScore
        return min(100, total_score)
    }

    /// Calcula o progresso (0–1) para a barra.
    private func calculateProgress(for journey: Journey) -> Double {
        let level = Double(calculateLevel(for: journey))
        return level / 100.0
    }

    /// Precisão média em % (0–100).
    private func calculateAccuracy(for journey: Journey) -> Int {
        let completed = journey.allLessons.filter { game.isCompleted($0.id) }
        guard !completed.isEmpty else { return 0 }

        let totalAccuracy = completed.reduce(0.0) { sum, lesson in
            let record = game.lessons[lesson.id]
            return sum + (record?.bestAccuracy ?? 0.0)
        }

        return Int((totalAccuracy / Double(completed.count)) * 100)
    }
}

// Store simplificado para verificar lendários (pode estar em outro lugar)
enum PathRewardsStore {
    static func isUnitLegendary(_ unitId: String) -> Bool {
        let key = "manna.legendary.\(unitId)"
        return UserDefaults.standard.bool(forKey: key)
    }

    static func markUnitLegendary(_ unitId: String) {
        let key = "manna.legendary.\(unitId)"
        UserDefaults.standard.set(true, forKey: key)
    }
}

#Preview {
    BibleLevelView()
        .environment(GameState())
        .environment(ContentStore())
}
