import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Solicita permissão para enviar notificações
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permissão concedida para notificações.")
            } else if let error = error {
                print("Erro ao solicitar permissão: \(error.localizedDescription)")
            }
        }
    }

    /// Envia uma notificação com a taxa de câmbio atual
    /// - Parameter rate: Taxa de câmbio para incluir na notificação
    func sendNotification(for rate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Atualização de Taxa de Câmbio"
        content.body = "1 BRL agora vale \(String(format: "%.2f", rate)) COP."
        content.sound = .default

        // Disparar a notificação imediatamente
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Disparo imediato
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }
}
