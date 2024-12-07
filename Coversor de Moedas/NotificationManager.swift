//
//  NotificationManager.swift
//  Conversor de Moedas
//
//  Commit: Implementado sistema de atualizações automáticas duas vezes ao dia (10h e 12h) apenas em dias úteis (segunda a sexta).
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
    func scheduleDailyUpdates(at hours: [Int]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Remove notificações anteriores
        
        for hour in hours {
            let content = UNMutableNotificationContent()
            content.title = "Atualização de Taxa de Câmbio"
            content.body = "As taxas de câmbio foram atualizadas."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            dateComponents.weekday = nil // Não fixa um dia específico
            
            // Configuração para apenas dias úteis (segunda a sexta)
            for weekday in 2...6 { // Segunda=2, Sexta=6
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
