import Speech
import AVFoundation
import Observation

/// Serviço de reconhecimento de fala em tempo real (pt-BR).
@Observable
final class SpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: ContentLanguage.current.voiceCode))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()

    private(set) var isListening = false
    private(set) var transcription = ""
    private(set) var error: String?

    /// Solicita permissões necessárias. Retorna true se concedidas.
    static func requestPermissions() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        let recordAuthorized = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        return speechAuthorized && recordAuthorized
    }

    /// Inicia escuta.
    func startListening() {
        guard !isListening, let recognizer = speechRecognizer, recognizer.isAvailable else {
            error = "Reconhecimento de fala não disponível"
            return
        }

        transcription = ""
        error = nil
        isListening = true

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = "Erro ao configurar áudio"
            isListening = false
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            error = "Não foi possível criar requisição"
            isListening = false
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        do {
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
                recognitionRequest.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self?.transcription = result.bestTranscription.formattedString
                    }
                    if error != nil {
                        self?.stopListening()
                    }
                }
            }
        } catch {
            self.error = "Erro ao iniciar áudio"
            isListening = false
        }
    }

    /// Para de escutar.
    func stopListening() {
        isListening = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
    }

    /// Verifica se a transcrição contém as palavras-chave do versículo (70% de match).
    func checkTranscription(against verseText: String) -> Bool {
        let verseParts = normalize(verseText).split(separator: " ")
        let transcriptParts = normalize(transcription).split(separator: " ")

        let matches = verseParts.filter { part in transcriptParts.contains(where: { $0.hasPrefix(part) }) }
        let accuracy = Double(matches.count) / Double(verseParts.count)
        return accuracy >= 0.7
    }

    private func normalize(_ text: String) -> String {
        let normalized = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return normalized
    }
}
