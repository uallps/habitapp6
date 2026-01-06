import Foundation
import UserNotifications

class RecordatorioManager {
    static let shared = RecordatorioManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    /// Solicita permisos al usuario
    func requestPermissions() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting permissions: \(error)")
            return false
        }
    }
    
    /// Programa notificación 5 horas antes del deadline
    func scheduleNotification(for habit: Habit) async {
        await cancelNotification(for: habit.id)
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Recordatorio"
        content.body = "¡Quedan menos de 5 horas para completar '\(habit.nombre)'!"
        content.sound = .default
        
        let trigger: UNNotificationTrigger
        
        switch habit.frecuencia {
        case .diario:
            // 19:00 cada día (5 horas antes de medianoche)
            var dateComponents = DateComponents()
            dateComponents.hour = 19
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
        case .semanal:
            // Domingo 19:00 (5 horas antes del lunes 00:00)
            var dateComponents = DateComponents()
            dateComponents.weekday = 1 // Domingo
            dateComponents.hour = 19
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    /// Cancela notificación de un hábito
    func cancelNotification(for habitID: UUID) async {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habitID.uuidString)"]
        )
    }
    
    /// Cancela notificación solo si la instancia está completada
    func checkAndCancelIfCompleted(instance: HabitInstance, habit: Habit) async {
        if instance.completado {
            await cancelNotification(for: habit.id)
        }
    }
}

