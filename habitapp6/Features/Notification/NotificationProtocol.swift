//
//  NotificationProtocol.swift
//  habitapp6
//
//  Created by Oscar Marquez jurado on 7/1/26.
//

import Foundation

// MARK: - Feature Protocol (Punto de Variabilidad SPL)

/// Protocol que define la interfaz para la feature de notificaciones
/// Permite intercambiar implementaciones según la configuración del producto
protocol NotificationFeature {
    /// Solicita permisos al usuario para enviar notificaciones
    func requestPermissions() async -> Bool
    
    /// Programa notificaciones para un hábito específico
    func scheduleNotifications(for habit: Habit) async
    
    /// Cancela todas las notificaciones de un hábito
    func cancelNotifications(for habitID: UUID) async
    
    /// Actualiza notificaciones cuando cambia el estado de una instancia
    func updateNotifications(for instance: HabitInstance, habit: Habit) async
    
    /// Cancela todas las notificaciones programadas
    func cancelAllNotifications() async
}
