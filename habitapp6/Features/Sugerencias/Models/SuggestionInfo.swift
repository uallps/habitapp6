//
// SuggestionInfo.swift
// HabitTracker
//
// Feature: Sugerencias
// Modelo que representa la información de una sugerencia de hábito
//

import Foundation

/// Categoría temática de la sugerencia
public enum SuggestionCategory: String, Codable, CaseIterable {
  case salud = "Salud"
  case productividad = "Productividad"
  case mindfulness = "Mindfulness"
  case finanzas = "Finanzas"
  case hogar = "Hogar"
   
  var emoji: String {
    switch self {
    case .salud: return "❤️"
    case .productividad: return "⚡️"
    case .mindfulness: return "🧘"
    case .finanzas: return "💰"
    case .hogar: return "🏠"
    }
  }
}

/// Información detallada para una sugerencia de hábito
public struct SuggestionInfo: Identifiable, Codable, Equatable {
   
  public let id: UUID
   
  // MARK: - Properties
   
  /// Nombre sugerido del hábito
  public let nombre: String
   
  /// Frecuencia sugerida
  public let frecuencia: Frecuencia
   
  /// Categoría a la que pertenece
  public let categoria: SuggestionCategory
   
  /// Descripción motivacional de por qué adoptar este hábito
  public let impacto: String
   
  /// Dificultad estimada (1-3)
  public let nivelDificultad: Int
   
  // MARK: - Computed Properties
   
  /// Descripción de la dificultad
  public var descripcionDificultad: String {
    switch nivelDificultad {
    case 1: return "Fácil"
    case 2: return "Medio"
    default: return "Desafiante"
    }
  }
   
  /// Color asociado a la categoría (representación en String para persistencia)
  public var colorName: String {
    switch categoria {
    case .salud: return "green"
    case .productividad: return "blue"
    case .mindfulness: return "purple"
    case .finanzas: return "yellow"
    case .hogar: return "orange"
    }
  }
   
  // MARK: - Initialization
   
  public init(
    id: UUID = UUID(),
    nombre: String,
    frecuencia: Frecuencia,
    categoria: SuggestionCategory,
    impacto: String,
    nivelDificultad: Int = 1
  ) {
    self.id = id
    self.nombre = nombre
    self.frecuencia = frecuencia
    self.categoria = categoria
    self.impacto = impacto
    self.nivelDificultad = nivelDificultad
  }
   
  // MARK: - Static
   
  /// SuggestionInfo vacía por defecto
  public static var empty: SuggestionInfo {
    SuggestionInfo(nombre: "", frecuencia: .diario, categoria: .salud, impacto: "")
  }
}
