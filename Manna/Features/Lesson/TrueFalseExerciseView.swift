import SwiftUI

/// Exercício: verdadeiro ou falso.
/// Personagem reage com expressões conforme interage.
struct TrueFalseExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var selectedCharacter: MannaCharacter

    init(exercise: Exercise, vm: LessonViewModel) {
        self.exercise = exercise
        self.vm = vm
        _selectedCharacter = State(initialValue: characterForExercise(exercise.id))
    }

    var body: some View {
        VStack(spacing: 24) {
            // Personagem com a afirmação
            CharacterDisplay(
                character: selectedCharacter,
                mood: vm.selectedBool != nil ? .thinking : .happy,
                text: exercise.statement ?? ""
            )

            HStack(spacing: 12) {
                choice(true, label: "Verdadeiro", icon: "checkmark")
                choice(false, label: "Falso", icon: "xmark")
            }
        }
    }

    private func choice(_ value: Bool, label: String, icon: String) -> some View {
        let selected = vm.selectedBool == value
        return Button {
            vm.selectedBool = value
        } label: {
            ChoiceCard(isSelected: selected) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .heavy))
                    Text(label)
                        .font(Theme.font(18, .heavy))
                }
                .foregroundStyle(selected ? Theme.night : Theme.ink)
                .frame(maxWidth: .infinity, minHeight: 90)
            }
        }
        .buttonStyle(.plain)
    }
}
