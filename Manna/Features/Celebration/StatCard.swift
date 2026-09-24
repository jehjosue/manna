import SwiftUI

/// Cartão de estatística que anima de 0 até um valor.
struct StatCard: View {
    let icon: GameIcon
    let label: String
    let finalValue: Int
    let unit: String

    @State private var displayValue = 0

    var body: some View {
        VStack(spacing: 8) {
            GameIconView(icon: icon, size: 32)

            HStack(spacing: 4) {
                Text("+\(displayValue)")
                    .font(Theme.font(28, .heavy))
                    .foregroundStyle(icon.color)
                    .contentTransition(.numericText())

                Text(unit)
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            Text(label)
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
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                displayValue = finalValue
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCard(icon: .xp, label: "XP", finalValue: 15, unit: "XP")
        StatCard(icon: .manna, label: "Maná", finalValue: 35, unit: "")
    }
    .padding()
    .background(Theme.cream)
}
