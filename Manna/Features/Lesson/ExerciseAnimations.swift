import SwiftUI
import Combine

// MARK: - Modifiers de Animação

extension View {
    /// Tremida (shake) para erro: oscila lado a lado.
    func shakeAnimation(trigger: UUID) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }

    /// Movimento de seleção com press e spring.
    func pressAndSpring(isPressed: Bool) -> some View {
        scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
    }

    /// Transição de cor animada para o botão de verificação.
    func verifyButtonAnimation(isCorrect: Bool?) -> some View {
        self
            .opacity(isCorrect == nil ? 1 : 0.8)
            .scaleEffect(isCorrect == nil ? 1 : 1.05)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isCorrect)
    }
}

// MARK: - Shake Modifier

private struct ShakeModifier: ViewModifier {
    let trigger: UUID
    @State private var position: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(x: reduceMotion ? 0 : position)
            .onReceive(Just(trigger)) { _ in
                if !reduceMotion {
                    shake()
                }
            }
    }

    private func shake() {
        let sequence: [CGFloat] = [0, -12, 12, -12, 12, 0]
        for (index, offset) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                withAnimation(.linear(duration: 0.08)) {
                    position = offset
                }
            }
        }
    }
}

// MARK: - Selo "N SEGUIDAS" (Streak Badge)

struct StreakBadge: View {
    let count: Int
    let isVisible: Bool

    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        if isVisible {
            ZStack {
                // Fundo com glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Theme.bread, Theme.terracotta]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Theme.bread.opacity(0.5), radius: 8, x: 0, y: 4)
                    .shadow(color: Theme.terracotta.opacity(0.3), radius: 12, x: 0, y: 0)

                // Chama/pão pulsando
                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 28))
                        .scaleEffect(scale)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                            value: scale
                        )

                    Text("\(count)")
                        .font(Theme.font(18, .heavy))
                        .foregroundStyle(Theme.night)

                    Text("SEGUIDAS")
                        .font(Theme.font(10, .bold))
                        .foregroundStyle(Theme.night.opacity(0.8))
                }
                .padding(12)
            }
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if !reduceMotion {
                    scale = 1
                    rotation = 360
                }
            }
        }
    }
}

// MARK: - Progress Bar com Spring

struct AnimatedProgressBar: View {
    let progress: Double
    let isCorrect: Bool?

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Fundo
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Theme.line)

                    // Progresso com cor baseada em acerto/erro
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(progressColor)
                        .frame(width: geo.size.width * progress)
                        .animation(
                            reduceMotion ? .linear(duration: 0.3) : .spring(response: 0.4, dampingFraction: 0.65),
                            value: progress
                        )

                    // Brilho animado
                    if isCorrect == true {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.2)
                            .offset(x: geo.size.width * progress - geo.size.width * 0.1)
                    }
                }
                .frame(height: 12)
            }
            .frame(height: 12)
        }
    }

    private var progressColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Theme.olive : Theme.terracotta
        }
        return Theme.bread
    }
}

// MARK: - Burst de Partículas (Acerto)

struct ParticleBurst: View {
    let isVisible: Bool
    let count: Int = 12

    @State private var particles: [(id: UUID, offset: CGPoint, opacity: Double)] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.bread)
                    .offset(x: particle.offset.x, y: particle.offset.y)
                    .opacity(particle.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(Just(isVisible)) { show in
            if show && !reduceMotion {
                burst()
            }
        }
    }

    private func burst() {
        particles = (0..<count).map { _ in
            let angle = Double.random(in: 0..<2 * .pi)
            let distance = CGFloat.random(in: 40...120)
            let offset = CGPoint(
                x: cos(angle) * distance,
                y: sin(angle) * distance
            )
            return (id: UUID(), offset: .zero, opacity: 1)
        }

        for (index, particle) in particles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(index)) {
                let angle = Double.random(in: 0..<2 * .pi)
                let distance = CGFloat.random(in: 40...120)
                withAnimation(.easeOut(duration: 0.8)) {
                    if let idx = particles.firstIndex(where: { $0.id == particle.id }) {
                        particles[idx].offset = CGPoint(
                            x: cos(angle) * distance,
                            y: sin(angle) * distance
                        )
                        particles[idx].opacity = 0
                    }
                }
            }
        }
    }
}

// MARK: - Incentive Screen (Pausa no meio da lição)

struct IncentiveScreen: View {
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var selectedCharacter: MannaCharacter = .paz
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Personagem aleatório comemorando
            CharacterView(
                character: selectedCharacter,
                mood: .cheering,
                size: 160
            )
            .scaleEffect(scale)

            // Mensagem de incentivo
            VStack(spacing: 8) {
                Text("Você está indo muito bem!")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)

                Text("Continue a manter a sequência!")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
            .multilineTextAlignment(.center)

            Spacer()

            Button("Continuar") { onContinue() }
                .buttonStyle(.chunky)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.card.ignoresSafeArea())
        .onAppear {
            selectedCharacter = MannaCharacter.cast.randomElement() ?? .paz
            if !reduceMotion {
                scale = 0.8
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1
                }
            } else {
                scale = 1
            }
        }
    }
}

// MARK: - Correct/Wrong Animation Trigger

/// UUID que muda toda vez que há acerto/erro, disparando animações.
@Observable
final class AnimationTrigger {
    var wrongShakeTrigger = UUID()
    var correctBurstTrigger = UUID()

    func triggerWrong() {
        wrongShakeTrigger = UUID()
    }

    func triggerCorrect() {
        correctBurstTrigger = UUID()
    }
}

#Preview {
    VStack(spacing: 32) {
        StreakBadge(count: 5, isVisible: true)

        VStack(spacing: 12) {
            Text("Progresso")
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.inkMuted)
            AnimatedProgressBar(progress: 0.65, isCorrect: true)
        }

        Text("Animações").font(Theme.font(16, .semibold))
    }
    .padding()
}
