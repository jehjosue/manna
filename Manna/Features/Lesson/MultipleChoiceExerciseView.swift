import SwiftUI

/// Exercício: escolher 1 entre 2–4 opções.
/// Exibe um personagem determinístico do elenco com reações ao interagir.
struct MultipleChoiceExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var selectedCharacter: MannaCharacter
    @State private var isPressed = false

    private var options: [String] { exercise.options ?? [] }
    /// Opções curtas viram grade 2x2; longas, lista.
    private var useGrid: Bool { options.count == 4 && options.allSatisfy { $0.count <= 12 } }

    init(exercise: Exercise, vm: LessonViewModel) {
        self.exercise = exercise
        self.vm = vm
        _selectedCharacter = State(initialValue: characterForExercise(exercise.id))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Personagem com balão
            CharacterDisplay(
                character: selectedCharacter,
                mood: vm.selectedOption != nil ? .thinking : .happy,
                text: exercise.text
            )

            if let reference = exercise.reference {
                Text(reference)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            // Opções com animação de press
            if useGrid {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(options, id: \.self) { optionCard($0, minHeight: 72) }
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { optionCard($0, minHeight: 0) }
                }
            }
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
            .pressAndSpring(isPressed: isPressed && vm.selectedOption == option)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            if vm.selectedOption == option {
                withAnimation { isPressed = pressing }
            }
        }) { }
    }
}
