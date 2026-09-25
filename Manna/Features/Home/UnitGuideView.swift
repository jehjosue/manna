import SwiftUI

/// Sheet com guia de estudo da unidade: resumo e versículos-chave com áudio.
struct UnitGuideView: View {
    let unit: JourneyUnit
    @Environment(GameState.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var currentlyPlayingVerseId: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                if let guide = unit.guide {
                    VStack(spacing: 0) {
                        // MARK: - Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Guia de Estudo")
                                    .font(Theme.font(20, .heavy))
                                    .foregroundStyle(Theme.ink)
                                Text(unit.title)
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.inkMuted)
                            }
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Theme.ink)
                            }
                        }
                        .padding(16)
                        .background(Theme.card)

                        // MARK: - Conteúdo
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Resumo
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Resumo")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)

                                    Text(guide.summary)
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                        .lineSpacing(2)
                                }

                                Divider()
                                    .padding(.vertical, 8)

                                // Versículos-chave
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Versículos-chave")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)

                                    VStack(spacing: 12) {
                                        ForEach(guide.keyVerses, id: \.reference) { verse in
                                            KeyVerseCard(
                                                verse: verse,
                                                isPlaying: currentlyPlayingVerseId == verse.reference,
                                                soundEnabled: game.soundEnabled,
                                                onPlayAudio: {
                                                    playVerseAudio(verse.text, reference: verse.reference)
                                                }
                                            )
                                        }
                                    }
                                }

                                Spacer(minLength: 20)
                            }
                            .padding(16)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        SheepView(mood: .thinking, size: 100)
                        Text("Nenhum guia disponível")
                            .font(Theme.font(18, .heavy))
                            .foregroundStyle(Theme.ink)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func playVerseAudio(_ text: String, reference: String) {
        currentlyPlayingVerseId = reference
        Narrator.speak(text, slow: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.05) {
            currentlyPlayingVerseId = nil
        }
    }
}

// MARK: - Key Verse Card

struct KeyVerseCard: View {
    let verse: KeyVerse
    let isPlaying: Bool
    let soundEnabled: Bool
    let onPlayAudio: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(verse.reference)
                    .font(Theme.font(13, .heavy))
                    .foregroundStyle(Theme.wheat)
                    .textCase(.uppercase)

                Spacer()

                if soundEnabled {
                    Button(action: onPlayAudio) {
                        Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.night)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Text(verse.text)
                .font(Theme.font(14, .semibold))
                .foregroundStyle(Theme.ink)
                .lineSpacing(1.5)
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
    }
}

#Preview {
    UnitGuideView(
        unit: JourneyUnit(
            id: "unit-1",
            title: "Unidade 1",
            subtitle: "O nascimento de Jesus",
            lessons: [],
            guide: UnitGuide(
                summary: "Nesta unidade aprenderemos sobre o nascimento milagroso de Jesus Cristo, como anunciado pelos profetas e celebrado pelos pastores e sábios.",
                keyVerses: [
                    KeyVerse(reference: "Mateus 1:18-25", text: "Eis como se deu o nascimento de Jesus Cristo..."),
                    KeyVerse(reference: "Lucas 2:1-7", text: "Naqueles dias saiu um decreto de César Augusto...")
                ]
            )
        )
    )
    .environment(GameState())
}
