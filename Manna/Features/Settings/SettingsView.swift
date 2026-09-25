import SwiftUI
import StoreKit
import UIKit

/// Tela de configurações com perfil, notificações, som, assinatura e sobre.
struct SettingsView: View {
    @Environment(GameState.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var showNameEditor = false
    @State private var editedName = ""
    @State private var showDailyGoalPicker = false
    @State private var showReminder = false
    @State private var showBiblicalSources = false
    @State private var showAboutLinks = false

    let store = SubscriptionStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                Form {
                    // MARK: - Seção Perfil
                    Section(header: Text("Perfil").font(Theme.font(14, .heavy))) {
                        HStack {
                            Text("Nome")
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text(game.userName.isEmpty ? "Sem nome" : game.userName)
                                .foregroundStyle(Theme.inkMuted)
                                .onTapGesture {
                                    editedName = game.userName
                                    showNameEditor = true
                                }
                        }
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Seção Meta Diária
                    Section(header: Text("Meta Diária").font(Theme.font(14, .heavy))) {
                        Picker("Meta XP", selection: Binding(get: { game.dailyGoalXP }, set: { game.dailyGoalXP = $0 })) {
                            Text("Leve (10 XP)").tag(10)
                            Text("Regular (20 XP)").tag(20)
                            Text("Firme (30 XP)").tag(30)
                            Text("Intenso (50 XP)").tag(50)
                        }
                        .foregroundStyle(Theme.ink)
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Seção Notificações
                    Section(header: Text("Lembrete Diário").font(Theme.font(14, .heavy))) {
                        Toggle("Lembrete ativado", isOn: Binding(
                            get: { game.reminderHour != nil },
                            set: { enabled in
                                if enabled {
                                    NotificationScheduler.shared.requestPermission { granted in
                                        if granted {
                                            game.reminderHour = 20
                                            NotificationScheduler.shared.scheduleDaily(hour: 20)
                                        }
                                    }
                                } else {
                                    game.reminderHour = nil
                                    NotificationScheduler.shared.cancelDaily()
                                }
                            }
                        ))
                        .foregroundStyle(Theme.ink)
                        .tint(Theme.wheat)

                        if let hour = game.reminderHour {
                            HStack {
                                Text("Hora do lembrete")
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Picker("Hora", selection: Binding(
                                    get: { hour },
                                    set: { newHour in
                                        game.reminderHour = newHour
                                        NotificationScheduler.shared.cancelDaily()
                                        NotificationScheduler.shared.scheduleDaily(hour: newHour)
                                    }
                                )) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(String(format: "%02d:00", h)).tag(h)
                                    }
                                }
                                .frame(maxWidth: 100)
                                .foregroundStyle(Theme.wheat)
                            }
                        }
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Seção Som e Vibração
                    Section(header: Text("Feedback").font(Theme.font(14, .heavy))) {
                        Toggle("Som", isOn: Binding(
                            get: { game.soundEnabled },
                            set: { game.soundEnabled = $0; SoundFX.isEnabled = $0 }
                        ))
                        .foregroundStyle(Theme.ink)
                        .tint(Theme.wheat)

                        Toggle("Vibração", isOn: Binding(
                            get: { game.hapticsEnabled },
                            set: { game.hapticsEnabled = $0; Haptics.isEnabled = $0 }
                        ))
                        .foregroundStyle(Theme.ink)
                        .tint(Theme.wheat)
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Seção Manna Plus
                    Section(header: Text("Manna Plus").font(Theme.font(14, .heavy))) {
                        if game.isPlus {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("Assinante ativo")
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text("✓")
                                    .foregroundStyle(Theme.olive)
                            }

                            Button {
                                if #available(iOS 17.2, *) {
                                    Task {
                                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                            try? await AppStore.showManageSubscriptions(in: windowScene)
                                        }
                                    }
                                }
                            } label: {
                                Text("Gerenciar Assinatura")
                                    .font(Theme.font(14, .medium))
                                    .foregroundStyle(Theme.night)
                            }
                        } else {
                            Text("Desbloqueie óleo ilimitado, sem anúncios e muito mais")
                                .foregroundStyle(Theme.inkMuted)
                                .font(Theme.font(13, .regular))

                            Button {
                                // Abrir paywall (implementado no tab Loja)
                            } label: {
                                Text("Assinar Manna Plus")
                                    .font(Theme.font(14, .heavy))
                            }
                            .buttonStyle(.chunky)
                        }

                        Button {
                            Task {
                                await store.restore()
                            }
                        } label: {
                            Text("Restaurar Compras")
                                .font(Theme.font(13, .medium))
                                .foregroundStyle(Theme.night)
                        }
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Seção Sobre
                    Section(header: Text("Sobre").font(Theme.font(14, .heavy))) {
                        HStack {
                            Text("Versão")
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Text(appVersion)
                                .foregroundStyle(Theme.inkMuted)
                        }

                        Button {
                            showBiblicalSources = true
                        } label: {
                            Text("Fontes Bíblicas")
                                .font(Theme.font(14, .medium))
                                .foregroundStyle(Theme.night)
                        }

                        VStack(spacing: 8) {
                            Link(destination: URL(string: "https://manna.app/termos")!) {
                                Text("Termos de Serviço")
                                    .font(Theme.font(13, .medium))
                                    .foregroundStyle(Theme.night)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Link(destination: URL(string: "https://manna.app/privacidade")!) {
                                Text("Política de Privacidade")
                                    .font(Theme.font(13, .medium))
                                    .foregroundStyle(Theme.night)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Link(destination: URL(string: "mailto:contato@manna.app")!) {
                                Text("Contato")
                                    .font(Theme.font(13, .medium))
                                    .foregroundStyle(Theme.night)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .listRowBackground(Theme.card)

                    // MARK: - Botão Apagar Progresso (Debug)
                    #if DEBUG
                    Section {
                        Button("Apagar Progresso", role: .destructive) {
                            game.resetAll()
                        }
                        .font(Theme.font(13, .heavy))
                    }
                    .listRowBackground(Theme.terracottaLight)
                    #endif
                }
                .scrollContentBackground(.hidden)
                .background(Theme.cream)
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNameEditor) {
                EditNameView(name: $editedName, onSave: { newName in
                    game.userName = newName
                    showNameEditor = false
                })
            }
            .sheet(isPresented: $showBiblicalSources) {
                BibleSourcesView()
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

struct EditNameView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    var onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Seu nome", text: $name)
                        .font(Theme.font(16, .semibold))
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(16)

                    Button {
                        onSave(name)
                    } label: {
                        Text("Salvar")
                            .font(Theme.font(14, .heavy))
                    }
                    .buttonStyle(.chunky)
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle("Editar Nome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BibleSourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fontes Bíblicas")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(biblicalSourcesText)
                                .font(Theme.font(12, .regular))
                                .foregroundStyle(Theme.ink)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
            }
        }
    }

    private var biblicalSourcesText: String {
        """
        As lições do Manna utilizam a tradução Almeida Revista e Corrigida (ARC) ou adaptações de domínio público de passagens da Bíblia Sagrada.

        Unidades cobertas:
        • O Nascimento de Jesus (Lucas, Mateus, Marcos)
        • O Início do Ministério (Mateus, João, Marcos, Atos)
        • Ensinos e Milagres (Mateus, Lucas, João)
        • Morte e Ressurreição (Lucas, João, 1 Coríntios, Atos)

        Todas as citações seguem o contexto teológico mainstream cristão, evitando temas denominacionais controversos.

        Para questões de direitos autorais ou acurácia exegética, consulte contato@manna.app.
        """
    }
}

#Preview {
    SettingsView()
        .environment(GameState.load())
}
