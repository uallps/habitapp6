import Foundation

public class HabitInstance: Identifiable, Codable {
    public let id: UUID
    public let habitID: UUID
    public var fecha: Date
    public var completado: Bool
    
    public init(habitID: UUID, fecha: Date, completado: Bool = false) {
        self.id = UUID()
        self.habitID = habitID
        self.fecha = fecha
        self.completado = completado
    }
}
