import AVFoundation
import AudioToolbox
import UIKit

/// Efeitos sonoros do app. Contrato estável: `SoundFX.play(.correct)`.
/// Procura `<nome>.wav` no bundle (ex.: "correct.wav"); se não existir, usa um som do sistema.
enum SoundEffect: String, CaseIterable {
    case tap, correct, wrong, lessonComplete, streak, reward, levelUp, heartbeat
}

enum SoundFX {
    /// Ligado/desligado pelas Configurações (sincronizado com `GameState.soundEnabled` no RootView).
    static var isEnabled = true

    private static var players: [SoundEffect: AVAudioPlayer] = [:]

    static func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        if let player = player(for: effect) {
            player.currentTime = 0
            player.play()
        } else {
            AudioServicesPlaySystemSound(fallbackID(effect))
        }
    }

    private static func player(for effect: SoundEffect) -> AVAudioPlayer? {
        if let cached = players[effect] { return cached }
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        player.prepareToPlay()
        players[effect] = player
        return player
    }

    private static func fallbackID(_ effect: SoundEffect) -> SystemSoundID {
        switch effect {
        case .tap: 1104
        case .correct: 1057
        case .wrong: 1053
        case .lessonComplete, .levelUp: 1025
        case .streak, .reward: 1016
        case .heartbeat: 1103
        }
    }
}

/// Vibrações. Contrato estável: `Haptics.success()`, `.error()`, `.tap()`.
enum Haptics {
    /// Ligado/desligado pelas Configurações (sincronizado com `GameState.hapticsEnabled` no RootView).
    static var isEnabled = true

    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func tap() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
