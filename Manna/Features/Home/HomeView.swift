import SwiftUI

/// A trilha principal: unidades com cartões coloridos e lições em zigue-zague.
struct HomeView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @State private var route: HomeRoute?
    @State private var showOilEmpty = false
    @State private var showRestNotice = false

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

                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 28) {
                                ForEach(Array(journey.units.enumerated()), id: \.element.id) { unitIndex, unit in
                                    UnitSection(
                                        unit: unit,
                                        unitIndex: unitIndex,
                                        journey: journey,
                                        onLessonTap: open
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

/// Cartão de uma unidade + círculos de lições em zigue-zague.
struct UnitSection: View {
    let unit: JourneyUnit
    let unitIndex: Int
    let journey: Journey
    let onLessonTap: (Lesson) -> Void

    @Environment(GameState.self) private var game

    /// Deslocamento horizontal de cada lição (padrão senoidal).
    private static let zigzag: [CGFloat] = [0, -60, -90, -60, 0, 60, 90, 60]

    private var unitColor: Color { UnitPalette.face(unitIndex) }
    private var unitShadow: Color { UnitPalette.shadow(unitIndex) }

    var body: some View {
        VStack(spacing: 22) {
            unitCard

            VStack(spacing: 18) {
                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                    let offset = Self.zigzag[index % Self.zigzag.count]
                    ZStack {
                        LessonCircle(
                            lesson: lesson,
                            color: unitColor,
                            shadow: unitShadow,
                            isCompleted: game.isCompleted(lesson.id),
                            isCurrent: game.currentLessonId(in: journey) == lesson.id,
                            isLocked: !game.isUnlocked(lesson.id, in: journey),
                            onTap: { onLessonTap(lesson) }
                        )
                        .offset(x: offset)

                        // Ovelhinha no lado oposto do zigue-zague, uma por unidade
                        if index == 2 {
                            SheepView(mood: game.studiedToday ? .happy : .sleepy, size: 70)
                                .offset(x: offset <= 0 ? 110 : -110)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .id(lesson.id)
                }
            }
        }
    }

    private var unitCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(unit.title.uppercased())
                .font(Theme.font(13, .heavy))
                .foregroundStyle(.white.opacity(0.8))
            Text(unit.subtitle)
                .font(Theme.font(22, .heavy))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
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
