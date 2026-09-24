import SwiftUI

/// Exercício: verdadeiro ou falso.
struct TrueFalseExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text(exercise.statement ?? "")
                .font(Theme.font(21, .heavy))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.cream))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Theme.line, lineWidth: 2)
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
