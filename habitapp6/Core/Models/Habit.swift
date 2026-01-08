//
//  Habit.swift
//  HabitTracker
//
//  Core Model - Actualizado con soporte para Recordatorios y Categorías
//

import Foundation

public class Habit: Identifiable, Codable {
    
    // MARK: - Properties
    
    public let id: UUID
    public var nombre: String
    public var frecuencia: Frecuencia
    public var fechaCreacion: Date
    public var activo: Bool
    public var recordar: RecordatorioManager?
    public var categoria: String? 
    
    // MARK: - Initialization
    
    public init(
        nombre: String,
        frecuencia: Frecuencia = .diario,
        fechaCreacion: Date = Date(),
        activo: Bool = true,
        recordar: RecordatorioManager? = nil,
        categoria: String? = nil
    ) {
        self.id = UUID()
        self.nombre = nombre
        self.frecuencia = frecuencia
        self.fechaCreacion = fechaCreacion
        self.activo = activo
        self.recordar = recordar
        self.categoria = categoria
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case frecuencia
        case fechaCreacion
        case activo
        case recordar
        case categoria
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        nombre = try container.decode(String.self, forKey: .nombre)
        frecuencia = try container.decode(Frecuencia.self, forKey: .frecuencia)
        fechaCreacion = try container.decode(Date.self, forKey: .fechaCreacion)
        activo = try container.decode(Bool.self, forKey: .activo)
        recordar = try container.decodeIfPresent(RecordatorioManager.self, forKey: .recordar)
        categoria = try container.decodeIfPresent(String.self, forKey: .categoria)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nombre, forKey: .nombre)
        try container.encode(frecuencia, forKey: .frecuencia)
        try container.encode(fechaCreacion, forKey: .fechaCreacion)
        try container.encode(activo, forKey: .activo)
        try container.encodeIfPresent(recordar, forKey: .recordar)
        try container.encodeIfPresent(categoria, forKey: .categoria)
    }
    
    // MARK: - Recordatorio Helpers
    
    /// Indica si el hábito tiene recordatorios activos
    public var tieneRecordatorioActivo: Bool {
        return recordar?.activo ?? false
    }
    
    /// Activa el recordatorio con valores por defecto
    public func activarRecordatorio(horasAnticipacion: Int = 5) {
        if recordar == nil {
            recordar = RecordatorioManager(
                activo: true,
                horasAnticipacion: horasAnticipacion
            )
        } else {
            recordar?.activo = true
        }
    }
    
    /// Desactiva el recordatorio
    public func desactivarRecordatorio() {
        recordar?.activo = false
    }
}
