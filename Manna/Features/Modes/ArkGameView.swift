import SwiftUI

/// Minijogo: Arca de Noé — tocar nos pares de animais.
struct ArkGameView: View {
    @Environment(GameState.self) private var game
    let onFinish: (Int) -> Void

    @State private var timeRemaining = 60
    @State private var score = 0
    @State private var animals: [String] = ["🦁", "🦒", "🐘", "🦓", "🦏", "🦒", "🐘", "🦓", "🦁", "🦏"]
    @State private var shuffledAnimals: [String] = []
    @State private var selectedIndices: Set<Int> = []
    @State private var matchedPairs: Set<Int> = []
    @State private var gameOver = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Theme.card.ignoresSafeArea()

            VStack(spacing: 0) {
                // Cabeçalho
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Theme.line, lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: Double(timeRemaining) / 60)
                                .stroke(Theme.wheat, lineWidth: 4)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear, value: timeRemaining)

                            VStack(spacing: 2) {
                                Text("\(timeRemaining)")
                                    .font(Theme.font(24, .heavy))
                                    .foregroundStyle(Theme.ink)
                                Text("seg")
                                    .font(Theme.font(10, .semibold))
                                    .foregroundStyle(Theme.inkMuted)
                            }
                        }
                        .frame(width: 80, height: 80)
                    }

                    VStack(spacing: 12) {
                        SheepView(mood: .cheering, size: 60)

                        VStack(spacing: 2) {
                            Text("Pares")
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                            Text("\(score)")
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.wheat)
                        }
                    }

                    Spacer()
                }
                .padding(16)

                // Grid de animais
                VStack(spacing: 12) {
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0..<shuffledAnimals.count, id: \.self) { index in
                            Button {
                                toggleSelection(index)
                            } label: {
                                Text(shuffledAnimals[index])
                                    .font(.system(size: 32))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        matchedPairs.contains(index)
                                            ? Theme.olive.opacity(0.2)
                                            : (selectedIndices.contains(index) ? Theme.wheat.opacity(0.3) : Theme.card)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .strokeBorder(
                                                selectedIndices.contains(index) ? Theme.wheat : Theme.line,
                                                lineWidth: 2
                                            )
                                    )
                                    .opacity(matchedPairs.contains(index) ? 0.3 : 1)
                            }
                            .disabled(matchedPairs.contains(index))
                        }
                    }
                    .padding(16)
                }

                Spacer()
            }

            // Game over overlay
            if gameOver {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()

                    VStack(spacing: 20) {
                        SheepView(mood: score > 3 ? .cheering : .thinking, size: 120)

                        Text(score > 3 ? "Muito bom!" : "Tente de novo!")
                            .font(Theme.font(24, .heavy))
                            .foregroundStyle(Theme.ink)

                        Text("\(score) pares encontrados")
                            .font(Theme.font(16, .semibold))
                            .foregroundStyle(Theme.inkMuted)

                        Button(action: { onFinish(score) }) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                    }
                    .padding(24)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(16)
                }
            }
        }
        .onAppear {
            shuffledAnimals = animals.shuffled()
            startTimer()
            Narrator.speak("Toque nos pares de animais! Você tem 60 segundos!", slow: false)
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func toggleSelection(_ index: Int) {
        guard !matchedPairs.contains(index) else { return }

        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)

            if selectedIndices.count == 2 {
                checkMatch()
            }
        }
    }

    private func checkMatch() {
        let indices = Array(selectedIndices).sorted()
        let isMatch = shuffledAnimals[indices[0]] == shuffledAnimals[indices[1]]

        if isMatch {
            score += 1
            matchedPairs.formUnion(indices)
            SoundFX.play(.correct)
            Haptics.success()

            if matchedPairs.count == shuffledAnimals.count {
                endGame()
            }
        } else {
            SoundFX.play(.wrong)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedIndices.removeAll()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        gameOver = true
    }
}

#Preview {
    ArkGameView { score in }
        .environment(GameState())
}
