//
//  Categoria.swift
//  HabitTracker
//
//  Feature: Categorias - Modelo de categoría de hábito
//

import Foundation
import SwiftUI

/// Categorías predefinidas para agrupar hábitos
enum Categoria: String, CaseIterable, Codable, Identifiable {
    case ninguno = "ninguno"
    case fisicos = "físicos"
    case sociales = "sociales"
    case aprendizaje = "aprendizaje"
    case mentales = "mentales"
    case productivos = "productivos"
    
    var id: String { rawValue }
    
    // MARK: - Display Properties
    
    /// Nombre para mostrar en la UI
    var displayName: String {
        switch self {
        case .ninguno: return "Sin categoría"
        case .fisicos: return "Físicos"
        case .sociales: return "Sociales"
        case .aprendizaje: return "Aprendizaje"
        case .mentales: return "Mentales"
        case .productivos: return "Productivos"
        }
    }
    
    /// Color asociado a la categoría
    var color: Color {
        switch self {
        case .ninguno: return .gray
        case .fisicos: return .red
        case .sociales: return .blue
        case .aprendizaje: return .purple
        case .mentales: return .green
        case .productivos: return .orange
        }
    }
    
    /// Icono SF Symbol asociado a la categoría
    var icon: String {
        switch self {
        case .ninguno: return "folder"
        case .fisicos: return "heart.circle.fill"
        case .sociales: return "person.2.fill"
        case .aprendizaje: return "book.fill"
        case .mentales: return "brain.head.profile"
        case .productivos: return "briefcase.fill"
        }
    }
    
    /// Descripción de la categoría
    var descripcion: String {
        switch self {
        case .ninguno: return "Hábitos sin categoría asignada"
        case .fisicos: return "Ejercicio, deporte, salud física"
        case .sociales: return "Relaciones, familia, amigos"
        case .aprendizaje: return "Estudios, lectura, cursos"
        case .mentales: return "Meditación, mindfulness, bienestar"
        case .productivos: return "Trabajo, proyectos, organización"
        }
    }
    
    // MARK: - Static Methods
    
    /// Categorías disponibles para selección (excluyendo "ninguno" si se desea)
    static var seleccionables: [Categoria] {
        return allCases
    }
    
    /// Categorías activas (todas excepto ninguno)
    static var activas: [Categoria] {
        return allCases.filter { $0 != .ninguno }
    }
}

// MARK: - Categoria Extension for Habit

extension Habit {
    /// Categoría del hábito (propiedad opcional para la feature)
    /// Se almacena como String en el modelo base
    var categoriaEnum: Categoria {
        get {
            guard let cat = categoria else { return .ninguno }
            return Categoria(rawValue: cat) ?? .ninguno
        }
        set {
            categoria = newValue.rawValue
        }
    }
    
    /// Verifica si el hábito tiene una categoría asignada
    var tieneCategoria: Bool {
        return categoriaEnum != .ninguno
    }
}
