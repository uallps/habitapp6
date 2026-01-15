//
//  NotificationService.swift
//  HabitTracker
//
//  Feature: Recordatorios
//  Servicio para gestionar notificaciones locales del sistema
//

import Foundation
import UserNotifications

/// Protocolo para el servicio de notificaciones (útil para testing y SPL)
@MainActor
public protocol NotificationServiceProtocol {
    func requestAuthorization() async -> Bool
    func scheduleHabitReminder(for habit: Habit, instance: HabitInstance) async
    func cancelReminder(for habit: Habit)
    func cancelAllReminders()
    func checkPendingNotifications() async -> [UNNotificationRequest]
}

/// Servicio singleton para gestionar notificaciones locales
@MainActor
public class NotificationService: NSObject, ObservableObject, NotificationServiceProtocol {
    
    // MARK: - Singleton
    
    public static let shared = NotificationService()
    
    // MARK: - Properties
    
    @Published public var isAuthorized: Bool = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Solicita permisos de notificación al usuario
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            isAuthorized = granted
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error solicitando autorización de notificaciones: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Verifica el estado actual de autorización
    public func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Schedule Notifications
    
    /// Programa un recordatorio para un hábito específico
    /// La notificación se envía cuando faltan menos de 5 horas para la siguiente instancia
    public func scheduleHabitReminder(for habit: Habit, instance: HabitInstance) async {
        // Verificar que el hábito tiene recordatorios activos
        guard let recordatorio = habit.recordar, recordatorio.activo else {
            return
        }
        
        // Verificar que la instancia no está completada
        guard !instance.completado else {
            return
        }
        
        // Calcular cuándo enviar la notificación
        guard let triggerDate = calculateTriggerDate(
            for: habit,
            instance: instance,
            horasAnticipacion: recordatorio.horasAnticipacion
        ) else {
            return
        }
        
        // Crear el contenido de la notificación
        let content = UNMutableNotificationContent()
        content.title = "⏰ Recordatorio de Hábito"
        content.body = "¡No olvides completar '\(habit.nombre)'! Te quedan menos de \(recordatorio.horasAnticipacion) horas."
        content.sound = .default
        content.badge = 1
        
        // Añadir información adicional
        content.userInfo = [
            "habitID": habit.id.uuidString,
            "instanceID": instance.id.uuidString,
            "habitNombre": habit.nombre
        ]
        
        // Crear el trigger basado en la fecha calculada
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: false
        )
        
        // Crear identificador único para esta notificación
        let identifier = "\(recordatorio.notificationIdentifier)_\(instance.id.uuidString)"
        
        // Crear y programar la request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            print("✅ Notificación programada para '\(habit.nombre)' a las \(triggerDate)")
        } catch {
            print("❌ Error programando notificación: \(error.localizedDescription)")
        }
    }
    
    /// Programa recordatorios para todos los hábitos activos con recordatorios
    public func scheduleAllReminders(habits: [Habit], instances: [HabitInstance]) async {
        for habit in habits where habit.activo && habit.recordar?.activo == true {
            // Buscar instancia pendiente para hoy
            if let instance = instances.first(where: {
                $0.habitID == habit.id && !$0.completado
            }) {
                await scheduleHabitReminder(for: habit, instance: instance)
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancela los recordatorios de un hábito específico
    public func cancelReminder(for habit: Habit) {
        guard let recordatorio = habit.recordar else { return }
        
        // Cancelar todas las notificaciones que contengan el identificador del recordatorio
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(recordatorio.notificationIdentifier) }
                .map { $0.identifier }
            
            self?.notificationCenter.removePendingNotificationRequests(
                withIdentifiers: identifiersToRemove
            )
            print("🗑️ Cancelados \(identifiersToRemove.count) recordatorios para '\(habit.nombre)'")
        }
    }
    
    /// Cancela un recordatorio específico por su identificador
    public func cancelReminder(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancela todos los recordatorios pendientes
    public func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("🗑️ Todos los recordatorios cancelados")
    }
    
    // MARK: - Query Notifications
    
    /// Obtiene todas las notificaciones pendientes
    public func checkPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    /// Verifica si un hábito tiene recordatorios pendientes
    public func hasPendingReminder(for habit: Habit) async -> Bool {
        guard let recordatorio = habit.recordar else { return false }
        
        let pendingRequests = await checkPendingNotifications()
        return pendingRequests.contains {
            $0.identifier.contains(recordatorio.notificationIdentifier)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Calcula la fecha de disparo de la notificación
    /// La notificación se dispara X horas antes del final del período del hábito
    private func calculateTriggerDate(
        for habit: Habit,
        instance: HabitInstance,
        horasAnticipacion: Int
    ) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // Calcular el fin del período según la frecuencia
        let endOfPeriod: Date
        
        switch habit.frecuencia {
        case .diario:
            // Fin del día (23:59:59)
            guard let endOfDay = calendar.date(
                bySettingHour: 23,
                minute: 59,
                second: 59,
                of: instance.fecha
            ) else {
                return nil
            }
            endOfPeriod = endOfDay
            
        case .semanal:
            // Fin de la semana (domingo 23:59:59)
            var components = calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: instance.fecha
            )
            components.weekday = 1 // Domingo
            components.hour = 23
            components.minute = 59
            components.second = 59
            
            guard let weekEnd = calendar.date(from: components),
                  let nextWeekEnd = calendar.date(byAdding: .day, value: 7, to: weekEnd) else {
                return nil
            }
            endOfPeriod = nextWeekEnd
        }
        
        // Calcular fecha de trigger (X horas antes del fin del período)
        guard let triggerDate = calendar.date(
            byAdding: .hour,
            value: -horasAnticipacion,
            to: endOfPeriod
        ) else {
            return nil
        }
        
        // Solo programar si la fecha de trigger es en el futuro
        if triggerDate > now {
            return triggerDate
        }
        
        return nil
    }
}

// MARK: - UNUserNotificationCenterDelegate Extension

extension NotificationService: UNUserNotificationCenterDelegate {
    
    /// Maneja notificaciones recibidas mientras la app está en primer plano
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Mostrar la notificación incluso si la app está en primer plano
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Maneja la respuesta del usuario a una notificación
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let habitID = userInfo["habitID"] as? String {
            print("📱 Usuario interactuó con recordatorio del hábito: \(habitID)")
            // Aquí se podría notificar a otros componentes para navegar al hábito
            NotificationCenter.default.post(
                name: .habitReminderTapped,
                object: nil,
                userInfo: ["habitID": habitID]
            )
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let habitReminderTapped = Notification.Name("habitReminderTapped")
}
