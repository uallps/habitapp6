import Foundation

public struct HabitInstance: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let habitID: UUID
    public let fecha: Date
    public var completado: Bool
    
    public init(habitID: UUID, fecha: Date, completado: Bool = false) {
        self.id = UUID()
        self.habitID = habitID
        self.fecha = fecha
        self.completado = completado
    }
}
