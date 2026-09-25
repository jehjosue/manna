import SwiftUI

/// Humores da ovelhinha (mascote).
enum SheepMood: String, CaseIterable {
    case happy       // padrão, sorrindo
    case cheering    // comemorando (braços/patas para cima, pulando)
    case sad         // errou / acabou o óleo
    case thinking    // durante uma pergunta
    case sleepy      // lembrete / dia de descanso
}

/// Ovelhinha desenhada em SwiftUI com animações por mood.
/// Contrato estável: `SheepView(mood:size:)`.
struct SheepView: View {
    var mood: SheepMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Respiração sutil (escala)
            sheepBody
                .scaleEffect(isAnimating ? 1.03 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
        }
        .frame(width: size, height: size)
        .onAppear { isAnimating = true }
    }

    private var sheepBody: some View {
        ZStack(alignment: .top) {
            // Corpo de lã (vários círculos brancos sobrepostos)
            ZStack {
                // Camada de trás
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.55)
                    .offset(y: size * 0.1)

                // Camadas laterais (textura fofinha)
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.35, height: size * 0.4)
                    .offset(x: -size * 0.22, y: size * 0.05)

                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.35, height: size * 0.4)
                    .offset(x: size * 0.22, y: size * 0.05)

                // Topo fofinho
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.5, height: size * 0.35)
                    .offset(y: -size * 0.15)
            }
            // Contorno sutil do corpo
            .overlay(
                ZStack {
                    Circle()
                        .strokeBorder(Theme.line.opacity(0.3), lineWidth: size * 0.02)
                        .frame(width: size * 0.7, height: size * 0.55)
                        .offset(y: size * 0.1)
                }
            )

            // Cabeça oval cinza-escuro
            ZStack {
                Ellipse()
                    .fill(Color(hex: 0x4A4038))
                    .frame(width: size * 0.42, height: size * 0.48)
                    .offset(y: -size * 0.08)

                // Orelhas
                Circle()
                    .fill(Color(hex: 0x4A4038))
                    .frame(width: size * 0.15, height: size * 0.2)
                    .offset(x: -size * 0.16, y: -size * 0.22)

                Circle()
                    .fill(Color(hex: 0x4A4038))
                    .frame(width: size * 0.15, height: size * 0.2)
                    .offset(x: size * 0.16, y: -size * 0.22)

                // Olhos
                eyeView(isLeft: true)
                eyeView(isLeft: false)

                // Bochechas rosadas
                Circle()
                    .fill(Color(hex: 0xE8B4C2).opacity(0.6))
                    .frame(width: size * 0.12, height: size * 0.08)
                    .offset(x: -size * 0.18, y: -size * 0.02)

                Circle()
                    .fill(Color(hex: 0xE8B4C2).opacity(0.6))
                    .frame(width: size * 0.12, height: size * 0.08)
                    .offset(x: size * 0.18, y: -size * 0.02)

                // Boca conforme o mood
                mouthView
            }

            // Perninhas
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: size * 0.1) {
                    legView(isLeft: true)
                    legView(isLeft: false)
                }
                .offset(y: size * 0.15)
            }
        }
    }

    private func eyeView(isLeft: Bool) -> some View {
        ZStack {
            // Branco do olho
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.1, height: size * 0.12)

            // Pupila
            Circle()
                .fill(Color(hex: 0x1A1A1A))
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(y: size * 0.02)

            // Brilho especular
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.025, height: size * 0.025)
                .offset(x: -size * 0.015, y: -size * 0.02)
        }
        .offset(x: isLeft ? -size * 0.11 : size * 0.11, y: -size * 0.1)
    }

    @ViewBuilder
    private var mouthView: some View {
        TimelineView(.animation) { timeline in
            let mouthOpenAmount = BlinkClock.mouthOpen(at: timeline.now, talking: isTalking)

            switch mood {
            case .happy:
                // Sorriso simples (ou boca aberta se falando)
                if isTalking && mouthOpenAmount > 0.3 {
                    Ellipse()
                        .fill(Color(hex: 0x1A1A1A).opacity(0.6))
                        .frame(width: size * 0.12, height: size * 0.08 * mouthOpenAmount)
                        .offset(y: size * 0.05)
                } else {
                    Capsule()
                        .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                        .frame(width: size * 0.15, height: size * 0.08)
                        .offset(y: size * 0.05)
                }

            case .cheering:
                // Boca aberta em emoção (pulinho animado)
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color(hex: 0x1A1A1A))
                        .frame(width: size * 0.12, height: size * 0.04)
                        .offset(y: size * 0.03)

                    Text("O")
                        .font(Theme.font(size * 0.12, .heavy))
                        .foregroundStyle(Color(hex: 0x1A1A1A))
                        .offset(y: size * 0.05)
                }
                // Pulinho
                .offset(y: isAnimating ? -size * 0.04 : 0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)

            case .sad:
                // Sobrancelhas caídas e boca triste
                Capsule()
                    .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                    .frame(width: size * 0.15, height: size * 0.06)
                    .rotationEffect(.degrees(20))
                    .offset(y: size * 0.08)

            case .thinking:
                // Olhar de lado e "?" pequeno
                HStack(spacing: size * 0.05) {
                    Text("?")
                        .font(Theme.font(size * 0.08, .heavy))
                        .foregroundStyle(Color(hex: 0x8C8170))
                        .offset(y: -size * 0.02)
                }
                .offset(y: size * 0.02)

            case .sleepy:
                // Olhos fechados em arco e "z" flutuando
                ZStack {
                    // Arcos de olhos fechados (subscrito das pupils anteriores)
                    Capsule()
                        .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                        .frame(width: size * 0.08, height: size * 0.05)
                        .offset(x: -size * 0.11, y: -size * 0.1)

                    Capsule()
                        .stroke(Color(hex: 0x1A1A1A), lineWidth: size * 0.015)
                        .frame(width: size * 0.08, height: size * 0.05)
                        .offset(x: size * 0.11, y: -size * 0.1)

                    // "z" flutuante
                    Text("z")
                        .font(Theme.font(size * 0.08, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .offset(x: size * 0.15, y: -size * 0.18)
                        .offset(y: isAnimating ? -size * 0.05 : 0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                }
            }
        }
    }

    private func legView(isLeft: Bool) -> some View {
        Capsule()
            .fill(Color(hex: 0x4A4038))
            .frame(width: size * 0.12, height: size * 0.18)
            .offset(x: isLeft ? -size * 0.12 : size * 0.12)
    }
}

/// Balão de fala usado pela ovelhinha e pelos personagens bíblicos.
/// Mantém contrato estável com "rabinho" apontando para baixo.
struct SpeechBubble: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(Theme.font(17, .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Theme.line, lineWidth: 2)
                )

            // Rabinho apontando para baixo
            Triangle()
                .fill(Theme.card)
                .frame(width: 14, height: 10)
                .offset(x: 0, y: -1)
                .overlay(
                    Triangle()
                        .stroke(Theme.line, lineWidth: 2)
                        .frame(width: 14, height: 10)
                        .offset(x: 0, y: -1)
                )
        }
    }
}

/// Triângulo para o "rabinho" do balão de fala.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            VStack {
                SheepView(mood: .happy, size: 100)
                Text("Happy").font(.caption)
            }
            VStack {
                SheepView(mood: .cheering, size: 100)
                Text("Cheering").font(.caption)
            }
            VStack {
                SheepView(mood: .sad, size: 100)
                Text("Sad").font(.caption)
            }
        }
        HStack(spacing: 16) {
            VStack {
                SheepView(mood: .thinking, size: 100)
                Text("Thinking").font(.caption)
            }
            VStack {
                SheepView(mood: .sleepy, size: 100)
                Text("Sleepy").font(.caption)
            }
        }
        Spacer()
        SpeechBubble(text: "Oi! Eu sou a Béé 🐑")
    }
    .padding()
    .background(Theme.cream)
}
