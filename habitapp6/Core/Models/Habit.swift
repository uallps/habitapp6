import Foundation

public class Habit: Identifiable, Codable {
        
    public let id: UUID
    public var nombre: String
    public var frecuencia: Frecuencia
    public var fechaCreacion: Date
    public var activo: Bool
    public var recordar : RecordatorioManager?
    
    public init(nombre: String, frecuencia: Frecuencia = .diario,
                fechaCreacion: Date = Date(), activo: Bool = true, recordar: RecoratorioManager? = nil) {
        self.id = UUID()
        self.nombre = nombre
        self.frecuencia = frecuencia
        self.fechaCreacion = fechaCreacion
        self.activo = activo
        self.recordar = recordar
    }
}
