//
//  CategoriaFilterView.swift
//  HabitTracker
//
//  Feature: Categorias - Filtro de hábitos por categoría
//

import SwiftUI

/// Filtro horizontal de categorías
struct CategoriaFilterView: View {
    @Binding var selectedFilter: Categoria?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Botón "Todos"
                FilterChipView(
                    title: "Todos",
                    icon: "square.grid.2x2",
                    color: .accentColor,
                    isSelected: selectedFilter == nil
                ) {
                    selectedFilter = nil
                }
                
                // Categorías
                ForEach(Categoria.activas) { categoria in
                    FilterChipView(
                        title: categoria.displayName,
                        icon: categoria.icon,
                        color: categoria.color,
                        isSelected: selectedFilter == categoria
                    ) {
                        if selectedFilter == categoria {
                            selectedFilter = nil
                        } else {
                            selectedFilter = categoria
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Chip individual de filtro
struct FilterChipView: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

/// Vista de lista de hábitos agrupados por categoría
struct HabitsByCategoriaView: View {
    @ObservedObject var dataStore: HabitDataStore
    @ObservedObject var pluginManager: PluginManager
    
    var body: some View {
        List {
            ForEach(Categoria.allCases) { categoria in
                let habitsInCategory = dataStore.habits.filter { $0.categoriaEnum == categoria }
                
                if !habitsInCategory.isEmpty {
                    Section {
                        ForEach(habitsInCategory) { habit in
                            NavigationLink(destination: HabitDetailView(dataStore: dataStore, habit: habit)) {
                                HabitCategoriaRowView(
                                    habit: habit,
                                    dataStore: dataStore,
                                    pluginManager: pluginManager
                                )
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: categoria.icon)
                                .foregroundColor(categoria.color)
                            Text(categoria.displayName)
                            Spacer()
                            Text("\(habitsInCategory.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// Fila de hábito simplificada para vista por categoría
struct HabitCategoriaRowView: View {
    let habit: Habit
    @ObservedObject var dataStore: HabitDataStore
    @ObservedObject var pluginManager: PluginManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.nombre)
                    .font(.headline)
                    .foregroundColor(habit.activo ? .primary : .secondary)
                
                HStack(spacing: 8) {
                    Label(
                        habit.frecuencia.rawValue.capitalized,
                        systemImage: habit.frecuencia == .diario ? "sun.max" : "calendar.badge.clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if !habit.activo {
                        Text("• Pausado")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Badges de otras features si están activas
            HStack(spacing: 6) {
                if pluginManager.isRachasEnabled {
                    // Badge de racha (simplificado)
                    let racha = RachaCalculator.shared.calcularRachaActual(
                        para: habit,
                        instancias: dataStore.instances
                    )
                    if racha > 0 {
                        RachaBadgeView(rachaActual: racha, frecuencia: habit.frecuencia)
                    }
                }
                
                if pluginManager.isRecordatoriosEnabled && habit.tieneRecordatorioActivo {
                    RecordatorioBadgeView(habit: habit)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#if DEBUG
struct CategoriaFilterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CategoriaFilterView(selectedFilter: .constant(nil))
            CategoriaFilterView(selectedFilter: .constant(.fisicos))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
