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
    // En SuggestionGenerator.swift

        // Base de datos local de sugerencias (50 hábitos)
        private let bibliotecaSugerencias: [SuggestionInfo] = [
            // SALUD (15)
            SuggestionInfo(nombre: "Beber 2L de agua", frecuencia: .diario, categoria: .salud, impacto: "Mejora tu hidratación y energía", nivelDificultad: 1),
            SuggestionInfo(nombre: "Caminar 5.000 pasos", frecuencia: .diario, categoria: .salud, impacto: "Activa tu circulación", nivelDificultad: 1),
            SuggestionInfo(nombre: "Sin azúcar añadido", frecuencia: .diario, categoria: .salud, impacto: "Desintoxica tu cuerpo", nivelDificultad: 3),
            SuggestionInfo(nombre: "Comer 1 fruta", frecuencia: .diario, categoria: .salud, impacto: "Vitaminas naturales esenciales", nivelDificultad: 1),
            SuggestionInfo(nombre: "Dormir 8 horas", frecuencia: .diario, categoria: .salud, impacto: "Recuperación física y mental", nivelDificultad: 2),
            SuggestionInfo(nombre: "Entrenamiento de fuerza", frecuencia: .semanal, categoria: .salud, impacto: "Fortalece músculos y huesos", nivelDificultad: 3),
            SuggestionInfo(nombre: "Usar hilo dental", frecuencia: .diario, categoria: .salud, impacto: "Higiene bucal completa", nivelDificultad: 1),
            SuggestionInfo(nombre: "Subir por las escaleras", frecuencia: .diario, categoria: .salud, impacto: "Cardio simple y efectivo", nivelDificultad: 1),
            SuggestionInfo(nombre: "Desayuno saludable", frecuencia: .diario, categoria: .salud, impacto: "Energía estable por la mañana", nivelDificultad: 2),
            SuggestionInfo(nombre: "Estiramientos", frecuencia: .diario, categoria: .salud, impacto: "Mejora flexibilidad y postura", nivelDificultad: 1),
            SuggestionInfo(nombre: "No alcohol", frecuencia: .semanal, categoria: .salud, impacto: "Mejora calidad de sueño", nivelDificultad: 2),
            SuggestionInfo(nombre: "Protector solar", frecuencia: .diario, categoria: .salud, impacto: "Previene envejecimiento prematuro", nivelDificultad: 1),
            SuggestionInfo(nombre: "Chequeo de peso", frecuencia: .semanal, categoria: .salud, impacto: "Control de progreso físico", nivelDificultad: 1),
            SuggestionInfo(nombre: "Cocinar en casa", frecuencia: .diario, categoria: .salud, impacto: "Control total de ingredientes", nivelDificultad: 2),
            SuggestionInfo(nombre: "Tomar vitaminas", frecuencia: .diario, categoria: .salud, impacto: "Suplementación necesaria", nivelDificultad: 1),

            // PRODUCTIVIDAD (10)
            SuggestionInfo(nombre: "Leer 15 minutos", frecuencia: .diario, categoria: .productividad, impacto: "Expande tu conocimiento", nivelDificultad: 2),
            SuggestionInfo(nombre: "Planificar la semana", frecuencia: .semanal, categoria: .productividad, impacto: "Claridad en tus objetivos", nivelDificultad: 2),
            SuggestionInfo(nombre: "Aprender algo nuevo", frecuencia: .diario, categoria: .productividad, impacto: "Estimulación cognitiva", nivelDificultad: 2),
            SuggestionInfo(nombre: "Inbox Zero", frecuencia: .diario, categoria: .productividad, impacto: "Mente despejada de correos", nivelDificultad: 2),
            SuggestionInfo(nombre: "Deep Work (1h)", frecuencia: .diario, categoria: .productividad, impacto: "Avance real en tareas clave", nivelDificultad: 3),
            SuggestionInfo(nombre: "Revisar metas anuales", frecuencia: .semanal, categoria: .productividad, impacto: "No perder el rumbo", nivelDificultad: 1),
            SuggestionInfo(nombre: "Organizar archivos", frecuencia: .semanal, categoria: .productividad, impacto: "Entorno digital limpio", nivelDificultad: 1),
            SuggestionInfo(nombre: "Madrugar", frecuencia: .diario, categoria: .productividad, impacto: "Aprovecha la mañana", nivelDificultad: 3),
            SuggestionInfo(nombre: "Escuchar podcast", frecuencia: .diario, categoria: .productividad, impacto: "Aprendizaje pasivo", nivelDificultad: 1),
            SuggestionInfo(nombre: "Escribir To-Do list", frecuencia: .diario, categoria: .productividad, impacto: "Priorización efectiva", nivelDificultad: 1),

            // MINDFULNESS (10)
            SuggestionInfo(nombre: "Meditar 10 min", frecuencia: .diario, categoria: .mindfulness, impacto: "Reduce estrés y ansiedad", nivelDificultad: 2),
            SuggestionInfo(nombre: "Diario de gratitud", frecuencia: .diario, categoria: .mindfulness, impacto: "Mejora el bienestar emocional", nivelDificultad: 1),
            SuggestionInfo(nombre: "Sin móvil 1h antes dormir", frecuencia: .diario, categoria: .mindfulness, impacto: "Mejora calidad de sueño", nivelDificultad: 2),
            SuggestionInfo(nombre: "Respiración consciente", frecuencia: .diario, categoria: .mindfulness, impacto: "Calma instantánea", nivelDificultad: 1),
            SuggestionInfo(nombre: "Paseo por naturaleza", frecuencia: .semanal, categoria: .mindfulness, impacto: "Desconexión total", nivelDificultad: 1),
            SuggestionInfo(nombre: "Llamar a un familiar", frecuencia: .semanal, categoria: .mindfulness, impacto: "Conexión social", nivelDificultad: 1),
            SuggestionInfo(nombre: "Leer ficción", frecuencia: .diario, categoria: .mindfulness, impacto: "Escapismo saludable", nivelDificultad: 1),
            SuggestionInfo(nombre: "Yoga", frecuencia: .semanal, categoria: .mindfulness, impacto: "Conexión mente-cuerpo", nivelDificultad: 2),
            SuggestionInfo(nombre: "Afirmaciones positivas", frecuencia: .diario, categoria: .mindfulness, impacto: "Autoestima", nivelDificultad: 1),
            SuggestionInfo(nombre: "Ayuno de redes sociales", frecuencia: .semanal, categoria: .mindfulness, impacto: "Detox de dopamina", nivelDificultad: 3),

            // HOGAR (8)
            SuggestionInfo(nombre: "Hacer la cama", frecuencia: .diario, categoria: .hogar, impacto: "Primera victoria del día", nivelDificultad: 1),
            SuggestionInfo(nombre: "Limpiar escritorio", frecuencia: .semanal, categoria: .hogar, impacto: "Espacio limpio, mente clara", nivelDificultad: 1),
            SuggestionInfo(nombre: "Lavar platos noche", frecuencia: .diario, categoria: .hogar, impacto: "Amanecer sin caos", nivelDificultad: 2),
            SuggestionInfo(nombre: "Regar plantas", frecuencia: .semanal, categoria: .hogar, impacto: "Cuidado del entorno", nivelDificultad: 1),
            SuggestionInfo(nombre: "Sacar basura", frecuencia: .diario, categoria: .hogar, impacto: "Higiene básica", nivelDificultad: 1),
            SuggestionInfo(nombre: "Limpieza profunda", frecuencia: .semanal, categoria: .hogar, impacto: "Mantenimiento del hogar", nivelDificultad: 3),
            SuggestionInfo(nombre: "Organizar ropa", frecuencia: .semanal, categoria: .hogar, impacto: "Facilita vestirse", nivelDificultad: 2),
            SuggestionInfo(nombre: "Ventilar casa", frecuencia: .diario, categoria: .hogar, impacto: "Aire fresco y renovado", nivelDificultad: 1),

            // FINANZAS (7)
            SuggestionInfo(nombre: "Revisar gastos", frecuencia: .semanal, categoria: .finanzas, impacto: "Control económico", nivelDificultad: 2),
            SuggestionInfo(nombre: "Ahorrar % sueldo", frecuencia: .semanal, categoria: .finanzas, impacto: "Futuro asegurado", nivelDificultad: 2),
            SuggestionInfo(nombre: "Día sin gastos", frecuencia: .semanal, categoria: .finanzas, impacto: "Disciplina financiera", nivelDificultad: 3),
            SuggestionInfo(nombre: "Cocinar vs pedir", frecuencia: .semanal, categoria: .finanzas, impacto: "Ahorro considerable", nivelDificultad: 2),
            SuggestionInfo(nombre: "Leer noticias economía", frecuencia: .diario, categoria: .finanzas, impacto: "Cultura financiera", nivelDificultad: 2),
            SuggestionInfo(nombre: "Cancelar suscripción", frecuencia: .semanal, categoria: .finanzas, impacto: "Eliminar gastos hormiga", nivelDificultad: 1),
            SuggestionInfo(nombre: "Revisar inversiones", frecuencia: .semanal, categoria: .finanzas, impacto: "Crecimiento patrimonial", nivelDificultad: 2)
        ]    // MARK: - Initialization
    
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
