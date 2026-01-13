//
//  HabitsListView.swift
//  HabitTracker
//
//  Vista de lista de hábitos - Integrada con sistema de plugins SPL
//

import SwiftUI

struct HabitsListView: View {
    
    // 1. Usamos ObservedObject directamente, sin ViewModel intermedio que cause el crash
    @ObservedObject var dataStore: HabitDataStore
    @ObservedObject private var pluginManager = PluginManager.shared
    
    // Estados de navegación
    @State private var showingCreateView = false
    @State private var showingSuggestions = false
    @State private var selectedHabitForReminder: Habit?
    
    // Estados de filtrado
    @State private var selectedCategoriaFilter: Categoria? = nil
    @State private var showByCategoria: Bool = false
    
    // 2. Borramos el 'init' personalizado que causaba el error EXC_BAD_ACCESS
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtro de categorías (solo si plugin habilitado)
                if pluginManager.isCategoriasEnabled && !dataStore.habits.isEmpty {
                    VStack(spacing: 8) {
                        CategoriaFilterView(selectedFilter: $selectedCategoriaFilter)
                        
                        // Toggle para ver por categoría
                        HStack {
                            Spacer()
                            Button {
                                showByCategoria.toggle()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: showByCategoria ? "list.bullet" : "folder")
                                    Text(showByCategoria ? "Ver lista" : "Ver por categoría")
                                        .font(.caption)
                                }
                                .foregroundColor(.accentColor)
                            }
                            .padding(.trailing)
                        }
                    }
                    .padding(.top, 8)
                }
                
                // Lista de hábitos
                if showByCategoria && pluginManager.isCategoriasEnabled {
                    HabitsByCategoriaView(dataStore: dataStore, pluginManager: pluginManager)
                } else {
                    List {
                        if filteredHabits.isEmpty {
                            if dataStore.habits.isEmpty {
                                emptyStateView
                            } else {
                                noResultsView
                            }
                        } else {
                            ForEach(filteredHabits) { habit in
                                NavigationLink(destination: HabitDetailView(dataStore: dataStore, habit: habit)) {
                                    HabitRowView(
                                        dataStore: dataStore,
                                        habit: habit,
                                        pluginManager: pluginManager,
                                        onToggleActive: {
                                            // 3. Llamamos a la función local
                                            toggleHabitActive(habit)
                                        },
                                        onReminderTap: {
                                            selectedHabitForReminder = habit
                                        }
                                    )
                                }
                            }
                            // 4. Llamamos a la función local
                            .onDelete(perform: deleteHabits)
                        }
                    }
                }
            }
            .navigationTitle("Mis Hábitos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button {
                            showingSuggestions = true
                        } label: {
                            Image(systemName: "lightbulb")
                                .symbolVariant(.fill)
                                .foregroundColor(.yellow)
                        }
                        
                        Button {
                            showingCreateView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreateHabitView(dataStore: dataStore)
            }
            .sheet(isPresented: $showingSuggestions) {
                SuggestionListView(habitHandler: dataStore)
            }
            .sheet(item: $selectedHabitForReminder) { habit in
                if pluginManager.isRecordatoriosEnabled {
                    RecordatorioConfigView(dataStore: dataStore, habit: habit)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredHabits: [Habit] {
        guard pluginManager.isCategoriasEnabled, let filter = selectedCategoriaFilter else {
            return dataStore.habits
        }
        return dataStore.habits.filter { $0.categoriaEnum == filter }
    }
    
    // MARK: - Views Auxiliares
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No hay hábitos")
                .font(.headline)
            Text("Toca el botón + para crear uno o la bombilla para obtener ideas")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Sin resultados")
                .font(.headline)
            Text("No hay hábitos en esta categoría")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Mostrar todos") {
                selectedCategoriaFilter = nil
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Logic Actions (Movidas aquí para evitar el crash)
    
    func toggleHabitActive(_ habit: Habit) {
        if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
            dataStore.habits[index].activo.toggle()
            Task {
                await dataStore.saveData()
            }
        }
    }
    
    func deleteHabits(at offsets: IndexSet) {
        let habitsToDelete = offsets.map { filteredHabits[$0] }
        
        for habit in habitsToDelete {
            Task {
                await pluginManager.willDeleteHabit(habit)
                
                // Lógica de borrado directa en dataStore
                if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
                    dataStore.habits.remove(at: index)
                }
                dataStore.instances.removeAll { $0.habitID == habit.id }
                await dataStore.saveData()
                
                await pluginManager.didDeleteHabit(habitId: habit.id)
            }
        }
    }
}

// MARK: - Habit Row View (Mantenemos la fila igual)
struct HabitRowView: View {
    @ObservedObject var dataStore: HabitDataStore
    let habit: Habit
    @ObservedObject var pluginManager: PluginManager
    let onToggleActive: () -> Void
    let onReminderTap: () -> Void
    @State private var rachaActual: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(habit.nombre)
                        .font(.headline)
                        .foregroundColor(habit.activo ? .primary : .secondary)
                    
                    if pluginManager.isCategoriasEnabled && habit.tieneCategoria {
                        CategoriaBadgeView(categoria: habit.categoriaEnum)
                    }
                    if pluginManager.isRachasEnabled {
                        RachaBadgeView(rachaActual: rachaActual, frecuencia: habit.frecuencia)
                    }
                    if pluginManager.isRecordatoriosEnabled {
                        RecordatorioBadgeView(habit: habit)
                    }
                }
                HStack(spacing: 8) {
                    Label(habit.frecuencia.rawValue.capitalized, systemImage: habit.frecuencia == .diario ? "sun.max" : "calendar.badge.clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !habit.activo {
                        Text("• Pausado").font(.caption).foregroundColor(.orange)
                    }
                }
            }
            Spacer()
            if pluginManager.isRecordatoriosEnabled {
                RecordatorioQuickButton(habit: habit, action: onReminderTap)
            }
            Toggle("", isOn: Binding(get: { habit.activo }, set: { _ in onToggleActive() }))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
        .onAppear {
            if pluginManager.isRachasEnabled {
                // Pequeña protección por si RachaCalculator falla
                if let racha = try? RachaCalculator.shared.calcularRachaActual(para: habit, instancias: dataStore.instances) {
                    rachaActual = racha
                }
            }
        }
    }
}
