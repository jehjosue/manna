import SwiftUI

/// A trilha principal: unidades com cartões coloridos e lições em zigue-zague.
struct HomeView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @State private var route: HomeRoute?
    @State private var showOilEmpty = false
    @State private var showRestNotice = false
    @State private var showSections = false

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            if let error = content.loadError {
                VStack(spacing: 16) {
                    SheepView(mood: .sad, size: 100)
                    Text("Não foi possível carregar as lições")
                        .font(Theme.font(20, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(error)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            } else if let journey = content.journey {
                VStack(spacing: 0) {
                    TopStatsBar()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                    Button { showSections = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text(journey.title)
                                .lineLimit(1)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(Theme.font(13, .bold))
                        .foregroundStyle(Theme.inkMuted)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 6)
                    .sheet(isPresented: $showSections) {
                        SectionsOverviewView(journey: journey)
                    }

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 28) {
                                ForEach(Array(journey.units.enumerated()), id: \.element.id) { unitIndex, unit in
                                    UnitSection(
                                        unit: unit,
                                        unitIndex: unitIndex,
                                        journey: journey,
                                        onLessonTap: open,
                                        onCelebrate: { result in route = .celebration(result) }
                                    )
                                }
                                Spacer(minLength: 40)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .onAppear {
                            if let currentId = game.currentLessonId(in: journey) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation { proxy.scrollTo(currentId, anchor: .center) }
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .fullScreenCover(item: $route) { route in
            switch route {
            case .lesson(let lesson):
                LessonView(
                    lesson: lesson,
                    onFinish: { outcome in
                        let result = game.completeLesson(outcome)
                        self.route = .celebration(result)
                    },
                    onQuit: { self.route = nil }
                )
            case .celebration(let result):
                CelebrationFlowView(result: result, onDone: { self.route = nil })
            }
        }
        .sheet(isPresented: $showOilEmpty) {
            OilEmptySheet()
        }
        .alert("Seu pão diário está a salvo 🕊️", isPresented: $showRestNotice) {
            Button("Amém!") { game.clearRestNotice() }
        } message: {
            let days = game.restUsedNotice ?? 1
            Text(days == 1
                 ? "Você ficou 1 dia sem estudar e seu dia de descanso protegeu sua sequência."
                 : "Você ficou \(days) dias sem estudar e seus dias de descanso protegeram sua sequência.")
        }
        .onAppear {
            if game.restUsedNotice != nil { showRestNotice = true }
        }
    }

    private func open(_ lesson: Lesson) {
        if game.hasOil {
            route = .lesson(lesson)
        } else {
            showOilEmpty = true
        }
    }
}

/// Cartão de uma unidade + círculos de lições em zigue-zague + botões de guia, baú, lendário.
struct UnitSection: View {
    let unit: JourneyUnit
    let unitIndex: Int
    let journey: Journey
    let onLessonTap: (Lesson) -> Void
    let onCelebrate: (LessonResult) -> Void

    @Environment(GameState.self) private var game
    @State private var showGuide = false
    @State private var showTreasure = false
    @State private var showLegendary = false
    @State private var showTopicDetail = false

    /// Deslocamento horizontal de cada lição (padrão senoidal).
    private static let zigzag: [CGFloat] = [0, -60, -90, -60, 0, 60, 90, 60]

    private var unitColor: Color { UnitPalette.face(unitIndex) }
    private var unitShadow: Color { UnitPalette.shadow(unitIndex) }

    private var allLessonsCompleted: Bool {
        unit.lessons.allSatisfy { game.isCompleted($0.id) }
    }

    private var shouldShowTreasure: Bool {
        guard unit.lessons.count >= 3 else { return false }
        let thirdLessonId = unit.lessons[2].id
        return game.isCompleted(thirdLessonId) && !PathRewardsStore.shared.hasTreasureOpened(unit.id)
    }

    var body: some View {
        VStack(spacing: 22) {
            unitCard
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))

            VStack(spacing: 18) {
                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                    let offset = Self.zigzag[index % Self.zigzag.count]
                    let isCompleted = game.isCompleted(lesson.id)
                    let isCurrent = game.currentLessonId(in: journey) == lesson.id

                    ZStack {
                        LessonCircle(
                            lesson: lesson,
                            color: unitColor,
                            shadow: unitShadow,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            isLocked: !game.isUnlocked(lesson.id, in: journey),
                            onTap: { onLessonTap(lesson) }
                        )
                        .offset(x: offset)
                        .scaleEffect(isCompleted ? 1.0 : 1.0, anchor: .center)
                        .onAppear {
                            if isCompleted && index > 0 && !game.isCompleted(unit.lessons[index - 1].id) {
                                // Animação de desbloqueio quando a lição anterior foi concluída
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        // Scale animation trigger
                                    }
                                }
                            }
                        }

                        // Personagem variado por unidade (não só Béé)
                        if index == 2 {
                            let character = selectCharacterForUnit(unitIndex)
                            CharacterView(
                                character: character,
                                mood: game.studiedToday ? .happy : .sleepy,
                                size: 70
                            )
                            .offset(x: offset <= 0 ? 110 : -110)
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .id(lesson.id)

                    // Baú após 3ª lição
                    if index == 2 && shouldShowTreasure {
                        TreasureChestNode(onTap: { showTreasure = true })
                            .frame(maxWidth: .infinity)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                // Nível lendário (após todas concluídas)
                if allLessonsCompleted && !PathRewardsStore.shared.isUnitLegendary(unit.id) {
                    LegendaryLevelNode(unitIndex: unitIndex, onTap: { showLegendary = true })
                        .frame(maxWidth: .infinity)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showGuide) {
            UnitGuideView(unit: unit)
        }
        .sheet(isPresented: $showTopicDetail) {
            TopicDetailView(unit: unit)
        }
        .fullScreenCover(isPresented: $showTreasure) {
            TreasureRewardView(unitId: unit.id, onDone: { showTreasure = false })
        }
        .fullScreenCover(isPresented: $showLegendary) {
            Group {
                if let legendaryLesson = createLegendaryLesson() {
                    if game.hasOil {
                        LessonView(
                            lesson: legendaryLesson,
                            mode: .legendary,
                            onFinish: { outcome in
                                let result = game.completeActivity(outcome, kind: .practice, baseXP: 40)
                                PathRewardsStore.shared.markUnitLegendary(unit.id)
                                showLegendary = false
                                // Espera a tela da lição fechar antes de abrir a celebração.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onCelebrate(result) }
                            },
                            onQuit: { showLegendary = false }
                        )
                    } else {
                        OilEmptySheet()
                            .presentationDetents([.medium])
                    }
                } else {
                    Color.clear
                        .onAppear { showLegendary = false }
                }
            }
        }
    }

    private func selectCharacterForUnit(_ index: Int) -> MannaCharacter {
        // Varia o personagem por unidade, mas Béé aparece ocasionalmente
        let characters: [MannaCharacter] = [.paz, .tito, .juda, .vovoEster, .pastorDavi, .mirela, .tobias, .tioSamuel, .ana, .noemi, .bee]
        return characters[index % characters.count]
    }

    private func createLegendaryLesson() -> Lesson? {
        guard unit.lessons.count >= 3 else { return nil }
        // Pega até 10 exercícios aleatórios da unidade
        var allExercises: [Exercise] = []
        for lesson in unit.lessons {
            allExercises.append(contentsOf: lesson.exercises)
        }
        guard !allExercises.isEmpty else { return nil }
        let selectedExercises = Array(allExercises.shuffled().prefix(min(10, allExercises.count)))
        return Lesson(
            id: "legendary-\(unit.id)",
            title: "Lendário",
            icon: "crown.fill",
            exercises: selectedExercises
        )
    }

    private var unitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.title.uppercased())
                    .font(Theme.font(13, .heavy))
                    .foregroundStyle(.white.opacity(0.8))
                Text(unit.subtitle)
                    .font(Theme.font(22, .heavy))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Botões de ação
            HStack(spacing: 8) {
                // Botão de detalhes (informações)
                Button(action: { showTopicDetail = true }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                }

                // Botão de guia (caderno)
                Button(action: { showGuide = true }) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                }

                // Coroa se lendário completo
                if PathRewardsStore.shared.isUnitLegendary(unit.id) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: 0xFFD700))
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous).fill(unitColor)
        )
        .background(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .fill(unitShadow)
                .offset(y: Theme.depth)
        )
        .padding(.bottom, Theme.depth)
    }
}

// MARK: - Treasure Chest Node

struct TreasureChestNode: View {
    let onTap: () -> Void
    @State private var isShaking = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Baú desenhado
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: 0x8B6F47))
                        .frame(width: 60, height: 45)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(hex: 0xA0826D))
                        .frame(width: 50, height: 12)
                        .offset(y: -16)

                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: 0xFFD700))
                }
                .offset(x: isShaking && !reduceMotion ? ([-2, 2, -2, 2].randomElement() ?? 0) : 0)

                Text("Baú da Unidade")
                    .font(Theme.font(12, .heavy))
                    .foregroundStyle(Theme.ink)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Theme.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
            .onAppear {
                if !reduceMotion {
                    startShaking()
                }
            }
        }
    }

    private func startShaking() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if !reduceMotion {
                withAnimation(.linear(duration: 0.05)) {
                    isShaking.toggle()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            timer.invalidate()
            isShaking = false
        }
    }
}

// MARK: - Legendary Level Node

struct LegendaryLevelNode: View {
    let unitIndex: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: 0xFFD700), Color(hex: 0xFFA500)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(hex: 0x8B4513))
                }

                VStack(spacing: 2) {
                    Text("Nível Lendário")
                        .font(Theme.font(12, .heavy))
                        .foregroundStyle(Theme.ink)

                    Text("Desafio de 10 exercícios")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Theme.card, Theme.cream]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(hex: 0xFFD700), lineWidth: 2)
            )
        }
    }
}

/// Cores alternadas das unidades.
enum UnitPalette {
    static func face(_ index: Int) -> Color {
        [Theme.wheat, Theme.olive, Theme.night][index % 3]
    }
    static func shadow(_ index: Int) -> Color {
        [Theme.wheatDark, Theme.oliveDark, Theme.nightDark][index % 3]
    }
}

/// Um círculo 3D que representa uma lição (concluída, atual ou bloqueada).
struct LessonCircle: View {
    let lesson: Lesson
    let color: Color
    let shadow: Color
    let isCompleted: Bool
    let isCurrent: Bool
    let isLocked: Bool
    let onTap: () -> Void

    @State private var pulse = false

    private let diameter: CGFloat = 76

    var body: some View {
        VStack(spacing: 6) {
            if isCurrent {
                Text("COMEÇAR")
                    .font(Theme.font(13, .heavy))
                    .foregroundStyle(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Theme.line, lineWidth: 2)
                    )
                    .offset(y: pulse ? -3 : 3)
            }

            Button(action: onTap) {
                ZStack {
                    if isCurrent {
                        Circle()
                            .strokeBorder(color.opacity(0.35), lineWidth: 6)
                            .frame(width: diameter + 22, height: diameter + 22)
                            .scaleEffect(pulse ? 1.06 : 0.98)
                    }
                    Circle()
                        .fill(isLocked ? Theme.lineDark : shadow)
                        .frame(width: diameter, height: diameter)
                        .offset(y: 6)
                    Circle()
                        .fill(isLocked ? Theme.line : color)
                        .frame(width: diameter, height: diameter)
                    Image(systemName: symbol)
                        .font(.system(size: isLocked ? 22 : 28, weight: .bold))
                        .foregroundStyle(isLocked ? Theme.lineDark : .white)
                }
                .frame(width: diameter + 24, height: diameter + 24)
            }
            .buttonStyle(LessonPressStyle())
            .disabled(isLocked)
        }
        .onAppear {
            guard isCurrent else { return }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var symbol: String {
        if isLocked { return "lock.fill" }
        if isCompleted { return "checkmark" }
        return lesson.icon
    }
}

/// Afunda o círculo ao tocar.
private struct LessonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Sheet mostrando "Sua lamparina está sem óleo" com opções.
struct OilEmptySheet: View {
    @Environment(GameState.self) private var game
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            SheepView(mood: .sad, size: 90)

            VStack(spacing: 8) {
                Text("Sua lamparina está sem óleo")
                    .font(Theme.font(22, .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Cada erro gasta uma gota. O óleo volta sozinho com o tempo — ou encha agora com maná.")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button("Encher com \(GameState.refillOilCost) maná") {
                    game.refillOilWithManna()
                    dismiss()
                }
                .buttonStyle(.chunky)
                .disabled(game.manna < GameState.refillOilCost)

                Button("Vou esperar") { dismiss() }
                    .buttonStyle(.chunkyNight)
            }
        }
        .padding(24)
        .background(Theme.cream)
        .presentationDetents([.medium])
    }
}

/// Telas abertas em tela cheia a partir da trilha.
enum HomeRoute: Identifiable {
    case lesson(Lesson)
    case celebration(LessonResult)

    var id: String {
        switch self {
        case .lesson(let lesson): "lesson-\(lesson.id)"
        case .celebration(let result): "celebration-\(result.lessonId)"
        }
    }
}

#Preview {
    HomeView()
        .environment(GameState())
        .environment(ContentStore())
}
