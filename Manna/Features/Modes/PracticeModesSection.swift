import SwiftUI

/// Seção pública para inserir no PracticeHubView.
/// Nome exato: PracticeModesSection()
/// Sem parâmetros.
struct PracticeModesSection: View {
    @Environment(GameState.self) private var game
    @State private var selectedMode: PracticeModeType?
    @State private var showCelebration = false
    @State private var lastGameScore = 0

    enum PracticeModeType { case radio, roleplay, videoCall, miniGame }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Novos Modos de Estudo")
                .font(Theme.font(18, .heavy))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 16)

            VStack(spacing: 12) {
                // Rádio Manna
                NavigationLink(destination: RadioListView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.wheat)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rádio Manna")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Episódios bíblicos com Béé")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                // Conversa com Personagens
                NavigationLink(destination: RoleplayView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.olive)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Conversa com Personagens")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Diálogos com figuras bíblicas")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                // Ligação com Béé
                NavigationLink(destination: VideoCallView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.terracotta)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ligação com Béé")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Conversa por voz com Béé")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                // Minijogo
                Button {
                    selectedMode = .miniGame
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.manna)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Arca de Noé")
                                .font(Theme.font(18, .heavy))
                                .foregroundStyle(Theme.ink)
                            Text("Minijogo: encontre os pares")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 16)
        }
        .sheet(item: $selectedMode) { mode in
            switch mode {
            case .miniGame:
                ArkGameView { score in
                    lastGameScore = score
                    selectedMode = nil
                    showCelebration = true
                }
            default:
                EmptyView()
            }
        }
        .fullScreenCover(isPresented: $showCelebration) {
            let outcome = LessonOutcome(
                lessonId: "arca-noé",
                correctCount: lastGameScore,
                totalCount: 5,
                mistakes: max(0, 5 - lastGameScore)
            )
            let result = game.completeActivity(outcome, kind: .challenge, baseXP: lastGameScore * 8)
            CelebrationFlowView(result: result) {
                showCelebration = false
            }
        }
    }
}

extension PracticeModesSection.PracticeModeType: Identifiable {
    var id: String {
        switch self {
        case .radio: "radio"
        case .roleplay: "roleplay"
        case .videoCall: "videoCall"
        case .miniGame: "miniGame"
        }
    }
}

#Preview {
    PracticeModesSection()
        .environment(GameState())
        .environment(ContentStore())
}
