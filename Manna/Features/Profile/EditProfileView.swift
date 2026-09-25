import SwiftUI

struct EditProfileView: View {
    @Environment(GameState.self) var game
    @Environment(AvatarStore.self) var avatarStore
    @Environment(\.dismiss) var dismiss

    private let identity = ProfileIdentityStore.shared

    @State private var tempName: String = ""
    @State private var tempUsername: String = ""
    @State private var tempBio: String = ""
    @State private var tempStatus: String = ""
    @State private var isShowingAvatarEditor = false
    @State private var isShowingStatusPicker = false
    @State private var usernameError: String = ""

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    Spacer()
                    Text("Editar Perfil")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Color.clear.frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Conteúdo
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar com botão editar
                        VStack(spacing: 12) {
                            ZStack(alignment: .bottomTrailing) {
                                SheepAvatarView(size: 120)

                                Button(action: { isShowingAvatarEditor = true }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Theme.wheat)
                                        .background(Circle().fill(Theme.card))
                                }
                            }

                            Text("Editar Avatar")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.wheat)
                        }
                        .frame(maxWidth: .infinity)

                        // Nome
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.ink)

                            TextField("Seu nome", text: $tempName)
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                                .placeholder(when: tempName.isEmpty) {
                                    Text("Seu nome")
                                        .font(Theme.font(16, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        // @usuário
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("@usuário")
                                    .font(Theme.font(14, .bold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                if !usernameError.isEmpty {
                                    Text(usernameError)
                                        .font(Theme.font(11, .semibold))
                                        .foregroundStyle(.red)
                                }
                            }

                            HStack {
                                Text("@")
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(Theme.inkMuted)

                                TextField("usuário", text: $tempUsername)
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .placeholder(when: tempUsername.isEmpty) {
                                        Text("usuário")
                                            .font(Theme.font(16, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    .onChange(of: tempUsername) { oldValue, newValue in
                                        let sanitized = ProfileIdentityStore.sanitize(newValue)
                                        tempUsername = sanitized
                                        validateUsername()
                                    }
                                Spacer()
                            }
                            .padding(12)
                            .background(Theme.card)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (opcional)")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.ink)

                            TextEditor(text: $tempBio)
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                                .frame(height: 80)
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        // Status
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Status (opcional)")
                                    .font(Theme.font(14, .bold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                            }

                            Button(action: { isShowingStatusPicker = true }) {
                                HStack {
                                    if tempStatus.isEmpty {
                                        Text("Escolher status...")
                                            .font(Theme.font(16, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    } else {
                                        Text(tempStatus)
                                            .font(Theme.font(16, .semibold))
                                            .foregroundStyle(Theme.ink)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Botão Salvar
                        Button(action: saveChanges) {
                            Text("Salvar Mudanças")
                                .font(Theme.font(16, .bold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(.horizontal, 20)

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            tempName = game.userName
            tempUsername = identity.username
            tempBio = identity.bio
            tempStatus = identity.status
        }
        .sheet(isPresented: $isShowingAvatarEditor) {
            AvatarEditorView()
        }
        .sheet(isPresented: $isShowingStatusPicker) {
            StatusPickerSheet(selectedStatus: $tempStatus)
        }
    }

    private func validateUsername() {
        if tempUsername.isEmpty {
            usernameError = ""
        } else if tempUsername.count < 3 {
            usernameError = "Mínimo 3 caracteres"
        } else if !ProfileIdentityStore.isValid(tempUsername) {
            usernameError = "Apenas letras, números e _"
        } else {
            usernameError = ""
        }
    }

    private func saveChanges() {
        guard !tempName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        if !tempUsername.isEmpty {
            guard ProfileIdentityStore.isValid(tempUsername) else { return }
            identity.username = tempUsername
        }

        identity.bio = tempBio.trimmingCharacters(in: .whitespaces)
        identity.status = tempStatus

        game.userName = tempName.trimmingCharacters(in: .whitespaces)
        game.save()

        dismiss()
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    EditProfileView()
        .environment(GameState.load())
        .environment(ProfileIdentityStore.shared)
        .environment(AvatarStore.shared)
}
