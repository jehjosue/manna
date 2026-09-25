import SwiftUI

/// Tela para gerenciar visibilidade de jornadas (ocultar/mostrar).
struct ManageJourneysView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ContentStore.self) private var content
    @State private var visibilityStore = JourneyVisibilityStore.shared
    @State private var selectedJourney: Journey?
    @State private var showDetails = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Gerenciar Jornadas")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(content.journeys, id: \.id) { journey in
                                JourneyManageCard(
                                    journey: journey,
                                    isHidden: visibilityStore.isHidden(journey.id),
                                    onToggle: {
                                        visibilityStore.toggleVisibility(journey.id)
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }

                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct JourneyManageCard: View {
    let journey: Journey
    let isHidden: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Ícone da jornada
                Image(systemName: journey.icon ?? "book.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.wheat)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                        .opacity(isHidden ? 0.5 : 1.0)

                    Text(journey.subtitle ?? "")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .lineLimit(1)
                        .opacity(isHidden ? 0.5 : 1.0)
                }

                Spacer()

                // Toggle de visibilidade
                VStack(spacing: 4) {
                    Button(action: onToggle) {
                        Image(systemName: isHidden ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isHidden ? Theme.inkMuted : Theme.wheat)
                            .frame(width: 32, height: 32)
                            .background(isHidden ? Theme.lineDark : Theme.card)
                            .cornerRadius(8)
                    }

                    Text(isHidden ? "Oculta" : "Visível")
                        .font(Theme.font(10, .heavy))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .padding(12)
            .background(isHidden ? Theme.lineDark.opacity(0.3) : Theme.card)
            .cornerRadius(12)
            .opacity(isHidden ? 0.6 : 1.0)
        }
    }
}

#Preview {
    ManageJourneysView()
        .environment(ContentStore.shared)
}
