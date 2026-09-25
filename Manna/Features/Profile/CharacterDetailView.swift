import SwiftUI

/// Tela de detalhe para um personagem individual, mostrando o character falando sua bio via Narrator.
struct CharacterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let character: MannaCharacter

    @State private var isSpeak = false
    @State private var showBio = false
    @StateObject private var narratorState = Narrator.state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Cabeçalho
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Voltar")
                        }
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.ink)
                    }

                    Spacer()
                }
                .padding(16)

                // Conteúdo
                ScrollView {
                    VStack(spacing: 24) {
                        // Personagem grande
                        CharacterView(
                            character: character,
                            mood: narratorState.isSpeaking ? .happy : .thinking,
                            size: 200,
                            isTalking: narratorState.isSpeaking
                        )
                        .characterBreathing(size: 200)
                        .characterReaction(narratorState.isSpeaking ? .happy : .thinking)

                        // Nome e cor de destaque
                        VStack(spacing: 8) {
                            Text(character.displayName)
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)

                            Capsule()
                                .fill(character.accent)
                                .frame(width: 40, height: 6)
                        }

                        // Bio com animação
                        VStack(spacing: 16) {
                            Text(character.bio)
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .opacity(showBio ? 1 : 0)
                                .offset(y: showBio ? 0 : 10)

                            // Botão para ouvir a bio
                            Button(action: speakBio) {
                                HStack(spacing: 8) {
                                    Image(systemName: isSpeak ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                                    Text("Ouvir bio")
                                        .font(Theme.font(14, .heavy))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showBio = true
                    }
                }
            } else {
                showBio = true
            }
        }
    }

    private func speakBio() {
        isSpeak = true
        Narrator.speak(character.bio, slow: false) {
            isSpeak = false
        }
    }
}

#Preview {
    CharacterDetailView(character: .bee)
}
