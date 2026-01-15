//
//  RachaInfo.swift
//  HabitTracker
//
//  Feature: Rachas
//  Modelo que representa la información de racha de un hábito
//

import Foundation

/// Información de racha para un hábito
public struct RachaInfo: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Racha actual (períodos consecutivos completados)
    public let rachaActual: Int
    
    /// Mejor racha histórica
    public let mejorRacha: Int
    
    /// Fecha de inicio de la racha actual
    public let inicioRachaActual: Date?
    
    /// Total de períodos completados históricamente
    public let totalCompletados: Int
    
    /// Total de períodos desde la creación del hábito
    public let totalPeriodos: Int
    
    /// Indica si la racha está en riesgo (período actual no completado)
    public let rachaEnRiesgo: Bool
    
    /// Frecuencia del hábito (para mostrar unidad correcta)
    public let frecuencia: Frecuencia
    
    // MARK: - Computed Properties
    
    /// Porcentaje de completado histórico
    public var porcentajeCompletado: Double {
        guard totalPeriodos > 0 else { return 0 }
        return Double(totalCompletados) / Double(totalPeriodos) * 100
    }
    
    /// Unidad de tiempo según frecuencia
    public var unidadTiempo: String {
        switch frecuencia {
        case .diario:
            return rachaActual == 1 ? "día" : "días"
        case .semanal:
            return rachaActual == 1 ? "semana" : "semanas"
        }
    }
    
    /// Unidad de tiempo para mejor racha
    public var unidadTiempoMejorRacha: String {
        switch frecuencia {
        case .diario:
            return mejorRacha == 1 ? "día" : "días"
        case .semanal:
            return mejorRacha == 1 ? "semana" : "semanas"
        }
    }
    
    /// Descripción de la racha actual
    public var descripcionRacha: String {
        if rachaActual == 0 {
            return "Sin racha activa"
        }
        return "\(rachaActual) \(unidadTiempo)"
    }
    
    /// Descripción de la mejor racha
    public var descripcionMejorRacha: String {
        if mejorRacha == 0 {
            return "Sin récord"
        }
        return "\(mejorRacha) \(unidadTiempoMejorRacha)"
    }
    
    /// Indica si la racha actual es la mejor racha
    public var esNuevoRecord: Bool {
        return rachaActual > 0 && rachaActual >= mejorRacha
    }
    
    // MARK: - Initialization
    
    public init(
        rachaActual: Int = 0,
        mejorRacha: Int = 0,
        inicioRachaActual: Date? = nil,
        totalCompletados: Int = 0,
        totalPeriodos: Int = 0,
        rachaEnRiesgo: Bool = false,
        frecuencia: Frecuencia = .diario
    ) {
        self.rachaActual = rachaActual
        self.mejorRacha = mejorRacha
        self.inicioRachaActual = inicioRachaActual
        self.totalCompletados = totalCompletados
        self.totalPeriodos = totalPeriodos
        self.rachaEnRiesgo = rachaEnRiesgo
        self.frecuencia = frecuencia
    }
    
    // MARK: - Static
    
    /// RachaInfo vacía por defecto
    public static var empty: RachaInfo {
        RachaInfo()
    }
}

// MARK: - Milestone

/// Representa un hito de racha alcanzado
public struct RachaMilestone: Identifiable, Equatable {
    public let id = UUID()
    public let valor: Int
    public let emoji: String
    public let titulo: String
    public let descripcion: String
    
    public static let milestones: [RachaMilestone] = [
        RachaMilestone(valor: 3, emoji: "🌱", titulo: "Brote", descripcion: "¡3 períodos consecutivos!"),
        RachaMilestone(valor: 7, emoji: "🌿", titulo: "Crecimiento", descripcion: "¡Una semana de constancia!"),
        RachaMilestone(valor: 14, emoji: "🌳", titulo: "Arraigado", descripcion: "¡2 semanas sin fallar!"),
        RachaMilestone(valor: 21, emoji: "⭐", titulo: "Hábito Formado", descripcion: "¡21 períodos! El hábito se está formando"),
        RachaMilestone(valor: 30, emoji: "🔥", titulo: "En Llamas", descripcion: "¡Un mes completo!"),
        RachaMilestone(valor: 50, emoji: "💎", titulo: "Diamante", descripcion: "¡50 períodos de dedicación!"),
        RachaMilestone(valor: 100, emoji: "🏆", titulo: "Centenario", descripcion: "¡100 períodos! Eres imparable"),
        RachaMilestone(valor: 365, emoji: "👑", titulo: "Leyenda", descripcion: "¡Un año completo!")
    ]
    
    /// Obtiene el milestone actual según la racha
    public static func milestoneActual(para racha: Int) -> RachaMilestone? {
        return milestones.filter { $0.valor <= racha }.last
    }
    
    /// Obtiene el próximo milestone a alcanzar
    public static func proximoMilestone(para racha: Int) -> RachaMilestone? {
        return milestones.first { $0.valor > racha }
    }
    
    /// Calcula el progreso hacia el próximo milestone (0.0 - 1.0)
    public static func progresoHaciaProximo(racha: Int) -> Double {
        guard let proximo = proximoMilestone(para: racha) else { return 1.0 }
        let anterior = milestones.filter { $0.valor <= racha }.last?.valor ?? 0
        let rango = proximo.valor - anterior
        let progreso = racha - anterior
        return Double(progreso) / Double(rango)
    }
}
