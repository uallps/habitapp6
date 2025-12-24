import Foundation

/// Modelo que representa un hábito. Diseñado para usarse como modelo de base de datos
/// (Codable para serialización, Identifiable para listas y UUID como llave primaria).
public struct Habit: Identifiable, Codable, Equatable, Hashable {
	public let id: UUID
	public var nombre: String
	public var frecuencia: Frecuencia
	public var fechaCreacion: Date
	public var activo: Bool

	/// Inicializador completo con valores por defecto razonables.
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

// MARK: - Samples / Helpers
public extension Habit {
	/// Ejemplo de uso rápido para previews y tests
	static let sample = Habit(nombre: "Ejemplo", frecuencia: .diario)
}

