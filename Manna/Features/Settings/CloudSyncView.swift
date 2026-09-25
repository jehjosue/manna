import SwiftUI

/// Tela de configuração de sincronização de progresso com iCloud.
struct CloudSyncView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameState.self) private var game
    @State private var cloudSync = CloudProgressSync.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var remoteDate: Date?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    // MARK: - Header
                    HStack {
                        Text("Progresso na Nuvem")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(Theme.ink)
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
                            // MARK: - Status do iCloud
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: cloudSync.isAvailable ? "icloud.fill" : "icloud.slash.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(cloudSync.isAvailable ? Theme.wheat : Theme.inkMuted)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(cloudSync.isAvailable ? "Conectado ao iCloud" : "Desconectado")
                                            .font(Theme.font(16, .heavy))
                                            .foregroundStyle(Theme.ink)
                                        Text("Seu progresso está \(cloudSync.isAvailable ? "sincronizado" : "local apenas")")
                                            .font(Theme.font(12, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(cloudSync.isAvailable ? Theme.oliveLight : Theme.lineDark)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)

                            // MARK: - Informações
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Como funciona")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)
                                    .padding(.horizontal, 16)

                                VStack(alignment: .leading, spacing: 8) {
                                    InfoItemRow(
                                        icon: "📱",
                                        title: "Mesma conta",
                                        description: "Sincroniza em todos os seus dispositivos com a mesma conta iCloud"
                                    )
                                    InfoItemRow(
                                        icon: "🔄",
                                        title: "Automático",
                                        description: "Seu progresso sincroniza automaticamente a cada 5 minutos"
                                    )
                                    InfoItemRow(
                                        icon: "🔒",
                                        title: "Privado",
                                        description: "Seus dados são criptografados e nunca são vistos por nós"
                                    )
                                }
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Última sincronização
                            if let lastSync = cloudSync.lastSyncDate {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Última sincronização")
                                            .font(Theme.font(14, .heavy))
                                            .foregroundStyle(Theme.ink)
                                        Spacer()
                                        Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                                            .font(Theme.font(12, .semibold))
                                            .foregroundStyle(Theme.inkMuted)
                                    }
                                    .padding(12)
                                    .background(Theme.card)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Botões de ação
                            VStack(spacing: 12) {
                                Button {
                                    checkForRemoteProgress()
                                } label: {
                                    if isRestoring {
                                        ProgressView()
                                            .tint(Theme.cream)
                                    } else {
                                        Text("Verificar Progresso na Nuvem")
                                            .font(Theme.font(14, .heavy))
                                    }
                                }
                                .buttonStyle(.chunky)
                                .disabled(!cloudSync.isAvailable || isRestoring)

                                Text("Sincroniza automaticamente cada 5 minutos. Use isto para verificar manualmente se há progresso mais novo.")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.inkMuted)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 16)

                            Spacer(minLength: 32)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Progresso Encontrado", isPresented: $showRestoreAlert) {
                Button("Restaurar", role: .none) {
                    restoreFromCloud()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                if let date = remoteDate {
                    Text("Encontramos um progresso mais recente de \(date.formatted(date: .abbreviated, time: .shortened)). Deseja restaurar? Depois, feche e abra o app para ver o progresso.")
                } else {
                    Text("Seu progresso está atualizado.")
                }
            }
        }
    }

    private func checkForRemoteProgress() {
        isRestoring = true

        cloudSync.checkForRemoteProgress { hasNewer, date in
            remoteDate = hasNewer ? date : nil
            showRestoreAlert = true
            isRestoring = false

            if !hasNewer {
                Haptics.tap()
            }
        }
    }

    private func restoreFromCloud() {
        cloudSync.restoreFromCloud(gameState: game)
        SoundFX.play(.correct)
        Haptics.success()
    }
}

struct InfoItemRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 16))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.font(13, .heavy))
                    .foregroundStyle(Theme.ink)
                Text(description)
                    .font(Theme.font(11, .regular))
                    .foregroundStyle(Theme.inkMuted)
            }
            Spacer()
        }
    }
}

#Preview {
    CloudSyncView()
        .environment(GameState.load())
}
