import SwiftUI

/// Paz — pomba branca serena com asas graciosas, bico laranja-claro, raminho de oliveira.
/// Exprime calma, consolo e sabedoria.
struct PazFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        ZStack {
            doveBody
                .characterBreathing(size: size)
                .characterReaction(mood)
        }
        .frame(width: size, height: size)
    }

    private var doveBody: some View {
        ZStack(alignment: .top) {
            // Cauda de asas arredondada (branca com bordas suaves)
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.65, height: size * 0.55)
                .offset(y: size * 0.15)
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 2)

            // Asas abertas (duas metades arredondadas, uma de cada lado)
            // Asa esquerda
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.28, height: size * 0.5)
                .offset(x: -size * 0.22, y: size * 0.02)
                .overlay(
                    Ellipse()
                        .stroke(Color(hex: 0xE0E0E0), lineWidth: size * 0.02)
                        .frame(width: size * 0.28, height: size * 0.5)
                        .offset(x: -size * 0.22, y: size * 0.02)
                )
                .rotationEffect(.degrees(-15))

            // Asa direita
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.28, height: size * 0.5)
                .offset(x: size * 0.22, y: size * 0.02)
                .overlay(
                    Ellipse()
                        .stroke(Color(hex: 0xE0E0E0), lineWidth: size * 0.02)
                        .frame(width: size * 0.28, height: size * 0.5)
                        .offset(x: size * 0.22, y: size * 0.02)
                )
                .rotationEffect(.degrees(15))

            // Corpo central (mais denso)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.5, height: size * 0.55)
                .offset(y: size * 0.08)

            // Pescoço fino
            Capsule()
                .fill(Color.white)
                .frame(width: size * 0.18, height: size * 0.22)
                .offset(y: -size * 0.05)

            // Cabeça pequena e redonda
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.32, height: size * 0.36)
                .offset(y: -size * 0.18)
                .overlay(
                    Circle()
                        .strokeBorder(Color(hex: 0xE8E8E8), lineWidth: size * 0.015)
                        .frame(width: size * 0.32, height: size * 0.36)
                        .offset(y: -size * 0.18)
                )

            // Bico laranja-claro
            Path { path in
                let centerY = -size * 0.18
                let centerX = size * 0.1
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addLine(to: CGPoint(x: centerX + size * 0.12, y: centerY - size * 0.03))
                path.addLine(to: CGPoint(x: centerX, y: centerY + size * 0.03))
                path.closeSubpath()
            }
            .fill(Color(hex: 0xE8B896))

            // Olhos
            eyeView(isLeft: true)
            eyeView(isLeft: false)

            // Pálpebras para piscar
            TimelineView(.animation) { timeline in
                let closed = BlinkClock.isClosed(at: timeline.now, seed: 2.1)
                if closed {
                    // Olho esquerdo fechado
                    Capsule()
                        .fill(Color.white)
                        .frame(width: size * 0.09, height: size * 0.04)
                        .offset(x: -size * 0.09, y: -size * 0.22)

                    // Olho direito fechado
                    Capsule()
                        .fill(Color.white)
                        .frame(width: size * 0.09, height: size * 0.04)
                        .offset(x: size * 0.09, y: -size * 0.22)
                }
            }

            // Boca
            mouthView

            // Raminho de oliveira (opcional, nas asas superiores)
            oliveLeavesDeco
        }
    }

    private func eyeView(isLeft: Bool) -> some View {
        ZStack {
            // Branco do olho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.08, height: size * 0.08)

            // Pupila
            Circle()
                .fill(Color(hex: 0x4A7C59))
                .frame(width: size * 0.04, height: size * 0.04)

            // Brilho especular
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.02, height: size * 0.02)
                .offset(x: -size * 0.01, y: -size * 0.01)
        }
        .offset(x: isLeft ? -size * 0.09 : size * 0.09, y: -size * 0.22)
    }

    @ViewBuilder
    private var mouthView: some View {
        TimelineView(.animation) { timeline in
            let mouthOpenAmount = BlinkClock.mouthOpen(at: timeline.now, talking: isTalking)

            if isTalking && mouthOpenAmount > 0.2 {
                Ellipse()
                    .fill(Color(hex: 0xD4A374).opacity(0.7))
                    .frame(width: size * 0.08, height: size * 0.05 * mouthOpenAmount)
                    .offset(y: -size * 0.12)
            } else {
                // Boca fechada — ponto ou linha sutil
                Capsule()
                    .fill(Color(hex: 0x8C7968))
                    .frame(width: size * 0.06, height: size * 0.02)
                    .offset(y: -size * 0.12)
            }
        }
    }

    private var oliveLeavesDeco: some View {
        ZStack {
            // Raminho de oliveira simples nas asas
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addCurve(
                    to: CGPoint(x: size * 0.15, y: -size * 0.12),
                    control1: CGPoint(x: size * 0.05, y: -size * 0.02),
                    control2: CGPoint(x: size * 0.12, y: -size * 0.08)
                )
            }
            .stroke(Color(hex: 0x7A9B6B), lineWidth: size * 0.02)

            // Folhinhas (pequenos elipsóides)
            Ellipse()
                .fill(Color(hex: 0x7A9B6B))
                .frame(width: size * 0.06, height: size * 0.04)
                .offset(x: size * 0.04, y: -size * 0.04)

            Ellipse()
                .fill(Color(hex: 0x8FB377))
                .frame(width: size * 0.06, height: size * 0.04)
                .offset(x: size * 0.10, y: -size * 0.08)
        }
        .offset(x: -size * 0.12, y: -size * 0.22)
        .opacity(0.8)
    }
}