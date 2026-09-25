import SwiftUI

/// "Meus versículos": todos os versículos das lições concluídas + versículos aprendidos.
/// Ordenar (recentes/A–Z/livro), buscar, ouvir (Narrator), marcar como "sei de cor".
/// Botão "Praticar estes versículos" abre uma lição sintética.
struct MyVersesView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @State private var versesStore = VersesStore.shared
    @State private var sortBy: VersesStore.SortOption = .recent
    @State private var searchText = ""
    @State private var showLessonView = false
    @State private var practiceLessonVerses: Lesson?
    @State private var showCelebration = false
    @State private var lastResult: LessonResult?

    var filteredVerses: [SavedVerse] {
        let sorted = versesStore.sorted(by: sortBy)
        if searchText.isEmpty {
            return sorted
        }
        return sorted.filter {
            $0.reference.localizedCaseInsensitiveContains(searchText) ||
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("Meus Versículos")
                            .font(Theme.font(28, .heavy))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Busca
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.inkMuted)
                        TextField("Buscar versículos...", text: $searchText)
                            .font(Theme.font(14, .semibold))
                    }
                    .padding(10)
                    .background(Theme.card)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Filtros de ordenação
                    HStack(spacing: 8) {
                        ForEach(VersesStore.SortOption.allCases, id: \.self) { option in
                            Button(action: { sortBy = option }) {
                                Text(option.rawValue)
                                    .font(Theme.font(12, .heavy))
                                    .foregroundStyle(sortBy == option ? .white : Theme.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(sortBy == option ? Theme.olive : Theme.card)
                                    .cornerRadius(6)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    ScrollView {
                        VStack(spacing: 12) {
                            if filteredVerses.isEmpty {
                                VStack(spacing: 12) {
                                    SheepView(mood: .sleepy, size: 80)
                                    Text("Nenhum versículo ainda")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Conclua lições para colecionar versículos")
                                        .font(Theme.font(14, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(32)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(filteredVerses, id: \.id) { verse in
                                        verseCard(verse)
                                    }
                                }
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(16)
                    }

                    // Botão "Praticar"
                    if !versesStore.verses.isEmpty {
                        Button(action: createPracticeLesson) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Praticar estes \(versesStore.verses.count) versículos")
                            }
                            .font(Theme.font(16, .heavy))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(Theme.olive)
                            .cornerRadius(12)
                        }
                        .padding(16)
                    }
                }
            }
        }
        .sheet(isPresented: $showLessonView) {
            if let lesson = practiceLessonVerses {
                LessonView(
                    lesson: lesson,
                    mode: .practice,
                    onFinish: { outcome in
                        lastResult = game.completeActivity(outcome, kind: .practice, baseXP: min(30, outcome.correctCount))
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
    }

    @ViewBuilder
    private func verseCard(_ verse: SavedVerse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verse.reference)
                        .font(Theme.font(12, .heavy))
                        .foregroundStyle(Theme.oil)
                    Text(verse.text)
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(nil)
                }

                Spacer()

                VStack(spacing: 8) {
                    Button(action: { Narrator.speak(verse.text, slow: false) }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(Theme.oil)
                    }

                    Button(action: { versesStore.toggleMemorized(verse.id) }) {
                        Image(systemName: verse.memorized ? "heart.fill" : "heart")
                            .foregroundStyle(verse.memorized ? Theme.terracotta : Theme.line)
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(8)
    }

    private func createPracticeLesson() {
        // Cria uma lição apenas com exercícios dos versículos
        // Para simplificar, usa exercícios de buildVerse/speak disponíveis nas lições concluídas
        guard let journey = content.journey else { return }

        let completedLessons = journey.allLessons.filter { game.isCompleted($0.id) }
        let verseExercises = completedLessons.flatMap { $0.exercises }
            .filter { [ExerciseKind.buildVerse, .typeAnswer, .listen, .speak].contains($0.kind) }

        guard !verseExercises.isEmpty else { return }

        let practice = Array(verseExercises.shuffled().prefix(10))
        let lesson = Lesson(
            id: "practice-my-verses",
            title: "Praticar Meus Versículos",
            icon: "book.fill",
            exercises: practice
        )

        practiceLessonVerses = lesson
        showLessonView = true
    }
}

#Preview {
    MyVersesView()
        .environment(GameState())
        .environment(ContentStore())
}
