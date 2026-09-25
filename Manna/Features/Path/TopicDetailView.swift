import SwiftUI

/// Detalhe de um tema (unidade): resumo do guia, versículos-chave, lista de lições.
struct TopicDetailView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @Environment(\.dismiss) private var dismiss

    let unit: JourneyUnit
    @State private var selectedLesson: Lesson?
    @State private var showLessonView = false
    @State private var syntethicLesson: Lesson?
    @State private var showSkipTest = false
    @State private var readingVerse: KeyVerse?
    @State private var showCelebration = false
    @State private var lastResult: LessonResult?

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    Text(unit.title)
                        .font(Theme.font(20, .heavy))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                }
                .padding(16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Resumo do guia
                        if let guide = unit.guide {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Resumo")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)

                                Text(guide.summary)
                                    .font(Theme.font(14, .semibold))
                                    .foregroundStyle(Theme.inkMuted)
                                    .lineLimit(nil)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Theme.card)
                            .cornerRadius(12)

                            // Versículos-chave
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Versículos-chave")
                                    .font(Theme.font(16, .heavy))
                                    .foregroundStyle(Theme.ink)

                                VStack(spacing: 10) {
                                    ForEach(guide.keyVerses, id: \.reference) { verse in
                                        verseCard(verse)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Theme.card)
                            .cornerRadius(12)
                        }

                        // Lições da unidade
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lições")
                                .font(Theme.font(16, .heavy))
                                .foregroundStyle(Theme.ink)

                            VStack(spacing: 10) {
                                ForEach(unit.lessons, id: \.id) { lesson in
                                    lessonRow(lesson)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Theme.card)
                        .cornerRadius(12)

                        Spacer(minLength: 40)
                    }
                    .padding(16)
                }
            }
        }
        .fullScreenCover(isPresented: $showLessonView) {
            if let lesson = selectedLesson {
                LessonView(
                    lesson: lesson,
                    onFinish: { outcome in
                        let result = game.completeLesson(outcome)
                        lastResult = result
                        showLessonView = false
                        showCelebration = true
                    },
                    onQuit: { showLessonView = false }
                )
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let result = lastResult {
                CelebrationFlowView(result: result) {
                    showCelebration = false
                }
            }
        }
        .fullScreenCover(isPresented: $showSkipTest) {
            UnitSkipTestView(unit: unit) { showSkipTest = false }
        }
    }

    @ViewBuilder
    private func verseCard(_ verse: KeyVerse) -> some View {
        Button(action: { readingVerse = verse; Narrator.speak(verse.text, slow: false) }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(verse.reference)
                        .font(Theme.font(12, .heavy))
                        .foregroundStyle(Theme.oil)

                    Spacer()

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.oil)
                }

                Text(verse.text)
                    .font(Theme.font(13, .semibold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.cream)
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private func lessonRow(_ lesson: Lesson) -> some View {
        Button(action: { selectedLesson = lesson; showLessonView = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(game.isCompleted(lesson.id) ? Theme.olive : Theme.wheat)
                        .frame(width: 40, height: 40)

                    Image(systemName: game.isCompleted(lesson.id) ? "checkmark" : lesson.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(Theme.font(14, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text("\(lesson.exercises.count) exercícios")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(12)
            .background(Theme.cream)
            .cornerRadius(8)
        }
    }
}

#Preview {
    TopicDetailView(
        unit: JourneyUnit(
            id: "u1",
            title: "Unidade 1",
            subtitle: "O Nascimento",
            lessons: [],
            guide: UnitGuide(
                summary: "Nesta unidade aprendemos sobre o nascimento de Jesus.",
                keyVerses: [
                    KeyVerse(reference: "Lucas 2:11", text: "Pois vos nasceu hoje na cidade de Davi um Salvador, que é Cristo, o Senhor.")
                ]
            )
        )
    )
    .environment(GameState())
    .environment(ContentStore())
}
