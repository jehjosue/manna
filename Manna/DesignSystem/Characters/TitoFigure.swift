import SwiftUI

/// Tito — jumentinho cinza-marrom, teimoso e brincalhão.
/// Orelhas grandes, franja despenteada, sorriso travesso.
struct TitoFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        ZStack {
            donkeyBody
                .characterBreathing(size: size)
                .characterReaction(mood)
        }
        .frame(width: size, height: size)
    }

    private var donkeyBody: some View {
        ZStack(alignment: .top) {
            // Corpo principal (oval cinza-marrom)
            Ellipse()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.7, height: size * 0.5)
                .offset(y: size * 0.1)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)

            // Pescoço ligando à cabeça
            Ellipse()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.28, height: size * 0.3)
                .offset(y: -size * 0.08)

            // Cabeça
            Ellipse()
                .fill(Color(hex: 0x9D8B75))
                .frame(width: size * 0.4, height: size * 0.45)
                .offset(y: -size * 0.15)
                .overlay(
                    Ellipse()
                        .strokeBorder(Color(hex: 0x7A6B5F), lineWidth: size * 0.015)
                        .frame(width: size * 0.4, height: size * 0.45)
                        .offset(y: -size * 0.15)
                )

            // Orelhas grandes (característica do jumento)
            // Orelha esquerda
            Ellipse()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.14, height: size * 0.35)
                .offset(x: -size * 0.14, y: -size * 0.32)
                .overlay(
                    Ellipse()
                        .fill(Color(hex: 0xA48A76))
                        .frame(width: size * 0.08, height: size * 0.25)
                        .offset(x: -size * 0.14, y: -size * 0.32)
                )

            // Orelha direita
            Ellipse()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.14, height: size * 0.35)
                .offset(x: size * 0.14, y: -size * 0.32)
                .overlay(
                    Ellipse()
                        .fill(Color(hex: 0xA48A76))
                        .frame(width: size * 0.08, height: size * 0.25)
                        .offset(x: size * 0.14, y: -size * 0.32)
                )

            // Franja despenteada (3 tufos pequenos na testa)
            franjaTufts

            // Focinho/Nariz (elipsóide mais clara)
            Ellipse()
                .fill(Color(hex: 0xB8A899))
                .frame(width: size * 0.2, height: size * 0.16)
                .offset(y: -size * 0.08)

            // Narinas
            Circle()
                .fill(Color(hex: 0x5C4F47))
                .frame(width: size * 0.04, height: size * 0.04)
                .offset(x: -size * 0.05, y: -size * 0.06)

            Circle()
                .fill(Color(hex: 0x5C4F47))
                .frame(width: size * 0.04, height: size * 0.04)
                .offset(x: size * 0.05, y: -size * 0.06)

            // Olhos (expressão travessa)
            eyeView(isLeft: true)
            eyeView(isLeft: false)

            // Pálpebras para piscar
            TimelineView(.animation) { timeline in
                let closed = BlinkClock.isClosed(at: timeline.date, seed: 3.2)
                if closed {
                    Capsule()
                        .fill(Color(hex: 0x9D8B75))
                        .frame(width: size * 0.1, height: size * 0.045)
                        .offset(x: -size * 0.12, y: -size * 0.18)

                    Capsule()
                        .fill(Color(hex: 0x9D8B75))
                        .frame(width: size * 0.1, height: size * 0.045)
                        .offset(x: size * 0.12, y: -size * 0.18)
                }
            }

            // Boca (sorriso travesso)
            mouthView

            // Barriguinhas nas bochechas (rosa-claro)
            Circle()
                .fill(Color(hex: 0xD4A8A0).opacity(0.5))
                .frame(width: size * 0.1, height: size * 0.07)
                .offset(x: -size * 0.18, y: -size * 0.08)

            Circle()
                .fill(Color(hex: 0xD4A8A0).opacity(0.5))
                .frame(width: size * 0.1, height: size * 0.07)
                .offset(x: size * 0.18, y: -size * 0.08)

            // Perninhas (4 Capsules)
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: size * 0.08) {
                    legView(isLeft: true)
                    legView(isLeft: false)
                }
                .offset(y: size * 0.1)
            }
        }
    }

    private func eyeView(isLeft: Bool) -> some View {
        ZStack {
            // Branco do olho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.09, height: size * 0.11)

            // Pupila (oval vertical)
            Ellipse()
                .fill(Color(hex: 0x3D2817))
                .frame(width: size * 0.05, height: size * 0.07)

            // Brilho especular
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.025, height: size * 0.025)
                .offset(x: -size * 0.015, y: -size * 0.025)
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.18)
    }

    @ViewBuilder
    private var mouthView: some View {
        TimelineView(.animation) { timeline in
            let mouthOpenAmount = BlinkClock.mouthOpen(at: timeline.date, talking: isTalking)

            if isTalking && mouthOpenAmount > 0.3 {
                Ellipse()
                    .fill(Color(hex: 0x5C4F47).opacity(0.8))
                    .frame(width: size * 0.1, height: size * 0.06 * mouthOpenAmount)
                    .offset(y: size * 0.02)
            } else {
                // Sorriso travesso (Capsule curvo)
                Capsule()
                    .stroke(Color(hex: 0x5C4F47), lineWidth: size * 0.015)
                    .frame(width: size * 0.12, height: size * 0.07)
                    .offset(y: size * 0.02)
            }
        }
    }

    private var franjaTufts: some View {
        ZStack {
            // Tufo esquerdo
            Ellipse()
                .fill(Color(hex: 0x7A6B5F))
                .frame(width: size * 0.08, height: size * 0.12)
                .offset(x: -size * 0.08, y: -size * 0.26)
                .rotationEffect(.degrees(-25))

            // Tufo central
            Ellipse()
                .fill(Color(hex: 0x8B7355))
                .frame(width: size * 0.1, height: size * 0.14)
                .offset(y: -size * 0.28)

            // Tufo direito
            Ellipse()
                .fill(Color(hex: 0x7A6B5F))
                .frame(width: size * 0.08, height: size * 0.12)
                .offset(x: size * 0.08, y: -size * 0.26)
                .rotationEffect(.degrees(25))
        }
    }

    private func legView(isLeft: Bool) -> some View {
        Capsule()
            .fill(Color(hex: 0x7A6B5F))
            .frame(width: size * 0.1, height: size * 0.2)
            .offset(x: isLeft ? -size * 0.12 : size * 0.12)
    }
}