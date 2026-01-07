//
//  HabitsListView.swift
//  HabitTracker
//
//  Vista de lista de hábitos - Actualizada con indicadores de Recordatorios
//

import SwiftUI

struct HabitsListView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitsViewModel
    @State private var showingCreateView = false
    @State private var selectedHabitForReminder: Habit?
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitsViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            List {
                if dataStore.habits.isEmpty {
                    emptyStateView
                } else {
                    ForEach(dataStore.habits) { habit in
                        NavigationLink(destination: HabitDetailView(dataStore: dataStore, habit: habit)) {
                            HabitRowView(
                                habit: habit,
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
                RecordatorioConfigView(dataStore: dataStore, habit: habit)
            }
        }
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
    
    // MARK: - Actions
    
    func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = dataStore.habits[index]
            
            // Cancelar recordatorios antes de eliminar
            NotificationService.shared.cancelReminder(for: habit)
            
            viewModel.deleteHabit(habit)
        }
    }
}

// MARK: - Habit Row View

/// Vista de fila para cada hábito en la lista
struct HabitRowView: View {
    
    let habit: Habit
    let onToggleActive: () -> Void
    let onReminderTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Información del hábito
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(habit.nombre)
                        .font(.headline)
                        .foregroundColor(habit.activo ? .primary : .secondary)
                    
                    // Badge de recordatorio
                    RecordatorioBadgeView(habit: habit)
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
            
            // Botón rápido de recordatorio
            RecordatorioQuickButton(habit: habit, action: onReminderTap)
            
            // Toggle de activo
            Toggle("", isOn: Binding(
                get: { habit.activo },
                set: { _ in onToggleActive() }
            ))
            .labelsHidden()
            .tint(.green)
        }
        .padding(.vertical, 4)
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
