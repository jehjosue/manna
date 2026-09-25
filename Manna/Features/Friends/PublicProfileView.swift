import SwiftUI

/// Perfil público de um outro usuário (não editável).
struct PublicProfileView: View {
    let profile: MannaPublicProfile
    private let friends = FriendsService.shared
    @State private var isFollowing = false
    @State private var showNudgeSheet = false
    @State private var showReportSheet = false
    @State private var showStreakInvite = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header com avatar e nome
            VStack(spacing: 16) {
                // Avatar
                VStack {
                    if let avatarJSON = profile.avatar {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.manna)
                    } else {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.line)
                    }
                }

                VStack(spacing: 4) {
                    Text(profile.displayName)
                        .font(Theme.font(20, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("@\(profile.username)")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)

                    if let status = profile.status {
                        Text(status)
                            .font(Theme.font(12, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }

                // Badges: pão, XP, liga
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("\(profile.bread)")
                            .font(Theme.font(16, .bold))
                            .foregroundStyle(Theme.bread)

                        Text("Pão")
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(spacing: 4) {
                        Text("\(profile.weeklyXP)")
                            .font(Theme.font(16, .bold))
                            .foregroundStyle(Theme.manna)

                        Text("XP esta semana")
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(spacing: 4) {
                        Text(profile.currentLeague)
                            .font(Theme.font(14, .bold))
                            .foregroundStyle(Theme.oil)

                        Text("Liga")
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Theme.card)

            // MARK: - Action Buttons
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button(action: { Task { isFollowing = await friends.follow(userId: profile.id) } }) {
                        if isFollowing {
                            Label("Seguindo", systemImage: "checkmark.circle.fill")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.cream)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Theme.manna, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else {
                            Label("Seguir", systemImage: "plus.circle")
                                .font(Theme.font(14, .semibold))
                                .foregroundStyle(Theme.ink)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Theme.line, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }

                    Button(action: { showNudgeSheet = true }) {
                        Label("Cutucar", systemImage: "hand.raised.fill")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Theme.terracotta, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }

                HStack(spacing: 10) {
                    Button(action: { showStreakInvite = true }) {
                        Label("🍞 Pão compartilhado", systemImage: "link")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Theme.bread, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    ShareProfileButton(profile: profile)
                }

                Button(action: { showReportSheet = true }) {
                    Label("Denunciar", systemImage: "flag.fill")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.bread)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding(16)
            .background(Theme.cream)

            Spacer()
        }
        .background(Theme.cream)
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNudgeSheet) {
            NudgeSheet(toUser: profile)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportSheet(reportedUser: profile)
        }
        .sheet(isPresented: $showStreakInvite) {
            StreakInviteSheet(toUser: profile)
        }
    }
}

// MARK: - Share Profile Button

struct ShareProfileButton: View {
    let profile: MannaPublicProfile

    var body: some View {
        ShareLink(
            item: "Estude a Bíblia comigo no Manna! Meu usuário: @\(profile.username)",
            subject: Text("Vem estudar comigo no Manna!")
        ) {
            Label("Compartilhar", systemImage: "share.fill")
                .font(Theme.font(14, .semibold))
                .foregroundStyle(Theme.cream)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Theme.olive, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

// MARK: - Nudge Sheet

struct NudgeSheet: View {
    let toUser: MannaPublicProfile
    private let friends = FriendsService.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedMessageIndex = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cutucar \(toUser.displayName)")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("Escolha uma mensagem pré-definida (sem texto livre)")
                        .font(Theme.font(12, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 10) {
                    ForEach(0..<NUDGE_MESSAGES.count, id: \.self) { index in
                        Button(action: { selectedMessageIndex = index }) {
                            HStack {
                                Text(NUDGE_MESSAGES[index])
                                    .font(Theme.font(14, .regular))
                                    .foregroundStyle(Theme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if selectedMessageIndex == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.manna)
                                }
                            }
                            .padding(12)
                            .background(selectedMessageIndex == index ? Theme.card : Theme.line, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }

                Spacer()

                Button(action: {
                    Task {
                        _ = await friends.sendNudge(toUserId: toUser.id, messageIndex: selectedMessageIndex)
                        dismiss()
                    }
                }) {
                    Text("Enviar cutucão")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Theme.terracotta, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(16)
            .background(Theme.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Streak Invite Sheet

struct StreakInviteSheet: View {
    let toUser: MannaPublicProfile
    private let friends = FriendsService.shared
    @Environment(\.dismiss) var dismiss
    @State private var isInviting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🍞 Pão Compartilhado")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.bread)

                    Text("Estudem juntos por dias consecutivos e fortaleçam a comunidade!")
                        .font(Theme.font(13, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.olive)
                        Text("Convite enviado para \(toUser.displayName)")
                            .font(Theme.font(13, .semibold))
                            .foregroundStyle(Theme.olive)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Theme.oliveLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Theme.olive, lineWidth: 1.5)
                    )

                    Text("Quando \(toUser.displayName) aceitar, você verá a missão na aba Amigos → Pão Compartilhado.")
                        .font(Theme.font(12, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                Button(action: {
                    Task {
                        isInviting = true
                        _ = await friends.inviteFriendStreak(toUserId: toUser.id)
                        isInviting = false
                        DispatchQueue.main.async {
                            dismiss()
                        }
                        SoundFX.play(.reward)
                        Haptics.success()
                    }
                }) {
                    if isInviting {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Enviar Convite")
                    }
                }
                .buttonStyle(.chunky)
                .disabled(isInviting)

                Button(action: { dismiss() }) {
                    Text("Cancelar")
                }
                .buttonStyle(.chunkyNight)
            }
            .padding(16)
            .background(Theme.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Report Sheet

struct ReportSheet: View {
    let reportedUser: MannaPublicProfile
    private let friends = FriendsService.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedReason = ""

    let reasons = ["spam", "harassment", "inappropriate", "impersonation", "other"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Denunciar @\(reportedUser.username)")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.bread)

                    Text("Sua denúncia nos ajuda a manter Manna seguro")
                        .font(Theme.font(12, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 10) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: { selectedReason = reason }) {
                            HStack {
                                Text(reason.capitalized)
                                    .font(Theme.font(14, .regular))
                                    .foregroundStyle(Theme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.bread)
                                }
                            }
                            .padding(12)
                            .background(selectedReason == reason ? Theme.card : Theme.line, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }

                Spacer()

                VStack(spacing: 10) {
                    Button(action: {
                        Task {
                            _ = await friends.report(userId: reportedUser.id, reason: selectedReason)
                            await friends.blockUser(userId: reportedUser.id)
                            dismiss()
                        }
                    }) {
                        Text("Denunciar e bloquear")
                            .font(Theme.font(16, .semibold))
                            .foregroundStyle(Theme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Theme.bread, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(selectedReason.isEmpty)

                    Button(action: { dismiss() }) {
                        Text("Cancelar")
                            .font(Theme.font(16, .regular))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Theme.line, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(16)
            .background(Theme.cream)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        PublicProfileView(
            profile: MannaPublicProfile(
                id: "user_123",
                username: "example_user",
                displayName: "João Silva",
                bread: 42,
                weeklyXP: 250,
                xpTotal: 1500,
                avatar: nil,
                status: "🙏 Estudando com fé",
                updatedAt: Date()
            )
        )
    }
}
