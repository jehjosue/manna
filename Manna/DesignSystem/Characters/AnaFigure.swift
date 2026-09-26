import SwiftUI

/// Ana — mulher jovem de origem asiática, cabelo liso preso em rabo, jaleco verde-oliva de enfermeira.
struct AnaFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                // Corpo (jaleco verde-oliva)
                Capsule()
                    .fill(Theme.olive)
                    .frame(width: size * 0.5, height: size * 0.33)
                    .offset(y: size * 0.16)

                // Ombros
                HStack(spacing: size * 0.22) {
                    Circle()
                        .fill(Theme.olive)
                        .frame(width: size * 0.12, height: size * 0.12)
                    Circle()
                        .fill(Theme.olive)
                        .frame(width: size * 0.12, height: size * 0.12)
                }
                .offset(y: size * 0.08)

                // Braços (pele médio-clara)
                HStack(spacing: size * 0.47) {
                    Capsule()
                        .fill(Color(hex: 0xD4B5A0))
                        .frame(width: size * 0.08, height: size * 0.21)
                        .offset(x: -size * 0.08, y: size * 0.05)

                    Capsule()
                        .fill(Color(hex: 0xD4B5A0))
                        .frame(width: size * 0.08, height: size * 0.21)
                        .offset(x: size * 0.08, y: size * 0.05)
                }

                // Cabeça (pele médio-clara com traços asiáticos)
                Circle()
                    .fill(Color(hex: 0xE0C9B8))
                    .frame(width: size * 0.46, height: size * 0.46)
                    .offset(y: -size * 0.16)

                // Cabelo preto liso preso em rabo
                cabeloPreso()

                // Rabo de cavalo
                raboDeCavalo()

                // Olhos asiáticos (ligeiramente puxados)
                olhoView(isLeft: true, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.5))
                olhoView(isLeft: false, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.5))

                // Boca conforme mood
                bocaView(context.date)
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private func cabeloPreso() -> some View {
        ZStack {
            // Cabelo puxado para cima e para trás
            Ellipse()
                .fill(Color(hex: 0x1A1A1A))
                .frame(width: size * 0.38, height: size * 0.32)
                .offset(y: -size * 0.18)

            // Franja suave
            Capsule()
                .fill(Color(hex: 0x1A1A1A))
                .frame(width: size * 0.24, height: size * 0.08)
                .offset(y: -size * 0.28)

            // Fita ou presilha (rosa suave)
            Ellipse()
                .fill(Color(hex: 0xE8B4C2).opacity(0.7))
                .frame(width: size * 0.12, height: size * 0.06)
                .offset(y: -size * 0.08)
        }
    }

    private func raboDeCavalo() -> some View {
        // Rabo descendo pelas costas (simplificado)
        Capsule()
            .fill(Color(hex: 0x1A1A1A))
            .frame(width: size * 0.08, height: size * 0.25)
            .offset(x: size * 0.12, y: size * 0.08)
    }

    private func olhoView(isLeft: Bool, date: Date, closed: Bool) -> some View {
        ZStack {
            if closed {
                // Olhos fechados em arco (traço asiático)
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.02)
                    .frame(width: size * 0.09, height: size * 0.048)
                    .rotationEffect(.degrees(12))
            } else {
                // Branco do olho
                Ellipse()
                    .fill(Color.white)
                    .frame(width: size * 0.1, height: size * 0.105)

                // Pupila
                Circle()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.052, height: size * 0.052)
                    .offset(y: size * 0.015)

                // Brilho
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.02, height: size * 0.02)
                    .offset(x: -size * 0.012, y: -size * 0.016)

                // Linha de cílios (opcional, traço asiático)
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.012)
                    .frame(width: size * 0.1, height: size * 0.04)
                    .offset(y: -size * 0.05)
            }
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.1)
    }

    @ViewBuilder
    private func bocaView(_ date: Date) -> some View {
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        switch mood {
        case .happy:
            // Sorriso doce
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.14, height: size * 0.07)
                .offset(y: size * 0.065)

        case .cheering:
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.11, height: size * 0.035)
                    .offset(y: size * 0.02)

                Text("O")
                    .font(Theme.font(size * 0.11, .heavy))
                    .foregroundStyle(Color(hex: 0x1A1A1A))
                    .offset(y: size * 0.045)
            }
            .offset(y: size * 0.065)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.12, height: size * 0.06)
                .rotationEffect(.degrees(22))
                .offset(y: size * 0.08)

        case .thinking:
            // Mão no queixo pensativo
            Circle()
                .fill(Color(hex: 0xD4B5A0))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: -size * 0.16, y: size * 0.06)

            Text("?")
                .font(Theme.font(size * 0.09, .heavy))
                .foregroundStyle(Color(hex: 0x8C8170))
                .offset(x: size * 0.02, y: size * 0.03)

        case .sleepy:
            ZStack {
                Text("z")
                    .font(Theme.font(size * 0.08, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .offset(x: size * 0.12, y: -size * 0.18)
            }

        case .surprised:
            Text("o")
                .font(Theme.font(size * 0.11, .heavy))
                .foregroundStyle(Color(hex: 0x1A1A1A))
                .offset(y: size * 0.065)
        }
    }
}
