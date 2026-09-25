import SwiftUI

/// Pastor Davi — homem jovem negro, barba curta, camisa azul, alça de violão no ombro.
struct PastorDaviFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking = false

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                // Camisa azul + alça de violão
                shirtAndStrap

                // Pescoço
                neckView

                // Cabeça
                headView(date: timeline.now)
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private var shirtAndStrap: some View {
        ZStack {
            // Corpo (camisa azul)
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(Color(hex: 0x3B5A8E))
                .frame(width: size * 0.75, height: size * 0.45)
                .offset(y: size * 0.2)

            // Alça do violão (marrom-avermelhado)
            Capsule()
                .fill(Color(hex: 0x8B6F47).opacity(0.9))
                .frame(width: size * 0.08, height: size * 0.4)
                .offset(x: size * 0.22, y: -size * 0.05)
                .rotationEffect(.degrees(-25), anchor: .topTrailing)

            // Botões da camisa (detalhes)
            VStack(spacing: size * 0.08) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color(hex: 0x2A4169))
                        .frame(width: size * 0.05, height: size * 0.05)
                }
            }
            .offset(y: size * 0.1)
        }
    }

    private var neckView: some View {
        Capsule()
            .fill(Color(hex: 0x3D2817))  // Pele negra
            .frame(width: size * 0.16, height: size * 0.11)
            .offset(y: -size * 0.04)
    }

    private func headView(date: Date) -> some View {
        let isClosed = BlinkClock.isClosed(at: date, seed: 3.7)
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        return ZStack {
            // Face (redonda, pele negra)
            Circle()
                .fill(Color(hex: 0x3D2817))
                .frame(width: size * 0.52, height: size * 0.52)

            // Cabelo preto curto (topo da cabeça)
            Ellipse()
                .fill(Color(hex: 0x1A1410))
                .frame(width: size * 0.56, height: size * 0.35)
                .offset(y: -size * 0.08)

            // Orelhas
            Circle()
                .fill(Color(hex: 0x2A1810))
                .frame(width: size * 0.11, height: size * 0.13)
                .offset(x: -size * 0.27, y: -size * 0.06)

            Circle()
                .fill(Color(hex: 0x2A1810))
                .frame(width: size * 0.11, height: size * 0.13)
                .offset(x: size * 0.27, y: -size * 0.06)

            // Barba curta (contorno no queixo)
            Capsule()
                .fill(Color(hex: 0x1A1410).opacity(0.7))
                .frame(width: size * 0.22, height: size * 0.06)
                .offset(y: size * 0.15)

            // Olhos (com piscada)
            if isClosed {
                Capsule()
                    .stroke(Color(hex: 0xFFF8DC), lineWidth: size * 0.02)
                    .frame(width: size * 0.07, height: size * 0.03)
                    .offset(x: -size * 0.11, y: -size * 0.08)

                Capsule()
                    .stroke(Color(hex: 0xFFF8DC), lineWidth: size * 0.02)
                    .frame(width: size * 0.07, height: size * 0.03)
                    .offset(x: size * 0.11, y: -size * 0.08)
            } else {
                eyeView(isLeft: true, mood: mood)
                eyeView(isLeft: false, mood: mood)
            }

            // Sobrancelhas (pretas)
            Capsule()
                .fill(Color(hex: 0x1A1410))
                .frame(width: size * 0.1, height: size * 0.03)
                .offset(x: -size * 0.09, y: -size * 0.16)
                .rotationEffect(.degrees(mood == .sad ? 20 : -3), anchor: .center)

            Capsule()
                .fill(Color(hex: 0x1A1410))
                .frame(width: size * 0.1, height: size * 0.03)
                .offset(x: size * 0.09, y: -size * 0.16)
                .rotationEffect(.degrees(mood == .sad ? 20 : -3), anchor: .center)

            // Nariz (proporções africanas)
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0x2A1810))
                    .frame(width: size * 0.05, height: size * 0.07)
            }
            .offset(y: size * 0.01)

            // Lábios (tom mais claro)
            mouthView(mouthOpen: mouthOpen)

            // Bochechas (tons naturais, discretas)
            Circle()
                .fill(Color(hex: 0x4A3420).opacity(0.4))
                .frame(width: size * 0.09, height: size * 0.07)
                .offset(x: -size * 0.17, y: size * 0.02)

            Circle()
                .fill(Color(hex: 0x4A3420).opacity(0.4))
                .frame(width: size * 0.09, height: size * 0.07)
                .offset(x: size * 0.17, y: size * 0.02)
        }
        .offset(y: -size * 0.15)
    }

    private func eyeView(isLeft: Bool, mood: CharacterMood) -> some View {
        ZStack {
            // Branco do olho (leve tom cremoso)
            Circle()
                .fill(Color(hex: 0xF5E6D3))
                .frame(width: size * 0.09, height: size * 0.09)

            // Íris (castanha)
            Circle()
                .fill(Color(hex: 0x5D4037))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(y: mood == .thinking ? -size * 0.015 : size * 0.01)

            // Pupila
            Circle()
                .fill(Color(hex: 0x1A1410))
                .frame(width: size * 0.035, height: size * 0.035)
                .offset(y: mood == .thinking ? -size * 0.015 : size * 0.01)

            // Brilho especular
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.02, height: size * 0.02)
                .offset(x: -size * 0.01, y: -size * 0.02)
        }
        .offset(x: isLeft ? -size * 0.11 : size * 0.11, y: -size * 0.08)
    }

    @ViewBuilder
    private func mouthView(mouthOpen: CGFloat) -> some View {
        switch mood {
        case .happy:
            Capsule()
                .stroke(Color(hex: 0x6D4C41), lineWidth: size * 0.02)
                .frame(width: size * 0.12, height: size * 0.06)
                .offset(y: size * 0.12)

        case .cheering:
            VStack(spacing: size * 0.01) {
                Capsule()
                    .fill(Color(hex: 0x6D4C41))
                    .frame(width: size * 0.1, height: size * 0.03)

                Ellipse()
                    .fill(Color(hex: 0x8D6E63).opacity(0.6))
                    .frame(width: size * 0.08, height: size * 0.06 * (1 + mouthOpen * 0.5))
            }
            .offset(y: size * 0.11)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x6D4C41), lineWidth: size * 0.02)
                .frame(width: size * 0.12, height: size * 0.05)
                .rotationEffect(.degrees(35))
                .offset(y: size * 0.13)

        case .thinking:
            Circle()
                .fill(Color(hex: 0x6D4C41))
                .frame(width: size * 0.04, height: size * 0.04)
                .offset(y: size * 0.12)

        case .sleepy:
            Capsule()
                .stroke(Color(hex: 0x6D4C41), lineWidth: size * 0.02)
                .frame(width: size * 0.08, height: size * 0.03)
                .rotationEffect(.degrees(-15))
                .offset(y: size * 0.12)

        case .surprised:
            VStack(spacing: 0) {
                Ellipse()
                    .fill(Color(hex: 0x6D4C41))
                    .frame(width: size * 0.07, height: size * 0.08)
            }
            .offset(y: size * 0.11)
        }
    }
}
