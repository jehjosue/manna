import SwiftUI

/// Mural: eventos dos amigos que sigo (conquistas, pão compartilhado, etc).
struct FeedView: View {
    let events: [MannaFeedEvent]

    var body: some View {
        if events.isEmpty {
            VStack(spacing: 12) {
                SheepView(mood: .sleepy, size: 60)

                Text("Seu mural está vazio")
                    .font(Theme.font(16, .semibold))
                    .foregroundStyle(Theme.ink)

                Text("Siga amigos para ver seus eventos e conquistas")
                    .font(Theme.font(14, .regular))
                    .foregroundStyle(Theme.inkMuted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(16)
        } else {
            List(events) { event in
                FeedEventCard(event: event)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.cream)
        }
    }
}

struct FeedEventCard: View {
    @State var event: MannaFeedEvent
    private let friends = FriendsService.shared

    var emojiByKind: String {
        switch event.kind {
        case "achievement": return "🏆"
        case "bread": return "🍞"
        case "journey": return "📖"
        case "league": return "🏅"
        default: return "✨"
        }
    }

    var colorByKind: Color {
        switch event.kind {
        case "achievement": return Theme.terracotta
        case "bread": return Theme.bread
        case "journey": return Theme.olive
        case "league": return Theme.manna
        default: return Theme.ink
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.authorName)
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.ink)

                    HStack(spacing: 4) {
                        Text(emojiByKind)
                        Text(event.kind.capitalized)
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.inkMuted)

                        Text("•")
                            .foregroundStyle(Theme.inkMuted)

                        Text(relativeTime(event.createdAt))
                            .font(Theme.font(11, .regular))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }

                Spacer()
            }

            // MARK: - Event Text
            Text(event.text)
                .font(Theme.font(13, .regular))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: - Reactions
            VStack(alignment: .leading, spacing: 8) {
                if !event.reactions.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(Set(event.reactions.map { $0.emoji })), id: \.self) { emoji in
                            let count = event.reactions.filter { $0.emoji == emoji }.count
                            Button(action: {
                                Task {
                                    if event.myReaction == emoji {
                                        _ = await friends.removeReaction(eventId: event.id, emoji: emoji)
                                    } else {
                                        _ = await friends.react(eventId: event.id, emoji: emoji)
                                    }
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(emoji)
                                    Text("\(count)")
                                        .font(Theme.font(11, .regular))
                                        .foregroundStyle(event.myReaction == emoji ? Theme.cream : Theme.ink)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(event.myReaction == emoji ? colorByKind : Theme.line, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                }

                // Add reaction button
                Menu {
                    ForEach(EMOJI_REACTIONS, id: \.self) { emoji in
                        Button(emoji) {
                            Task {
                                _ = await friends.react(eventId: event.id, emoji: emoji)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "smileyface")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.inkMuted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.line, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func relativeTime(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "ontem" : "há \(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "há \(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "há \(minutes)m"
        } else {
            return "agora"
        }
    }
}

#Preview {
    FeedView(
        events: [
            MannaFeedEvent(
                id: "evt_1",
                authorId: "user_123",
                authorName: "João Silva",
                kind: "achievement",
                text: "Desbloqueou a conquista 'Primeira Semana'",
                createdAt: Date().addingTimeInterval(-3600),
                reactions: [
                    MannaReaction(id: "r1", eventId: "evt_1", authorId: "user_456", emoji: "❤️", createdAt: Date()),
                    MannaReaction(id: "r2", eventId: "evt_1", authorId: "user_789", emoji: "❤️", createdAt: Date()),
                ],
                myReaction: nil
            ),
            MannaFeedEvent(
                id: "evt_2",
                authorId: "user_456",
                authorName: "Maria Santos",
                kind: "bread",
                text: "Completou 7 dias de pão compartilhado com João",
                createdAt: Date().addingTimeInterval(-7200),
                reactions: [],
                myReaction: nil
            ),
        ]
    )
}
