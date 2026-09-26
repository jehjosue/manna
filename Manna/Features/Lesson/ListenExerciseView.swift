import SwiftUI
import AVFoundation

/// Exercício: ouvir um texto em voz alta (pt-BR) e escolher a resposta certa.
/// O texto NÃO é mostrado na tela; apenas as opções como múltipla escolha.
/// Personagem reage ao ouvir.
struct ListenExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var selectedCharacter: MannaCharacter
    @State private var isListening = false

    private var options: [String] { exercise.options ?? [] }
    private var useGrid: Bool { options.count == 4 && options.allSatisfy { $0.count <= 12 } }

    init(exercise: Exercise, vm: LessonViewModel) {
        self.exercise = exercise
        self.vm = vm
        _selectedCharacter = State(initialValue: characterForExercise(exercise.id))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Personagem com instrução no balão
            CharacterDisplay(
                character: selectedCharacter,
                mood: isListening ? .thinking : .happy,
                text: "Ouça e escolha a resposta correta"
            )

            // Botões de áudio
            HStack(spacing: 12) {
                Button {
                    isListening = true
                    speakText(isSlow: false)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 20))
                        Text("Ouvir")
                            .font(Theme.font(17, .heavy))
                            .textCase(.uppercase)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.chunky)

                Button {
                    isListening = true
                    speakText(isSlow: true)
                } label: {
                    Image(systemName: "tortoise.fill")
                        .font(.system(size: 20))
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.chunky)
            }

            Spacer().frame(height: 12)

            // Opções
            if useGrid {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(options, id: \.self) { optionCard($0, minHeight: 72) }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { optionCard($0, minHeight: 0) }
                }
            }

            // Botão para pular
            Button("Não posso ouvir agora") {
                vm.skipCurrent()
            }
            .font(Theme.font(14, .semibold))
            .foregroundStyle(Theme.inkMuted)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .onAppear {
            isListening = true
            speakText(isSlow: false)
        }
        .onDisappear {
            Narrator.stop()
        }
    }

    private func optionCard(_ option: String, minHeight: CGFloat) -> some View {
        Button {
            vm.selectedOption = option
        } label: {
            ChoiceCard(isSelected: vm.selectedOption == option) {
                Text(option)
                    .font(Theme.font(17, .semibold))
                    .foregroundStyle(vm.selectedOption == option ? Theme.night : Theme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: minHeight)
            }
        }
        .buttonStyle(.plain)
    }

    private func speakText(isSlow: Bool) {
        guard let text = exercise.text else { return }
        Narrator.speak(text, slow: isSlow)
    }
}
