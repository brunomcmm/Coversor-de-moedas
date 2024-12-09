//
//  NotificationManager.swift
//  Conversor de Moedas
//
//  Commit: Atualizado para incluir o valor atual na notificação de atualização programada.
//  Criado por Bruno Maciel.
//

import Foundation
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
    
    /// Agenda atualizações automáticas em horários específicos, apenas em dias úteis
    func scheduleDailyUpdates(at hours: [Int], fetchCurrentRate: @escaping () -> Double) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Remove notificações anteriores
        
        for hour in hours {
            for weekday in 2...6 { // Segunda=2, Sexta=6
                let content = UNMutableNotificationContent()
                content.title = "Atualização de Taxa de Câmbio"
                
                // Obtém o valor atual da taxa e inclui no corpo da notificação
                let currentRate = fetchCurrentRate()
                content.body = "1 BRL agora vale \(String(format: "%.2f", currentRate)) COP."
                content.sound = .default
                
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = 0
                dateComponents.weekday = weekday
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let request = UNNotificationRequest(
                    identifier: "update-\(hour)-\(weekday)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Erro ao agendar notificação: \(error.localizedDescription)")
                    } else {
                        print("Notificação agendada para \(hour):00 em dia \(weekday).")
                    }
                }
            }
        }
    }
    
    /// Envia uma notificação com a taxa atual (uso manual ou de emergência)
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
