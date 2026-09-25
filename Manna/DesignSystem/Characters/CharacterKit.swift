import SwiftUI

// MARK: - Elenco do Manna

/// Personagens originais do Manna (11, como o elenco principal de apps de estudo gamificados).
/// Cada um tem um arquivo próprio em DesignSystem/Characters/ com a sua "Figure".
enum MannaCharacter: String, CaseIterable, Identifiable, Codable {
    case bee          // Béé — ovelhinha, mascote (SheepView)
    case paz          // Paz — pomba branca, calma e sábia
    case tito         // Tito — jumentinho brincalhão e teimoso
    case juda         // Judá — leãozinho corajoso
    case vovoEster    // Vovó Ester — avó professora de escola bíblica
    case pastorDavi   // Pastor Davi — pastor jovem que toca violão
    case mirela       // Mirela — adolescente curiosa, fones de ouvido
    case tobias       // Tobias — menino de 9 anos, cheio de energia
    case tioSamuel    // Tio Samuel — pescador de barba, conta histórias
    case ana          // Ana — enfermeira, mãe, doce e prática
    case noemi        // Noemi — universitária de óculos, estudiosa

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bee: "Béé"
        case .paz: "Paz"
        case .tito: "Tito"
        case .juda: "Judá"
        case .vovoEster: "Vovó Ester"
        case .pastorDavi: "Pastor Davi"
        case .mirela: "Mirela"
        case .tobias: "Tobias"
        case .tioSamuel: "Tio Samuel"
        case .ana: "Ana"
        case .noemi: "Noemi"
        }
    }

    var bio: String {
        switch self {
        case .bee: "A ovelhinha que acompanha você em cada passo."
        case .paz: "Uma pomba serena que sempre traz uma palavra de consolo."
        case .tito: "Jumentinho teimoso, mas o amigo mais fiel da turma."
        case .juda: "Leãozinho corajoso que adora os heróis da fé."
        case .vovoEster: "Ensina na escola bíblica há 40 anos e faz o melhor bolo."
        case .pastorDavi: "Pastor jovem, toca violão e ama os Salmos."
        case .mirela: "Adolescente curiosa que pergunta o porquê de tudo."
        case .tobias: "Tem 9 anos, muita energia e decorou todos os livros da Bíblia."
        case .tioSamuel: "Pescador de mãos calejadas e histórias do mar da Galileia."
        case .ana: "Enfermeira e mãe; ora pelos pacientes em cada plantão."
        case .noemi: "Estuda história e adora mapas e línguas antigas."
        }
    }

    /// Cor de destaque (balões de fala, cartões).
    var accent: Color {
        switch self {
        case .bee: Theme.wheat
        case .paz: Theme.rest
        case .tito: Color(hex: 0x9B8468)
        case .juda: Color(hex: 0xE0A526)
        case .vovoEster: Color(hex: 0xB86B9C)
        case .pastorDavi: Theme.night
        case .mirela: Color(hex: 0x8A5CC7)
        case .tobias: Theme.terracotta
        case .tioSamuel: Color(hex: 0x3F8FA3)
        case .ana: Theme.olive
        case .noemi: Color(hex: 0xC7883A)
        }
    }

    /// Elenco que aparece falando nas lições (a Béé fica como mascote e guia).
    static let cast: [MannaCharacter] = allCases.filter { $0 != .bee }
}

/// Expressão do personagem.
enum CharacterMood: String, CaseIterable {
    case happy, cheering, sad, thinking, sleepy, surprised

    var sheepMood: SheepMood {
        switch self {
        case .happy, .surprised: .happy
        case .cheering: .cheering
        case .sad: .sad
        case .thinking: .thinking
        case .sleepy: .sleepy
        }
    }
}

/// Ponto único para desenhar qualquer personagem.
/// `isTalking` mexe a boca (use `Narrator.state.isSpeaking` para sincronizar com a voz).
struct CharacterView: View {
    let character: MannaCharacter
    var mood: CharacterMood = .happy
    var size: CGFloat = 120
    var isTalking: Bool = false

    var body: some View {
        switch character {
        case .bee: SheepView(mood: mood.sheepMood, size: size, isTalking: isTalking)
        case .paz: PazFigure(mood: mood, size: size, isTalking: isTalking)
        case .tito: TitoFigure(mood: mood, size: size, isTalking: isTalking)
        case .juda: JudaFigure(mood: mood, size: size, isTalking: isTalking)
        case .vovoEster: VovoEsterFigure(mood: mood, size: size, isTalking: isTalking)
        case .pastorDavi: PastorDaviFigure(mood: mood, size: size, isTalking: isTalking)
        case .mirela: MirelaFigure(mood: mood, size: size, isTalking: isTalking)
        case .tobias: TobiasFigure(mood: mood, size: size, isTalking: isTalking)
        case .tioSamuel: TioSamuelFigure(mood: mood, size: size, isTalking: isTalking)
        case .ana: AnaFigure(mood: mood, size: size, isTalking: isTalking)
        case .noemi: NoemiFigure(mood: mood, size: size, isTalking: isTalking)
        }
    }
}

// MARK: - Animação compartilhada

/// Pisca os olhos em intervalos irregulares (~3–5 s). Use: `let closed = BlinkClock.isClosed(at: date, seed: 1)`
/// dentro de `TimelineView(.animation)`.
enum BlinkClock {
    static func isClosed(at date: Date, seed: Double) -> Bool {
        let period = 3.7 + seed.truncatingRemainder(dividingBy: 1.3)
        let t = (date.timeIntervalSinceReferenceDate + seed * 0.77).truncatingRemainder(dividingBy: period)
        return t < 0.14
    }

    /// Abertura da boca 0...1 quando está falando (oscilação natural), 0 parado.
    static func mouthOpen(at date: Date, talking: Bool) -> CGFloat {
        guard talking else { return 0 }
        let t = date.timeIntervalSinceReferenceDate
        let v = (sin(t * 14) + sin(t * 23 + 1.3) * 0.6 + 1.6) / 3.2
        return CGFloat(min(max(v, 0), 1))
    }
}

extension View {
    /// Respiração sutil (sobe e desce 2% do tamanho).
    func characterBreathing(size: CGFloat, active: Bool = true) -> some View {
        modifier(BreathingModifier(size: size, active: active))
    }

    /// Reação por humor: pulinhos ao comemorar, tremida na tristeza, inclinação ao pensar.
    func characterReaction(_ mood: CharacterMood) -> some View {
        modifier(ReactionModifier(mood: mood))
    }
}

private struct BreathingModifier: ViewModifier {
    let size: CGFloat
    let active: Bool
    @State private var up = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: 1, y: up && active ? 1.02 : 1, anchor: .bottom)
            .offset(y: up && active ? -size * 0.01 : 0)
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: up)
            .onAppear { up = true }
    }
}

private struct ReactionModifier: ViewModifier {
    let mood: CharacterMood
    @State private var phase = false

    func body(content: Content) -> some View {
        content
            .offset(y: mood == .cheering && phase ? -10 : 0)
            .rotationEffect(.degrees(mood == .thinking ? (phase ? 4 : -2) : 0))
            .offset(x: mood == .sad && phase ? 2 : 0)
            .animation(animation, value: phase)
            .onAppear { phase = true }
            .onChange(of: mood) { _, _ in
                phase = false
                DispatchQueue.main.async { phase = true }
            }
    }

    private var animation: Animation {
        switch mood {
        case .cheering: .spring(response: 0.35, dampingFraction: 0.45).repeatForever(autoreverses: true)
        case .sad: .easeInOut(duration: 0.08).repeatCount(6, autoreverses: true)
        case .thinking: .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
        default: .default
        }
    }
}
