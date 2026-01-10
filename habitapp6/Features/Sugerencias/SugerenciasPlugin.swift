
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
    
    var isEnabled: Bool {
        return true
    }
    
    let pluginId: String = "com.habittracker.sugerencias"
    let pluginName: String = "Sugerencias"
    let pluginDescription: String = "Descubre nuevos hábitos y añádelos fácilmente a tu rutina"
    
    // MARK: - Private Properties
    
    private let generator: SuggestionGenerator
    
    // MARK: - Initialization
    
    init() {
        self.generator = SuggestionGenerator.shared
        print("💡 SugerenciasPlugin inicializado")
    }
    
    // MARK: - DataPlugin Methods
    
    func willCreateHabit(_ habit: Habit) async { }
    
    func didCreateHabit(_ habit: Habit) async {
        print("💡 SugerenciasPlugin: Nuevo hábito creado")
    }
    
    func willDeleteHabit(_ habit: Habit) async { }
    
    func didDeleteHabit(habitId: UUID) async { }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async { }
    
    // MARK: - View Methods
    
    /// Provee el botón para la barra de herramientas
    /// ACEPTA EL PROTOCOLO 'HabitSuggestionHandler', NO LA CLASE CONCRETA
    @ViewBuilder
    func toolbarButton(handler: HabitSuggestionHandler) -> some View {
        if isEnabled {
            NavigationLink(destination: SuggestionListView(habitHandler: handler)) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
    
    /// Provee una sección de "Sugerencia del día" para la pantalla principal
    @ViewBuilder
    func featuredSuggestionSection(handler: HabitSuggestionHandler) -> some View {
        if isEnabled {
            // Obtenemos una sugerencia (lógica simplificada para la vista)
            let suggestion = generator.obtenerSugerenciaDelDia()
            
            // Verificamos si ya existe usando el protocolo
            if !handler.habits.contains(where: { $0.nombre == suggestion.nombre }) {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Sugerencia del día")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(suggestion.nombre)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(suggestion.impacto)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                            // Acción rápida de agregar
                            let habit = Habit(nombre: suggestion.nombre, frecuencia: suggestion.frecuencia)
                            handler.addHabit(habit)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    Text("Descubrir")
                }
            }
        }
    }
}
