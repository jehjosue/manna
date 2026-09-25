import SwiftUI
import Observation

/// Exibe um personagem com balão de fala, sincronizado com o Narrator.
/// O personagem interage: pensa enquanto responde, comemora acertando, fica triste em erro.
struct CharacterDisplay: View {
    let character: MannaCharacter
    let mood: CharacterMood
    let text: String?
    var size: CGFloat = 120

    var body: some View {
        TimelineView(.animation) { timeline in
            let narrator = Narrator.state

            VStack(alignment: .center, spacing: 12) {
                CharacterView(
                    character: character,
                    mood: mood,
                    size: size,
                    isTalking: narrator.isSpeaking
                )
                .characterBreathing(size: size, active: mood != .sad)
                .characterReaction(mood)

                if let text = text {
                    SpeechBubble(text: text)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        CharacterDisplay(
            character: .paz,
            mood: .thinking,
            text: "Qual é a resposta correta?"
        )

        CharacterDisplay(
            character: .juda,
            mood: .cheering,
            text: "Parabéns, acertou!"
        )

        CharacterDisplay(
            character: .tito,
            mood: .sad,
            text: "Tente novamente!"
        )
    }
    .padding()
}
