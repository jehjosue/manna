import AVFoundation

/// Voz que lê textos em português (versículos, histórias, exercícios de ouvir).
/// Mantém um único sintetizador vivo — criar um novo a cada fala faz o som ser cortado.
enum Narrator {
    private static let synthesizer = AVSpeechSynthesizer()

    static var isSpeaking: Bool { synthesizer.isSpeaking }

    static func speak(_ text: String, slow: Bool = false) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = slow ? AVSpeechUtteranceDefaultSpeechRate * 0.7 : AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    static func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
