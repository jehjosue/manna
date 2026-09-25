import SwiftUI

/// Visão geral de seções de uma jornada.
/// Agrupa as 4 unidades em 2 seções (ou trata cada uma como seção).
/// Mostra progresso, estado (bloqueado/atual/concluído), botão "Continuar" ou "Pular para cá".
struct SectionsOverviewView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @Environment(\.dismiss) private var dismiss

    let journey: Journey
    @State private var selectedSection: Int?
    @State private var selectedUnit: JourneyUnit?
    @State private var showSkipTest = false
    @State private var showTopicDetail: JourneyUnit?

    /// Agrupa as 4 unidades em 2 seções (seção 1: u1-u2, seção 2: u3-u4).
    var sections: [[JourneyUnit]] {
        let grouped = stride(from: 0, to: journey.units.count, by: 2).map { start in
            Array(journey.units[start..<min(start + 2, journey.units.count)])
        }
        return grouped
    }

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
                        Text(journey.title)
                            .font(Theme.font(22, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                    }
                    .padding(16)

                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(Array(sections.enumerated()), id: \.offset) { sectionIndex, units in
                                sectionCard(sectionIndex: sectionIndex, units: units)
                            }
                            Spacer(minLength: 40)
                        }
                        .padding(16)
                    }
                }
            }
        }
        .sheet(item: $showTopicDetail) { unit in
            TopicDetailView(unit: unit)
        }
        .fullScreenCover(isPresented: $showSkipTest) {
            if let unit = selectedUnit {
                UnitSkipTestView(unit: unit) { showSkipTest = false }
            }
        }
    }

    @ViewBuilder
    private func sectionCard(sectionIndex: Int, units: [JourneyUnit]) -> some View {
        VStack(spacing: 12) {
            // Cabeçalho da seção
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Seção \(sectionIndex + 1)")
                        .font(Theme.font(12, .heavy))
                        .foregroundStyle(Theme.inkMuted)
                    Text(sectionTitle(for: units))
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                }
                Spacer()

                // Progresso
                let completed = units.filter { unit in
                    unit.lessons.allSatisfy { game.isCompleted($0.id) }
                }.count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completed)/\(units.count)")
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text("concluído")
                        .font(Theme.font(10, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }

            // Unidades da seção
            VStack(spacing: 10) {
                ForEach(units, id: \.id) { unit in
                    unitRow(unit: unit)
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func unitRow(unit: JourneyUnit) -> some View {
        Button(action: { showTopicDetail = unit }) {
            HStack(spacing: 12) {
                // Ícone de status
                ZStack {
                    Circle()
                        .fill(statusColor(for: unit))
                        .frame(width: 40, height: 40)

                    Image(systemName: statusIcon(for: unit))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.title)
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(unit.subtitle)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(12)
            .background(Theme.cream)
            .cornerRadius(8)
        }
    }

    private func sectionTitle(for units: [JourneyUnit]) -> String {
        let unitTitles = units.map { $0.title }.joined(separator: " - ")
        return unitTitles
    }

    private func statusIcon(for unit: JourneyUnit) -> String {
        let allCompleted = unit.lessons.allSatisfy { game.isCompleted($0.id) }
        if allCompleted { return "checkmark" }

        let hasStarted = unit.lessons.contains { game.isCompleted($0.id) }
        if hasStarted { return "play.fill" }

        if game.isUnlocked(unit.lessons.first?.id ?? "", in: journey) { return "play.circle.fill" }
        return "lock.fill"
    }

    private func statusColor(for unit: JourneyUnit) -> Color {
        let allCompleted = unit.lessons.allSatisfy { game.isCompleted($0.id) }
        if allCompleted { return Theme.olive }

        let hasStarted = unit.lessons.contains { game.isCompleted($0.id) }
        if hasStarted { return Theme.terracotta }

        if game.isUnlocked(unit.lessons.first?.id ?? "", in: journey) { return Theme.wheat }
        return Theme.lineDark
    }
}

#Preview {
    SectionsOverviewView(journey: Journey(
        id: "test",
        title: "Vida de Jesus",
        subtitle: nil,
        icon: nil,
        order: 1,
        units: [
            JourneyUnit(
                id: "u1",
                title: "Unidade 1",
                subtitle: "O Nascimento",
                lessons: [],
                guide: nil
            )
        ]
    ))
    .environment(GameState())
    .environment(ContentStore())
}
