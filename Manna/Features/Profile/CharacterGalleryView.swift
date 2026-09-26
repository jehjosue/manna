import SwiftUI

/// Galeria completa dos 11 personagens com animação de entrada escalonada.
struct CharacterGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateChars = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Título
                        VStack(spacing: 8) {
                            Text("Conheça a Turma")
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)

                            Text("11 personagens para te acompanhar")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        // Grade de personagens com animação
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(MannaCharacter.cast.enumerated()), id: \.element) { index, character in
                                NavigationLink(destination: CharacterDetailView(character: character)) {
                                    CharacterCardView(character: character)
                                        .opacity(animateChars ? 1 : 0)
                                        .offset(y: animateChars ? 0 : 20)
                                        .animation(
                                            reduceMotion ? .none : .easeOut(duration: 0.5).delay(Double(index) * 0.06),
                                            value: animateChars
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Voltar")
                        }
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.ink)
                    }
                }
            }
            .onAppear {
                if !reduceMotion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        animateChars = true
                    }
                } else {
                    animateChars = true
                }
            }
        }
    }
}

/// Card individual para cada personagem na galeria.
struct CharacterCardView: View {
    let character: MannaCharacter
    @State private var isCheering = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            // Personagem com aceno (cheering)
            CharacterView(character: character, mood: isCheering ? .cheering : .happy, size: 90)
                .characterBreathing(size: 90)
                .characterReaction(isCheering ? .cheering : .happy)

            // Nome
            Text(character.displayName)
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Bio
            Text(character.bio)
                .font(Theme.font(11, .semibold))
                .foregroundStyle(Theme.inkMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Theme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(character.accent, lineWidth: 1)
        )
        .onHover { isHovering in
            if isHovering && !reduceMotion {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCheering = true
                }
            }
        }
    }
}

#Preview {
    CharacterGalleryView()
}
