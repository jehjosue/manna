import SwiftUI

/// Tio Samuel — pescador de meia-idade, pele bronzeada, barba grisalha cheia, gorro azul-petróleo.
struct TioSamuelFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                // Corpo (camisa clara)
                Capsule()
                    .fill(Color(hex: 0xE8D5C4))
                    .frame(width: size * 0.48, height: size * 0.32)
                    .offset(y: size * 0.16)

                // Ombros
                HStack(spacing: size * 0.2) {
                    Circle()
                        .fill(Color(hex: 0xE8D5C4))
                        .frame(width: size * 0.13, height: size * 0.13)
                    Circle()
                        .fill(Color(hex: 0xE8D5C4))
                        .frame(width: size * 0.13, height: size * 0.13)
                }
                .offset(y: size * 0.08)

                // Braços (pele bronzeada)
                HStack(spacing: size * 0.45) {
                    Capsule()
                        .fill(Color(hex: 0xA0704D))
                        .frame(width: size * 0.075, height: size * 0.22)
                        .offset(x: -size * 0.08, y: size * 0.05)

                    Capsule()
                        .fill(Color(hex: 0xA0704D))
                        .frame(width: size * 0.075, height: size * 0.22)
                        .offset(x: size * 0.08, y: size * 0.05)
                }

                // Cabeça (pele bronzeada)
                Circle()
                    .fill(Color(hex: 0xB8906F))
                    .frame(width: size * 0.48, height: size * 0.48)
                    .offset(y: -size * 0.16)

                // Gorro azul-petróleo
                gorroAzul()

                // Barba grisalha cheia
                barbaGrisalha()

                // Olhos
                olhoView(isLeft: true, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.3))
                olhoView(isLeft: false, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.3))

                // Boca conforme mood
                bocaView(context.date)
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private func gorroAzul() -> some View {
        ZStack {
            // Corpo do gorro (meia-esfera)
            Ellipse()
                .fill(Color(hex: 0x1F4D63))
                .frame(width: size * 0.52, height: size * 0.28)
                .offset(y: -size * 0.18)

            // Borda do gorro
            Ellipse()
                .strokeBorder(Color(hex: 0x162D42), lineWidth: size * 0.015)
                .frame(width: size * 0.52, height: size * 0.28)
                .offset(y: -size * 0.18)

            // Pompon no topo (opcional, para estilo)
            Circle()
                .fill(Color(hex: 0x2A6B8A))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(y: -size * 0.35)
        }
    }

    private func barbaGrisalha() -> some View {
        ZStack {
            // Barba preenchida
            Ellipse()
                .fill(Color(hex: 0x8B8680).opacity(0.7))
                .frame(width: size * 0.28, height: size * 0.16)
                .offset(y: size * 0.08)

            // Textura de barba (pequenos pontos)
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color(hex: 0x5D5A55).opacity(0.5))
                    .frame(width: size * 0.015, height: size * 0.015)
                    .offset(x: CGFloat(i - 3) * size * 0.04, y: size * 0.08)
            }
        }
    }

    private func olhoView(isLeft: Bool, date: Date, closed: Bool) -> some View {
        ZStack {
            if closed {
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.05)
            } else {
                Circle()
                    .fill(Color(hex: 0xF5F5DC))
                    .frame(width: size * 0.1, height: size * 0.12)

                Circle()
                    .fill(Color(hex: 0x3A3A3A))
                    .frame(width: size * 0.055, height: size * 0.055)
                    .offset(y: size * 0.02)

                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.022, height: size * 0.022)
                    .offset(x: -size * 0.012, y: -size * 0.018)
            }
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.1)
    }

    @ViewBuilder
    private func bocaView(_ date: Date) -> some View {
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        switch mood {
        case .happy:
            // Sorriso caloroso
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.16, height: size * 0.08)
                .offset(y: size * 0.08)

        case .cheering:
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.13, height: size * 0.038)
                    .offset(y: size * 0.02)

                Text("O")
                    .font(Theme.font(size * 0.12, .heavy))
                    .foregroundStyle(Color(hex: 0x1A1A1A))
                    .offset(y: size * 0.05)
            }
            .offset(y: size * 0.08)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.14, height: size * 0.065)
                .rotationEffect(.degrees(25))
                .offset(y: size * 0.1)

        case .thinking:
            // Olhar de lado e mão no queixo
            Circle()
                .fill(Color(hex: 0xA0704D))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.15, y: size * 0.06)

            Text("?")
                .font(Theme.font(size * 0.09, .heavy))
                .foregroundStyle(Color(hex: 0x8C8170))
                .offset(x: size * 0.02, y: size * 0.04)

        case .sleepy:
            ZStack {
                Text("z")
                    .font(Theme.font(size * 0.08, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .offset(x: size * 0.12, y: -size * 0.18)
            }

        case .surprised:
            Text("o")
                .font(Theme.font(size * 0.12, .heavy))
                .foregroundStyle(Color(hex: 0x1A1A1A))
                .offset(y: size * 0.08)
        }
    }
}
