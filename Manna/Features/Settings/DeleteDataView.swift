import SwiftUI

/// Tela para apagar permanentemente todos os dados do usuário.
struct DeleteDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameState.self) private var game
    @State private var confirmationText = ""
    @State private var showConfirmation = false
    @State private var isDeleting = false

    var canDelete: Bool {
        confirmationText.uppercased() == "APAGAR"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Apagar Dados")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(.red)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.inkMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: - Aviso em destaque
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.red)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Esta ação é irreversível")
                                            .font(Theme.font(16, .heavy))
                                            .foregroundStyle(.red)
                                        Text("Todos os seus dados serão apagados permanentemente")
                                            .font(Theme.font(13, .semibold))
                                            .foregroundStyle(Theme.ink)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                            }
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)

                            // MARK: - Descrição do que será apagado
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Será apagado:")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                VStack(alignment: .leading, spacing: 8) {
                                    DataItemRow(icon: "📚", text: "Seu progresso em todas as jornadas")
                                    DataItemRow(icon: "🏆", text: "Todas as conquistas e badges")
                                    DataItemRow(icon: "🍞", text: "Seu pão diário (sequência)")
                                    DataItemRow(icon: "💰", text: "Maná e óleo acumulados")
                                    DataItemRow(icon: "📊", text: "Histórico de estudos e estatísticas")
                                    DataItemRow(icon: "👤", text: "Seu perfil e configurações")
                                }
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Campo de confirmação
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Digite APAGAR para confirmar")
                                    .font(Theme.font(14, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                TextField("APAGAR", text: $confirmationText)
                                    .font(Theme.font(16, .semibold))
                                    .padding(12)
                                    .background(Theme.card)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                    .textCase(.uppercase)
                                    .foregroundStyle(canDelete ? .red : Theme.inkMuted)
                            }

                            // MARK: - Botão delete (disabled até confirmação)
                            Button(role: .destructive) {
                                showConfirmation = true
                            } label: {
                                if isDeleting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Apagar Tudo")
                                        .font(Theme.font(14, .heavy))
                                }
                            }
                            .buttonStyle(.chunky)
                            .disabled(!canDelete || isDeleting)
                            .padding(.horizontal, 16)
                            .opacity(canDelete ? 1.0 : 0.5)

                            Spacer(minLength: 32)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Confirmar Exclusão",
                isPresented: $showConfirmation,
                presenting: ()
            ) { _ in
                Button("Apagar Permanentemente", role: .destructive) {
                    performDelete()
                }
            } message: { _ in
                Text("Tem certeza? Todos os seus dados serão apagados e não podem ser recuperados.")
            }
        }
    }

    private func performDelete() {
        isDeleting = true

        // Delay para feedback visual
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Apagar todas as preferências do UserDefaults
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
                UserDefaults.standard.synchronize()
            }

            // Apagar app group defaults também
            if let groupDefaults = UserDefaults(suiteName: "group.app.manna.ios") {
                groupDefaults.removePersistentDomain(forName: "group.app.manna.ios")
            }

            SoundFX.play(.correct)
            Haptics.success()
            isDeleting = false

            // Resetar GameState e voltar ao onboarding
            CloudProgressSync.shared.eraseCloud()
            game.resetAll()
            dismiss()
        }
    }
}

struct DataItemRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 16))
            Text(text)
                .font(Theme.font(13, .regular))
                .foregroundStyle(Theme.ink)
            Spacer()
        }
    }
}

#Preview {
    DeleteDataView()
        .environment(GameState.load())
}
