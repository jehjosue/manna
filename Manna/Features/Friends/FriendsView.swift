import SwiftUI

/// Tela principal de amigos: navegação entre seguindo, seguidores, mural e pão compartilhado.
struct FriendsView: View {
    private let friends = FriendsService.shared
    @Environment(GameState.self) private var game
    @State private var selectedTab = 0
    @State private var isSearching = false
    @State private var sharedBreadCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header com abas
                VStack(spacing: 12) {
                    HStack {
                        Text("Amigos")
                            .font(Theme.font(24, .bold))
                            .foregroundStyle(Theme.ink)

                        Spacer()

                        NavigationLink(destination: FriendSearchView()) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                                .frame(width: 40, height: 40)
                                .background(Theme.line, in: Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Cards de resumo
                    HStack(spacing: 8) {
                        // Card: nº de amigos
                        VStack(spacing: 6) {
                            Text("\(friends.following.count)")
                                .font(Theme.font(20, .bold))
                                .foregroundStyle(Theme.manna)

                            Text("Seguindo")
                                .font(Theme.font(12, .regular))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(spacing: 6) {
                            Text("\(friends.followers.count)")
                                .font(Theme.font(20, .bold))
                                .foregroundStyle(Theme.bread)

                            Text("Seguidores")
                                .font(Theme.font(12, .regular))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal, 16)

                    // Abas
                    Picker("", selection: $selectedTab) {
                        Text("Seguindo").tag(0)
                        Text("Seguidores").tag(1)
                        Text("Mural").tag(2)
                        Text("🍞 Compartilhado").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .background(Theme.card)

                // MARK: - Conteúdo das abas
                ZStack {
                    if friends.accountStatus == .couldNotDetermine || friends.accountStatus == .noAccount {
                        OfflineStateView(message: "Entre no iCloud para usar amigos")
                    } else {
                        Group {
                            switch selectedTab {
                            case 0:
                                FollowingListView(profiles: friends.following)
                            case 1:
                                FollowersListView(profiles: friends.followers)
                            case 2:
                                FeedView(events: friends.feed)
                            case 3:
                                FriendStreakView(streaks: friends.friendStreaks)
                            default:
                                EmptyView()
                            }
                        }
                        .transition(.opacity)
                    }
                }

                Spacer()
            }
            .background(Theme.cream)
        }
        .task {
            await friends.refresh()
        }
    }
}

// MARK: - Following List

struct FollowingListView: View {
    let profiles: [MannaPublicProfile]

    var body: some View {
        if profiles.isEmpty {
            VStack(spacing: 12) {
                SheepView(mood: .thinking, size: 60)

                Text("Ninguém por aqui ainda")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.ink)

                Text("Busque amigos para seguir")
                    .font(Theme.font(14, .regular))
                    .foregroundStyle(Theme.inkMuted)

                NavigationLink(destination: FriendSearchView()) {
                    Label("Adicionar amigos", systemImage: "plus.circle.fill")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Theme.manna, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(16)
        } else {
            List(profiles) { profile in
                NavigationLink(destination: PublicProfileView(profile: profile)) {
                    FollowingCard(profile: profile)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.cream)
        }
    }
}

struct FollowingCard: View {
    let profile: MannaPublicProfile
    private let friends = FriendsService.shared

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarJSON = profile.avatar {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.manna)
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.inkMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.ink)

                Text("@\(profile.username)")
                    .font(Theme.font(12, .regular))
                    .foregroundStyle(Theme.inkMuted)

                HStack(spacing: 8) {
                    FriendStatPill(value: Int(profile.weeklyXP), label: "XP esta semana")
                    FriendStatPill(value: Int(profile.bread), label: "Pão")
                }
            }

            Spacer()

            VStack(spacing: 6) {
                Button(action: { Task { await friends.unfollow(userId: profile.id) } }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.manna)
                }

                Text(profile.currentLeague)
                    .font(Theme.font(10, .regular))
                    .foregroundStyle(Theme.inkMuted)
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Followers List

struct FollowersListView: View {
    let profiles: [MannaPublicProfile]

    var body: some View {
        if profiles.isEmpty {
            VStack(spacing: 12) {
                SheepView(mood: .sad, size: 60)

                Text("Nenhum seguidor ainda")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.ink)

                Text("Compartilhe seu perfil para ganhar seguidores")
                    .font(Theme.font(14, .regular))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(16)
        } else {
            List(profiles) { profile in
                NavigationLink(destination: PublicProfileView(profile: profile)) {
                    FollowersCard(profile: profile)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.cream)
        }
    }
}

struct FollowersCard: View {
    let profile: MannaPublicProfile

    var body: some View {
        HStack(spacing: 12) {
            if let avatarJSON = profile.avatar {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.manna)
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.inkMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.ink)

                Text("@\(profile.username)")
                    .font(Theme.font(12, .regular))
                    .foregroundStyle(Theme.inkMuted)

                Text(profile.status ?? "—")
                    .font(Theme.font(11, .regular))
                    .foregroundStyle(Theme.inkMuted)
            }

            Spacer()

            Text(profile.currentLeague)
                .font(Theme.font(11, .semibold))
                .foregroundStyle(Theme.bread)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.line, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    FriendsView()
        .environment(GameState())
}
