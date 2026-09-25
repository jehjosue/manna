import SwiftUI

struct ProfileCompletionCard: View {
    @Environment(GameState.self) var game
    @Environment(AvatarStore.self) var avatarStore

    private let identity = ProfileIdentityStore.shared

    var isComplete: Bool {
        !game.userName.isEmpty &&
        identity.hasUsername &&
        hasCustomizedAvatar &&
        !identity.status.isEmpty
    }

    var completedSteps: Int {
        var count = 0
        if !game.userName.isEmpty { count += 1 }
        if identity.hasUsername { count += 1 }
        if hasCustomizedAvatar { count += 1 }
        if !identity.status.isEmpty { count += 1 }
        return count
    }

    var hasCustomizedAvatar: Bool {
        // Avatar foi customizado se tem acessórios equipados ou cor diferente
        !avatarStore.equippedAccessories.isEmpty || avatarStore.woolColor != .white
    }

    var body: some View {
        if !isComplete {
            NavigationLink(destination: EditProfileView()) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Complete seu perfil")
                                .font(Theme.font(16, .bold))
                                .foregroundStyle(Theme.ink)

                            Text("\(completedSteps)/4 passos")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Theme.wheat.opacity(0.2))

                            Text("\(completedSteps)/4")
                                .font(Theme.font(12, .bold))
                                .foregroundStyle(Theme.wheat)
                        }
                        .frame(width: 48, height: 48)
                    }

                    ProgressView(value: Double(completedSteps), total: 4)
                        .tint(Theme.wheat)
                        .frame(height: 6)

                    HStack {
                        Text("Toque para continuar")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.wheat)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.wheat)
                    }
                }
                .padding(14)
                .background(Theme.wheat.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.wheat, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ProfileCompletionCard()
        .environment(GameState.load())
        .environment(ProfileIdentityStore.shared)
        .environment(AvatarStore.shared)
}
