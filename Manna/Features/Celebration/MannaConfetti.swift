import SwiftUI

/// "Maná do céu": grãos dourados caindo pela tela inteira.
struct MannaConfetti: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var fallen = false

    private let particleCount = 36

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Capsule()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 0.7)
                        .rotationEffect(.degrees(fallen ? p.spin : 0))
                        .position(
                            x: p.x * geo.size.width + (fallen ? p.drift : 0),
                            y: fallen ? geo.size.height + 40 : -20 - p.delayOffset
                        )
                        .opacity(fallen ? 0.2 : 1)
                        .animation(.easeIn(duration: p.duration).delay(p.delay), value: fallen)
                }
            }
            .onAppear {
                particles = (0..<particleCount).map { _ in ConfettiParticle.random() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { fallen = true }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat            // 0...1 da largura
    let drift: CGFloat        // deslocamento horizontal ao cair
    let size: CGFloat
    let spin: Double
    let duration: Double
    let delay: Double
    let delayOffset: CGFloat
    let color: Color

    static func random() -> ConfettiParticle {
        ConfettiParticle(
            x: .random(in: 0.02...0.98),
            drift: .random(in: -40...40),
            size: .random(in: 7...13),
            spin: .random(in: -240...240),
            duration: .random(in: 1.8...3.0),
            delay: .random(in: 0...0.8),
            delayOffset: .random(in: 0...80),
            color: [Theme.manna, Theme.wheat, Theme.bread, Color(hex: 0xF4D58D)].randomElement() ?? Theme.manna
        )
    }
}

#Preview {
    ZStack {
        Theme.cream.ignoresSafeArea()
        MannaConfetti()
    }
}
