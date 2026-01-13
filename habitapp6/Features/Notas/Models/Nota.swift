//
//  Nota.swift
//  HabitTracker
//
//  Feature: Notas
//  Modelo que representa una nota asociada a un hábito
//

import Foundation

/// Representa una nota diaria asociada a un hábito
public struct Nota: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
    
    /// Identificador único de la nota
    public let id: UUID
    
    /// ID del hábito al que pertenece la nota
    public let habitID: UUID
    
    /// Fecha de la nota
    public let fecha: Date
    
    /// Contenido de texto de la nota
    public var contenido: String
    
    /// Fecha de creación de la nota
    public let fechaCreacion: Date
    
    /// Fecha de última modificación
    public var fechaModificacion: Date
    
    /// Indica si la nota está marcada como importante
    public var esImportante: Bool
    
    /// Tags opcionales para categorizar la nota
    public var tags: [String]
    
    // MARK: - Computed Properties
    
    /// Indica si la nota está vacía
    public var estaVacia: Bool {
        return contenido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Conteo de palabras en la nota
    public var cantidadPalabras: Int {
        let palabras = contenido.components(separatedBy: .whitespacesAndNewlines)
        return palabras.filter { !$0.isEmpty }.count
    }
    
    /// Conteo de caracteres
    public var cantidadCaracteres: Int {
        return contenido.count
    }
    
    /// Preview del contenido (primeras 100 caracteres)
    public var preview: String {
        if contenido.count <= 100 {
            return contenido
        }
        let index = contenido.index(contenido.startIndex, offsetBy: 100)
        return String(contenido[..<index]) + "..."
    }
    
    /// Indica si la nota fue editada después de creada
    public var fueEditada: Bool {
        return fechaModificacion > fechaCreacion
    }
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        habitID: UUID,
        fecha: Date = Date(),
        contenido: String = "",
        fechaCreacion: Date = Date(),
        fechaModificacion: Date = Date(),
        esImportante: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.habitID = habitID
        self.fecha = fecha
        self.contenido = contenido
        self.fechaCreacion = fechaCreacion
        self.fechaModificacion = fechaModificacion
        self.esImportante = esImportante
        self.tags = tags
    }
    
    // MARK: - Methods
    
    /// Actualiza el contenido de la nota
    public mutating func actualizarContenido(_ nuevoContenido: String) {
        self.contenido = nuevoContenido
        self.fechaModificacion = Date()
    }
    
    /// Marca/desmarca la nota como importante
    public mutating func toggleImportante() {
        self.esImportante.toggle()
        self.fechaModificacion = Date()
    }
    
    /// Añade un tag a la nota
    public mutating func agregarTag(_ tag: String) {
        let tagLimpio = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !tagLimpio.isEmpty && !tags.contains(tagLimpio) {
            tags.append(tagLimpio)
            fechaModificacion = Date()
        }
    }
    
    /// Elimina un tag de la nota
    public mutating func eliminarTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        fechaModificacion = Date()
    }
}

// MARK: - Nota Statistics

/// Estadísticas de notas para un hábito
public struct NotaEstadisticas: Codable, Equatable {
    
    /// Total de notas
    public let totalNotas: Int
    
    /// Notas marcadas como importantes
    public let notasImportantes: Int
    
    /// Total de palabras escritas
    public let totalPalabras: Int
    
    /// Total de caracteres
    public let totalCaracteres: Int
    
    /// Días con notas
    public let diasConNotas: Int
    
    /// Tags más usados
    public let tagsPopulares: [String: Int]
    
    /// Nota más reciente
    public let notaMasReciente: Date?
    
    /// Nota más antigua
    public let notaMasAntigua: Date?
    
    // MARK: - Computed Properties
    
    /// Promedio de palabras por nota
    public var promedioPalabrasPorNota: Double {
        guard totalNotas > 0 else { return 0 }
        return Double(totalPalabras) / Double(totalNotas)
    }
    
    /// Porcentaje de notas importantes
    public var porcentajeImportantes: Double {
        guard totalNotas > 0 else { return 0 }
        return Double(notasImportantes) / Double(totalNotas) * 100
    }
    
    // MARK: - Initialization
    
    public init(
        totalNotas: Int = 0,
        notasImportantes: Int = 0,
        totalPalabras: Int = 0,
        totalCaracteres: Int = 0,
        diasConNotas: Int = 0,
        tagsPopulares: [String: Int] = [:],
        notaMasReciente: Date? = nil,
        notaMasAntigua: Date? = nil
    ) {
        self.totalNotas = totalNotas
        self.notasImportantes = notasImportantes
        self.totalPalabras = totalPalabras
        self.totalCaracteres = totalCaracteres
        self.diasConNotas = diasConNotas
        self.tagsPopulares = tagsPopulares
        self.notaMasReciente = notaMasReciente
        self.notaMasAntigua = notaMasAntigua
    }
    
    /// Estadísticas vacías por defecto
    public static var empty: NotaEstadisticas {
        NotaEstadisticas()
    }
}

// MARK: - Nota Filter

/// Filtros para buscar y filtrar notas
public struct NotaFiltro {
    
    /// Rango de fechas
    public var rangoFechas: ClosedRange<Date>?
    
    /// Solo notas importantes
    public var soloImportantes: Bool
    
    /// Tags a filtrar
    public var tags: [String]
    
    /// Texto de búsqueda
    public var textoBusqueda: String?
    
    /// Hábitos específicos (si está vacío, incluye todos)
    public var habitIDs: [UUID]
    
    public init(
        rangoFechas: ClosedRange<Date>? = nil,
        soloImportantes: Bool = false,
        tags: [String] = [],
        textoBusqueda: String? = nil,
        habitIDs: [UUID] = []
    ) {
        self.rangoFechas = rangoFechas
        self.soloImportantes = soloImportantes
        self.tags = tags
        self.textoBusqueda = textoBusqueda
        self.habitIDs = habitIDs
    }
    
    /// Filtro vacío (sin filtros aplicados)
    public static var ninguno: NotaFiltro {
        NotaFiltro()
    }
}
