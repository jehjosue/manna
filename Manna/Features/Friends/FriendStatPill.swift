import SwiftUI

// MARK: - FriendStatPill (componente de estatísticas para amigos)

/// Pequeno card com valor e label para exibir XP/Pão em cards de perfil.
struct FriendStatPill: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(Theme.font(12, .bold))
                .foregroundStyle(Theme.manna)

            Text(label)
                .font(Theme.font(9, .regular))
                .foregroundStyle(Theme.inkMuted)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.line, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
