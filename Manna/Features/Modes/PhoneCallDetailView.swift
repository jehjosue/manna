import SwiftUI

/// Detalhe de uma ligação com Béé (video call).
struct PhoneCallDetailView: View {
    @Environment(GameState.self) private var game
    let call: PhoneCall
    let onClose: () -> Void

    @State private var currentTurnIndex = 0
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var feedback: String?
    @State private var correctTurns = 0
    @State private var totalTurns = 0
    @State private var showCallRings = true
    @State private var callRingScale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentTurn: PhoneTurn? {
        guard currentTurnIndex < call.turns.count else { return nil }
        return call.turns[currentTurnIndex]
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Cabeçalho
                HStack(spacing: 12) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.ink)
                    }

                    ProgressView(value: Double(currentTurnIndex) / Double(call.turns.count))
                        .tint(Theme.terracotta)

                    Spacer()
                }
                .padding(16)
                .background(Theme.card)

                // Conteúdo — tela de chamada
                ZStack {
                    // Fundo degradê
                    LinearGradient(
                        gradient: Gradient(colors: [Theme.terracotta.opacity(0.1), Theme.oil.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 24) {
                        Spacer()

                        // Anéis de chamada (antes de atender)
                        if showCallRings && currentTurnIndex == 0 {
                            ZStack {
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .strokeBorder(Theme.wheat, lineWidth: 2)
                                        .frame(width: 120 + CGFloat(index) * 30, height: 120 + CGFloat(index) * 30)
                                        .opacity(Double(1 - index) * 0.3)
                                        .scaleEffect(callRingScale)
                                }
                            }
                            .onAppear {
                                if !reduceMotion {
                                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                        callRingScale = 1.4
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            showCallRings = false
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        showCallRings = false
                                    }
                                }
                            }
                        }

                        // Avatar de Béé com sincronização de fala
                        CharacterView(
                            character: .bee,
                            mood: currentTurn?.isUserTurn ?? false ? .thinking : .happy,
                            size: 180,
                            isTalking: Narrator.state.isSpeaking && !(currentTurn?.isUserTurn ?? false)
                        )
                        .characterBreathing(size: 180)
                        .characterReaction(currentTurn?.isUserTurn ?? false ? .thinking : .happy)

                        // Nome e status
                        VStack(spacing: 4) {
                            Text("Béé")
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)

                            if currentTurn?.isUserTurn ?? false {
                                Text("Toque e fale")
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.terracotta)
                            } else {
                                Text("Ouvindo...")
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.oil)
                            }
                        }

                        // Fala/transcrição
                        if let turn = currentTurn {
                            VStack(spacing: 12) {
                                Text(turn.text)
                                    .font(Theme.font(16, .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .multilineTextAlignment(.center)
                                    .padding(12)
                                    .background(Theme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                if !speechRecognizer.transcription.isEmpty {
                                    Text("Você disse:")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)

                                    Text(speechRecognizer.transcription)
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.ink)
                                        .padding(12)
                                        .background(Theme.card.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }

                                if let feedback = feedback {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.olive)
                                        Text(feedback)
                                            .font(Theme.font(13, .semibold))
                                            .foregroundStyle(Theme.olive)
                                    }
                                    .padding(10)
                                    .background(Theme.oliveLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }

                        // Botão microfone (se turno do usuário)
                        if currentTurn?.isUserTurn ?? false {
                            Button {
                                if speechRecognizer.isListening {
                                    speechRecognizer.stopListening()
                                    checkResponse()
                                } else {
                                    Task {
                                        let authorized = await SpeechRecognizer.requestPermissions()
                                        if authorized {
                                            speechRecognizer.startListening()
                                        }
                                    }
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: speechRecognizer.isListening ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.system(size: 64))
                                    Text(speechRecognizer.isListening ? "Solte para enviar" : "Toque e fale")
                                        .font(Theme.font(14, .semibold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.chunky)
                            .padding(.horizontal, 24)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 20)
                }

                // Botão continuar
                if feedback != nil || (currentTurn?.isUserTurn ?? false) == false {
                    VStack(spacing: 0) {
                        Divider()
                        Button(action: goNext) {
                            Text("CONTINUAR")
                                .font(Theme.font(17, .heavy))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.chunky)
                        .padding(16)
                    }
                    .background(Theme.cream)
                }
            }
        }
        .onAppear {
            if let turn = currentTurn, !turn.isUserTurn {
                Narrator.speak(turn.text, slow: false)
            }
        }
    }

    private func checkResponse() {
        guard let turn = currentTurn, turn.isUserTurn else { return }

        let transcribed = speechRecognizer.transcription.lowercased()
        let matched = turn.keywordMatches.contains { keyword in
            transcribed.contains(keyword.lowercased())
        }

        if matched {
            correctTurns += 1
            feedback = "Ótima resposta!"
            SoundFX.play(.correct)
        } else {
            feedback = "Tente de novo ou continue."
            SoundFX.play(.wrong)
        }

        totalTurns += 1
    }

    private func goNext() {
        if currentTurnIndex < call.turns.count - 1 {
            feedback = nil
            currentTurnIndex += 1

            if let turn = currentTurn, !turn.isUserTurn {
                Narrator.speak(turn.text, slow: false)
            }
        } else {
            finishCall()
        }
    }

    private func finishCall() {
        let outcome = LessonOutcome(
            lessonId: call.id,
            correctCount: correctTurns,
            totalCount: totalTurns,
            mistakes: max(0, totalTurns - correctTurns)
        )

        let result = game.completeActivity(outcome, kind: .story, baseXP: 30)
        onClose()
    }
}

#Preview {
    PhoneCallDetailView(
        call: PhoneCall(
            id: "test",
            title: "Teste",
            subtitle: "Ligação Teste",
            icon: "phone.fill",
            duration: 120,
            turns: [
                PhoneTurn(speaker: "Béé", text: "Oi!", isUserTurn: false, keywordMatches: [])
            ]
        ),
        onClose: {}
    )
    .environment(GameState())
}
