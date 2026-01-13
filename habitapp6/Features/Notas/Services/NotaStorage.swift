//
//  NotaStorage.swift
//  HabitTracker
//
//  Feature: Notas
//  Servicio para gestionar el almacenamiento y recuperación de notas
//

import Foundation

/// Protocolo para el almacenamiento de notas (útil para testing y SPL)
public protocol NotaStorageProtocol {
    func guardarNota(_ nota: Nota) async throws
    func obtenerNota(id: UUID) async throws -> Nota?
    func obtenerNotas(habitID: UUID) async throws -> [Nota]
    func obtenerNotas(filtro: NotaFiltro) async throws -> [Nota]
    func obtenerTodasLasNotas() async throws -> [Nota]
    func eliminarNota(id: UUID) async throws
    func actualizarNota(_ nota: Nota) async throws
    func calcularEstadisticas(habitID: UUID) async throws -> NotaEstadisticas
}

/// Servicio para gestionar el almacenamiento de notas
public class NotaStorage: ObservableObject, NotaStorageProtocol {
    
    // MARK: - Singleton
    
    nonisolated public static let shared = NotaStorage()
    
    // MARK: - Published Properties
    
    @Published public private(set) var notas: [Nota] = []
    
    // MARK: - Private Properties
    
    private let fileManager = FileManager.default
    private let calendar = Calendar.current
    
    // MARK: - Main Actor Isolation
    
    @MainActor private var _mainActorMaker: Void = ()
    
    private var documentosURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var notasFileURL: URL {
        documentosURL.appendingPathComponent("notas.json")
    }
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await cargarNotas()
        }
    }
    
    // MARK: - Public Methods
    
    /// Guarda una nueva nota
    public func guardarNota(_ nota: Nota) async throws {
        // Verificar si ya existe una nota para ese hábito en esa fecha
        if let existente = notas.first(where: {
            $0.habitID == nota.habitID &&
            calendar.isDate($0.fecha, inSameDayAs: nota.fecha)
        }) {
            // Si existe, actualizar en lugar de crear duplicado
            var notaActualizada = existente
            notaActualizada.actualizarContenido(nota.contenido)
            try await actualizarNota(notaActualizada)
        } else {
            notas.append(nota)
            try await persistirNotas()
        }
    }
    
    /// Obtiene una nota específica por ID
    public func obtenerNota(id: UUID) async throws -> Nota? {
        return notas.first { $0.id == id }
    }
    
    /// Obtiene todas las notas de un hábito específico
    public func obtenerNotas(habitID: UUID) async throws -> [Nota] {
        return notas
            .filter { $0.habitID == habitID }
            .sorted { $0.fecha > $1.fecha }
    }
    
    /// Obtiene notas aplicando filtros
    public func obtenerNotas(filtro: NotaFiltro) async throws -> [Nota] {
        var resultado = notas
        
        // Filtrar por hábitos específicos
        if !filtro.habitIDs.isEmpty {
            resultado = resultado.filter { filtro.habitIDs.contains($0.habitID) }
        }
        
        // Filtrar por rango de fechas
        if let rango = filtro.rangoFechas {
            resultado = resultado.filter { rango.contains($0.fecha) }
        }
        
        // Filtrar solo importantes
        if filtro.soloImportantes {
            resultado = resultado.filter { $0.esImportante }
        }
        
        // Filtrar por tags
        if !filtro.tags.isEmpty {
            resultado = resultado.filter { nota in
                filtro.tags.contains { tag in
                    nota.tags.contains(tag)
                }
            }
        }
        
        // Filtrar por texto de búsqueda
        if let busqueda = filtro.textoBusqueda, !busqueda.isEmpty {
            resultado = resultado.filter {
                $0.contenido.lowercased().contains(busqueda.lowercased())
            }
        }
        
        return resultado.sorted { $0.fecha > $1.fecha }
    }
    
    /// Obtiene todas las notas
    public func obtenerTodasLasNotas() async throws -> [Nota] {
        return notas.sorted { $0.fecha > $1.fecha }
    }
    
    /// Elimina una nota
    public func eliminarNota(id: UUID) async throws {
        notas.removeAll { $0.id == id }
        try await persistirNotas()
    }
    
    /// Actualiza una nota existente
    public func actualizarNota(_ nota: Nota) async throws {
        if let index = notas.firstIndex(where: { $0.id == nota.id }) {
            notas[index] = nota
            try await persistirNotas()
        } else {
            throw NotaStorageError.notaNoEncontrada
        }
    }
    
    /// Obtiene la nota de un hábito para una fecha específica
    public func obtenerNotaDelDia(habitID: UUID, fecha: Date) async throws -> Nota? {
        return notas.first {
            $0.habitID == habitID &&
            calendar.isDate($0.fecha, inSameDayAs: fecha)
        }
    }
    
    /// Calcula estadísticas para un hábito
    public func calcularEstadisticas(habitID: UUID) async throws -> NotaEstadisticas {
        let notasHabito = try await obtenerNotas(habitID: habitID)
        
        guard !notasHabito.isEmpty else {
            return .empty
        }
        
        let totalNotas = notasHabito.count
        let notasImportantes = notasHabito.filter { $0.esImportante }.count
        let totalPalabras = notasHabito.reduce(0) { $0 + $1.cantidadPalabras }
        let totalCaracteres = notasHabito.reduce(0) { $0 + $1.cantidadCaracteres }
        
        // Contar días únicos con notas
        let diasUnicos = Set(notasHabito.map {
            calendar.startOfDay(for: $0.fecha)
        }).count
        
        // Contar tags populares
        var tagsCount: [String: Int] = [:]
        for nota in notasHabito {
            for tag in nota.tags {
                tagsCount[tag, default: 0] += 1
            }
        }
        
        let notaMasReciente = notasHabito.max { $0.fecha < $1.fecha }?.fecha
        let notaMasAntigua = notasHabito.min { $0.fecha < $1.fecha }?.fecha
        
        return NotaEstadisticas(
            totalNotas: totalNotas,
            notasImportantes: notasImportantes,
            totalPalabras: totalPalabras,
            totalCaracteres: totalCaracteres,
            diasConNotas: diasUnicos,
            tagsPopulares: tagsCount,
            notaMasReciente: notaMasReciente,
            notaMasAntigua: notaMasAntigua
        )
    }
    
    /// Obtiene todos los tags únicos
    public func obtenerTagsUnicos() -> [String] {
        var tags = Set<String>()
        for nota in notas {
            tags.formUnion(nota.tags)
        }
        return Array(tags).sorted()
    }
    
    // MARK: - Private Methods
    
    /// Carga las notas desde el almacenamiento
    private func cargarNotas() async {
        do {
            guard fileManager.fileExists(atPath: notasFileURL.path) else {
                print("📝 NotaStorage: No hay archivo de notas previo")
                return
            }
            
            let data = try Data(contentsOf: notasFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            notas = try decoder.decode([Nota].self, from: data)
            print("📝 NotaStorage: \(notas.count) notas cargadas")
        } catch {
            print("❌ NotaStorage: Error al cargar notas: \(error)")
            notas = []
        }
    }
    
    /// Persiste las notas al almacenamiento
    private func persistirNotas() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(notas)
        try data.write(to: notasFileURL, options: .atomic)
        print("📝 NotaStorage: \(notas.count) notas guardadas")
    }
}

// MARK: - Errors

public enum NotaStorageError: LocalizedError {
    case notaNoEncontrada
    case errorAlGuardar
    case errorAlCargar
    
    public var errorDescription: String? {
        switch self {
        case .notaNoEncontrada:
            return "La nota no fue encontrada"
        case .errorAlGuardar:
            return "Error al guardar la nota"
        case .errorAlCargar:
            return "Error al cargar las notas"
        }
    }
}
