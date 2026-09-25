import WidgetKit
import SwiftUI

struct MannaWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MannaWidgetEntry {
        MannaWidgetEntry(
            date: Date(),
            snapshot: WidgetSnapshot(
                bread: 5,
                studiedToday: false,
                xpToday: 15,
                dailyGoalXP: 20,
                manna: 150,
                userName: "Você",
                updatedAt: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MannaWidgetEntry) -> Void) {
        completion(MannaWidgetEntry(date: Date(), snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MannaWidgetEntry>) -> Void) {
        var entries: [MannaWidgetEntry] = []
        let currentDate = Date()

        // Entry agora
        let snapshot = loadSnapshot()
        entries.append(MannaWidgetEntry(date: currentDate, snapshot: snapshot))

        // Próxima atualização em 30 minutos
        if let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) {
            entries.append(MannaWidgetEntry(date: nextUpdate, snapshot: snapshot))
        }

        // Atualizar à meia-noite
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate),
           let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: nextDay) {
            entries.append(MannaWidgetEntry(date: midnight, snapshot: snapshot))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func loadSnapshot() -> WidgetSnapshot {
        guard let shared = UserDefaults(suiteName: "group.app.manna.ios"),
              let data = shared.data(forKey: WidgetSnapshot.key),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return WidgetSnapshot(
                bread: 0,
                studiedToday: false,
                xpToday: 0,
                dailyGoalXP: 20,
                manna: 50,
                userName: "Béé",
                updatedAt: Date()
            )
        }
        return snapshot
    }
}

struct MannaWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct WidgetSnapshot: Codable {
    static let key = "manna.widget.snapshot"
    let bread: Int
    let studiedToday: Bool
    let xpToday: Int
    let dailyGoalXP: Int
    let manna: Int
    let userName: String
    let updatedAt: Date
}

struct MannaWidgetEntryView: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    var entry: MannaWidgetEntry

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Header: nome e pão
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.snapshot.userName)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: 0x3D3326))

                    Text(entry.snapshot.studiedToday ? "Pão garantido hoje ✅" : "Seu pão está esfriando…")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x8C8170))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color(hex: 0xD98E3A))
                            Text(String(entry.snapshot.bread))
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 28, height: 28)

                        Text("pão")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: 0x8C8170))
                    }
                }
            }

            Divider()
                .foregroundStyle(Color(hex: 0xE6DED0))

            // Progresso da meta XP
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Meta: \(entry.snapshot.xpToday)/\(entry.snapshot.dailyGoalXP) XP")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x3D3326))

                    Spacer()

                    Text(entry.snapshot.studiedToday ? "✓" : "↗")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(entry.snapshot.studiedToday ? Color(hex: 0x7A9A3A) : Color(hex: 0xD0643F))
                }

                // Barra de progresso
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(hex: 0xE6DED0))

                    let progress = min(Double(entry.snapshot.xpToday) / Double(entry.snapshot.dailyGoalXP), 1.0)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            entry.snapshot.studiedToday
                                ? Color(hex: 0x7A9A3A)
                                : Color(hex: 0xE8A33D)
                        )
                        .frame(width: progress * 120)
                }
                .frame(height: 6)
            }

            Divider()
                .foregroundStyle(Color(hex: 0xE6DED0))

            // Ovelhinha + maná
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    SimpleSheepView()
                        .frame(width: 36, height: 36)

                    Text("Béé")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x8C8170))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0xC9A227))
                            Text("✨")
                                .font(.system(size: 12))
                        }
                        .frame(width: 20, height: 20)

                        Text(String(entry.snapshot.manna))
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: 0xC9A227))
                    }

                    Text("maná")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x8C8170))
                }
            }
        }
        .padding(12)
        .background(Color(hex: 0xFFF9EF))
        .cornerRadius(16)
        .containerBackground(Color(hex: 0xFFF9EF), for: .widget)
    }
}

struct SimpleSheepView: View {
    var body: some View {
        ZStack {
            // Corpo arredondado
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)

            // Cabeça
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .offset(y: -10)

            // Orelhas
            HStack(spacing: 2) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 6)
                Spacer()
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 6)
            }
            .frame(width: 10)
            .offset(y: -14)

            // Olhos
            HStack(spacing: 2) {
                Circle()
                    .fill(Color(hex: 0x3D3326))
                    .frame(width: 2, height: 2)
                Spacer()
                Circle()
                    .fill(Color(hex: 0x3D3326))
                    .frame(width: 2, height: 2)
            }
            .frame(width: 4)
            .offset(y: -10)
        }
    }
}

struct MannaWidget: Widget {
    let kind: String = "MannaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MannaWidgetProvider()) { entry in
            MannaWidgetEntryView(entry: entry)
                .containerBackground(.fill, for: .widget)
        }
        .configurationDisplayName("Manna")
        .description("Seu progresso diário")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

#Preview("Small", as: .systemSmall) {
    MannaWidget()
} timeline: {
    MannaWidgetEntry(
        date: Date(),
        snapshot: WidgetSnapshot(
            bread: 5,
            studiedToday: true,
            xpToday: 20,
            dailyGoalXP: 20,
            manna: 150,
            userName: "Maria",
            updatedAt: Date()
        )
    )
}

#Preview("Medium", as: .systemMedium) {
    MannaWidget()
} timeline: {
    MannaWidgetEntry(
        date: Date(),
        snapshot: WidgetSnapshot(
            bread: 3,
            studiedToday: false,
            xpToday: 10,
            dailyGoalXP: 20,
            manna: 80,
            userName: "João",
            updatedAt: Date()
        )
    )
}
