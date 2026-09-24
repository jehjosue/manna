import SwiftUI

/// Exercício: escolher 1 entre 2–4 opções.
struct MultipleChoiceExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel

    private var options: [String] { exercise.options ?? [] }
    /// Opções curtas viram grade 2x2; longas, lista.
    private var useGrid: Bool { options.count == 4 && options.allSatisfy { $0.count <= 12 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let speaker = exercise.speaker, let text = exercise.text {
                SpeakerLine(speaker: speaker, text: text)
            } else if let text = exercise.text {
                Text(text)
                    .font(Theme.font(20, .semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let reference = exercise.reference {
                Text(reference)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

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
        }
        .buttonStyle(.plain)
    }
}
