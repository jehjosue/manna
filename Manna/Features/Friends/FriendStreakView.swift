import SwiftUI

/// Pão compartilhado: missões com amigos (estudar juntos por dias consecutivos).
struct FriendStreakView: View {
    let streaks: [MannaFriendStreak]
    private let friends = FriendsService.shared
    @State private var pendingStreaks: [MannaFriendStreak] = []
    @State private var activeStreaks: [MannaFriendStreak] = []

    var body: some View {
        VStack(spacing: 16) {
            if streaks.isEmpty {
                VStack(spacing: 12) {
                    SheepView(mood: .happy, size: 60)

                    Text("Nenhum pão compartilhado")
                        .font(Theme.font(16, .semibold))
                        .foregroundStyle(Theme.ink)

                    Text("Convide um amigo para estudar juntos!")
                        .font(Theme.font(14, .regular))
                        .foregroundStyle(Theme.inkMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(16)
            } else {
                List {
                    // MARK: - Pending Streaks
                    let pending = streaks.filter { $0.status == "pending" }
                    if !pending.isEmpty {
                        Section("Convites pendentes") {
                            ForEach(pending) { streak in
                                StreakCardPending(streak: streak)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }

                    // MARK: - Active Streaks
                    let active = streaks.filter { $0.status == "active" }
                    if !active.isEmpty {
                        Section("Pão compartilhado") {
                            ForEach(active) { streak in
                                StreakCardActive(streak: streak)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listSectionSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.cream)
            }
        }
        .background(Theme.cream)
    }
}

// MARK: - Pending Streak Card (Convite)

struct StreakCardPending: View {
    let streak: MannaFriendStreak
    private let friends = FriendsService.shared
    @State private var isAccepting = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🍞 Convite de pão compartilhado")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.bread)

                    Text("Estude juntos por dias consecutivos")
                        .font(Theme.font(12, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                Image(systemName: "hourglass.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.bread)
            }

            HStack(spacing: 10) {
                Button(action: { Task { isAccepting = true; _ = await friends.acceptFriendStreak(streakId: streak.id) } }) {
                    Label("Aceitar", systemImage: "checkmark.circle.fill")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.bread, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(isAccepting)

                Button(action: { Task { _ = await friends.removeFriendStreak(streakId: streak.id) } }) {
                    Label("Recusar", systemImage: "xmark.circle")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.line, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Active Streak Card

struct StreakCardActive: View {
    let streak: MannaFriendStreak
    private let friends = FriendsService.shared

    var isUserAStudiedToday: Bool {
        guard let lastDay = streak.lastDayA else { return false }
        return Calendar.current.isDateInToday(lastDay)
    }

    var isUserBStudiedToday: Bool {
        guard let lastDay = streak.lastDayB else { return false }
        return Calendar.current.isDateInToday(lastDay)
    }

    var bothStudiedToday: Bool {
        isUserAStudiedToday && isUserBStudiedToday
    }

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("🍞")
                        Text("\(streak.days) dias")
                            .font(Theme.font(16, .bold))
                            .foregroundStyle(Theme.bread)
                    }

                    Text("Estudando juntos")
                        .font(Theme.font(12, .regular))
                        .foregroundStyle(Theme.inkMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isUserAStudiedToday ? Theme.bread : Theme.line)
                            .frame(width: 10, height: 10)

                        Text("Você")
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.ink)
                    }

                    HStack(spacing: 6) {
                        Circle()
                            .fill(isUserBStudiedToday ? Theme.bread : Theme.line)
                            .frame(width: 10, height: 10)

                        Text("Amigo")
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.ink)
                    }
                }
            }

            // MARK: - Mark Today Button
            if !isUserAStudiedToday {
                Button(action: { Task { _ = await friends.markFriendStreakToday(streakId: streak.id) } }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))

                        Text("Marcar que estudei hoje")
                            .font(Theme.font(13, .semibold))

                        Spacer()

                        if bothStudiedToday {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundStyle(Theme.cream)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Theme.manna, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.manna)

                    Text("Você estudou hoje!")
                        .font(Theme.font(13, .semibold))
                        .foregroundStyle(Theme.manna)

                    Spacer()

                    if bothStudiedToday {
                        Text("✅ Ambos estudaram!")
                            .font(Theme.font(11, .semibold))
                            .foregroundStyle(Theme.bread)
                    }
                }
                .padding(10)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // MARK: - Remove Button
            Button(action: { Task { _ = await friends.removeFriendStreak(streakId: streak.id) } }) {
                Text("Sair do pão compartilhado")
                    .font(Theme.font(12, .regular))
                    .foregroundStyle(Theme.bread)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Theme.line, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    FriendStreakView(
        streaks: [
            MannaFriendStreak(
                id: "str_1",
                userA: "user_123",
                userB: "user_456",
                status: "active",
                days: 12,
                lastDayA: Date(),
                lastDayB: Date(),
                createdAt: Date().addingTimeInterval(-86400 * 12)
            ),
            MannaFriendStreak(
                id: "str_2",
                userA: "user_789",
                userB: "user_000",
                status: "pending",
                days: 0,
                lastDayA: nil,
                lastDayB: nil,
                createdAt: Date().addingTimeInterval(-86400)
            ),
        ]
    )
}
