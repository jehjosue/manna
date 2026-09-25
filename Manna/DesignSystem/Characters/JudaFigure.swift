import SwiftUI

/// Judá — leãozinho dourado, corajoso e cheio de energia.
/// Juba exuberante, olhos brilhantes, postura altiva.
struct JudaFigure: View {
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        ZStack {
            lionBody
                .characterBreathing(size: size)
                .characterReaction(mood)
        }
        .frame(width: size, height: size)
    }

    private var lionBody: some View {
        ZStack(alignment: .top) {
            // Juba (círculos sobrepostos em padrão radial)
            jubaView

            // Cabeça central (mais escura que a juba)
            Circle()
                .fill(Color(hex: 0xD4A040))
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(y: -size * 0.06)
                .overlay(
                    Circle()
                        .strokeBorder(Color(hex: 0xC49030), lineWidth: size * 0.015)
                        .frame(width: size * 0.42, height: size * 0.42)
                        .offset(y: -size * 0.06)
                )

            // Focinho
            Ellipse()
                .fill(Color(hex: 0xE8C260))
                .frame(width: size * 0.24, height: size * 0.18)
                .offset(y: size * 0.02)

            // Nariz (preto pequeno)
            Circle()
                .fill(Color(hex: 0x1A1A1A))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(y: size * 0.04)

            // Olhos brilhantes e corajosos
            eyeView(isLeft: true)
            eyeView(isLeft: false)

            // Pálpebras para piscar
            TimelineView(.animation) { timeline in
                let closed = BlinkClock.isClosed(at: timeline.now, seed: 4.5)
                if closed {
                    Capsule()
                        .fill(Color(hex: 0xD4A040))
                        .frame(width: size * 0.1, height: size * 0.045)
                        .offset(x: -size * 0.11, y: -size * 0.12)

                    Capsule()
                        .fill(Color(hex: 0xD4A040))
                        .frame(width: size * 0.1, height: size * 0.045)
                        .offset(x: size * 0.11, y: -size * 0.12)
                }
            }

            // Sobrancelhas (expressão séria)
            Capsule()
                .fill(Color(hex: 0xB8860B).opacity(0.7))
                .frame(width: size * 0.12, height: size * 0.04)
                .offset(x: -size * 0.1, y: -size * 0.15)
                .rotationEffect(.degrees(-15))

            Capsule()
                .fill(Color(hex: 0xB8860B).opacity(0.7))
                .frame(width: size * 0.12, height: size * 0.04)
                .offset(x: size * 0.1, y: -size * 0.15)
                .rotationEffect(.degrees(15))

            // Boca (feroz ou alegre conforme o mood)
            mouthView

            // Corpo (mais abaixo, conectando à cabeça)
            Ellipse()
                .fill(Color(hex: 0xC49030))
                .frame(width: size * 0.6, height: size * 0.45)
                .offset(y: size * 0.18)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)

            // Perninhas (4 Capsules vigorosas)
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: size * 0.08) {
                    legView(isLeft: true)
                    legView(isLeft: false)
                }
                .offset(y: size * 0.1)
            }

            // Cauda (longa e majestosa, saindo do corpo)
            tailView
        }
    }

    private var jubaView: some View {
        ZStack {
            // Camada base da juba (grande círculo)
            Circle()
                .fill(Color(hex: 0xE0B560).opacity(0.9))
                .frame(width: size * 0.7, height: size * 0.7)
                .offset(y: -size * 0.08)

            // Círculos radiais para textura de pelos (8 posições)
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * (Double.pi / 4)
                let radius = size * 0.28
                Circle()
                    .fill(Color(hex: 0xD4A040).opacity(0.8))
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(
                        x: cos(angle) * radius,
                        y: -size * 0.08 + sin(angle) * radius
                    )
            }
        }
    }

    private func eyeView(isLeft: Bool) -> some View {
        ZStack {
            // Branco do olho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.09, height: size * 0.11)

            // Pupila (ouro escuro)
            Circle()
                .fill(Color(hex: 0x8B6914))
                .frame(width: size * 0.055, height: size * 0.055)

            // Brilho especular (coragem!)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.025, height: size * 0.025)
                .offset(x: -size * 0.015, y: -size * 0.02)
        }
        .offset(x: isLeft ? -size * 0.1 : size * 0.1, y: -size * 0.12)
    }

    @ViewBuilder
    private var mouthView: some View {
        TimelineView(.animation) { timeline in
            let mouthOpenAmount = BlinkClock.mouthOpen(at: timeline.now, talking: isTalking)

            switch mood {
            case .happy:
                if isTalking && mouthOpenAmount > 0.3 {
                    Ellipse()
                        .fill(Color(hex: 0x4A3C2A).opacity(0.8))
                        .frame(width: size * 0.1, height: size * 0.07 * mouthOpenAmount)
                        .offset(y: size * 0.08)
                } else {
                    Capsule()
                        .stroke(Color(hex: 0x4A3C2A), lineWidth: size * 0.02)
                        .frame(width: size * 0.14, height: size * 0.08)
                        .offset(y: size * 0.08)
                }

            case .cheering:
                VStack(spacing: 0) {
                    Text("!")
                        .font(Theme.font(size * 0.16, .heavy))
                        .foregroundStyle(Color(hex: 0x4A3C2A))
                        .offset(y: size * 0.06)
                }

            case .sad:
                Capsule()
                    .stroke(Color(hex: 0x4A3C2A), lineWidth: size * 0.02)
                    .frame(width: size * 0.12, height: size * 0.07)
                    .rotationEffect(.degrees(25))
                    .offset(y: size * 0.1)

            case .thinking:
                HStack(spacing: size * 0.03) {
                    Text("🤔")
                        .font(.system(size: size * 0.1))
                        .offset(y: size * 0.02)
                }

            case .sleepy:
                ZStack {
                    Capsule()
                        .stroke(Color(hex: 0x4A3C2A), lineWidth: size * 0.02)
                        .frame(width: size * 0.08, height: size * 0.05)
                        .offset(x: -size * 0.1, y: -size * 0.12)

                    Capsule()
                        .stroke(Color(hex: 0x4A3C2A), lineWidth: size * 0.02)
                        .frame(width: size * 0.08, height: size * 0.05)
                        .offset(x: size * 0.1, y: -size * 0.12)
                }

            case .surprised:
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x4A3C2A).opacity(0.6))
                        .frame(width: size * 0.08, height: size * 0.1)
                        .offset(y: size * 0.06)
                }
            }
        }
    }

    private var tailView: some View {
        ZStack {
            // Cauda curva saindo para baixo/trás
            Path { path in
                path.move(to: CGPoint(x: size * 0.2, y: size * 0.35))
                path.addCurve(
                    to: CGPoint(x: size * 0.35, y: size * 0.5),
                    control1: CGPoint(x: size * 0.3, y: size * 0.38),
                    control2: CGPoint(x: size * 0.35, y: size * 0.45)
                )
            }
            .stroke(Color(hex: 0xB8860B), lineWidth: size * 0.06)

            // Tufo na ponta (mais claro)
            Circle()
                .fill(Color(hex: 0xE0B560))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.35, y: size * 0.5)
        }
    }

    private func legView(isLeft: Bool) -> some View {
        Capsule()
            .fill(Color(hex: 0xB8860B))
            .frame(width: size * 0.11, height: size * 0.22)
            .offset(x: isLeft ? -size * 0.12 : size * 0.12)
    }
}