//
//  HabitsListView.swift
//  HabitTracker
//
//  Vista de lista de hábitos - Integrada con sistema de plugins SPL
//

import SwiftUI

struct HabitsListView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitsViewModel
    @ObservedObject private var pluginManager = PluginManager.shared
    @State private var showingCreateView = false
    @State private var selectedHabitForReminder: Habit?
    @State private var selectedCategoriaFilter: Categoria? = nil
    @State private var showByCategoria: Bool = false
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitsViewModel(dataStore: dataStore))
    }
    
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
                                            viewModel.toggleHabitActive(habit)
                                        },
                                        onReminderTap: {
                                            selectedHabitForReminder = habit
                                        }
                                    )
                                }
                            }
                            .onDelete(perform: deleteHabits)
                        }
                    }
                }
            }
            .navigationTitle("Mis Hábitos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreateHabitView(dataStore: dataStore)
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
    
    // MARK: - Views
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No hay hábitos")
                .font(.headline)
            
            Text("Toca el botón + para crear tu primer hábito")
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
    
    // MARK: - Actions
    
    func deleteHabits(at offsets: IndexSet) {
        let habitsToDelete = offsets.map { filteredHabits[$0] }
        
        for habit in habitsToDelete {
            // Notificar a los plugins antes de eliminar
            Task {
                await pluginManager.willDeleteHabit(habit)
                viewModel.deleteHabit(habit)
                await pluginManager.didDeleteHabit(habitId: habit.id)
            }
        }
    }
}

// MARK: - Habit Row View

/// Vista de fila para cada hábito en la lista
struct HabitRowView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    let habit: Habit
    @ObservedObject var pluginManager: PluginManager
    let onToggleActive: () -> Void
    let onReminderTap: () -> Void
    
    @State private var rachaActual: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Información del hábito
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(habit.nombre)
                        .font(.headline)
                        .foregroundColor(habit.activo ? .primary : .secondary)
                    
                    // Badge de categoría (solo si plugin habilitado)
                    if pluginManager.isCategoriasEnabled && habit.tieneCategoria {
                        CategoriaBadgeView(categoria: habit.categoriaEnum)
                    }
                    
                    // Badge de racha (solo si plugin habilitado)
                    if pluginManager.isRachasEnabled {
                        RachaBadgeView(rachaActual: rachaActual, frecuencia: habit.frecuencia)
                    }
                    
                    // Badge de recordatorio (solo si plugin habilitado)
                    if pluginManager.isRecordatoriosEnabled {
                        RecordatorioBadgeView(habit: habit)
                    }
                }
                
                HStack(spacing: 8) {
                    // Frecuencia
                    Label(
                        habit.frecuencia.rawValue.capitalized,
                        systemImage: habit.frecuencia == .diario ? "sun.max" : "calendar.badge.clock"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    // Estado
                    if !habit.activo {
                        Text("• Pausado")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Botón rápido de recordatorio (solo si plugin habilitado)
            if pluginManager.isRecordatoriosEnabled {
                RecordatorioQuickButton(habit: habit, action: onReminderTap)
            }
            
            // Toggle de activo
            Toggle("", isOn: Binding(
                get: { habit.activo },
                set: { _ in onToggleActive() }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
        .onAppear {
            if pluginManager.isRachasEnabled {
                calcularRacha()
            }
        }
        .onChange(of: dataStore.instances.count) { _ in
            if pluginManager.isRachasEnabled {
                calcularRacha()
            }
        }
    }
    
    private func calcularRacha() {
        rachaActual = RachaCalculator.shared.calcularRachaActual(para: habit, instancias: dataStore.instances)
    }
}

// MARK: - Habit Identifiable Extension

extension Habit: Hashable {
    public static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview

#if DEBUG
struct HabitsListView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore()
        
        // Añadir hábitos de ejemplo
        let habit1 = Habit(nombre: "Ejercicio", frecuencia: .diario)
        habit1.activarRecordatorio(horasAnticipacion: 5)
        
        let habit2 = Habit(nombre: "Leer", frecuencia: .diario)
        
        let habit3 = Habit(nombre: "Revisión semanal", frecuencia: .semanal)
        habit3.activarRecordatorio(horasAnticipacion: 12)
        
        dataStore.habits = [habit1, habit2, habit3]
        
        return HabitsListView(dataStore: dataStore)
    }
}
#endif
