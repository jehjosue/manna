import SwiftUI

/// Desafio relâmpago: 60 segundos, rodadas de associar pares.
struct ChallengeView: View {
    let pairs: [(left: String, right: String)]
    let onFinish: (Int) -> Void  // passa o número de pares acertados

    @State private var timeRemaining: Int = {
        let baseTime = 60
        let boost = BoostInventoryStore.shared.consumeTimerBoost() ? 15 : 0
        return baseTime + boost
    }()
    @State private var baseDuration = 60
    @State private var pairsMatched = 0
    @State private var leftSelected: Int?
    @State private var rightSelected: Int?
    @State private var matchedLeft: Set<Int> = []
    @State private var matchedRight: Set<Int> = []
    @State private var wrongFlash: (left: Int, right: Int)?
    @State private var isFinished = false
    @State private var timer: Timer?

    @State private var leftItems: [String] = []
    @State private var rightItems: [String] = []

    var body: some View {
        ZStack {
            Theme.card.ignoresSafeArea()

            VStack(spacing: 0) {
                // Topo: cronômetro circular e placar
                HStack(spacing: 24) {
                    // Cronômetro
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Theme.line, lineWidth: 6)
                            Circle()
                                .trim(from: 0, to: Double(timeRemaining) / Double(baseDuration))
                                .stroke(Theme.wheat, lineWidth: 6)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear, value: timeRemaining)

                            VStack(spacing: 2) {
                                Text("\(timeRemaining)")
                                    .font(Theme.font(28, .heavy))
                                    .foregroundStyle(Theme.ink)
                                Text("seg")
                                    .font(Theme.font(12, .semibold))
                                    .foregroundStyle(Theme.inkMuted)
                            }
                        }
                        .frame(width: 100, height: 100)
                    }

                    // Placar
                    VStack(spacing: 12) {
                        SheepView(mood: .cheering, size: 80)
                        VStack(spacing: 4) {
                            Text("Pares")
                                .font(Theme.font(12, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                            Text("\(pairsMatched)")
                                .font(Theme.font(32, .heavy))
                                .foregroundStyle(Theme.wheat)
                        }

                        // Indicador de boost
                        if timeRemaining > 60 {
                            Text("+15s")
                                .font(Theme.font(11, .heavy))
                                .foregroundStyle(Theme.manna)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.manna.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }

                    Spacer()
                }
                .padding(20)

                Spacer()

                // Pares (lado esquerdo)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<leftItems.count, id: \.self) { index in
                            let isMatched = matchedLeft.contains(index)
                            let isSelected = leftSelected == index

                            Button {
                                if !isMatched {
                                    leftSelected = isSelected ? nil : index
                                    checkPair()
                                }
                            } label: {
                                Text(leftItems[index])
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(isMatched ? Theme.inkMuted : Theme.ink)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isMatched ? Theme.line : (isSelected ? Theme.wheat.opacity(0.2) : Theme.card))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(
                                                wrongFlash?.left == index ? Theme.terracotta : (isSelected ? Theme.wheat : Theme.line),
                                                lineWidth: 2
                                            )
                                    )
                                    .opacity(isMatched ? 0.5 : 1)
                            }
                            .disabled(isMatched)
                        }
                    }
                    .padding(16)
                }

                Spacer()

                // Pares (lado direito)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<rightItems.count, id: \.self) { index in
                            let isMatched = matchedRight.contains(index)
                            let isSelected = rightSelected == index

                            Button {
                                if !isMatched {
                                    rightSelected = isSelected ? nil : index
                                    checkPair()
                                }
                            } label: {
                                Text(rightItems[index])
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(isMatched ? Theme.inkMuted : Theme.ink)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isMatched ? Theme.line : (isSelected ? Theme.olive.opacity(0.2) : Theme.card))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(
                                                wrongFlash?.right == index ? Theme.terracotta : (isSelected ? Theme.olive : Theme.line),
                                                lineWidth: 2
                                            )
                                    )
                                    .opacity(isMatched ? 0.5 : 1)
                            }
                            .disabled(isMatched)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            setupPairs()
            startChallenge()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func setupPairs() {
        let shuffled = pairs.shuffled()
        leftItems = shuffled.map(\.left)
        rightItems = shuffled.map(\.right).shuffled()
    }

    private func startChallenge() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endChallenge()
            }
        }
    }

    private func checkPair() {
        guard let l = leftSelected, let r = rightSelected else { return }

        let isMatch = pairs.contains { $0.left == leftItems[l] && $0.right == rightItems[r] }
        if isMatch {
            matchedLeft.insert(l)
            matchedRight.insert(r)
            pairsMatched += 1
            Haptics.success()
            SoundFX.play(.correct)
            leftSelected = nil
            rightSelected = nil
        } else {
            Haptics.error()
            SoundFX.play(.wrong)
            wrongFlash = (l, r)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongFlash = nil
                leftSelected = nil
                rightSelected = nil
            }
        }
    }

    private func endChallenge() {
        timer?.invalidate()
        isFinished = true
        onFinish(pairsMatched)
    }
}

#Preview {
    ChallengeView(
        pairs: [
            ("Adão", "Primeiro homem"),
            ("Noé", "Arca"),
            ("Abraão", "Pai da fé"),
        ]
    ) { score in
        print("Score: \(score)")
    }
    .environment(GameState())
}
