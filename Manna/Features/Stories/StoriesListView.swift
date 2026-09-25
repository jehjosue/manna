import SwiftUI

/// Grade de histórias: ícone, título, referência, selo de conclusão.
/// Histórias liberam em ordem ou quando completadas 3 lições a mais que o índice.
struct StoriesListView: View {
    @Environment(GameState.self) private var game
    @Environment(ContentStore.self) private var content
    @State private var selectedStory: Story?
    @State private var showCelebration = false
    @State private var lastResult: LessonResult?

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Histórias")
                            .font(Theme.font(32, .heavy))
                            .foregroundStyle(Theme.ink)
                        Text("Leia as histórias bíblicas")
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                    // MARK: - Grade de histórias
                    if content.stories.isEmpty {
                        VStack(spacing: 16) {
                            SheepView(mood: .thinking, size: 100)
                            Text("Nenhuma história encontrada")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(24)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(Array(content.stories.enumerated()), id: \.element.id) { index, story in
                                        StoryGridCard(
                                            story: story,
                                            index: index,
                                            isUnlocked: canAccessStory(index),
                                            isCompleted: game.storiesCompleted.contains(story.id),
                                            onTap: {
                                                if canAccessStory(index) {
                                                    selectedStory = story
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(16)

                                Spacer(minLength: 20)
                            }
                        }
                }
            }
        }
        .fullScreenCover(item: $selectedStory) { story in
                StoryPlayerView(
                    story: story,
                    onFinish: { outcome in
                        let result = game.completeActivity(outcome, kind: .story, baseXP: 20)
                        lastResult = result
                        selectedStory = nil
                        showCelebration = true
                    },
                    onQuit: { selectedStory = nil }
                )
            }
        .fullScreenCover(isPresented: $showCelebration) {
            if let result = lastResult {
                CelebrationFlowView(result: result) {
                    showCelebration = false
                }
            }
        }
    }

    private func canAccessStory(_ index: Int) -> Bool {
        // Primeira história sempre desbloqueada
        if index == 0 { return true }
        // Próxima história se a anterior foi completada OU completadas 3 lições a mais
        let previousStory = content.stories[index - 1]
        let previousCompleted = game.storiesCompleted.contains(previousStory.id)
        return previousCompleted || game.completedLessonCount >= index * 2
    }
}

// MARK: - Story Grid Card

struct StoryGridCard: View {
    let story: Story
    let index: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Ícone grande em círculo colorido
                ZStack {
                    Circle()
                        .fill(storyColor.opacity(0.2))

                    Image(systemName: story.icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(isUnlocked ? storyColor : Theme.line)
                }
                .frame(height: 120)
                .overlay(
                    Group {
                        if isCompleted {
                            ZStack {
                                Circle()
                                    .fill(Theme.olive)
                                    .frame(width: 32, height: 32)
                                    .offset(x: 40, y: -40)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .offset(x: 40, y: -40)
                            }
                        }
                    }
                )

                // Título e referência
                VStack(alignment: .center, spacing: 4) {
                    Text(story.title)
                        .font(Theme.font(16, .heavy))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)

                    Text(story.reference)
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
            .padding(12)
            .background(Theme.card)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Theme.line, lineWidth: 1)
            )
            .opacity(isUnlocked ? 1 : 0.5)
        }
        .disabled(!isUnlocked)
    }

    private var storyColor: Color {
        [Theme.wheat, Theme.olive, Theme.night, Theme.terracotta, Theme.rest][index % 5]
    }
}

#Preview {
    StoriesListView()
        .environment(GameState())
        .environment(ContentStore())
}
