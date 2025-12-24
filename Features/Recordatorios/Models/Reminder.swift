import Foundation

/// Datos adicionales para los recordatorios.
/// Un hábito puede tener 0..n recordatorios
public struct Reminder: Identifiable, Codable {
    public let id: UUID
    public var habitId: UUID
    public var hora: Date
    public var diasSemana: [Int]
    public var activo: Bool
}