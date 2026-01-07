//
//  RecordatorioManager.swift
//  HabitTracker
//
//  Feature: Recordatorios
//  Modelo que gestiona la configuración de recordatorios para un hábito
//

import Foundation

/// Configuración de recordatorio para un hábito
public class RecordatorioManager: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Indica si los recordatorios están habilitados para este hábito
    public var activo: Bool
    
    /// Hora preferida para recibir el recordatorio (hora y minuto)
    public var horaRecordatorio: Date
    
    /// Horas antes del fin del período para enviar recordatorio (por defecto 5 horas)
    public var horasAnticipacion: Int
    
    /// Identificador único para las notificaciones de este recordatorio
    public var notificationIdentifier: String
    
    // MARK: - Initialization
    
    public init(
        activo: Bool = true,
        horaRecordatorio: Date = RecordatorioManager.defaultHora(),
        horasAnticipacion: Int = 5
    ) {
        self.activo = activo
        self.horaRecordatorio = horaRecordatorio
        self.horasAnticipacion = horasAnticipacion
        self.notificationIdentifier = UUID().uuidString
    }
    
    // MARK: - Helper Methods
    
    /// Hora por defecto: 19:00 (7 PM)
    public static func defaultHora() -> Date {
        var components = DateComponents()
        components.hour = 19
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    /// Obtiene solo la hora y minuto del recordatorio
    public var horaYMinuto: (hora: Int, minuto: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: horaRecordatorio)
        return (components.hour ?? 19, components.minute ?? 0)
    }
    
    /// Formatea la hora para mostrar en UI
    public var horaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: horaRecordatorio)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: RecordatorioManager, rhs: RecordatorioManager) -> Bool {
        return lhs.activo == rhs.activo &&
               lhs.horaRecordatorio == rhs.horaRecordatorio &&
               lhs.horasAnticipacion == rhs.horasAnticipacion &&
               lhs.notificationIdentifier == rhs.notificationIdentifier
    }
}
