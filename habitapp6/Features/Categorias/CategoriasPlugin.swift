//
//  CategoriasPlugin.swift
//  HabitTracker
//
//  Feature: Categorias - Plugin SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

/// Plugin que gestiona las categorías de hábitos
@MainActor
class CategoriasPlugin: DataPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    var isEnabled: Bool {
        return config.showCategorias
    }
    
    let pluginId: String = "com.habittracker.categorias"
    let pluginName: String = "Categorías"
    let pluginDescription: String = "Agrupa tus hábitos por categorías con colores"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    
    // MARK: - Initialization
    
    init(config: AppConfig) {
        self.config = config
        print("📁 CategoriasPlugin inicializado - Habilitado: \(isEnabled)")
    }
    
    // MARK: - DataPlugin Methods
    
    func willDeleteHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        print("🗑️ CategoriasPlugin: Hábito '\(habit.nombre)' con categoría '\(habit.categoriaEnum.displayName)' será eliminado")
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        print("📝 CategoriasPlugin: Hábito \(habitId) eliminado")
    }
    
    // MARK: - View Methods
    
    /// Provee el badge de categoría para la fila del hábito
    @ViewBuilder
    func habitRowBadge(for habit: Habit) -> some View {
        if isEnabled && habit.tieneCategoria {
            CategoriaBadgeView(categoria: habit.categoriaEnum)
        }
    }
    
    /// Provee la sección de categoría para el detalle del hábito
    @ViewBuilder
    func habitDetailSection(categoria: Binding<Categoria>) -> some View {
        if isEnabled {
            CategoriaDetailSectionView(categoria: categoria)
        }
    }
    
    /// Provee el filtro de categorías
    @ViewBuilder
    func filterView(selectedFilter: Binding<Categoria?>) -> some View {
        if isEnabled {
            CategoriaFilterView(selectedFilter: selectedFilter)
        }
    }
    
    /// Provee la vista de hábitos agrupados por categoría
    @ViewBuilder
    func habitsByCategoriaView(dataStore: HabitDataStore, pluginManager: PluginManager) -> some View {
        if isEnabled {
            HabitsByCategoriaView(dataStore: dataStore, pluginManager: pluginManager)
        }
    }
    
    /// Provee la vista de configuración del plugin
    @ViewBuilder
    func settingsView() -> some View {
        Toggle("Mostrar Categorías", isOn: Binding(
            get: { self.config.showCategorias },
            set: { self.config.showCategorias = $0 }
        ))
    }
    
    // MARK: - Helper Methods
    
    /// Filtra hábitos por categoría
    func filterHabits(_ habits: [Habit], by categoria: Categoria?) -> [Habit] {
        guard isEnabled, let categoria = categoria else {
            return habits
        }
        return habits.filter { $0.categoriaEnum == categoria }
    }
    
    /// Agrupa hábitos por categoría
    func groupHabitsByCategoria(_ habits: [Habit]) -> [Categoria: [Habit]] {
        guard isEnabled else { return [:] }
        
        var grouped: [Categoria: [Habit]] = [:]
        for categoria in Categoria.allCases {
            let habitsInCategory = habits.filter { $0.categoriaEnum == categoria }
            if !habitsInCategory.isEmpty {
                grouped[categoria] = habitsInCategory
            }
        }
        return grouped
    }
    
    /// Cuenta hábitos por categoría
    func countByCategoria(_ habits: [Habit]) -> [Categoria: Int] {
        guard isEnabled else { return [:] }
        
        var counts: [Categoria: Int] = [:]
        for categoria in Categoria.allCases {
            counts[categoria] = habits.filter { $0.categoriaEnum == categoria }.count
        }
        return counts
    }
}
