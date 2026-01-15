//
// SugerenciasPlugin.swift
// HabitTracker
//
// Feature: Sugerencias - Plugin SPL
//

import Foundation
import SwiftUI

/// Plugin que gestiona las sugerencias de hábitos
@MainActor
class SugerenciasPlugin: DataPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    // Conectado al AppConfig para activar/desactivar remotamente
    var isEnabled: Bool {
        return config.showSugerencias
    }
    
    let pluginId: String = "com.habittracker.sugerencias"
    let pluginName: String = "Sugerencias"
    let pluginDescription: String = "Descubre nuevos hábitos y añádelos fácilmente a tu rutina"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    private let generator: SuggestionGenerator
    
    // MARK: - Initialization
    
    init(config: AppConfig) {
        self.config = config
        self.generator = SuggestionGenerator.shared
        print("💡 SugerenciasPlugin inicializado")
    }
    
    // MARK: - DataPlugin Methods (Hooks)
    
    func willCreateHabit(_ habit: Habit) async { }
    
    func didCreateHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        print("💡 SugerenciasPlugin: Nuevo hábito creado")
    }
    
    func willDeleteHabit(_ habit: Habit) async { }
    func didDeleteHabit(habitId: UUID) async { }
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async { }
    
    // MARK: - View Methods (UI Injection)
    
    /// Provee el botón (bombilla) para la barra de herramientas
    /// ACEPTA EL PROTOCOLO 'HabitSuggestionHandler'
    @ViewBuilder
    func toolbarButton(handler: HabitSuggestionHandler) -> some View {
        if isEnabled {
            NavigationLink(destination: SuggestionListView(habitHandler: handler)) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
    
    /// Provee una sección de "Sugerencia del día" incrustada en la lista principal
    @ViewBuilder
    func featuredSuggestionSection(handler: HabitSuggestionHandler) -> some View {
        if isEnabled {
            // Lógica para obtener una sugerencia aleatoria
            let suggestion = generator.obtenerSugerenciaDelDia()
            
            // Solo la mostramos si el usuario NO tiene ese hábito ya
            if !handler.habits.contains(where: { $0.nombre.lowercased() == suggestion.nombre.lowercased() }) {
                Section {
                    HStack(spacing: 12) {
                        // Icono
                        ZStack {
                            Circle()
                                .fill(colorParaCategoria(suggestion.categoria).opacity(0.15))
                                .frame(width: 40, height: 40)
                            Text(suggestion.categoria.emoji)
                        }
                        
                        // Textos
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sugerencia del día")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(suggestion.nombre)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(suggestion.impacto)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Botón de acción rápida (+)
                        Button {
                            let habit = Habit(nombre: suggestion.nombre, frecuencia: suggestion.frecuencia)
                            handler.addHabit(habit)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle()) // Para que no clicable toda la celda
                    }
                } header: {
                    Text("Descubrir")
                }
            }
        }
    }
    
    // Helper para colores
    private func colorParaCategoria(_ cat: SuggestionCategory) -> Color {
        switch cat {
        case .salud: return .green
        case .productividad: return .blue
        case .mindfulness: return .purple
        case .finanzas: return .yellow
        case .hogar: return .orange
        }
    }
}
