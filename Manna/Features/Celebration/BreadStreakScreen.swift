import SwiftUI

/// Tela 2: Exibe a sequência do pão diário com os últimos 7 dias.
struct BreadStreakScreen: View {
    let result: LessonResult
    @State private var iconGlow = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Iniciais dos últimos 7 dias (o último é hoje).
    private var dayLabels: [String] {
        let initials = ["D", "S", "T", "Q", "Q", "S", "S"]   // domingo = 1
        return (0..<7).map { index in
            let date = Calendar.current.date(byAdding: .day, value: index - 6, to: Date()) ?? Date()
            return initials[Calendar.current.component(.weekday, from: date) - 1]
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Fundo colorido do tema de pão
            ZStack {
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .fill(Theme.bread.opacity(0.15))

                VStack(spacing: 16) {
                    ZStack {
                        GameIconView(icon: .bread, size: 56)

                        if !reduceMotion {
                            Circle()
                                .strokeBorder(Theme.bread.opacity(0.3), lineWidth: 2)
                                .frame(width: 80, height: 80)
                                .opacity(iconGlow ? 0 : 1)
                                .scaleEffect(iconGlow ? 1.3 : 1.0)
                        }
                    }
                    .onAppear {
                        if !reduceMotion {
                            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                iconGlow = true
                            }
                        }
                    }

                    // Número animado da sequência
                    HStack(spacing: 0) {
                        Text("\(result.breadAfter)")
                            .font(Theme.font(64, .heavy))
                            .foregroundStyle(Theme.bread)
                            .contentTransition(.numericText())
                    }
                    .scaleEffect(1.0)

                    Text("dias de pão diário")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
                .padding(24)
            }

            // Mensagem de motivação
            VStack(spacing: 8) {
                if result.breadAfter == 1 {
                    Text("Você começou seu pão diário!")
                        .font(Theme.font(18, .heavy))
                        .foregroundStyle(Theme.ink)
                } else {
                    Text("Volte amanhã para manter seu pão quentinho!")
                        .font(Theme.font(18, .heavy))
                        .foregroundStyle(Theme.ink)
                }

                Text("Cada dia é um novo versículo")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            // Últimos 7 dias
            VStack(spacing: 12) {
                Text("Últimos 7 dias")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(result.lastSevenDays[index] ? Theme.bread : Theme.line)

                                if result.lastSevenDays[index] {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Theme.cream)
                                }
                            }
                            .frame(width: 32, height: 32)
                            .transition(.scale.combined(with: .opacity))

                            Text(dayLabels[index])
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                }
            }
            .padding(16)
            .background(Theme.card)
            .cornerRadius(Theme.corner)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.corner)
                    .strokeBorder(Theme.line, lineWidth: 2)
            )
            .transition(.scale.combined(with: .opacity))

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
        accuracy: 0.9,
        isPerfect: false,
        breadBefore: 6,
        breadAfter: 7,
        breadExtendedToday: true,
        completedMissions: [],
        dailyGoalReachedNow: false,
        lastSevenDays: [true, true, false, true, true, true, true]
    )

    ZStack {
        Theme.cream.ignoresSafeArea()
        BreadStreakScreen(result: sampleResult)
    }
}
