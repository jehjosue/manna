import SwiftUI
import UserNotifications

/// Tela expandida de configuração de notificações com múltiplos tipos de alerta.
struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dailyReminderEnabled = false
    @State private var dailyReminderHour = 20
    @State private var breadRiskEnabled = false
    @State private var oilFullEnabled = false
    @State private var weeklyReviewEnabled = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    let scheduler = NotificationScheduler.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - Header
                        HStack {
                            Text("Notificações")
                                .font(Theme.font(28, .heavy))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Theme.inkMuted)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        // MARK: - Status de permissão
                        VStack(spacing: 12) {
                            if notificationStatus == .denied {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(Theme.terracotta)
                                    Text("Notificações desativadas. Abra Ajustes do sistema para habilitar.")
                                        .font(Theme.font(13, .semibold))
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Theme.terracottaLight)
                                .cornerRadius(12)

                                Button {
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    }
                                } label: {
                                    Text("Abrir Ajustes")
                                        .font(Theme.font(13, .heavy))
                                }
                                .buttonStyle(.chunky)
                            } else if notificationStatus == .authorized {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.olive)
                                    Text("Notificações habilitadas")
                                        .font(Theme.font(13, .semibold))
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Theme.oliveLight)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Lembrete Diário
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Lembrete Diário")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Um versículo por dia, sempre na mesma hora")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { dailyReminderEnabled },
                                    set: { enabled in
                                        dailyReminderEnabled = enabled
                                        if enabled {
                                            scheduler.requestPermission { granted in
                                                if granted {
                                                    scheduler.scheduleDaily(hour: dailyReminderHour)
                                                }
                                            }
                                        } else {
                                            scheduler.cancelDaily()
                                        }
                                    }
                                ))
                                .tint(Theme.wheat)
                            }

                            if dailyReminderEnabled {
                                HStack {
                                    Text("Hora do lembrete")
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                    Picker("Hora", selection: Binding(
                                        get: { dailyReminderHour },
                                        set: { newHour in
                                            dailyReminderHour = newHour
                                            scheduler.cancelDaily()
                                            scheduler.scheduleDaily(hour: newHour)
                                        }
                                    )) {
                                        ForEach(0..<24, id: \.self) { h in
                                            Text(String(format: "%02d:00", h)).tag(h)
                                        }
                                    }
                                    .frame(maxWidth: 100)
                                    .foregroundStyle(Theme.wheat)
                                }
                                .padding(12)
                                .background(Theme.card)
                                .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        // MARK: - Aviso Pão em Risco
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Aviso de Pão em Risco")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Alerta à noite se não estudar hoje")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { breadRiskEnabled },
                                    set: { enabled in
                                        breadRiskEnabled = enabled
                                        if enabled {
                                            scheduler.requestPermission { granted in
                                                if granted {
                                                    scheduler.scheduleBreadRisk()
                                                }
                                            }
                                        } else {
                                            scheduler.cancelBreadRisk()
                                        }
                                    }
                                ))
                                .tint(Theme.wheat)
                            }
                        }
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        // MARK: - Aviso Óleo Cheio
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Óleo Cheio")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Lembrete quando suas vidas estão recarregadas")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { oilFullEnabled },
                                    set: { enabled in
                                        oilFullEnabled = enabled
                                        if enabled {
                                            scheduler.requestPermission { granted in
                                                if granted {
                                                    scheduler.scheduleOilFull()
                                                }
                                            }
                                        } else {
                                            scheduler.cancelOilFull()
                                        }
                                    }
                                ))
                                .tint(Theme.wheat)
                            }
                        }
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        // MARK: - Resumo Semanal
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Resumo Semanal")
                                        .font(Theme.font(16, .heavy))
                                        .foregroundStyle(Theme.ink)
                                    Text("Retrospectiva de sua semana toda domingo")
                                        .font(Theme.font(12, .semibold))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { weeklyReviewEnabled },
                                    set: { enabled in
                                        weeklyReviewEnabled = enabled
                                        if enabled {
                                            scheduler.requestPermission { granted in
                                                if granted {
                                                    scheduler.scheduleWeeklyReview()
                                                }
                                            }
                                        } else {
                                            scheduler.cancelWeeklyReview()
                                        }
                                    }
                                ))
                                .tint(Theme.wheat)
                            }
                        }
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)

                        Spacer(minLength: 32)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationStatus()
                loadNotificationPreferences()
            }
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
            }
        }
    }

    private func loadNotificationPreferences() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                dailyReminderEnabled = requests.contains { $0.identifier == "manna.daily.reminder" }
                breadRiskEnabled = requests.contains { $0.identifier == "manna.bread.risk" }
                oilFullEnabled = requests.contains { $0.identifier == "manna.oil.warning" }
                weeklyReviewEnabled = requests.contains { $0.identifier == "manna.weekly.review" }

                // Extrair hora do lembrete diário se estiver agendado
                if let dailyRequest = requests.first(where: { $0.identifier == "manna.daily.reminder" }) {
                    if let trigger = dailyRequest.trigger as? UNCalendarNotificationTrigger,
                       let hour = trigger.dateComponents.hour {
                        dailyReminderHour = hour
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationsSettingsView()
}
