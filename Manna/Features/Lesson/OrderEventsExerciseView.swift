import SwiftUI

/// Exercício: ordenar acontecimentos tocando em cartões para montar a sequência correta.
/// Tocar em um cartão da lista embaralhada move para "Sua ordem" numerada; tocar de novo devolve.
struct OrderEventsExerciseView: View {
    let exercise: Exercise
    @Bindable var vm: LessonViewModel
    @State private var shuffledIndices: [Int] = []

    private var availableTokens: [(Int, String)] {
        // Retorna os tokens que ainda não foram selecionados, em ordem embaralhada
        let available = shuffledIndices.filter { !vm.orderSelectedIndices.contains($0) }
        return available.map { ($0, vm.orderEventTokens[$0]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .center, spacing: 12) {
                SheepView(mood: .thinking, size: 100)
                Text("Coloque os eventos em ordem")
                    .font(Theme.font(17, .semibold))
                    .foregroundStyle(Theme.ink)
            }
            .frame(maxWidth: .infinity)

            if let reference = exercise.reference {
                Text(reference)
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)
            }

            // Área "Sua ordem"
            if !vm.orderSelectedIndices.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sua ordem:")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)

                    VStack(spacing: 8) {
                        ForEach(Array(vm.orderSelectedIndices.enumerated()), id: \.offset) { position, tokenIndex in
                            Button {
                                vm.deselectOrderEvent(at: position)
                            } label: {
                                HStack(spacing: 12) {
                                    Text("\(position + 1)")
                                        .font(Theme.font(17, .heavy))
                                        .foregroundStyle(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Theme.wheat))

                                    if tokenIndex < vm.orderEventTokens.count {
                                        Text(vm.orderEventTokens[tokenIndex])
                                            .font(Theme.font(16, .semibold))
                                            .foregroundStyle(Theme.ink)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Theme.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Theme.line, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Banco de cartões (não selecionados, embaralhados)
            VStack(alignment: .leading, spacing: 8) {
                Text("Disponíveis:")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)

                VStack(spacing: 8) {
                    ForEach(availableTokens, id: \.0) { index, token in
                        Button {
                            vm.selectOrderEvent(index)
                        } label: {
                            Text(token)
                                .font(Theme.font(16, .semibold))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Theme.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Theme.line, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            shuffledIndices = (0..<vm.orderEventTokens.count).shuffled()
        }
    }
}
