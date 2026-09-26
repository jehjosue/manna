import SwiftUI

/// Conversa com personagens bíblicos (roleplay).
struct RoleplayView: View {
    @Environment(GameState.self) private var game
    @State private var conversations: [Conversation] = []
    @State private var selectedConversation: Conversation?
    @State private var showConversationDetail = false
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Cabeçalho
                    VStack(spacing: 8) {
                        HStack {
                            Text("Conversa com Personagens")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        Text("Diálogos interativos com figuras bíblicas")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)

                    if !conversations.isEmpty {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(conversations, id: \.id) { conversation in
                                    Button {
                                        selectedConversation = conversation
                                        showConversationDetail = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Theme.olive)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(conversation.title)
                                                    .font(Theme.font(18, .heavy))
                                                    .foregroundStyle(Theme.ink)
                                                    .lineLimit(1)
                                                Text(conversation.subtitle)
                                                    .font(Theme.font(14, .semibold))
                                                    .foregroundStyle(Theme.inkMuted)
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(Theme.inkMuted)
                                        }
                                        .padding(16)
                                        .background(Theme.card)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                            }
                            .padding(16)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.terracotta)
                            Text(loadError ?? "Nenhuma conversa encontrada")
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onAppear { loadConversations() }
        .sheet(isPresented: $showConversationDetail) {
            if let conversation = selectedConversation {
                ConversationDetailView(conversation: conversation) {
                    showConversationDetail = false
                }
            }
        }
    }

    private func loadConversations() {
        guard let url = ContentLanguage.url(for: "conversas"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([Conversation].self, from: data) else {
            loadError = "Erro ao carregar conversas"
            return
        }
        conversations = loaded
    }
}

// MARK: - Modelos

struct Conversation: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let reference: String
    let turns: [ConversationTurn]
}

struct ConversationTurn: Codable, Hashable {
    let speaker: String
    let text: String
    let isUserTurn: Bool
    let options: [String]?
}

#Preview {
    RoleplayView()
        .environment(GameState())
}
