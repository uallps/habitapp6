//
//  HabitDetailView.swift
//  HabitTracker
//
//  Vista de detalle de un hábito - Actualizada con soporte para Recordatorios
//

import SwiftUI

struct HabitDetailView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingRecordatorioConfig = false
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(
            dataStore: dataStore,
            habit: habit
        ))
    }
    
    var body: some View {
        Form {
            // MARK: - Información Básica
            Section("Información") {
                TextField("Nombre", text: $viewModel.habit.nombre)
                
                Picker("Frecuencia", selection: $viewModel.habit.frecuencia) {
                    ForEach(Frecuencia.allCases, id: \.self) { frecuencia in
                        Text(frecuencia.rawValue.capitalized).tag(frecuencia)
                    }
                }
                
                Toggle("Activo", isOn: $viewModel.habit.activo)
            }
            
            // MARK: - Recordatorios (Feature)
            Section {
                Button {
                    showingRecordatorioConfig = true
                } label: {
                    RecordatorioStatusView(habit: viewModel.habit)
                }
                .buttonStyle(.plain)
            } header: {
                HStack {
                    Text("Recordatorio")
                    Spacer()
                    if viewModel.habit.tieneRecordatorioActivo {
                        RecordatorioBadgeView(habit: viewModel.habit)
                    }
                }
            } footer: {
                Text("Configura notificaciones para recordarte completar este hábito antes de que termine el período.")
            }
            
            // MARK: - Estadísticas
            Section("Estadísticas") {
                let completedCount = dataStore.instances.filter {
                    $0.habitID == viewModel.habit.id && $0.completado
                }.count
                
                let totalCount = dataStore.instances.filter {
                    $0.habitID == viewModel.habit.id
                }.count
                
                StatRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Veces completado",
                    value: "\(completedCount)"
                )
                
                StatRow(
                    icon: "calendar",
                    iconColor: .blue,
                    title: "Total de instancias",
                    value: "\(totalCount)"
                )
                
                if totalCount > 0 {
                    let percentage = Double(completedCount) / Double(totalCount) * 100
                    StatRow(
                        icon: "percent",
                        iconColor: .orange,
                        title: "Tasa de completado",
                        value: String(format: "%.1f%%", percentage)
                    )
                }
                
                StatRow(
                    icon: "clock",
                    iconColor: .purple,
                    title: "Fecha de creación",
                    value: viewModel.habit.fechaCreacion.formatted(date: .abbreviated, time: .omitted)
                )
            }
            
            // MARK: - Acciones Rápidas
            Section {
                if !viewModel.habit.tieneRecordatorioActivo {
                    Button {
                        activateQuickReminder()
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.orange)
                            Text("Activar recordatorio rápido (5h antes)")
                        }
                    }
                } else {
                    Button(role: .destructive) {
                        deactivateReminder()
                    } label: {
                        HStack {
                            Image(systemName: "bell.slash.fill")
                            Text("Desactivar recordatorio")
                        }
                    }
                }
            }
        }
        .navigationTitle("Detalles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    viewModel.updateHabit()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingRecordatorioConfig) {
            RecordatorioConfigView(dataStore: dataStore, habit: viewModel.habit)
                .onDisappear {
                    // Recargar el hábito después de cerrar la configuración
                    if let updatedHabit = dataStore.habits.first(where: { $0.id == viewModel.habit.id }) {
                        viewModel.habit = updatedHabit
                    }
                }
        }
    }
    
    // MARK: - Actions
    
    private func activateQuickReminder() {
        viewModel.habit.activarRecordatorio(horasAnticipacion: 5)
        viewModel.updateHabit()
        
        // Programar notificaciones
        Task {
            await scheduleNotificationsForHabit()
        }
    }
    
    private func deactivateReminder() {
        viewModel.habit.desactivarRecordatorio()
        viewModel.updateHabit()
        
        // Cancelar notificaciones
        NotificationService.shared.cancelReminder(for: viewModel.habit)
    }
    
    private func scheduleNotificationsForHabit() async {
        // Buscar instancia pendiente
        if let instance = dataStore.instances.first(where: {
            $0.habitID == viewModel.habit.id && !$0.completado
        }) {
            await NotificationService.shared.scheduleHabitReminder(
                for: viewModel.habit,
                instance: instance
            )
        }
    }
}

// MARK: - Supporting Views

/// Fila de estadística reutilizable
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let dataStore = HabitDataStore()
            let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
            
            HabitDetailView(dataStore: dataStore, habit: habit)
        }
    }
}
#endif
