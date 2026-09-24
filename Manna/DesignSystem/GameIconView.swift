import SwiftUI

/// PLACEHOLDER — será substituído por ícones desenhados em SwiftUI (pão, grãos de maná, lamparina...).
/// Contrato estável: `GameIconView(icon:size:dimmed:)`.
struct GameIconView: View {
    let icon: GameIcon
    var size: CGFloat = 24
    var dimmed: Bool = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.85, weight: .bold))
            .frame(width: size, height: size)
            .foregroundStyle(dimmed ? Theme.lineDark : icon.color)
    }

    private var symbol: String {
        switch icon {
        case .bread: "circle.fill"
        case .manna: "sparkles"
        case .oil: "drop.fill"
        case .rest: "moon.stars.fill"
        case .xp: "bolt.fill"
        }
    }
}
