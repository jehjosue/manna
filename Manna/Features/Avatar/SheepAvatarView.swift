import SwiftUI

/// Ovelhinha com acessórios equipados (versão customizável).
struct SheepAvatarView: View {
    let size: CGFloat
    @Environment(AvatarStore.self) var avatarStore

    var body: some View {
        ZStack {
            // Base: SheepView com cor de lã customizada
            SheepView(mood: .happy, size: size)
                .foregroundStyle(avatarStore.woolColor.swiftUIColor)

            // Acessórios equipados
            AccessoriesLayer(size: size)
        }
    }
}

private struct AccessoriesLayer: View {
    let size: CGFloat
    @Environment(AvatarStore.self) var avatarStore

    var body: some View {
        ZStack {
            ForEach(avatarStore.equippedAccessories.sorted(), id: \.self) { accessoryId in
                if let type = AccessoryType(rawValue: accessoryId) {
                    accessoryView(for: type, size: size)
                }
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func accessoryView(for type: AccessoryType, size: CGFloat) -> some View {
        switch type {
        case .shepherdHat:
            // Chapéu simples no topo
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                        .fill(Color(hex: 0x8B4513))
                        .frame(height: size * 0.18)

                    RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                        .strokeBorder(Color(hex: 0x654321), lineWidth: size * 0.02)
                        .frame(height: size * 0.18)
                }
                .offset(y: -size * 0.12)

                Spacer()
            }

        case .flowerCrown:
            // Coroa de flores ao redor da cabeça
            ZStack {
                // Flores coloridas
                ForEach(0..<6, id: \.self) { i in
                    let angle = Double(i) * 60
                    let rads = angle * .pi / 180
                    let x = size * 0.25 * cos(rads)
                    let y = size * 0.25 * sin(rads) - size * 0.15

                    VStack(spacing: 2) {
                        Circle()
                            .fill(Color(hex: 0xFF69B4))
                            .frame(width: size * 0.08)

                        Circle()
                            .fill(Color(hex: 0xFFD700))
                            .frame(width: size * 0.06)
                    }
                    .offset(x: x, y: y)
                }
            }

        case .scarf:
            // Cachecol ao redor do pescoço
            VStack(spacing: 0) {
                Spacer()

                Capsule()
                    .fill(Color(hex: 0xE74C3C))
                    .frame(height: size * 0.15)
                    .offset(y: size * 0.05)

                Spacer()
            }
            .padding(.horizontal, size * 0.1)

        case .glasses:
            // Óculos redondos
            HStack(spacing: size * 0.08) {
                Circle()
                    .strokeBorder(Color(hex: 0x2C3E50), lineWidth: size * 0.03)
                    .frame(width: size * 0.12, height: size * 0.12)

                Circle()
                    .strokeBorder(Color(hex: 0x2C3E50), lineWidth: size * 0.03)
                    .frame(width: size * 0.12, height: size * 0.12)
            }
            .offset(y: -size * 0.02)

        case .bow:
            // Laço decorativo
            HStack(spacing: 0) {
                // Lado esquerdo do laço
                RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                    .fill(Color(hex: 0xFF1493))
                    .frame(width: size * 0.1, height: size * 0.08)
                    .rotationEffect(.degrees(-20))

                // Centro
                Circle()
                    .fill(Color(hex: 0xFF1493))
                    .frame(width: size * 0.08)

                // Lado direito do laço
                RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                    .fill(Color(hex: 0xFF1493))
                    .frame(width: size * 0.1, height: size * 0.08)
                    .rotationEffect(.degrees(20))
            }
            .offset(y: size * 0.08)

        case .staff:
            // Cajadinho inclinado
            VStack(spacing: 0) {
                Spacer()

                HStack {
                    // Haste
                    Capsule()
                        .fill(Color(hex: 0x8B7355))
                        .frame(width: size * 0.06, height: size * 0.4)
                        .rotationEffect(.degrees(25), anchor: .topTrailing)

                    Spacer()
                }
                .padding(.leading, size * 0.05)
            }

        case .winterHat:
            // Gorro de inverno com pompom
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: 0xE63946))
                        .frame(width: size * 0.1)

                    RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                        .fill(Color(hex: 0xE63946))
                        .frame(height: size * 0.14)
                }

                Spacer()
            }
            .offset(y: -size * 0.08)

        case .bethlehemStar:
            // Estrela de Belém no topo
            VStack(spacing: 0) {
                Image(systemName: "star.fill")
                    .font(.system(size: size * 0.12, weight: .bold))
                    .foregroundStyle(Color(hex: 0xFFD700))
                    .offset(y: -size * 0.18)

                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        VStack {
            Text("Padrão (Branca)")
                .font(Theme.font(14, .bold))
            SheepAvatarView(size: 120)
        }

        VStack {
            Text("Com Acessórios")
                .font(Theme.font(14, .bold))
            SheepAvatarView(size: 120)
                .environment(AvatarStore.shared)
        }
    }
    .padding()
    .background(Theme.cream)
    .environment(AvatarStore.shared)
}
