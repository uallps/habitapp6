
import Foundation
import SwiftUI

public enum TipoLogro: String, Codable, CaseIterable, Identifiable {
    case primerHabito = "creador_1"
    case constructor = "creador_3"
    case primeraAccion = "accion_1"
    case constante = "accion_3"
    case experto = "accion_5"
    case inicioRacha = "racha_1"
    
    public var id: String { rawValue }
    
    var titulo: String {
        switch self {
        case .primerHabito: return "El Comienzo"
        case .constructor: return "Arquitecto"
        case .primeraAccion: return "Primer Paso"
        case .constante: return "Constante"
        case .experto: return "Experto"
        case .inicioRacha: return "Buena Racha"
        }
    }
    
    var descripcion: String {
        switch self {
        case .primerHabito: return "Crea tu primer hábito."
        case .constructor: return "Ten 3 hábitos creados."
        case .primeraAccion: return "Completa una tarea por primera vez."
        case .constante: return "Completa tareas 3 veces en total."
        case .experto: return "Completa tareas 5 veces en total."
        case .inicioRacha: return "Consigue tu primer día de racha."
        }
    }
    
    var icon: String {
        switch self {
        case .primerHabito: return "flag.fill"
        case .constructor: return "square.stack.3d.up.fill"
        case .primeraAccion: return "checkmark.circle.fill"
        case .constante: return "flame.fill"
        case .experto: return "star.circle.fill"
        case .inicioRacha: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .primerHabito: return .blue
        case .constructor: return .purple
        case .primeraAccion: return .green
        case .constante: return .orange
        case .experto: return .red
        case .inicioRacha: return .yellow
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
