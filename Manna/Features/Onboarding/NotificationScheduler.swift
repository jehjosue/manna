import Foundation
import UserNotifications
import UIKit

/// Gerencia agendamento de notificações diárias do Manna.
struct NotificationScheduler {
    static let shared = NotificationScheduler()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationId = "manna.daily.reminder"

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
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }

    /// Cancela todas as notificações diárias.
    func cancelDaily() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
}
