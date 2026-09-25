import Foundation
import UserNotifications
import UIKit

/// Gerencia agendamento de notificações diárias do Manna com múltiplos tipos.
struct NotificationScheduler {
    static let shared = NotificationScheduler()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderId = "manna.daily.reminder"
    private let breadRiskId = "manna.bread.risk"
    private let oilWarningId = "manna.oil.warning"
    private let weeklyReviewId = "manna.weekly.review"

    /// Textos rotativos do lembrete diário.
    private let reminderTexts = [
        "Béé! Seu pão diário está esperando 🍞",
        "Um versículo por dia faz bem para a alma 🐑",
        "A jornada de volta ao Bom Pastor continua! 🐑",
        "Sua sequência espera por você hoje",
        "Mais um dia na jornada de Manna ✨",
    ]

    /// Solicita permissão de notificação ao usuário.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Agenda notificação diária repetida para a hora especificada (0-23).
    func scheduleDaily(hour: Int) {
        guard (0...23).contains(hour) else { return }

        let content = UNMutableNotificationContent()
        content.sound = .default

        // Rotaciona entre textos
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let textIndex = (dayOfYear - 1) % reminderTexts.count
        content.body = reminderTexts[textIndex]

        // Trigger: repetir diariamente nessa hora
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderId, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação diária: \(error.localizedDescription)")
            }
        }
    }

    /// Cancela notificação diária.
    func cancelDaily() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }

    /// Agenda aviso de pão em risco para noite (21h) se não estudar hoje.
    func scheduleBreadRisk() {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = "Seu pão diário está em risco! Estude antes da meia-noite 🍞"

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: breadRiskId, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Erro ao agendar aviso de pão: \(error.localizedDescription)")
            }
        }
    }

    /// Cancela aviso de pão.
    func cancelBreadRisk() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [breadRiskId])
    }

    /// Agenda aviso quando óleo cheio (para assinantes que querem lembrete).
    func scheduleOilFull() {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = "Seu óleo está cheio! Aproveite para estudar sem limites 💧"

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: oilWarningId, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Erro ao agendar aviso de óleo: \(error.localizedDescription)")
            }
        }
    }

    /// Cancela aviso de óleo.
    func cancelOilFull() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [oilWarningId])
    }

    /// Agenda resumo semanal para domingo 18h.
    func scheduleWeeklyReview() {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.body = "Veja sua retrospectiva da semana! Como foi sua jornada? 📊"

        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // domingo
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyReviewId, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Erro ao agendar resumo semanal: \(error.localizedDescription)")
            }
        }
    }

    /// Cancela resumo semanal.
    func cancelWeeklyReview() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [weeklyReviewId])
    }

    /// Cancela todas as notificações.
    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
