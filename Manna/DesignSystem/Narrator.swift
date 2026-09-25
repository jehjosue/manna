import AVFoundation
import Observation

/// Voz que lê textos (versículos, histórias, exercícios de ouvir).
/// Mantém um único sintetizador vivo — criar um novo a cada fala faz o som ser cortado.
enum Narrator {
    private static let synthesizer: AVSpeechSynthesizer = {
        let s = AVSpeechSynthesizer()
        s.delegate = state
        return s
    }()

    /// Estado observável: `Narrator.state.isSpeaking` anima a boca dos personagens.
    static let state = NarratorState()

    static var isSpeaking: Bool { synthesizer.isSpeaking }

    /// Idioma da voz (segue o idioma do conteúdo; padrão português do Brasil).
    static var voiceLanguage = "pt-BR"

    /// Fala o texto. `onFinish` é chamado quando esta fala termina (não quando é interrompida).
    static func speak(_ text: String, slow: Bool = false, onFinish: (() -> Void)? = nil) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        utterance.rate = slow ? AVSpeechUtteranceDefaultSpeechRate * 0.7 : AVSpeechUtteranceDefaultSpeechRate
        state.pendingFinish = onFinish
        state.currentUtterance = utterance
        synthesizer.speak(utterance)
    }

    static func stop() {
        state.pendingFinish = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}

@Observable
final class NarratorState: NSObject, AVSpeechSynthesizerDelegate {
    private(set) var isSpeaking = false
    @ObservationIgnored fileprivate var pendingFinish: (() -> Void)?
    @ObservationIgnored fileprivate var currentUtterance: AVSpeechUtterance?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            guard utterance === self.currentUtterance else { return }
            let finish = self.pendingFinish
            self.pendingFinish = nil
            finish?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
