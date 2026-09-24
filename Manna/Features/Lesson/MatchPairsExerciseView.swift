import SwiftUI

/// Exercício: associar pares em duas colunas. Termina sozinho quando todos os pares são feitos.
/// Erros aqui contam como erro, mas não gastam óleo.
struct MatchPairsExerciseView: View {
    let vm: LessonViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 12) {
                ForEach(vm.leftItems.indices, id: \.self) { index in
                    card(
                        text: vm.leftItems[index],
                        selected: vm.leftSelected == index,
                        matched: vm.matchedLeft.contains(index),
                        wrong: vm.wrongFlash?.left == index
                    ) { vm.tapLeft(index) }
                }
            }
            VStack(spacing: 12) {
                ForEach(vm.rightItems.indices, id: \.self) { index in
                    card(
                        text: vm.rightItems[index],
                        selected: vm.rightSelected == index,
                        matched: vm.matchedRight.contains(index),
                        wrong: vm.wrongFlash?.right == index
                    ) { vm.tapRight(index) }
                }
            }
        }
        .padding(.top, 8)
    }

    private func card(text: String, selected: Bool, matched: Bool, wrong: Bool, action: @escaping () -> Void) -> some View {
        let tint: Color = wrong ? Theme.terracotta : (matched ? Theme.olive : Theme.night)
        return Button(action: action) {
            ChoiceCard(isSelected: selected || wrong || matched, tint: tint) {
                Text(text)
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(selected || wrong || matched ? tint : Theme.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .buttonStyle(.plain)
        .disabled(matched)
        .opacity(matched ? 0.55 : 1)
        .modifier(Shake(animatableData: wrong ? 1 : 0))
        .animation(.easeInOut(duration: 0.3), value: wrong)
    }
}

/// Tremidinha horizontal para par errado.
private struct Shake: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 6 * sin(animatableData * .pi * 4), y: 0))
    }
}
