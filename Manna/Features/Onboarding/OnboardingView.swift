import SwiftUI
import UserNotifications

/// Constante com o nome da mascote.
private let mascotName = "Béé"

/// Máquina de estados para o onboarding em 7 etapas.
private enum OnboardingStep: Equatable {
    case welcome
    case name(String)
    case knowledge(String)
    case dailyGoal(Int)
    case reminder(Int?)
    case characters
    case complete
}

/// Onboarding completo do Manna em estilo Duolingo:
/// 1. Boas-vindas
/// 2. Nome do usuário
/// 3. Conhecimento bíblico
/// 4. Meta diária de XP
/// 5. Lembrete diário
/// 6. Conclusão
struct OnboardingView: View {
    @Environment(GameState.self) private var game
    @State private var step = OnboardingStep.welcome
    @State private var tempName = ""
    @State private var tempKnowledge = ""
    @State private var tempDailyGoal = 20
    @State private var tempReminder: Int? = 20
    @State private var notificationGranted = false

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra de progresso
                if step != .complete {
                    progressBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                } else {
                    Spacer()
                        .frame(height: 16)
                }

                Spacer()

                // Conteúdo da tela atual
                Group {
                    switch step {
                    case .welcome:
                        welcomeScreen
                    case .name:
                        nameScreen
                    case .knowledge:
                        knowledgeScreen
                    case .dailyGoal:
                        dailyGoalScreen
                    case .reminder:
                        reminderScreen
                    case .characters:
                        charactersScreen
                    case .complete:
                        completeScreen
                    }
                }
                .transition(.slide)

                Spacer()

                // Botões de navegação
                if step != .complete {
                    navigationButtons
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Barra de Progresso
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: goBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Voltar")
                    }
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.ink)
                }
                .opacity(canGoBack ? 1 : 0)
                .disabled(!canGoBack)

                Spacer()

                Text("\(stepNumber)/6")
                    .font(Theme.font(14, .semibold))
                    .foregroundStyle(Theme.inkMuted)

                Spacer()
            }

            // Barra visual
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.line)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.wheat)
                        .frame(width: geo.size.width * CGFloat(stepNumber) / 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Telas

    private var welcomeScreen: some View {
        VStack(spacing: 24) {
            SheepView(mood: .cheering, size: 150)

            VStack(spacing: 12) {
                Text("Oi! Eu sou a \(mascotName) 🐑")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)

                Text("Manna")
                    .font(Theme.font(32, .heavy))
                    .foregroundStyle(Theme.wheat)

                Text("O pão nosso de cada dia, em 5 minutos.")
                    .font(Theme.font(18, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var nameScreen: some View {
        VStack(spacing: 24) {
            SpeechBubble(text: "Como posso te chamar?")

            TextField("Digite seu nome...", text: $tempName)
                .padding(12)
                .background(Theme.card)
                .cornerRadius(Theme.corner)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.corner)
                        .strokeBorder(tempName.isEmpty ? Theme.line : Theme.wheat, lineWidth: 2)
                )
                .font(Theme.font(17, .semibold))

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var knowledgeScreen: some View {
        VStack(spacing: 20) {
            SpeechBubble(text: "Quanto você já conhece da Bíblia?")

            VStack(spacing: 12) {
                knowledgeChoice(
                    title: "Estou começando",
                    subtitle: "Sem experiência prévia",
                    value: "iniciante"
                )

                knowledgeChoice(
                    title: "Conheço um pouco",
                    subtitle: "Conheço alguns versículos",
                    value: "conheco-um-pouco"
                )

                knowledgeChoice(
                    title: "Conheço bem",
                    subtitle: "Leio a Bíblia regularmente",
                    value: "conheco-bem"
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func knowledgeChoice(title: String, subtitle: String, value: String) -> some View {
        Button(action: { tempKnowledge = value }) {
            ChoiceCard(isSelected: tempKnowledge == value, tint: Theme.wheat) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.font(17, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(subtitle)
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var dailyGoalScreen: some View {
        VStack(spacing: 20) {
            SpeechBubble(text: "Qual sua meta diária?")

            VStack(spacing: 12) {
                goalChoice(title: "Leve", time: "5 min", xp: 10, value: 10)
                goalChoice(title: "Regular", time: "10 min", xp: 20, value: 20)
                goalChoice(title: "Firme", time: "15 min", xp: 30, value: 30)
                goalChoice(title: "Intenso", time: "20 min", xp: 50, value: 50)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func goalChoice(title: String, time: String, xp: Int, value: Int) -> some View {
        Button(action: { tempDailyGoal = value }) {
            ChoiceCard(isSelected: tempDailyGoal == value, tint: Theme.wheat) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(Theme.font(17, .heavy))
                            .foregroundStyle(Theme.ink)
                        Text(time)
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()

                    StatBadge(icon: .xp, value: "\(xp)", dimmed: false)
                }
            }
        }
    }

    private var reminderScreen: some View {
        VStack(spacing: 20) {
            SpeechBubble(text: "Quer um lembrete diário?")

            VStack(spacing: 12) {
                reminderChoice(title: "Manhã", time: "8h", hour: 8)
                reminderChoice(title: "Almoço", time: "12h", hour: 12)
                reminderChoice(title: "Noite", time: "20h", hour: 20)

                Button(action: { tempReminder = nil }) {
                    ChoiceCard(isSelected: tempReminder == nil, tint: Theme.wheat) {
                        Text("Sem lembrete")
                            .font(Theme.font(17, .heavy))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func reminderChoice(title: String, time: String, hour: Int) -> some View {
        Button(action: { tempReminder = hour }) {
            ChoiceCard(isSelected: tempReminder == hour, tint: Theme.wheat) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(Theme.font(17, .heavy))
                            .foregroundStyle(Theme.ink)
                        Text(time)
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()

                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.wheat)
                }
            }
        }
    }

    private var charactersScreen: some View {
        VStack(spacing: 20) {
            SpeechBubble(text: "Conheça a turma que te acompanha!")

            // Carrossel dos personagens com entrada escalonada
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(MannaCharacter.cast.enumerated()), id: \.element.id) { index, character in
                        VStack(spacing: 8) {
                            CharacterView(character: character, mood: .cheering, size: 70)
                                .characterBreathing(size: 70)

                            Text(character.displayName)
                                .font(Theme.font(11, .bold))
                                .foregroundStyle(Theme.ink)
                                .lineLimit(1)
                        }
                        .frame(width: 90)
                        .padding(8)
                        .background(Theme.card)
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var completeScreen: some View {
        VStack(spacing: 24) {
            CharacterView(character: .bee, mood: .cheering, size: 150)
                .characterBreathing(size: 150)
                .characterReaction(.cheering)

            VStack(spacing: 12) {
                Text("Tudo pronto, \(tempName.isEmpty ? "amigo" : tempName)! ")
                    .font(Theme.font(24, .heavy))
                    .foregroundStyle(Theme.ink)

                Text("Sua jornada começa em Belém ⭐")
                    .font(Theme.font(18, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Navegação

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button(action: goNext) {
                Text(isLastStep ? "COMEÇAR" : "CONTINUAR")
                    .font(Theme.font(17, .heavy))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.chunky)
            .disabled(!canContinue)
        }
    }

    private func goBack() {
        withAnimation(.default) {
            switch step {
            case .welcome: break
            case .name: step = .welcome
            case .knowledge: step = .name(tempName)
            case .dailyGoal: step = .knowledge(tempKnowledge)
            case .reminder: step = .dailyGoal(tempDailyGoal)
            case .characters: step = .reminder(tempReminder)
            case .complete: step = .characters
            }
        }
    }

    private func goNext() {
        withAnimation(.default) {
            switch step {
            case .welcome:
                step = .name("")
            case .name:
                step = .knowledge("")
            case .knowledge:
                step = .dailyGoal(20)
            case .dailyGoal:
                step = .reminder(20)
            case .reminder:
                step = .characters
            case .characters:
                // Solicita permissão e agenda notificação
                if let reminderHour = tempReminder {
                    NotificationScheduler.shared.requestPermission { granted in
                        if granted {
                            NotificationScheduler.shared.scheduleDaily(hour: reminderHour)
                        }
                    }
                }
                step = .complete
            case .complete:
                // Finaliza onboarding
                game.finishOnboarding(
                    name: tempName,
                    dailyGoalXP: tempDailyGoal,
                    knowledgeLevel: tempKnowledge,
                    reminderHour: tempReminder
                )
            }
        }
    }

    // MARK: - Lógica

    private var stepNumber: Int {
        switch step {
        case .welcome: 1
        case .name: 2
        case .knowledge: 3
        case .dailyGoal: 4
        case .reminder: 5
        case .characters: 6
        case .complete: 7
        }
    }

    private var canGoBack: Bool {
        stepNumber > 1
    }

    private var canContinue: Bool {
        switch step {
        case .welcome: true
        case .name: !tempName.trimmingCharacters(in: .whitespaces).isEmpty
        case .knowledge: !tempKnowledge.isEmpty
        case .dailyGoal: true
        case .reminder: true
        case .characters: true
        case .complete: true
        }
    }

    private var isLastStep: Bool {
        step == .complete
    }
}

#Preview {
    OnboardingView()
        .environment(GameState())
}
