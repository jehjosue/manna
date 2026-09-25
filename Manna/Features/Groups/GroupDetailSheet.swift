import SwiftUI
import UIKit

/// Detalhe de um grupo: barra de progresso, membros, incentivos, ações.
struct GroupDetailSheet: View {
    @Environment(GameState.self) private var game
    private let service = GroupsService.shared

    let group: MannaGroup
    @Binding var isPresented: Bool

    @State private var selectedCheer: String?
    @State private var isRefreshing = false
    @State private var showLeaveConfirm = false

    private let cheerMessages = [
        "Bora estudar! 📖",
        "Orando por vocês 🙏",
        "Que bênção! 🙌",
        "Não desistam! 💪",
        "Amém! ✨"
    ]

    var progress: Double {
        guard group.weeklyGoal > 0 else { return 0 }
        return Double(group.weeklyXP) / Double(group.weeklyGoal)
    }

    var isGoalReached: Bool {
        group.weeklyXP >= group.weeklyGoal
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Cabeçalho
                        headerSection

                        // Barra de progresso grande
                        progressSection

                        // Membros e contribuições
                        membersSection

                        // Mural de incentivos
                        if !group.cheers.isEmpty {
                            cheersSection
                        }

                        // Botões de incentivo
                        cheerButtonsSection

                        // Ações
                        actionsSection

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
                .refreshable {
                    await service.refresh()
                }
            }
            .navigationTitle(group.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showLeaveConfirm = true }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.terracotta)
                    }
                }
            }
            .confirmationDialog("Sair do grupo?", isPresented: $showLeaveConfirm) {
                Button("Sair", role: .destructive) {
                    leaveGroup()
                }
            } message: {
                Text("Você não poderá recuperar seus dados deste grupo.")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.code)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .tracking(2)

                    Text("\(group.members.count) membro\(group.members.count == 1 ? "" : "s")")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if isGoalReached {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.olive)
                        Text("Cumprida")
                            .font(Theme.font(10, .bold))
                            .foregroundStyle(Theme.olive)
                    }
                }
            }

            HStack(spacing: 8) {
                Button(action: {
                    UIPasteboard.general.string = group.code
                    Haptics.tap()
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                    Text("Copiar código")
                        .font(Theme.font(12, .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .foregroundStyle(Theme.wheat)
                .background(Theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Theme.wheat, lineWidth: 1.5)
                )

                ShareLink(
                    item: "Vamos estudar a Bíblia juntos no Manna! Entre no meu grupo com o código \(group.code).",
                    subject: Text("Junte-se ao meu grupo no Manna")
                ) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                        Text("Compartilhar")
                            .font(Theme.font(12, .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .foregroundStyle(.white)
                .background(Theme.night)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Theme.night, lineWidth: 1.5)
                )
            }
        }
        .padding(16)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meta desta semana")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.inkMuted)

                    Text("\(Int(group.weeklyXP)) / \(Int(group.weeklyGoal)) XP")
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Progresso")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)

                    Text(String(format: "%.0f%%", progress * 100))
                        .font(Theme.font(16, .bold))
                        .foregroundStyle(isGoalReached ? Theme.olive : Theme.wheat)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.line)

                    if progress > 0 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isGoalReached ? Theme.olive : Theme.wheat)
                            .frame(width: geo.size.width * min(progress, 1))
                    }
                }
            }
            .frame(height: 16)

            if isGoalReached {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.olive)
                    Text("Meta do grupo cumprida! 🎉")
                        .font(Theme.font(13, .bold))
                        .foregroundStyle(Theme.olive)
                    Spacer()
                }
                .padding(12)
                .background(Theme.oliveLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Theme.olive, lineWidth: 1.5)
                )
            }
        }
        .padding(16)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }

    // MARK: - Members

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contribuições")
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)

            VStack(spacing: 10) {
                ForEach(group.members.sorted(by: { $0.weeklyXP > $1.weeklyXP })) { member in
                    MemberContributionRow(member: member, groupGoal: group.weeklyGoal)
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }

    // MARK: - Cheers

    private var cheersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mural de incentivos")
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)

            VStack(spacing: 8) {
                ForEach(group.cheers.prefix(5)) { cheer in
                    CheerBubble(cheer: cheer)
                }

                if group.cheers.count > 5 {
                    Text("... e \(group.cheers.count - 5) mais")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }

    // MARK: - Cheer Buttons

    private var cheerButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Envie um incentivo")
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)

            VStack(spacing: 8) {
                ForEach(cheerMessages, id: \.self) { message in
                    Button(action: { sendCheer(message) }) {
                        Text(message)
                            .font(Theme.font(13, .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Theme.card)
                            .foregroundStyle(Theme.ink)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Theme.line, lineWidth: 1.5)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Button(action: { isPresented = false }) {
            Text("Fechar")
        }
        .buttonStyle(.chunkyNight)
    }

    // MARK: - Functions

    private func sendCheer(_ message: String) {
        Task {
            let success = await service.sendCheer(groupCode: group.code, message: message)
            if success {
                SoundFX.play(.reward)
                Haptics.success()
            }
        }
    }

    private func leaveGroup() {
        Task {
            let success = await service.leaveGroup(code: group.code)
            if success {
                DispatchQueue.main.async {
                    isPresented = false
                }
                SoundFX.play(.tap)
                Haptics.tap()
            }
        }
    }
}

// MARK: - Member Contribution Row

struct MemberContributionRow: View {
    let member: MannaMember
    let groupGoal: Int64

    var progress: Double {
        groupGoal > 0 ? Double(member.weeklyXP) / Double(groupGoal) : 0
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(member.displayName)
                        .font(Theme.font(13, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("\(Int(member.weeklyXP)) XP")
                        .font(Theme.font(11, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if member.bread > 0 {
                    HStack(spacing: 4) {
                        GameIconView(icon: .bread, size: 16)
                        Text("\(Int(member.bread))")
                            .font(Theme.font(11, .bold))
                            .foregroundStyle(Theme.bread)
                    }
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.line)

                    if progress > 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.olive)
                            .frame(width: geo.size.width * min(progress, 1))
                    }
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Cheer Bubble

struct CheerBubble: View {
    let cheer: MannaCheer

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(cheer.displayName)
                    .font(Theme.font(11, .bold))
                    .foregroundStyle(Theme.inkMuted)

                Spacer()

                Text(timeAgoString(cheer.createdAt))
                    .font(Theme.font(9, .semibold))
                    .foregroundStyle(Theme.lineDark)
            }

            Text(cheer.message)
                .font(Theme.font(12, .semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.oliveLight)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Theme.olive.opacity(0.3), lineWidth: 1)
        )
    }

    private func timeAgoString(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 { return "Agora" }
        if seconds < 3600 { return "\(Int(seconds/60))m atrás" }
        if seconds < 86400 { return "\(Int(seconds/3600))h atrás" }
        return "\(Int(seconds/86400))d atrás"
    }
}

// MARK: - Preview

#Preview {
    @State var isPresented = true
    let group = MannaGroup(
        id: "1",
        name: "Célula da Comunidade",
        code: "ABC123",
        weeklyGoal: 1000,
        createdBy: "usuario1",
        createdAt: Date(),
        weeklyXP: 750,
        members: [
            MannaMember(id: "1", groupCode: "ABC123", memberId: "u1", displayName: "Maria", weekKey: "2025-W01", weeklyXP: 350, bread: 7, updatedAt: Date()),
            MannaMember(id: "2", groupCode: "ABC123", memberId: "u2", displayName: "Pedro", weekKey: "2025-W01", weeklyXP: 250, bread: 5, updatedAt: Date()),
            MannaMember(id: "3", groupCode: "ABC123", memberId: "u3", displayName: "Ana", weekKey: "2025-W01", weeklyXP: 150, bread: 3, updatedAt: Date())
        ],
        cheers: [
            MannaCheer(id: "1", groupCode: "ABC123", memberId: "u1", displayName: "Maria", message: "Bora estudar! 📖", createdAt: Date(timeIntervalSinceNow: -3600)),
            MannaCheer(id: "2", groupCode: "ABC123", memberId: "u2", displayName: "Pedro", message: "Que bênção! 🙌", createdAt: Date(timeIntervalSinceNow: -7200))
        ]
    )

    return GroupDetailSheet(group: group, isPresented: $isPresented)
        .environment(GameState())
}
