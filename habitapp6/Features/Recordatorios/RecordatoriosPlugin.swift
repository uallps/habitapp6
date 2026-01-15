//
//  RecordatoriosPlugin.swift
//  HabitTracker
//
//  Feature: Recordatorios - Plugin SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

/// Plugin que gestiona los recordatorios de hábitos
@MainActor
class RecordatoriosPlugin: DataPlugin, NotificationPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    var isEnabled: Bool {
        return config.showRecordatorios
    }
    
    let pluginId: String = "com.habittracker.recordatorios"
    let pluginName: String = "Recordatorios"
    let pluginDescription: String = "Envía notificaciones para recordarte completar tus hábitos"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    private let notificationService: NotificationService
    
    // MARK: - Initialization
    
    init(config: AppConfig) {
        self.config = config
        self.notificationService = NotificationService.shared
        print("🔔 RecordatoriosPlugin inicializado - Habilitado: \(isEnabled)")
    }
    
    // MARK: - DataPlugin Methods
    
    func willDeleteHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        
        // Cancelar recordatorios antes de eliminar el hábito
        await cancelNotifications(for: habit)
        print("🗑️ RecordatoriosPlugin: Recordatorios cancelados para '\(habit.nombre)'")
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        print("📝 RecordatoriosPlugin: Hábito \(habitId) eliminado completamente")
    }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        guard habit.recordar?.activo == true else { return }
        
        if instance.completado {
            // Si se completó, cancelar el recordatorio pendiente
            await cancelNotifications(for: habit)
            print("✅ RecordatoriosPlugin: Instancia completada, recordatorio cancelado")
        } else {
            // Si se descompletó, reprogramar el recordatorio
            await scheduleNotifications(for: habit, instance: instance)
            print("🔄 RecordatoriosPlugin: Instancia descompletada, recordatorio reprogramado")
        }
    }
    
    // MARK: - NotificationPlugin Methods
    
    func scheduleNotifications(for habit: Habit, instance: HabitInstance) async {
        guard isEnabled else { return }
        await notificationService.scheduleHabitReminder(for: habit, instance: instance)
    }
    
    func cancelNotifications(for habit: Habit) async {
        guard isEnabled else { return }
        notificationService.cancelReminder(for: habit)
    }
    
    func cancelAllNotifications() async {
        guard isEnabled else { return }
        notificationService.cancelAllReminders()
    }
    
    // MARK: - View Methods
    
    /// Provee vista para la fila del hábito en listas
    @ViewBuilder
    func habitRowView(for habit: Habit) -> some View {
        if isEnabled {
            RecordatorioBadgeView(habit: habit)
        }
    }
    
    /// Provee vista para el detalle del hábito
    @ViewBuilder
    func habitDetailSection(for habit: Habit, dataStore: HabitDataStore, showConfig: Binding<Bool>) -> some View {
        if isEnabled {
            Section {
                Button {
                    showConfig.wrappedValue = true
                } label: {
                    RecordatorioStatusView(habit: habit)
                }
                .buttonStyle(.plain)
            } header: {
                HStack {
                    Text("Recordatorio")
                    Spacer()
                    if habit.tieneRecordatorioActivo {
                        RecordatorioBadgeView(habit: habit)
                    }
                }
            } footer: {
                Text("Configura notificaciones para recordarte completar este hábito antes de que termine el período.")
            }
        }
    }
    
    /// Provee el botón rápido de recordatorio
    @ViewBuilder
    func quickButton(for habit: Habit, action: @escaping () -> Void) -> some View {
        if isEnabled {
            RecordatorioQuickButton(habit: habit, action: action)
        }
    }
    
    /// Provee la vista de configuración del plugin
    @ViewBuilder
    func settingsView() -> some View {
        Toggle("Mostrar Recordatorios", isOn: Binding(
            get: { self.config.showRecordatorios },
            set: { self.config.showRecordatorios = $0 }
        ))
    }
}
