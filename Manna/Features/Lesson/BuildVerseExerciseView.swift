import SwiftUI

/// Exercício: montar o versículo tocando nos blocos.
/// Tocar no banco leva o bloco para a resposta (deixando um espaço cinza); tocar na resposta devolve.
struct BuildVerseExerciseView: View {
    let exercise: Exercise
    let vm: LessonViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let text = exercise.text {
                SpeakerLine(speaker: exercise.speaker ?? "Béé", text: text)
            }

            // Área de resposta com linhas de pauta
            ZStack(alignment: .topLeading) {
                VStack(spacing: 46) {
                    ForEach(0..<2, id: \.self) { _ in
                        Rectangle().fill(Theme.line).frame(height: 2)
                    }
                }
                .padding(.top, 46)

                FlowLayout(spacing: 8, lineSpacing: 10) {
                    ForEach(Array(vm.built.enumerated()), id: \.element) { position, bankIndex in
                        Button {
                            vm.tapBuilt(at: position)
                        } label: {
                            WordChip(text: vm.bank[bankIndex])
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)

            if let reference = exercise.reference {
                Text(reference)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            // Banco de blocos
            FlowLayout(spacing: 8, lineSpacing: 10) {
                ForEach(vm.bank.indices, id: \.self) { index in
                    let used = vm.isUsed(bankIndex: index)
                    Button {
                        vm.tapBank(index)
                    } label: {
                        WordChip(text: vm.bank[index], isPlaceholder: used)
                    }
                    .buttonStyle(.plain)
                    .disabled(used)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: vm.built)
    }
}

/// Bloco de palavra com sombra 3D; em modo "placeholder" vira um espaço cinza do mesmo tamanho.
struct WordChip: View {
    let text: String
    var isPlaceholder = false

    var body: some View {
        Text(text)
            .font(Theme.font(17, .semibold))
            .foregroundStyle(isPlaceholder ? .clear : Theme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isPlaceholder ? Theme.line : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isPlaceholder ? .clear : Theme.line, lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isPlaceholder ? .clear : Theme.line)
                    .offset(y: 3)
            )
    }
}
