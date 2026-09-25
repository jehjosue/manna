import SwiftUI

/// Exercício: digitar a palavra/trecho que falta na lacuna.
/// O texto mostra "___" destacado; comparação normalizada contra `answer` e `options`.
struct TypeAnswerExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var userInput: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let speaker = exercise.speaker, let text = exercise.text {
                SpeakerLine(speaker: speaker, text: text)
            } else if let text = exercise.text {
                VStack(alignment: .leading, spacing: 8) {
                    Text(text)
                        .font(Theme.font(20, .semibold))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let reference = exercise.reference {
                Text(reference)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            // Campo de entrada
            VStack(alignment: .leading, spacing: 8) {
                Text("Digite a resposta:")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)

                TextField("", text: $userInput)
                    .font(Theme.font(17, .semibold))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Theme.line, lineWidth: 2)
                    )
                    .focused($isInputFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onAppear { isInputFocused = true }
                    .onChange(of: userInput) { _, _ in
                        vm.typeAnswerInput = userInput
                    }
            }

            Spacer()

            // Botão para pular
            Button("Não posso responder agora") {
                vm.skipCurrent()
            }
            .font(Theme.font(14, .semibold))
            .foregroundStyle(Theme.inkMuted)
            .frame(maxWidth: .infinity)
        }
    }
}
