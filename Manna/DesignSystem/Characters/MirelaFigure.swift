import SwiftUI

/// Mirela — adolescente, cabelo cacheado volumoso, fones de ouvido no pescoço, moletom roxo.
struct MirelaFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking = false

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                // Moletom roxo + fones de ouvido
                hoodie

                // Pescoço
                neckView

                // Cabelo cacheado (volumoso)
                hairView

                // Cabeça
                headView(date: timeline.date)

                // Fones de ouvido no pescoço
                earphonesView
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private var hoodie: some View {
        ZStack {
            // Corpo (moletom roxo)
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(Color(hex: 0x8A5CC7))
                .frame(width: size * 0.78, height: size * 0.48)
                .offset(y: size * 0.22)

            // Cordão do moletom (detalhes)
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x6B4BA0))
                    .frame(width: size * 0.02, height: size * 0.08)

                Capsule()
                    .fill(Color(hex: 0x6B4BA0))
                    .frame(width: size * 0.15, height: size * 0.02)
            }
            .offset(y: size * 0.1)
        }
    }

    private var neckView: some View {
        Capsule()
            .fill(Color(hex: 0xE8C4B5))  // Pele clara (jovem)
            .frame(width: size * 0.15, height: size * 0.09)
            .offset(y: -size * 0.03)
    }

    private var hairView: some View {
        ZStack {
            // Cabelo cacheado volumoso (marrom claro com tons naturais)
            // Grande bola central (topo)
            Circle()
                .fill(Color(hex: 0x7A5C3E).opacity(0.9))
                .frame(width: size * 0.65, height: size * 0.65)
                .offset(y: -size * 0.1)

            // Cachos laterais esquerdo (volume)
            Circle()
                .fill(Color(hex: 0x8B6F47))
                .frame(width: size * 0.25, height: size * 0.28)
                .offset(x: -size * 0.24, y: -size * 0.18)

            // Cachos laterais direito (volume)
            Circle()
                .fill(Color(hex: 0x8B6F47))
                .frame(width: size * 0.25, height: size * 0.28)
                .offset(x: size * 0.24, y: -size * 0.18)

            // Cachos no topo (mais claros, destaque)
            Circle()
                .fill(Color(hex: 0x9D7E5D).opacity(0.8))
                .frame(width: size * 0.2, height: size * 0.2)
                .offset(y: -size * 0.32)

            // Franja cacheada
            Circle()
                .fill(Color(hex: 0x7A5C3E))
                .frame(width: size * 0.18, height: size * 0.15)
                .offset(y: -size * 0.12)
        }
    }

    private func headView(date: Date) -> some View {
        let isClosed = BlinkClock.isClosed(at: date, seed: 4.1)
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        return ZStack {
            // Face (oval, pele clara)
            Ellipse()
                .fill(Color(hex: 0xE8C4B5))
                .frame(width: size * 0.48, height: size * 0.54)

            // Orelhas (discretas, cobertas pelo cabelo)
            Circle()
                .fill(Color(hex: 0xD4B0A5))
                .frame(width: size * 0.1, height: size * 0.11)
                .offset(x: -size * 0.24, y: -size * 0.05)

            Circle()
                .fill(Color(hex: 0xD4B0A5))
                .frame(width: size * 0.1, height: size * 0.11)
                .offset(x: size * 0.24, y: -size * 0.05)

            // Olhos adolescentes (grandes, expressivos)
            if isClosed {
                Capsule()
                    .stroke(Color(hex: 0x4A3F35), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.035)
                    .offset(x: -size * 0.1, y: -size * 0.1)

                Capsule()
                    .stroke(Color(hex: 0x4A3F35), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.035)
                    .offset(x: size * 0.1, y: -size * 0.1)
            } else {
                eyeView(isLeft: true, mood: mood)
                eyeView(isLeft: false, mood: mood)
            }

            // Sobrancelhas (finas e arqueadas, típico adolescente)
            Capsule()
                .fill(Color(hex: 0x6B5444))
                .frame(width: size * 0.11, height: size * 0.025)
                .offset(x: -size * 0.095, y: -size * 0.15)
                .rotationEffect(.degrees(mood == .sad ? 18 : -8), anchor: .center)

            Capsule()
                .fill(Color(hex: 0x6B5444))
                .frame(width: size * 0.11, height: size * 0.025)
                .offset(x: size * 0.095, y: -size * 0.15)
                .rotationEffect(.degrees(mood == .sad ? 18 : -8), anchor: .center)

            // Nariz pequeno e delicado
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0xD4B0A5))
                    .frame(width: size * 0.03, height: size * 0.05)
            }
            .offset(y: -size * 0.02)

            // Bochechas rosadas (tons naturais de adolescente)
            Circle()
                .fill(Color(hex: 0xE8A8A0).opacity(0.45))
                .frame(width: size * 0.1, height: size * 0.075)
                .offset(x: -size * 0.15, y: -size * 0.02)

            Circle()
                .fill(Color(hex: 0xE8A8A0).opacity(0.45))
                .frame(width: size * 0.1, height: size * 0.075)
                .offset(x: size * 0.15, y: -size * 0.02)

            // Boca conforme mood
            mouthView(mouthOpen: mouthOpen)
        }
        .offset(y: -size * 0.12)
    }

    private func eyeView(isLeft: Bool, mood: CharacterMood) -> some View {
        ZStack {
            // Branco do olho (grande para adolescente)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.1, height: size * 0.1)

            // Íris (azul-verde claro)
            Circle()
                .fill(Color(hex: 0x6B9BD1))
                .frame(width: size * 0.067, height: size * 0.067)
                .offset(y: mood == .thinking ? -size * 0.012 : size * 0.008)

            // Pupila preta
            Circle()
                .fill(Color(hex: 0x1A1A1A))
                .frame(width: size * 0.04, height: size * 0.04)
                .offset(y: mood == .thinking ? -size * 0.012 : size * 0.008)

            // Brilho especular (faz parecer mais viva)
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.022, height: size * 0.022)
                .offset(x: -size * 0.008, y: -size * 0.025)

            // Cílios (traço fino superior)
            Capsule()
                .fill(Color(hex: 0x4A3F35))
                .frame(width: size * 0.06, height: size * 0.01)
                .offset(y: -size * 0.055)
        }
        .offset(x: isLeft ? -size * 0.105 : size * 0.105, y: -size * 0.1)
    }

    @ViewBuilder
    private func mouthView(mouthOpen: CGFloat) -> some View {
        switch mood {
        case .happy:
            Capsule()
                .stroke(Color(hex: 0xC96B6B), lineWidth: size * 0.018)
                .frame(width: size * 0.13, height: size * 0.065)
                .offset(y: size * 0.1)

        case .cheering:
            VStack(spacing: size * 0.01) {
                Capsule()
                    .fill(Color(hex: 0xC96B6B))
                    .frame(width: size * 0.11, height: size * 0.035)

                Ellipse()
                    .fill(Color(hex: 0xE8B0A0))
                    .frame(width: size * 0.085, height: size * 0.07 * (1 + mouthOpen * 0.4))
            }
            .offset(y: size * 0.09)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0xC96B6B), lineWidth: size * 0.018)
                .frame(width: size * 0.13, height: size * 0.055)
                .rotationEffect(.degrees(32))
                .offset(y: size * 0.11)

        case .thinking:
            Circle()
                .fill(Color(hex: 0xC96B6B))
                .frame(width: size * 0.044, height: size * 0.044)
                .offset(y: size * 0.1)

        case .sleepy:
            Capsule()
                .stroke(Color(hex: 0xC96B6B), lineWidth: size * 0.018)
                .frame(width: size * 0.09, height: size * 0.035)
                .rotationEffect(.degrees(-18))
                .offset(y: size * 0.1)

        case .surprised:
            VStack(spacing: 0) {
                Ellipse()
                    .fill(Color(hex: 0xC96B6B))
                    .frame(width: size * 0.075, height: size * 0.09)
            }
            .offset(y: size * 0.09)
        }
    }

    private var earphonesView: some View {
        ZStack {
            // Cabo do fone (cinza)
            Capsule()
                .fill(Color(hex: 0x4A4A4A))
                .frame(width: size * 0.65, height: size * 0.04)
                .offset(y: size * 0.18)

            // Cápsula esquerda (preto)
            Circle()
                .fill(Color(hex: 0x2A2A2A))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: -size * 0.22, y: size * 0.22)

            // Cápsula direita (preto)
            Circle()
                .fill(Color(hex: 0x2A2A2A))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.22, y: size * 0.22)

            // Detalhes (cinza escuro nas cápsulas)
            Circle()
                .fill(Color(hex: 0x3A3A3A).opacity(0.7))
                .frame(width: size * 0.05, height: size * 0.05)
                .offset(x: -size * 0.22, y: size * 0.22)

            Circle()
                .fill(Color(hex: 0x3A3A3A).opacity(0.7))
                .frame(width: size * 0.05, height: size * 0.05)
                .offset(x: size * 0.22, y: size * 0.22)
        }
    }
}
