import SwiftUI

/// Resumo de amigos no perfil: nº de amigos, atalhos "Adicionar amigos" e "Mural".
/// View pública autocontida (sem parâmetros obrigatórios).
struct FriendsProfileSection: View {
    private let friends = FriendsService.shared
    @State private var isNavigatingToFriends = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amigos")
                        .font(Theme.font(16, .bold))
                        .foregroundStyle(Theme.ink)

                    HStack(spacing: 8) {
                        VStack(spacing: 2) {
                            Text("\(friends.following.count)")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.manna)

                            Text("Seguindo")
                                .font(Theme.font(10, .regular))
                                .foregroundStyle(Theme.inkMuted)
                        }

                        VStack(spacing: 2) {
                            Text("\(friends.followers.count)")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.bread)

                            Text("Seguidores")
                                .font(Theme.font(10, .regular))
                                .foregroundStyle(Theme.inkMuted)
                        }

                        VStack(spacing: 2) {
                            Text("\(friends.friendStreaks.count)")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.olive)

                            Text("Pão")
                                .font(Theme.font(10, .regular))
                                .foregroundStyle(Theme.inkMuted)
                        }

                        Spacer()
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(12)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 10) {
                NavigationLink(destination: FriendSearchView()) {
                    Label("Adicionar amigos", systemImage: "plus.circle.fill")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.manna, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                NavigationLink(destination: FriendsView()) {
                    Label("Mural", systemImage: "bubble.right.fill")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.terracotta, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .task {
            await friends.refresh()
        }
    }
}

#Preview {
    VStack {
        FriendsProfileSection()
            .padding(16)
    }
    .background(Theme.cream)
}
