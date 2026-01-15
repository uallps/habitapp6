//
//  PluginProtocols.swift
//  HabitTracker
//
//  Core - Protocolos base para el sistema de plugins SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

// MARK: - Base Plugin Protocol

/// Protocolo base que todos los plugins deben implementar
@MainActor
protocol FeaturePlugin: AnyObject {
    /// Indica si el plugin está habilitado
    var isEnabled: Bool { get }
    
    /// Identificador único del plugin
    var pluginId: String { get }
    
    /// Nombre descriptivo del plugin
    var pluginName: String { get }
    
    /// Descripción del plugin
    var pluginDescription: String { get }
}

// MARK: - Data Plugin Protocol

/// Protocolo para plugins que necesitan reaccionar a cambios en datos
protocol DataPlugin: FeaturePlugin {
    /// Se llama cuando se va a crear un hábito
    func willCreateHabit(_ habit: Habit) async
    
    /// Se llama después de que un hábito ha sido creado
    func didCreateHabit(_ habit: Habit) async
    
    /// Se llama cuando se va a eliminar un hábito
    func willDeleteHabit(_ habit: Habit) async
    
    /// Se llama después de que un hábito ha sido eliminado
    func didDeleteHabit(habitId: UUID) async
    
    /// Se llama cuando se completa/descompleta una instancia
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async
}

/// Extensión con implementaciones por defecto
extension DataPlugin {
    func willCreateHabit(_ habit: Habit) async {}
    func didCreateHabit(_ habit: Habit) async {}
    func willDeleteHabit(_ habit: Habit) async {}
    func didDeleteHabit(habitId: UUID) async {}
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {}
}

// MARK: - Notification Plugin Protocol

/// Protocolo específico para plugins que manejan notificaciones
protocol NotificationPlugin: FeaturePlugin {
    /// Programa notificaciones para un hábito
    func scheduleNotifications(for habit: Habit, instance: HabitInstance) async
    
    /// Cancela notificaciones de un hábito
    func cancelNotifications(for habit: Habit) async
    
    /// Cancela todas las notificaciones del plugin
    func cancelAllNotifications() async
}

// MARK: - Statistics Plugin Protocol

/// Protocolo para plugins que calculan estadísticas
protocol StatisticsPlugin: FeaturePlugin {
    associatedtype StatisticsResult
    
    /// Calcula estadísticas para un hábito
    func calculateStatistics(for habit: Habit, instances: [HabitInstance]) -> StatisticsResult
}
