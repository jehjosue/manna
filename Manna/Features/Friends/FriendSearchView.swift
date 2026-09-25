import SwiftUI

/// Busca de amigos por @username com validação de nome de usuário.
struct FriendSearchView: View {
    private let friends = FriendsService.shared
    private let profile = ProfileIdentityStore.shared
    @State private var searchText = ""
    @State private var searchResults: [MannaPublicProfile] = []
    @State private var isLoading = false
    @State private var showProfileSetup = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search Bar
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.inkMuted)

                    TextField("Buscar @usuário", text: $searchText)
                        .font(Theme.font(16, .regular))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: searchText) { oldValue, newValue in
                            Task {
                                isLoading = true
                                searchResults = await friends.search(username: newValue)
                                isLoading = false
                            }
                        }

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                }
                .padding(10)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if profile.username.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Theme.bread)

                        Text("Escolha seu @usuário antes de adicionar amigos")
                            .font(Theme.font(12, .regular))
                            .foregroundStyle(Theme.bread)

                        Spacer()

                        Button("Configurar") {
                            showProfileSetup = true
                        }
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.manna)
                    }
                    .padding(12)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(16)
            .background(Theme.card)

            // MARK: - Results
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Theme.manna)

                    Text("Buscando...")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if searchText.isEmpty {
                VStack(spacing: 12) {
                    SheepView(mood: .thinking, size: 60)

                    Text("Busque por @usuário")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.ink)

                    Text("Digite para encontrar amigos que usam Manna")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(16)
            } else if searchResults.isEmpty {
                VStack(spacing: 12) {
                    SheepView(mood: .sad, size: 60)

                    Text("Nenhum resultado")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.ink)

                    Text("Tente outro @usuário ou convide um amigo")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(16)
            } else {
                List(searchResults) { result in
                    SearchResultCard(profile: result)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.cream)
            }

            Spacer()
        }
        .background(Theme.cream)
        .navigationTitle("Adicionar amigos")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProfileSetup) {
            ProfileSetupSheet()
        }
    }
}

struct SearchResultCard: View {
    let profile: MannaPublicProfile
    private let friends = FriendsService.shared
    @State private var isFollowing = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile.displayName)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.ink)

                    Spacer()

                    Text(profile.currentLeague)
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.cream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.manna, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                Text("@\(profile.username)")
                    .font(Theme.font(12, .regular))
                    .foregroundStyle(Theme.inkMuted)

                if let status = profile.status {
                    Text(status)
                        .font(Theme.font(11, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }

                HStack(spacing: 8) {
                    FriendStatPill(value: Int(profile.weeklyXP), label: "XP")
                    FriendStatPill(value: Int(profile.bread), label: "Pão")
                    FriendStatPill(value: Int(profile.xpTotal), label: "Total")
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Button(action: { Task { isFollowing = await friends.follow(userId: profile.id) } }) {
                    Image(systemName: isFollowing ? "checkmark.circle.fill" : "plus.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(isFollowing ? Theme.manna : Theme.inkMuted)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: PublicProfileView(profile: profile)) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Profile Setup Sheet (para escolher @username)

struct ProfileSetupSheet: View {
    private let profile = ProfileIdentityStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var errorMessage = ""

    var isValid: Bool {
        ProfileIdentityStore.isValid(username)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Escolha seu @usuário")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("Seu nome único no Manna (3-16 caracteres, sem espaços)")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 8) {
                    HStack {
                        Text("@")
                            .font(Theme.font(16, .semibold))
                            .foregroundStyle(Theme.inkMuted)

                        TextField("username", text: $username)
                            .font(Theme.font(16, .regular))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(12)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if !username.isEmpty && !isValid {
                        Label("Use 3-16 letras, números e _ ou -", systemImage: "exclamationmark.circle.fill")
                            .font(Theme.font(12, .regular))
                            .foregroundStyle(Theme.bread)
                    }
                }

                Spacer()

                Button(action: {
                    Task {
                        profile.username = username
                        dismiss()
                    }
                }) {
                    Text("Pronto")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(isValid ? Theme.manna : Theme.line, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!isValid)
            }
            .padding(16)
            .background(Theme.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FriendSearchView()
    }
}
