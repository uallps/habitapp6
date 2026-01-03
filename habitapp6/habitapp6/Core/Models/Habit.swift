import Foundation

public struct Habit: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var nombre: String
    public var frecuencia: Frecuencia
    public var fechaCreacion: Date
    public var activo: Bool
    
    public init(
        id: UUID = UUID(),
        nombre: String,
        frecuencia: Frecuencia = .diario,
        fechaCreacion: Date = Date(),
        activo: Bool = true
    ) {
        self.id = id
        self.nombre = nombre
        self.frecuencia = frecuencia
        self.fechaCreacion = fechaCreacion
        self.activo = activo
    }
}

public extension Habit {
    static let sample = Habit(nombre: "Ejemplo", frecuencia: .diario)
}
