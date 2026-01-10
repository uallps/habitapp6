//
// SuggestionGenerator.swift
// HabitTracker
//
// Feature: Sugerencias
// Servicio para generar y gestionar sugerencias de hábitos
//

import Foundation

/// Protocolo para el generador de sugerencias
public protocol SuggestionGeneratorProtocol {
  func obtenerSugerencias(excluyendo habitosExistentes: [Habit]) -> [SuggestionInfo]
  func obtenerSugerenciaDelDia() -> SuggestionInfo
}

/// Servicio para generar sugerencias de hábitos
public class SuggestionGenerator: SuggestionGeneratorProtocol {
    
    // MARK: - Singleton
    
    public static let shared = SuggestionGenerator()
    
    // Base de datos local de sugerencias (Hardcoded por ahora)
    private let bibliotecaSugerencias: [SuggestionInfo] = [
        SuggestionInfo(nombre: "Beber 2L de agua", frecuencia: .diario, categoria: .salud, impacto: "Mejora tu hidratación y energía", nivelDificultad: 1),
        SuggestionInfo(nombre: "Leer 15 minutos", frecuencia: .diario, categoria: .productividad, impacto: "Expande tu conocimiento diariamente", nivelDificultad: 2),
        SuggestionInfo(nombre: "Meditar", frecuencia: .diario, categoria: .mindfulness, impacto: "Reduce el estrés y mejora el foco", nivelDificultad: 2),
        SuggestionInfo(nombre: "Caminar 5.000 pasos", frecuencia: .diario, categoria: .salud, impacto: "Activa tu circulación", nivelDificultad: 1),
        SuggestionInfo(nombre: "Revisar gastos", frecuencia: .semanal, categoria: .finanzas, impacto: "Toma control de tu economía", nivelDificultad: 2),
        SuggestionInfo(nombre: "Limpiar escritorio", frecuencia: .semanal, categoria: .hogar, impacto: "Un espacio limpio aclara la mente", nivelDificultad: 1),
        SuggestionInfo(nombre: "Planificar la semana", frecuencia: .semanal, categoria: .productividad, impacto: "Organiza tus objetivos", nivelDificultad: 2),
        SuggestionInfo(nombre: "Sin azúcar", frecuencia: .diario, categoria: .salud, impacto: "Desintoxica tu cuerpo", nivelDificultad: 3)
    ]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Obtiene sugerencias filtrando las que el usuario ya tiene
    public func obtenerSugerencias(excluyendo habitosExistentes: [Habit]) -> [SuggestionInfo] {
        let nombresExistentes = habitosExistentes.map { $0.nombre.lowercased() }
        
        return bibliotecaSugerencias.filter { sugerencia in
            !nombresExistentes.contains(sugerencia.nombre.lowercased())
        }
    }
    
    /// Obtiene una sugerencia destacada aleatoria
    public func obtenerSugerenciaDelDia() -> SuggestionInfo {
        return bibliotecaSugerencias.randomElement() ?? SuggestionInfo.empty
    }
    
    // MARK: - Private Methods
    
    // Métodos auxiliares para lógica futura (ej. basada en hora del día)
    private func filtrarPorHoraDelDia() -> [SuggestionInfo] {
        // Implementación futura
        return []
    }
}
