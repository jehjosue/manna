import SwiftUI

struct MonthlyBadgesView: View {
    private let monthlyStore = MonthlyChallengeStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Insígnias Mensais")
                                .font(Theme.font(28, .bold))
                                .foregroundStyle(Theme.ink)

                            Text("Conclua 30 missões por mês e ganhe uma insígnia")
                                .font(Theme.font(13, .semibold))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                        if monthlyStore.completedMonthsList().isEmpty {
                            // Empty state
                            VStack(spacing: 16) {
                                Image(systemName: "star.slash")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Theme.inkMuted)

                                VStack(spacing: 4) {
                                    Text("Nenhuma insígnia conquistada")
                                        .font(Theme.font(16, .bold))
                                        .foregroundStyle(Theme.ink)

                                    Text("Complete 30 missões diárias em um mês para ganhar uma insígnia")
                                        .font(Theme.font(13, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            // Grid de insígnias
                            let badges = monthlyStore.completedMonthsList()
                            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(badges, id: \.self) { monthKey in
                                    MonthlyBadgeItem(monthKey: monthKey)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Insígnias Mensais")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MonthlyBadgeItem: View {
    let monthKey: String

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale.current

        if let date = formatter.date(from: monthKey) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthFormatter.locale = Locale.current
            let month = monthFormatter.string(from: date).capitalized

            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: date)

            return "\(month) \(year)"
        }
        return monthKey
    }

    var body: some View {
        VStack(spacing: 12) {
            // Insígnia com gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: 0xFFD700),
                                Color(hex: 0xFFA500)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "star.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color(hex: 0x8B4513))
            }
            .frame(height: 100)
            .cornerRadius(12)

            // Mês
            Text(monthLabel)
                .font(Theme.font(13, .bold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .multilineTextAlignment(.center)

            // Badge "30/30"
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text("30/30")
                    .font(Theme.font(10, .bold))
            }
            .foregroundStyle(Color(hex: 0xFFD700))
        }
        .padding(8)
        .background(Theme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(hex: 0xFFD700).opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    MonthlyBadgesView()
}
