import SwiftUI

/// Vovó Ester — avó professora com cabelo branco em coque, óculos redondos, xale lilás, pele morena clara.
struct VovoEsterFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking = false

    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                // Ombros e corpo
                shoulderBody

                // Pescoço
                neckView

                // Cabeça
                headView(date: timeline.date)

                // Xale lilás
                shawlView
            }
            .frame(width: size, height: size)
            .characterBreathing(size: size)
            .characterReaction(mood)
        }
    }

    private var shoulderBody: some View {
        ZStack {
            // Corpo (bege claro)
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(Color(hex: 0xE8DCC8))
                .frame(width: size * 0.75, height: size * 0.45)
                .offset(y: size * 0.2)
        }
    }

    private var neckView: some View {
        Capsule()
            .fill(Color(hex: 0xC4977F))  // Pele morena clara
            .frame(width: size * 0.15, height: size * 0.1)
            .offset(y: -size * 0.05)
    }

    private func headView(date: Date) -> some View {
        let isClosed = BlinkClock.isClosed(at: date, seed: 2.3)
        let mouthOpen = BlinkClock.mouthOpen(at: date, talking: isTalking)

        return ZStack {
            // Cabelo branco em coque (topo)
            Circle()
                .fill(Color(hex: 0xE8E8E8))
                .frame(width: size * 0.28, height: size * 0.3)
                .offset(y: -size * 0.3)

            // Tranças do coque (detalhes)
            ZStack {
                Circle()
                    .strokeBorder(Color(hex: 0xD0D0D0), lineWidth: size * 0.015)
                    .frame(width: size * 0.26, height: size * 0.28)
                    .offset(y: -size * 0.3)
            }

            // Face (oval, pele morena clara)
            Ellipse()
                .fill(Color(hex: 0xC4977F))
                .frame(width: size * 0.5, height: size * 0.58)

            // Orelhas
            Circle()
                .fill(Color(hex: 0xB88770))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: -size * 0.26, y: -size * 0.08)

            Circle()
                .fill(Color(hex: 0xB88770))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: size * 0.26, y: -size * 0.08)

            // Óculos redondos
            Circle()
                .strokeBorder(Color(hex: 0x8B7355), lineWidth: size * 0.025)
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: -size * 0.1, y: -size * 0.12)

            Circle()
                .strokeBorder(Color(hex: 0x8B7355), lineWidth: size * 0.025)
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.1, y: -size * 0.12)

            // Ponte dos óculos
            Capsule()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.06, height: size * 0.015)
                .offset(y: -size * 0.12)

            // Olhos (com piscada)
            if isClosed {
                // Olhos fechados
                Capsule()
                    .stroke(Color(hex: 0x3F3F3F), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.03)
                    .offset(x: -size * 0.12, y: -size * 0.12)

                Capsule()
                    .stroke(Color(hex: 0x3F3F3F), lineWidth: size * 0.02)
                    .frame(width: size * 0.08, height: size * 0.03)
                    .offset(x: size * 0.12, y: -size * 0.12)
            } else {
                // Olhos abertos
                eyeView(isLeft: true, mood: mood)
                eyeView(isLeft: false, mood: mood)
            }

            // Bochechas rosadas (mais suave para idosa)
            Circle()
                .fill(Color(hex: 0xD9A7A0).opacity(0.5))
                .frame(width: size * 0.11, height: size * 0.08)
                .offset(x: -size * 0.18, y: -size * 0.05)

            Circle()
                .fill(Color(hex: 0xD9A7A0).opacity(0.5))
                .frame(width: size * 0.11, height: size * 0.08)
                .offset(x: size * 0.18, y: -size * 0.05)

            // Sobrancelhas (cinzentas)
            Capsule()
                .fill(Color(hex: 0x7A7470))
                .frame(width: size * 0.1, height: size * 0.025)
                .offset(x: -size * 0.1, y: -size * 0.18)
                .rotationEffect(.degrees(mood == .sad ? 15 : -5), anchor: .center)

            Capsule()
                .fill(Color(hex: 0x7A7470))
                .frame(width: size * 0.1, height: size * 0.025)
                .offset(x: size * 0.1, y: -size * 0.18)
                .rotationEffect(.degrees(mood == .sad ? 15 : -5), anchor: .center)

            // Boca conforme mood e fala
            mouthView(mouthOpen: mouthOpen)

            // Nariz simples
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0xB88770))
                    .frame(width: size * 0.03, height: size * 0.06)
            }
            .offset(y: -size * 0.02)
        }
        .offset(y: -size * 0.15)
    }

    private func eyeView(isLeft: Bool, mood: CharacterMood) -> some View {
        ZStack {
            // Branco do olho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.09, height: size * 0.09)

            // Pupila
            Circle()
                .fill(Color(hex: 0x4B3F35))
                .frame(width: size * 0.05, height: size * 0.05)
                .offset(y: mood == .thinking ? -size * 0.015 : size * 0.01)

            // Brilho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.02, height: size * 0.02)
                .offset(x: -size * 0.01, y: -size * 0.015)
        }
        .offset(x: isLeft ? -size * 0.12 : size * 0.12, y: -size * 0.12)
    }

    @ViewBuilder
    private func mouthView(mouthOpen: CGFloat) -> some View {
        switch mood {
        case .happy, .cheering:
            Capsule()
                .stroke(Color(hex: 0x3F3F3F), lineWidth: size * 0.02)
                .frame(width: size * 0.12, height: size * 0.06)
                .offset(y: size * 0.08)

        case .sad:
            Capsule()
                .stroke(Color(hex: 0x3F3F3F), lineWidth: size * 0.02)
                .frame(width: size * 0.12, height: size * 0.05)
                .rotationEffect(.degrees(30))
                .offset(y: size * 0.1)

        case .thinking:
            Circle()
                .fill(Color(hex: 0x3F3F3F))
                .frame(width: size * 0.04, height: size * 0.04)
                .offset(y: size * 0.08)

        case .sleepy:
            Capsule()
                .stroke(Color(hex: 0x3F3F3F), lineWidth: size * 0.02)
                .frame(width: size * 0.08, height: size * 0.03)
                .rotationEffect(.degrees(-15))
                .offset(y: size * 0.08)

        case .surprised:
            VStack(spacing: 0) {
                Circle()
                    .fill(Color(hex: 0x3F3F3F))
                    .frame(width: size * 0.06, height: size * 0.07)
            }
            .offset(y: size * 0.08)
        }
    }

    private var shawlView: some View {
        ZStack {
            // Xale lilás envolto no ombro
            Capsule()
                .fill(Color(hex: 0xB86B9C).opacity(0.8))
                .frame(width: size * 0.9, height: size * 0.35)
                .offset(y: size * 0.25)

            // Franja do xale (detalhes)
            HStack(spacing: size * 0.05) {
                ForEach(0..<5, id: \.self) { _ in
                    Capsule()
                        .fill(Color(hex: 0xA75A88).opacity(0.6))
                        .frame(width: size * 0.03, height: size * 0.08)
                }
            }
            .offset(y: size * 0.35)
        }
    }
}
