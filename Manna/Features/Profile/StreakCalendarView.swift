import SwiftUI

/// Calendário mensal mostrando dias estudados.
struct StreakCalendarView: View {
    @Environment(GameState.self) var game

    @State private var currentDate = Date()

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // Navegação de mês
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }

                Spacer()

                Text(monthTitle)
                    .font(Theme.font(16, .bold))
                    .foregroundStyle(Theme.ink)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }
            .padding(.horizontal, 20)

            // Dias da semana
            HStack(spacing: 0) {
                ForEach(["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"], id: \.self) { day in
                    Text(day)
                        .font(Theme.font(11, .bold))
                        .foregroundStyle(Theme.inkMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)

            // Calendário
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        let date = Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth)!
                        let studied = game.studied(on: date)
                        let isToday = Calendar.current.isDateInToday(date)

                        VStack {
                            Text("\(day)")
                                .font(Theme.font(12, .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    studied
                                        ? Theme.bread
                                        : isToday
                                        ? Theme.line.opacity(0.3)
                                        : Theme.card
                                )
                                .foregroundStyle(studied ? .white : Theme.ink)
                                .cornerRadius(8)

                            if studied {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.bread)
                                    .offset(y: -2)
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .padding(.vertical, 12)
        .background(Theme.card)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }

    private var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
        return Calendar.current.date(from: components)!
    }

    private var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM 'de' yyyy"
        return formatter.string(from: currentDate)
    }

    private var days: [Int?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numDays = range.count

        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        var result: [Int?] = Array(repeating: nil, count: firstWeekday)
        result.append(contentsOf: (1...numDays).map { $0 })

        return result
    }

    private func previousMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }

    private func nextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

#Preview {
    StreakCalendarView()
        .environment(GameState.load())
        .background(Theme.cream)
}
