import SwiftUI

/// Ligação com Béé (conversa por voz roteirizada).
struct VideoCallView: View {
    @Environment(GameState.self) private var game
    @State private var phoneCalls: [PhoneCall] = []
    @State private var selectedCall: PhoneCall?
    @State private var showCallDetail = false
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Cabeçalho
                    VStack(spacing: 8) {
                        HStack {
                            Text("Ligação com Béé")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        Text("Conversa por voz com nossa mascote favorita")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)

                    if !phoneCalls.isEmpty {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(phoneCalls, id: \.id) { call in
                                    Button {
                                        selectedCall = call
                                        showCallDetail = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "phone.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Theme.terracotta)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(call.title)
                                                    .font(Theme.font(18, .heavy))
                                                    .foregroundStyle(Theme.ink)
                                                    .lineLimit(1)
                                                Text(call.subtitle)
                                                    .font(Theme.font(14, .semibold))
                                                    .foregroundStyle(Theme.inkMuted)
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(call.duration / 60) min")
                                                    .font(Theme.font(12, .semibold))
                                                    .foregroundStyle(Theme.inkMuted)
                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(Theme.inkMuted)
                                            }
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
                            Text(loadError ?? "Nenhuma ligação disponível")
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onAppear { loadPhoneCalls() }
        .sheet(isPresented: $showCallDetail) {
            if let call = selectedCall {
                PhoneCallDetailView(call: call) {
                    showCallDetail = false
                }
            }
        }
    }

    private func loadPhoneCalls() {
        guard let url = Bundle.main.url(forResource: "ligacoes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([PhoneCall].self, from: data) else {
            loadError = "Erro ao carregar ligações"
            return
        }
        phoneCalls = loaded
    }
}

// MARK: - Modelos

struct PhoneCall: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let duration: Int  // segundos
    let turns: [PhoneTurn]
}

struct PhoneTurn: Codable, Hashable {
    let speaker: String
    let text: String
    let isUserTurn: Bool
    let keywordMatches: [String]
}

#Preview {
    VideoCallView()
        .environment(GameState())
}
