//
//  Meta.swift
//  HabitTracker
//
//  Feature: Metas - Modelo de meta de hábito
//

import Foundation
import SwiftUI

/// Períodos de tiempo disponibles para las metas
public enum PeriodoMeta: String, CaseIterable, Codable, Identifiable {
    case semana = "1_semana"           // Corto plazo
    case mes = "1_mes"                 // Medio-corto plazo
    case tresMeses = "3_meses"         // Medio plazo
    case seisMeses = "6_meses"         // Largo plazo
    case nueveMeses = "9_meses"        // Largo plazo
    case año = "1_año"                 // Muy largo plazo
    
    public var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// Nombre para mostrar en la UI
    var displayName: String {
        switch self {
        case .semana: return "1 Semana"
        case .mes: return "1 Mes"
        case .tresMeses: return "3 Meses"
        case .seisMeses: return "6 Meses"
        case .nueveMeses: return "9 Meses"
        case .año: return "1 Año"
        }
    }
    
    /// Descripción del tipo de plazo
    var descripcionPlazo: String {
        switch self {
        case .semana: return "Corto plazo"
        case .mes: return "Medio-corto plazo"
        case .tresMeses: return "Medio plazo"
        case .seisMeses: return "Largo plazo"
        case .nueveMeses: return "Largo plazo"
        case .año: return "Muy largo plazo"
        }
    }
    
    /// Color asociado al período
    var color: Color {
        switch self {
        case .semana: return .green
        case .mes: return .blue
        case .tresMeses: return .purple
        case .seisMeses: return .orange
        case .nueveMeses: return .red
        case .año: return .pink
        }
    }
    
    /// Icono SF Symbol asociado al período
    var icon: String {
        switch self {
        case .semana: return "calendar.badge.clock"
        case .mes: return "calendar"
        case .tresMeses: return "calendar.badge.plus"
        case .seisMeses: return "calendar.circle"
        case .nueveMeses: return "calendar.circle.fill"
        case .año: return "star.circle.fill"
        }
    }
    
    /// Número de días del período
    var diasTotales: Int {
        switch self {
        case .semana: return 7
        case .mes: return 30
        case .tresMeses: return 90
        case .seisMeses: return 180
        case .nueveMeses: return 270
        case .año: return 365
        }
    }
    
    /// Calcula la fecha de fin basada en una fecha de inicio
    func fechaFin(desde inicio: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: diasTotales, to: inicio) ?? inicio
    }
}

/// Estado de una meta
public enum EstadoMeta: String, Codable {
    case activa = "activa"
    case completada = "completada"
    case fallida = "fallida"
    case cancelada = "cancelada"
    
    var displayName: String {
        switch self {
        case .activa: return "Activa"
        case .completada: return "Completada"
        case .fallida: return "Fallida"
        case .cancelada: return "Cancelada"
        }
    }
    
    var color: Color {
        switch self {
        case .activa: return .blue
        case .completada: return .green
        case .fallida: return .red
        case .cancelada: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .activa: return "target"
        case .completada: return "checkmark.seal.fill"
        case .fallida: return "xmark.seal.fill"
        case .cancelada: return "minus.circle.fill"
        }
    }
}

/// Modelo que representa una meta de un hábito
public class Meta: Identifiable, Codable {
    
    // MARK: - Properties
    
    public let id: UUID
    public let habitID: UUID
    public var nombre: String
    public var descripcion: String
    public var objetivo: Int                    // Número de veces a completar
    public var periodo: PeriodoMeta
    public var fechaInicio: Date
    public var fechaFin: Date
    public var estado: EstadoMeta
    public var fechaCompletado: Date?           // Fecha en que se completó (si aplica)
    
    // MARK: - Initialization
    
    public init(
        habitID: UUID,
        nombre: String,
        descripcion: String = "",
        objetivo: Int,
        periodo: PeriodoMeta,
        fechaInicio: Date = Date()
    ) {
        self.id = UUID()
        self.habitID = habitID
        self.nombre = nombre
        self.descripcion = descripcion
        self.objetivo = objetivo
        self.periodo = periodo
        self.fechaInicio = fechaInicio
        self.fechaFin = periodo.fechaFin(desde: fechaInicio)
        self.estado = .activa
        self.fechaCompletado = nil
    }
    
    // MARK: - Computed Properties
    
    /// Indica si la meta está activa
    var estaActiva: Bool {
        return estado == .activa
    }
    
    /// Indica si la meta ha expirado (pasó la fecha fin sin completarse)
    var haExpirado: Bool {
        return Date() > fechaFin && estado == .activa
    }
    
    /// Días restantes para completar la meta
    var diasRestantes: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: fechaFin)
        return max(0, components.day ?? 0)
    }
    
    /// Porcentaje del tiempo transcurrido
    var porcentajeTiempoTranscurrido: Double {
        let tiempoTotal = fechaFin.timeIntervalSince(fechaInicio)
        let tiempoTranscurrido = Date().timeIntervalSince(fechaInicio)
        return min(1.0, max(0.0, tiempoTranscurrido / tiempoTotal))
    }
    
    /// Descripción formateada del objetivo
    var descripcionObjetivo: String {
        return "\(objetivo) veces en \(periodo.displayName.lowercased())"
    }
    
    // MARK: - Methods
    
    /// Marca la meta como completada
    func marcarCompletada() {
        estado = .completada
        fechaCompletado = Date()
    }
    
    /// Marca la meta como fallida
    func marcarFallida() {
        estado = .fallida
    }
    
    /// Cancela la meta
    func cancelar() {
        estado = .cancelada
    }
    
    /// Calcula el progreso actual basado en las instancias completadas
    func calcularProgreso(instancias: [HabitInstance]) -> MetaProgreso {
        let instanciasEnPeriodo = instancias.filter { instance in
            instance.habitID == habitID &&
            instance.completado &&
            instance.fecha >= fechaInicio &&
            instance.fecha <= fechaFin
        }
        
        let completadas = instanciasEnPeriodo.count
        let porcentaje = Double(completadas) / Double(objetivo)
        
        return MetaProgreso(
            meta: self,
            completadas: completadas,
            objetivo: objetivo,
            porcentaje: min(1.0, porcentaje),
            diasRestantes: diasRestantes
        )
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case habitID
        case nombre
        case descripcion
        case objetivo
        case periodo
        case fechaInicio
        case fechaFin
        case estado
        case fechaCompletado
    }
}

/// Información de progreso de una meta
public struct MetaProgreso: Equatable {
    public let meta: Meta
    public let completadas: Int
    public let objetivo: Int
    public let porcentaje: Double
    public let diasRestantes: Int
    
    /// Indica si la meta está completada
    var estaCompletada: Bool {
        return completadas >= objetivo
    }
    
    /// Descripción del progreso
    var descripcionProgreso: String {
        return "\(completadas) de \(objetivo)"
    }
    
    /// Porcentaje formateado
    var porcentajeFormateado: String {
        return String(format: "%.0f%%", porcentaje * 100)
    }
    
    /// Color del progreso según el estado
    var colorProgreso: Color {
        if estaCompletada {
            return .green
        } else if porcentaje >= 0.75 {
            return .blue
        } else if porcentaje >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: MetaProgreso, rhs: MetaProgreso) -> Bool {
        return lhs.meta.id == rhs.meta.id &&
               lhs.completadas == rhs.completadas &&
               lhs.objetivo == rhs.objetivo
    }
}

// MARK: - Meta Extension for Display

extension Meta: Equatable {
    public static func == (lhs: Meta, rhs: Meta) -> Bool {
        return lhs.id == rhs.id
    }
}
