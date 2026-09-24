import SwiftUI

/// Botão "gordinho" com sombra 3D sólida embaixo, que afunda ao tocar.
struct ChunkyButtonStyle: ButtonStyle {
    var fill: Color = Theme.wheat
    var shadow: Color = Theme.wheatDark
    var foreground: Color = .white

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let face = isEnabled ? fill : Theme.line
        let base = isEnabled ? shadow : Theme.lineDark
        configuration.label
            .font(Theme.font(17, .heavy))
            .textCase(.uppercase)
            .foregroundStyle(isEnabled ? foreground : Theme.inkMuted)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous).fill(face)
            )
            .background(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .fill(base)
                    .offset(y: pressed ? 0 : Theme.depth)
            )
            .offset(y: pressed ? Theme.depth : 0)
            .padding(.bottom, Theme.depth)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

extension ButtonStyle where Self == ChunkyButtonStyle {
    static var chunky: ChunkyButtonStyle { ChunkyButtonStyle() }
    static var chunkyCorrect: ChunkyButtonStyle { ChunkyButtonStyle(fill: Theme.olive, shadow: Theme.oliveDark) }
    static var chunkyWrong: ChunkyButtonStyle { ChunkyButtonStyle(fill: Theme.terracotta, shadow: Theme.terracottaDark) }
    static var chunkyNight: ChunkyButtonStyle { ChunkyButtonStyle(fill: Theme.night, shadow: Theme.nightDark) }
}

/// Cartão branco com borda e sombra 3D sutil — usado em opções de resposta, blocos de palavras etc.
struct ChoiceCard<Content: View>: View {
    var isSelected: Bool = false
    var tint: Color = Theme.night
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.12) : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? tint : Theme.line, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.5) : Theme.line)
                    .offset(y: 3)
            )
    }
}

/// Ícone + número usado na barra do topo (pão diário, maná, óleo).
struct StatBadge: View {
    let icon: GameIcon
    let value: String
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            GameIconView(icon: icon, size: 24, dimmed: dimmed)
            Text(value)
                .font(Theme.font(17, .heavy))
                .foregroundStyle(dimmed ? Theme.lineDark : icon.color)
        }
    }
}

/// Os ícones dos sistemas do jogo.
enum GameIcon {
    case bread   // pão diário (sequência de dias)
    case manna   // moeda
    case oil     // óleo da lamparina (vidas)
    case rest    // dia de descanso (protege a sequência)
    case xp      // pontos de experiência

    var color: Color {
        switch self {
        case .bread: Theme.bread
        case .manna: Theme.manna
        case .oil: Theme.oil
        case .rest: Theme.rest
        case .xp: Theme.wheat
        }
    }
}
