//
//  NotificationManager.swift
//  Conversor de Moedas
//
//  Este módulo gerencia notificações e atualizações agendadas.
//  Criado por Bruno Maciel em 29/11/2024.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    /// Solicita permissão para notificações
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permissão concedida para notificações.")
            } else if let error = error {
                print("Erro ao solicitar permissão: \(error.localizedDescription)")
            }
        }
    }

    /// Agendar uma atualização diária às 10h
    func scheduleDailyUpdate(completion: @escaping () -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Atualização da Taxa de Câmbio"
        content.body = "As taxas de câmbio foram atualizadas."
        content.sound = .default

        // Configuração do horário da atualização
        var dateComponents = DateComponents()
        dateComponents.hour = 10 // Atualiza às 10h

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyUpdate",
            content: content,
            trigger: trigger
        )

        // Agendar a notificação
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                print("Notificação diária agendada.")
                // Executa a ação de atualização diária
                completion()
            }
        }
    }

    /// Envia uma notificação com a taxa atual
    func sendNotification(for rate: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Atualização de Taxa de Câmbio"
        content.body = "1 BRL agora vale \(String(format: "%.2f", rate)) COP."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Disparo imediato
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao enviar notificação: \(error.localizedDescription)")
            }
        }
    }
}
