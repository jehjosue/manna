import SwiftUI

/// Sheet para entrar em um grupo existente usando código.
struct JoinGroupSheet: View {
    @Environment(GameState.self) private var game
    @State private var service = GroupsService.shared

    @Binding var isPresented: Bool

    @State private var code = ""
    @State private var isJoining = false
    @State private var joinedGroup: MannaGroup?
    @State private var errorMessage: String?

    var canJoin: Bool {
        code.count == 6 && !isJoining
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                if let group = joinedGroup {
                    successView(group: group)
                } else {
                    formView
                }
            }
            .navigationTitle("Entrar em Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .disabled(isJoining)
                }
            }
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 24) {
                SheepView(mood: .thinking, size: 100)
                    .padding(.top, 12)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Código do grupo")
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.ink)

                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                ForEach(0..<6, id: \.self) { index in
                                    CodeCharacterBox(
                                        character: index < code.count ? String(code[code.index(code.startIndex, offsetBy: index)]) : "",
                                        isFocused: index == code.count
                                    )
                                }
                            }
                            .frame(height: 56)
                        }

                        TextField("", text: $code)
                            .font(Theme.font(16, .semibold))
                            .textContentType(.none)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .frame(height: 0)
                            .opacity(0)
                            .onChange(of: code) { oldValue, newValue in
                                // Limitar a 6 caracteres e deixar em maiúsculas
                                let filtered = newValue
                                    .uppercased()
                                    .filter { $0.isLetter || $0.isNumber }
                                    .prefix(6)
                                code = String(filtered)
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Onde conseguir o código?")
                            .font(Theme.font(13, .bold))
                            .foregroundStyle(Theme.ink)

                        Text("Peça ao criador do grupo. Ele pode compartilhar o código via chat, mensagem ou quando encontrar pessoalmente.")
                            .font(Theme.font(12, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
                .padding(16)
                .background(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Theme.line, lineWidth: 2)
                )
                .padding(.top, 8)

                if let error = errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(Theme.terracotta)

                            Text(error)
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.terracotta)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Theme.terracottaLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.terracotta, lineWidth: 2)
                    )
                }

                Spacer()

                Button(action: { joinGroup() }) {
                    if isJoining {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Entrar no grupo")
                    }
                }
                .buttonStyle(.chunky)
                .disabled(!canJoin)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Success View

    private func successView(group: MannaGroup) -> some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                SheepView(mood: .cheering, size: 120)

                Text("Bem-vindo ao grupo!")
                    .font(Theme.font(20, .bold))
                    .foregroundStyle(Theme.ink)

                Text(group.name)
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.wheat)
            }

            VStack(spacing: 12) {
                StatRow(label: "Meta semanal", value: "\(Int(group.weeklyGoal)) XP", color: Theme.wheat)
                StatRow(label: "Membros", value: "\(group.members.count)", color: Theme.night)
                StatRow(label: "Sua contribuição", value: "\(Int(game.weeklyXP)) XP", color: Theme.olive)
            }
            .padding(16)
            .background(Theme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Theme.line, lineWidth: 2)
            )
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.olive)
                    Text("Você se juntou com sucesso!")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.olive)
                }

                Text("Vá para a Aba de Ligas para ver seu progresso junto com seus companheiros de estudo.")
                    .font(Theme.font(12, .regular))
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.oliveLight)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.olive, lineWidth: 2)
            )
            .padding(.horizontal, 20)

            Spacer()

            Button(action: { isPresented = false }) {
                Text("Voltar para grupos")
            }
            .buttonStyle(.chunky)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Actions

    private func joinGroup() {
        guard code.count == 6 else { return }

        isJoining = true
        errorMessage = nil

        Task {
            let success = await service.joinGroup(code: code)

            DispatchQueue.main.async {
                isJoining = false

                if success {
                    if let group = service.myGroups.first(where: { $0.code == code }) {
                        self.joinedGroup = group
                        SoundFX.play(.reward)
                        Haptics.success()
                    }
                } else {
                    errorMessage = "Código não encontrado. Verifique e tente novamente."
                    SoundFX.play(.wrong)
                    Haptics.error()
                }
            }
        }
    }
}

// MARK: - Code Character Box

struct CodeCharacterBox: View {
    let character: String
    let isFocused: Bool

    var body: some View {
        VStack {
            Text(character)
                .font(Theme.font(24, .bold))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isFocused ? Theme.wheat : Theme.line, lineWidth: 2)
        )
        .animation(.easeOut(duration: 0.1), value: character)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.font(13, .semibold))
                .foregroundStyle(Theme.inkMuted)

            Spacer()

            Text(value)
                .font(Theme.font(14, .bold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview {
    JoinGroupSheet(isPresented: .constant(true))
        .environment(GameState())
}
