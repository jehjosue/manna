import SwiftUI

/// Noemi — universitária negra, tranças, óculos quadrados, blusa cor de mostarda.
struct NoemiFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        TimelineView(.animation) { context in
            ZStack {
                // Corpo (blusa mostarda)
                Capsule()
                    .fill(Color(hex: 0xD4A856))
                    .frame(width: size * 0.5, height: size * 0.34)
                    .offset(y: size * 0.15)

                // Ombros
                HStack(spacing: size * 0.22) {
                    Circle()
                        .fill(Color(hex: 0xD4A856))
                        .frame(width: size * 0.12, height: size * 0.12)
                    Circle()
                        .fill(Color(hex: 0xD4A856))
                        .frame(width: size * 0.12, height: size * 0.12)
                }
                .offset(y: size * 0.08)

                // Braços (pele negra)
                HStack(spacing: size * 0.47) {
                    Capsule()
                        .fill(Color(hex: 0x6B5344))
                        .frame(width: size * 0.08, height: size * 0.21)
                        .offset(x: -size * 0.08, y: size * 0.05)

                    Capsule()
                        .fill(Color(hex: 0x6B5344))
                        .frame(width: size * 0.08, height: size * 0.21)
                        .offset(x: size * 0.08, y: size * 0.05)
                }

                // Cabeça (pele negra)
                Circle()
                    .fill(Color(hex: 0x7D6647))
                    .frame(width: size * 0.47, height: size * 0.47)
                    .offset(y: -size * 0.15)

                // Tranças (estilo box braids)
                trancas()

                // Óculos quadrados
                oculosQuadrados()

                // Olhos
                olhoView(isLeft: true, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.9))
                olhoView(isLeft: false, date: context.date, closed: BlinkClock.isClosed(at: context.date, seed: 0.9))

                // Boca conforme mood
                bocaView(context.date)
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private func trancas() -> some View {
        ZStack {
            // Tranças laterais (colunas de cabelo)
            // Esquerda
            Capsule()
                .fill(Color(hex: 0x3C2B1E))
                .frame(width: size * 0.055, height: size * 0.34)
                .offset(x: -size * 0.16, y: -size * 0.1)

            // Centro-esquerda
            Capsule()
                .fill(Color(hex: 0x3C2B1E))
                .frame(width: size * 0.055, height: size * 0.36)
                .offset(x: -size * 0.08, y: -size * 0.12)

            // Centro-direita
            Capsule()
                .fill(Color(hex: 0x3C2B1E))
                .frame(width: size * 0.055, height: size * 0.36)
                .offset(x: size * 0.08, y: -size * 0.12)

            // Direita
            Capsule()
                .fill(Color(hex: 0x3C2B1E))
                .frame(width: size * 0.055, height: size * 0.34)
                .offset(x: size * 0.16, y: -size * 0.1)

            // Topo das tranças (mais grosso)
            Ellipse()
                .fill(Color(hex: 0x3C2B1E))
                .frame(width: size * 0.45, height: size * 0.25)
                .offset(y: -size * 0.2)
        }
    }

    private func oculosQuadrados() -> some View {
        ZStack {
            // Armação esquerda
            RoundedRectangle(cornerRadius: size * 0.02)
                .stroke(Color(hex: 0x8B7355), lineWidth: size * 0.02)
                .frame(width: size * 0.1, height: size * 0.09)
                .offset(x: -size * 0.11, y: -size * 0.1)

            // Armação direita
            RoundedRectangle(cornerRadius: size * 0.02)
                .stroke(Color(hex: 0x8B7355), lineWidth: size * 0.02)
                .frame(width: size * 0.1, height: size * 0.09)
                .offset(x: size * 0.11, y: -size * 0.1)

            // Ponte (haste do meio)
            Capsule()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.035, height: size * 0.015)
                .offset(y: -size * 0.1)

            // Lente preenchida (vidro)
            RoundedRectangle(cornerRadius: size * 0.02)
                .fill(Color(hex: 0xB8D4E3).opacity(0.3))
                .frame(width: size * 0.1, height: size * 0.09)
                .offset(x: -size * 0.11, y: -size * 0.1)

            RoundedRectangle(cornerRadius: size * 0.02)
                .fill(Color(hex: 0xB8D4E3).opacity(0.3))
                .frame(width: size * 0.1, height: size * 0.09)
                .offset(x: size * 0.11, y: -size * 0.1)
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
                    .fill(Color(hex: 0x2A1A0A))
                    .frame(width: size * 0.095, height: size * 0.11)

                Circle()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.055, height: size * 0.055)
                    .offset(y: size * 0.018)

                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.022, height: size * 0.022)
                    .offset(x: -size * 0.012, y: -size * 0.018)
            }
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.09)
    }

    @ViewBuilder
    private func bocaView(_ date: Date) -> some View {
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        switch mood {
        case .happy:
            // Sorriso caloroso
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.15, height: size * 0.075)
                .offset(y: size * 0.07)

        case .cheering:
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x1A1A1A))
                    .frame(width: size * 0.12, height: size * 0.036)
                    .offset(y: size * 0.02)

                Text("O")
                    .font(Theme.font(size * 0.12, .heavy))
                    .foregroundStyle(Color(hex: 0x1A1A1A))
                    .offset(y: size * 0.05)
            }
            .offset(y: size * 0.07)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                .frame(width: size * 0.13, height: size * 0.065)
                .rotationEffect(.degrees(24))
                .offset(y: size * 0.09)

        case .thinking:
            // Mão no queixo
            Circle()
                .fill(Color(hex: 0x6B5344))
                .frame(width: size * 0.07, height: size * 0.07)
                .offset(x: -size * 0.16, y: size * 0.07)

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
                .offset(y: size * 0.07)
        }
    }
}
