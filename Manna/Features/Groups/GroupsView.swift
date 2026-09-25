import SwiftUI

/// Vista principal de Grupos (integrada na aba Ligas).
/// Gerencia a jornada do usuário: vazio → criar/entrar → lista de grupos → detalhe do grupo.
struct GroupsView: View {
    @Environment(GameState.self) private var game
    private let service = GroupsService.shared

    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var selectedGroup: MannaGroup?

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            if service.myGroups.isEmpty {
                emptyState
            } else {
                groupsList
            }
        }
        .onAppear {
            Task {
                await service.refresh()
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateGroupSheet(isPresented: $showCreateSheet)
        }
        .sheet(isPresented: $showJoinSheet) {
            JoinGroupSheet(isPresented: $showJoinSheet)
        }
        .sheet(item: $selectedGroup) { group in
            GroupDetailSheet(
                group: service.myGroups.first(where: { $0.code == group.code }) ?? group,
                isPresented: Binding(get: { true }, set: { if !$0 { selectedGroup = nil } })
            )
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            SheepView(mood: .happy, size: 120)
                .padding(.bottom, 16)

            VStack(spacing: 12) {
                Text("Estude junto com sua comunidade")
                    .font(Theme.font(24, .bold))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)

                Text("Crie um grupo com sua igreja, célula ou família e alcancem uma meta semanal juntos.")
                    .font(Theme.font(16, .regular))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { showCreateSheet = true }) {
                    Text("Criar grupo")
                }
                .buttonStyle(.chunky)

                Button(action: { showJoinSheet = true }) {
                    Text("Entrar com código")
                }
                .buttonStyle(.chunkyNight)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Groups List

    private var groupsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Banner sem conexão
                OfflineBanner()

                // Cabeçalho com ações
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Meus Grupos")
                            .font(Theme.font(24, .bold))
                            .foregroundStyle(Theme.ink)

                        Text("\(service.myGroups.count) grupo\(service.myGroups.count == 1 ? "" : "s")")
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()

                    Menu {
                        Button(action: { showCreateSheet = true }) {
                            Label("Criar novo", systemImage: "plus.circle")
                        }
                        Button(action: { showJoinSheet = true }) {
                            Label("Entrar", systemImage: "arrow.down.circle")
                        }
                        Button(action: {
                            Task {
                                await service.sync(game: game)
                                await service.refresh()
                            }
                        }) {
                            Label("Atualizar", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.wheat)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Lista de grupos
                LazyVStack(spacing: 12) {
                    ForEach(service.myGroups) { group in
                        GroupCard(group: group)
                            .onTapGesture {
                                selectedGroup = group
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .refreshable {
            await service.sync(game: game)
            await service.refresh()
        }
    }
}

// MARK: - Group Card (lista)

struct GroupCard: View {
    let group: MannaGroup

    var progress: Double {
        guard group.weeklyGoal > 0 else { return 0 }
        return Double(group.weeklyXP) / Double(group.weeklyGoal)
    }

    var isGoalReached: Bool {
        group.weeklyXP >= group.weeklyGoal
    }

    var body: some View {
        VStack(spacing: 12) {
            // Nome do grupo
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(Theme.font(18, .bold))
                        .foregroundStyle(Theme.ink)

                    Text("Código: \(group.code)")
                        .font(Theme.font(12, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                if isGoalReached {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.olive)
                        Text("Cumprida")
                            .font(Theme.font(10, .bold))
                            .foregroundStyle(Theme.olive)
                    }
                }
            }

            // Barra de progresso
            VStack(spacing: 8) {
                HStack {
                    Text("Esta semana")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.inkMuted)

                    Spacer()

                    Text("\(Int(group.weeklyXP)) / \(Int(group.weeklyGoal)) XP")
                        .font(Theme.font(13, .bold))
                        .foregroundStyle(Theme.ink)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.line)

                        if progress > 0 {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isGoalReached ? Theme.olive : Theme.wheat)
                                .frame(width: geo.size.width * min(progress, 1))
                        }
                    }
                }
                .frame(height: 12)
            }

            // Ovelhinhas dos membros (até 8)
            if !group.members.isEmpty {
                HStack(spacing: 2) {
                    ForEach(group.members.prefix(8)) { member in
                        SheepMiniView(member: member)
                    }

                    if group.members.count > 8 {
                        Text("+\(group.members.count - 8)")
                            .font(Theme.font(11, .bold))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    Spacer()
                }
                .frame(height: 32)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Theme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 2)
        )
    }
}

// MARK: - Sheep Mini (para listar membros)

struct SheepMiniView: View {
    let member: MannaMember

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Theme.card)
                    .overlay(
                        Circle()
                            .strokeBorder(Theme.line, lineWidth: 1)
                    )

                // Círculo pequeno com as iniciais
                Text(member.displayName.prefix(1).uppercased())
                    .font(Theme.font(9, .bold))
                    .foregroundStyle(Theme.ink)
            }
            .frame(width: 24, height: 24)

            Text(member.displayName.split(separator: " ").first.map(String.init) ?? "?")
                .font(Theme.font(8, .semibold))
                .foregroundStyle(Theme.inkMuted)
                .lineLimit(1)
        }
    }
}

// MARK: - Previews

#Preview {
    GroupsView()
        .environment(GameState())
        .background(Theme.cream)
}

