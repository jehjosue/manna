import SwiftUI

/// Humores da ovelhinha (mascote).
enum SheepMood: String, CaseIterable {
    case happy       // padrão, sorrindo
    case cheering    // comemorando (braços/patas para cima, pulando)
    case sad         // errou / acabou o óleo
    case thinking    // durante uma pergunta
    case sleepy      // lembrete / dia de descanso
}

/// PLACEHOLDER — será substituído pela ovelhinha desenhada em SwiftUI.
/// Contrato estável: `SheepView(mood:size:)`.
struct SheepView: View {
    var mood: SheepMood = .happy
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle().fill(Color.white)
            Circle().strokeBorder(Theme.line, lineWidth: 3)
            Text("🐑").font(.system(size: size * 0.55))
        }
        .frame(width: size, height: size)
    }
}

/// Balão de fala usado pela ovelhinha e pelos personagens bíblicos.
struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.font(17, .semibold))
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 2)
            )
    }
}
