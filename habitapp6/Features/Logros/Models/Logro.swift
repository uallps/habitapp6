
import Foundation
import SwiftUI

public enum TipoLogro: String, Codable, CaseIterable, Identifiable {
    case primerHabito = "creador_1"
    case multicreator = "creador_3"     
    case primeraAccion = "accion_1"
    case rachaExpress = "accion_3"
    case imparable = "accion_5"
    
    public var id: String { rawValue }
    
    var titulo: String {
        switch self {
        case .primerHabito: return "El Comienzo"
        case .multicreator: return "Arquitecto"
        case .primeraAccion: return "Primer Paso"
        case .rachaExpress: return "En Movimiento"
        case .imparable: return "Imparable"
        }
    }
    
    var descripcion: String {
        switch self {
        case .primerHabito: return "Crea tu primer hábito."
        case .multicreator: return "Ten 3 hábitos creados en tu lista."
        case .primeraAccion: return "Completa una tarea por primera vez."
        case .rachaExpress: return "Completa tareas 3 veces."
        case .imparable: return "Completa tareas 5 veces."
        }
    }
    
    var icon: String {
        switch self {
        case .primerHabito: return "flag.fill"
        case .multicreator: return "square.stack.3d.up.fill"
        case .primeraAccion: return "checkmark.circle.fill"
        case .rachaExpress: return "flame.fill"
        case .imparable: return "star.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .primerHabito: return .blue
        case .multicreator: return .purple
        case .primeraAccion: return .green
        case .rachaExpress: return .orange
        case .imparable: return .yellow
        }
    }
}

public struct Logro: Identifiable, Codable, Equatable {
    public let id: String
    public let tipo: TipoLogro
    public var desbloqueado: Bool
    public var fechaDesbloqueo: Date?
    
    public var progresoActual: Int
    public var progresoTotal: Int
    
    public init(tipo: TipoLogro, desbloqueado: Bool = false, fechaDesbloqueo: Date? = nil, progresoActual: Int = 0, progresoTotal: Int = 1) {
        self.id = tipo.rawValue
        self.tipo = tipo
        self.desbloqueado = desbloqueado
        self.fechaDesbloqueo = fechaDesbloqueo
        self.progresoActual = progresoActual
        self.progresoTotal = progresoTotal
    }
    
    var porcentaje: Double {
        if progresoTotal == 0 { return 0 }
        return min(1.0, Double(progresoActual) / Double(progresoTotal))
    }
}
