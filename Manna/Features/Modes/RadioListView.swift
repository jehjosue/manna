import SwiftUI

/// Lista de episódios de rádio.
struct RadioListView: View {
    @Environment(GameState.self) private var game
    @State private var episodes: [RadioEpisode] = []
    @State private var selectedEpisode: RadioEpisode?
    @State private var showRadioPlayer = false
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Cabeçalho
                    VStack(spacing: 8) {
                        HStack {
                            Text("Rádio Manna")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        Text("Episódios bíblicos com Béé e o Narrador")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)

                    if let episodes = episodes.isEmpty ? nil : episodes {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(episodes, id: \.id) { episode in
                                    Button {
                                        selectedEpisode = episode
                                        showRadioPlayer = true
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "mic.fill")
                                                .font(.system(size: 28))
                                                .foregroundStyle(Theme.wheat)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(episode.title)
                                                    .font(Theme.font(18, .heavy))
                                                    .foregroundStyle(Theme.ink)
                                                    .lineLimit(1)
                                                Text(episode.subtitle)
                                                    .font(Theme.font(14, .semibold))
                                                    .foregroundStyle(Theme.inkMuted)
                                            }

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(episode.duration / 60) min")
                                                    .font(Theme.font(12, .semibold))
                                                    .foregroundStyle(Theme.inkMuted)
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundStyle(Theme.wheat)
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
                            Text(loadError ?? "Nenhum episódio encontrado")
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .onAppear { loadEpisodes() }
        .sheet(isPresented: $showRadioPlayer) {
            if let episode = selectedEpisode {
                RadioPlayerView(episode: episode) {
                    showRadioPlayer = false
                }
            }
        }
    }

    private func loadEpisodes() {
        guard let url = Bundle.main.url(forResource: "radio", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loaded = try? JSONDecoder().decode([RadioEpisode].self, from: data) else {
            loadError = "Erro ao carregar episódios"
            return
        }
        episodes = loaded
    }
}

// MARK: - Modelos

struct RadioEpisode: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let duration: Int  // segundos
    let steps: [RadioStep]
}

struct RadioStep: Codable, Hashable {
    enum Kind: String, Codable { case narration, question }
    let kind: Kind
    let speaker: String?
    let text: String
    let options: [String]?
    let answer: String?
}

#Preview {
    RadioListView()
        .environment(GameState())
}
