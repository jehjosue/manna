import SwiftUI

struct YearInReviewView: View {
    @Environment(GameState.self) var game
    @Environment(ContentStore.self) var content

    @State private var currentPage = 0
    @State private var showShareSheet = false

    var year: Int {
        Calendar.current.component(.year, from: Date())
    }

    var studiedDaysCount: Int {
        game.studiedDays.count
    }

    var completedJourneys: Int {
        content.journeys.filter { journey in
            !journey.allLessons.isEmpty && game.completedCount(in: journey) == journey.allLessons.count
        }.count
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            TabView(selection: $currentPage) {
                // Página 1: XP do ano
                YearInReviewPage(
                    title: "XP em \(year)",
                    value: String(game.xpTotal),
                    icon: "bolt.fill",
                    color: Theme.olive,
                    description: "Pontos de experiência acumulados"
                )
                .tag(0)

                // Página 2: Dias estudados
                YearInReviewPage(
                    title: "Dias Estudados",
                    value: String(studiedDaysCount),
                    icon: "calendar.badge.checkmark",
                    color: Theme.wheat,
                    description: "Dias que você dedicou a aprender"
                )
                .tag(1)

                // Página 3: Melhor sequência
                YearInReviewPage(
                    title: "Melhor Sequência",
                    value: String(game.bestBread),
                    icon: "flame.fill",
                    color: Color(hex: 0xFF6B6B),
                    description: "Dias consecutivos de estudo"
                )
                .tag(2)

                // Página 4: Lições
                YearInReviewPage(
                    title: "Lições Concluídas",
                    value: String(game.completedLessonCount),
                    icon: "book.fill",
                    color: Color(hex: 0x4A90E2),
                    description: "Lições que você terminou"
                )
                .tag(3)

                // Página 5: Histórias
                YearInReviewPage(
                    title: "Histórias Lidas",
                    value: String(game.storiesCompleted.count),
                    icon: "text.book.closed.fill",
                    color: Color(hex: 0x9B59B6),
                    description: "Histórias da Bíblia que você explorou"
                )
                .tag(4)

                // Página 6: Versículos
                YearInReviewPage(
                    title: "Versículos Aprendidos",
                    value: String(game.lessons.keys.count),
                    icon: "quote.opening",
                    color: Color(hex: 0xE67E22),
                    description: "Passagens bíblicas que você estudou"
                )
                .tag(5)

                // Página 7: Jornada favorita (por XP/progresso)
                let topJourney = content.journeys.max { j1, j2 in
                    let xp1 = game.completedCount(in: j1)
                    let xp2 = game.completedCount(in: j2)
                    return xp1 < xp2
                }

                YearInReviewPage(
                    title: "Sua Jornada Favorita",
                    value: topJourney?.title ?? "—",
                    icon: "map.fill",
                    color: Color(hex: 0x1ABC9C),
                    description: "Jornada onde você mais progrediu"
                )
                .tag(6)

                // Página 8: Cartão compartilhável
                YearInReviewSharePage(currentPage: $currentPage)
                    .tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

struct YearInReviewPage: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let description: String

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Theme.cream.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Ícone grande
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 140, height: 140)

                        Image(systemName: icon)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(color)
                    }

                    // Título
                    VStack(spacing: 8) {
                        Text(title)
                            .font(Theme.font(24, .bold))
                            .foregroundStyle(Theme.ink)

                        Text(value)
                            .font(Theme.font(48, .heavy))
                            .foregroundStyle(color)

                        Text(description)
                            .font(Theme.font(14, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    // Ovelhinha feliz
                    SheepView(mood: .cheering, size: 100)

                    Spacer()
                }
                .padding(20)
            }
        }
    }
}

struct YearInReviewSharePage: View {
    @Environment(GameState.self) var game
    @Binding var currentPage: Int

    @State private var showShareSheet = false

    var year: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Cartão de compartilhamento
                VStack(spacing: 20) {
                    VStack(spacing: 2) {
                        HStack {
                            Image(systemName: "book.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.wheat)

                            Text("Manna")
                                .font(Theme.font(14, .bold))
                                .foregroundStyle(Theme.ink)

                            Spacer()
                        }

                        Text("Retrospectiva \(year)")
                            .font(Theme.font(20, .bold))
                            .foregroundStyle(Theme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack(spacing: 12) {
                        StatBoxSmall(
                            value: String(game.xpTotal),
                            label: "XP",
                            icon: "bolt.fill"
                        )

                        StatBoxSmall(
                            value: String(game.studiedDays.count),
                            label: "Dias",
                            icon: "calendar"
                        )

                        StatBoxSmall(
                            value: String(game.bestBread),
                            label: "Sequência",
                            icon: "flame.fill"
                        )
                    }

                    VStack(spacing: 4) {
                        Text(game.userName)
                            .font(Theme.font(16, .bold))
                            .foregroundStyle(Theme.ink)

                        Text("Meu ano no Manna")
                            .font(Theme.font(12, .semibold))
                            .foregroundStyle(Theme.inkMuted)
                    }
                }
                .padding(20)
                .background(Theme.card)
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer()

                // Botões
                Button(action: { showShareSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Compartilhar Retrospectiva")
                            .font(Theme.font(15, .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.chunky)

                Button(action: { currentPage = 0 }) {
                    Text("Ver detalhes novamente")
                        .font(Theme.font(14, .semibold))
                        .foregroundStyle(Theme.wheat)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.chunkyNight)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = ShareCardRenderer.yearInReviewCard(
                gameName: game.userName,
                year: year,
                xpTotal: game.xpTotal,
                studiedDaysCount: game.studiedDays.count,
                bestBread: game.bestBread,
                completedLessons: game.completedLessonCount,
                completedStories: game.storiesCompleted.count,
                perfectLessons: game.perfectLessonCount
            ),
            let uiImage = image.asUIImage() {
                ShareSheet(items: [uiImage])
            }
        }
    }
}

struct StatBoxSmall: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.wheat)

            Text(value)
                .font(Theme.font(14, .bold))
                .foregroundStyle(Theme.ink)

            Text(label)
                .font(Theme.font(9, .semibold))
                .foregroundStyle(Theme.inkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Theme.wheat.opacity(0.1))
        .cornerRadius(8)
    }
}


#Preview {
    YearInReviewView()
        .environment(GameState.load())
        .environment(ContentStore.shared)
}
