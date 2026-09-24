import SwiftUI

/// Ícones dos sistemas de gamificação, desenhados em SwiftUI com shapes.
/// Contrato estável: `GameIconView(icon:size:dimmed:)`.
struct GameIconView: View {
    let icon: GameIcon
    var size: CGFloat = 24
    var dimmed: Bool = false

    var body: some View {
        ZStack {
            switch icon {
            case .bread:
                breadIcon

            case .manna:
                mannaIcon

            case .oil:
                oilIcon

            case .rest:
                restIcon

            case .xp:
                xpIcon
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(dimmed ? Theme.lineDark : icon.color)
    }

    // MARK: - Pão/Filão dourado com cortes
    private var breadIcon: some View {
        ZStack {
            // Forma base do pão (arredondado)
            RoundedRectangle(cornerRadius: size * 0.15, style: .continuous)
                .fill(dimmed ? Theme.lineDark : Theme.bread)

            // Cortes diagonais do pão
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .stroke(Theme.cream.opacity(0.4), lineWidth: size * 0.08)
                    .frame(width: size * 0.3, height: size * 0.08)
                    .rotationEffect(.degrees(30))
                    .offset(y: size * 0.05 - CGFloat(i) * size * 0.13)
            }
        }
    }

    // MARK: - Maná: três grãos/flocos brilhantes
    private var mannaIcon: some View {
        ZStack {
            // Grão central (maior)
            Circle()
                .fill(dimmed ? Theme.lineDark : Theme.manna)
                .frame(width: size * 0.5, height: size * 0.5)
                .overlay(
                    Circle()
                        .strokeBorder(Theme.cream.opacity(0.5), lineWidth: size * 0.04)
                )

            // Grão superior-esquerdo
            Circle()
                .fill(dimmed ? Theme.lineDark : Theme.manna)
                .frame(width: size * 0.28, height: size * 0.28)
                .offset(x: -size * 0.2, y: -size * 0.2)
                .overlay(
                    Circle()
                        .strokeBorder(Theme.cream.opacity(0.5), lineWidth: size * 0.03)
                        .offset(x: -size * 0.2, y: -size * 0.2)
                )

            // Grão inferior-direito
            Circle()
                .fill(dimmed ? Theme.lineDark : Theme.manna)
                .frame(width: size * 0.28, height: size * 0.28)
                .offset(x: size * 0.2, y: size * 0.2)
                .overlay(
                    Circle()
                        .strokeBorder(Theme.cream.opacity(0.5), lineWidth: size * 0.03)
                        .offset(x: size * 0.2, y: size * 0.2)
                )

            // Brilho/shimmer no centro
            Circle()
                .fill(Theme.cream.opacity(0.6))
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: -size * 0.08, y: -size * 0.08)
        }
    }

    // MARK: - Lamparina antiga com gota/chama
    private var oilIcon: some View {
        ZStack {
            // Corpo da lamparina (cilíndrico)
            VStack(spacing: 0) {
                Capsule()
                    .fill(dimmed ? Theme.lineDark : Theme.oil)
                    .frame(height: size * 0.25)

                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(dimmed ? Theme.lineDark : Theme.oil)
                    .frame(height: size * 0.5)
            }
            .frame(width: size * 0.4)

            // Alça da lamparina
            Capsule()
                .stroke(dimmed ? Theme.lineDark : Theme.oil, lineWidth: size * 0.06)
                .frame(width: size * 0.25, height: size * 0.35)
                .offset(x: size * 0.15, y: -size * 0.05)

            // Chama no topo (triângulo)
            VStack(spacing: 0) {
                Triangle()
                    .fill(Theme.cream.opacity(0.8))
                    .frame(width: size * 0.12, height: size * 0.15)
                    .offset(y: -size * 0.25)

                Spacer()
            }
        }
    }

    // MARK: - Lua com estrelinhas (pode usar SF Symbol ou desenhar)
    private var restIcon: some View {
        ZStack {
            // Lua crescente
            Circle()
                .fill(dimmed ? Theme.lineDark : Theme.rest)
                .frame(width: size * 0.45, height: size * 0.45)
                .offset(x: -size * 0.05)

            Circle()
                .fill(Theme.cream)
                .frame(width: size * 0.35, height: size * 0.35)
                .offset(x: size * 0.08)

            // Estrelinhas ao redor
            ForEach(0..<3, id: \.self) { i in
                let angle = Double(i) * 120
                let rads = angle * .pi / 180
                let x = size * 0.25 * cos(rads)
                let y = size * 0.25 * sin(rads)

                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.08))
                    .foregroundStyle(dimmed ? Theme.lineDark : Theme.rest)
                    .offset(x: x, y: y)
            }
        }
    }

    // MARK: - Raio (SF Symbol ou desenho)
    private var xpIcon: some View {
        ZStack {
            // Raio desenhado com path
            BoltShape()
                .fill(dimmed ? Theme.lineDark : Theme.wheat)
                .frame(width: size * 0.5, height: size * 0.6)

            // Brilho/halo ao redor
            Circle()
                .strokeBorder(Theme.wheat.opacity(0.3), lineWidth: size * 0.04)
                .frame(width: size * 0.6, height: size * 0.6)
        }
    }
}

/// Shape para desenhar um raio (bolt).
struct BoltShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width
        let h = rect.height

        // Topo do raio
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        // Borda direita superior
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.35))
        // Ponta direita
        path.addLine(to: CGPoint(x: w, y: h * 0.4))
        // Borda esquerda inferior
        path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.65))
        // Ponta esquerda
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.6))
        // Volta ao topo
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))
        path.closeSubpath()

        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                GameIconView(icon: .bread, size: 48)
                Text("Pão").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .manna, size: 48)
                Text("Maná").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .oil, size: 48)
                Text("Óleo").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .rest, size: 48)
                Text("Descanso").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .xp, size: 48)
                Text("XP").font(.caption)
            }
        }

        Divider()

        HStack(spacing: 20) {
            VStack(spacing: 8) {
                GameIconView(icon: .bread, size: 48, dimmed: true)
                Text("Pão").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .manna, size: 48, dimmed: true)
                Text("Maná").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .oil, size: 48, dimmed: true)
                Text("Óleo").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .rest, size: 48, dimmed: true)
                Text("Descanso").font(.caption)
            }
            VStack(spacing: 8) {
                GameIconView(icon: .xp, size: 48, dimmed: true)
                Text("XP").font(.caption)
            }
        }
    }
    .padding()
    .background(Theme.cream)
}
