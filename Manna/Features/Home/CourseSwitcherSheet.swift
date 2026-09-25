import SwiftUI

/// Sheet para selecionar qual jornada/curso estudar.
struct CourseSwitcherSheet: View {
    @Environment(ContentStore.self) private var content
    @Environment(GameState.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var journeyVisibility = JourneyVisibilityStore.shared

    var visibleJourneys: [Journey] {
        content.journeys.filter { !journeyVisibility.isHidden($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Escolha um curso")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Continue sua jornada de aprendizado")
                    .font(Theme.font(13, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()

            // MARK: - Lista de cursos
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(visibleJourneys) { journey in
                        CourseCardView(
                            journey: journey,
                            isSelected: content.selectedJourneyId == journey.id,
                            completedCount: game.completedCount(in: journey),
                            onSelect: {
                                content.selectedJourneyId = journey.id
                                dismiss()
                            }
                        )
                    }
                    Spacer(minLength: 16)
                }
                .padding(16)
            }
        }
        .background(Theme.cream)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Course Card

struct CourseCardView: View {
    let journey: Journey
    let isSelected: Bool
    let completedCount: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Ícone do curso
                    ZStack {
                        Circle()
                            .fill(courseColor.opacity(0.2))
                            .frame(width: 56, height: 56)

                        if let icon = journey.icon {
                            Image(systemName: icon)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(courseColor)
                        }
                    }

                    // Informações do curso
                    VStack(alignment: .leading, spacing: 4) {
                        Text(journey.title)
                            .font(Theme.font(16, .heavy))
                            .foregroundStyle(Theme.ink)

                        if let subtitle = journey.subtitle {
                            Text(subtitle)
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Progresso
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(completedCount)/\(journey.units.count)")
                            .font(Theme.font(14, .heavy))
                            .foregroundStyle(Theme.ink)

                        Text("lições")
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? courseColor.opacity(0.1) : Theme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(isSelected ? courseColor : Theme.line, lineWidth: 2)
                )

                // Barra de progresso
                ProgressView(value: Double(completedCount) / Double(journey.units.count))
                    .tint(courseColor)
                    .padding(.horizontal, 14)
            }
        }
    }

    private var courseColor: Color {
        [Theme.wheat, Theme.olive, Theme.night, Theme.terracotta, Theme.rest][
            (journey.order ?? 0) % 5
        ]
    }
}

#Preview {
    CourseSwitcherSheet()
        .environment(ContentStore())
        .environment(GameState())
}
