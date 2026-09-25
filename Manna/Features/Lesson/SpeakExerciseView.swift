import SwiftUI
import Speech
import AVFoundation

// MARK: - Exercício de Fala

/// Exercício: ler o versículo em voz alta e usar reconhecimento de fala para validar.
/// Ao parar, acerto se >= 70% das palavras aparecerem na transcrição.
/// Personagem reage ao gravar.
struct SpeakExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var recordingStartTime: Date?
    @State private var showPermissionError = false
    @State private var wasChecked = false
    @State private var selectedCharacter: MannaCharacter

    init(exercise: Exercise, vm: LessonViewModel) {
        self.exercise = exercise
        self.vm = vm
        self._speechRecognizer = State(initialValue: SpeechRecognizer())
        _selectedCharacter = State(initialValue: characterForExercise(exercise.id))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Personagem com instrução
            CharacterDisplay(
                character: selectedCharacter,
                mood: speechRecognizer.isListening ? .thinking : .happy,
                text: "Leia em voz alta o versículo"
            )

            // Exibir o versículo
            if let text = exercise.text {
                VStack(alignment: .center, spacing: 8) {
                    Text(text)
                        .font(Theme.font(18, .semibold))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Theme.line, lineWidth: 2)
                        )

                    if let reference = exercise.reference {
                        Text(reference)
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
            }

            Spacer().frame(height: 12)

            // Status e transcrição
            if !speechRecognizer.transcription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Você disse:")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)

                    Text(speechRecognizer.transcription)
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.card)
                        )
                }
            }

            // Botão principal de gravação
            Button {
                if speechRecognizer.isListening {
                    speechRecognizer.stopListening()
                } else {
                    Task {
                        let authorized = await SpeechRecognizer.requestPermissions()
                        if authorized {
                            speechRecognizer.startListening()
                            recordingStartTime = Date()
                        } else {
                            showPermissionError = true
                        }
                    }
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: speechRecognizer.isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 48))
                    Text(speechRecognizer.isListening ? "Parar e conferir" : "Toque e leia")
                        .font(Theme.font(17, .heavy))
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            }
            .buttonStyle(.chunky)

            Spacer()

            // Botão para pular
            Button("Não posso falar agora") {
                if speechRecognizer.isListening { speechRecognizer.stopListening() }
                vm.skipCurrent()
            }
            .font(Theme.font(14, .semibold))
            .foregroundStyle(Theme.inkMuted)
            .frame(maxWidth: .infinity)
        }
        .alert("Permissão de Microfone", isPresented: $showPermissionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Por favor, permita acesso ao microfone nas Configurações.")
        }
        .onChange(of: speechRecognizer.isListening) { _, isListening in
            if !isListening && recordingStartTime != nil {
                // Usuário parou de gravar
                checkResult()
            }
        }
    }

    private func checkResult() {
        guard let text = exercise.text, !wasChecked else { return }
        wasChecked = true

        let isCorrect = speechRecognizer.checkTranscription(against: text)
        // O LessonView verifica, toca o som e mostra a faixa.
        vm.speechAttempt = isCorrect
    }
}
