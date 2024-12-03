//
//  NotificationManager.swift
//  Conversor de Moedas
//
//  Implementado sistema de atualizações automáticas duas vezes ao dia (10h e 12h) apenas em dias úteis (segunda a sexta).
//  Criado por Bruno Maciel em 29/11/2024.
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
    func scheduleDailyUpdates(at hours: [Int], updateAction: @escaping () -> Void) {
        let calendar = Calendar.current
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let now = Date()
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            let weekday = calendar.component(.weekday, from: now)
            
            // Verificar se é um dia útil (segunda=2, terça=3, ..., sexta=6)
            if (2...6).contains(weekday) {
                // Verificar se o horário corresponde a um dos horários especificados
                if hours.contains(currentHour) && currentMinute == 0 {
                    updateAction()
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
