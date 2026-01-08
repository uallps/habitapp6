//
//  HabitDetailView.swift
//  HabitTracker
//
//  Vista de detalle de un hábito - Integrada con sistema de plugins SPL
//

import SwiftUI

struct HabitDetailView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitDetailViewModel
    @ObservedObject private var pluginManager = PluginManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingRecordatorioConfig = false
    @State private var showingRachaDetail = false
    @State private var showingMetasDetail = false
    @State private var rachaInfo: RachaInfo = .empty
    @State private var selectedCategoria: Categoria = .ninguno
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(
            dataStore: dataStore,
            habit: habit
        ))
    }
    
    var body: some View {
        Form {
            // MARK: - Información Básica (Core)
            Section("Información") {
                TextField("Nombre", text: $viewModel.habit.nombre)
                
                Picker("Frecuencia", selection: $viewModel.habit.frecuencia) {
                    ForEach(Frecuencia.allCases, id: \.self) { frecuencia in
                        Text(frecuencia.rawValue.capitalized).tag(frecuencia)
                    }
                }
                
                Toggle("Activo", isOn: $viewModel.habit.activo)
            }
            
            // MARK: - Categoría (Feature Plugin - Solo si está habilitado)
            if pluginManager.isCategoriasEnabled {
                categoriaSection
            }
            
            // MARK: - Racha (Feature Plugin - Solo si está habilitado)
            if pluginManager.isRachasEnabled {
                rachaSection
            }
            
            // MARK: - Metas (Feature Plugin - Solo si está habilitado)
            if pluginManager.isMetasEnabled {
                metasSection
            }
            
            // MARK: - Recordatorios (Feature Plugin - Solo si está habilitado)
            if pluginManager.isRecordatoriosEnabled {
                recordatorioSection
            }
            
            // MARK: - Estadísticas (Core)
            estadisticasSection
            
            // MARK: - Acciones Rápidas (Condicionales según plugins)
            if pluginManager.isRecordatoriosEnabled {
                accionesRecordatorioSection
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
            if pluginManager.isRecordatoriosEnabled {
                RecordatorioConfigView(dataStore: dataStore, habit: viewModel.habit)
                    .onDisappear {
                        reloadHabit()
                    }
            }
        }
        .sheet(isPresented: $showingRachaDetail) {
            if pluginManager.isRachasEnabled {
                NavigationView {
                    RachaDetailView(dataStore: dataStore, habit: viewModel.habit)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Cerrar") {
                                    showingRachaDetail = false
                                }
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showingMetasDetail) {
            if pluginManager.isMetasEnabled {
                MetasListView(habit: viewModel.habit, dataStore: dataStore)
            }
        }
        .onAppear {
            if pluginManager.isRachasEnabled {
                calcularRacha()
            }
            if pluginManager.isCategoriasEnabled {
                selectedCategoria = viewModel.habit.categoriaEnum
            }
        }
        .onChange(of: dataStore.instances.count) { _ in
            if pluginManager.isRachasEnabled {
                calcularRacha()
            }
        }
        .onChange(of: selectedCategoria) { newValue in
            viewModel.habit.categoriaEnum = newValue
        }
    }
    
    // MARK: - Categoria Section (Plugin)
    
    @ViewBuilder
    private var categoriaSection: some View {
        CategoriaDetailSectionView(categoria: $selectedCategoria)
    }
    
    // MARK: - Racha Section (Plugin)
    
    @ViewBuilder
    private var rachaSection: some View {
        Section {
            Button {
                showingRachaDetail = true
            } label: {
                RachaRowView(dataStore: dataStore, habit: viewModel.habit)
            }
            .buttonStyle(.plain)
            
            // Mini calendario para hábitos diarios
            if viewModel.habit.frecuencia == .diario {
                HStack {
                    Text("Últimos 7 días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    RachaMiniCalendarView(dataStore: dataStore, habit: viewModel.habit)
                }
            }
        } header: {
            HStack {
                Text("Racha")
                Spacer()
                RachaBadgeView(rachaActual: rachaInfo.rachaActual, frecuencia: viewModel.habit.frecuencia)
            }
        } footer: {
            Text("Mantén la constancia completando el hábito cada \(viewModel.habit.frecuencia == .diario ? "día" : "semana") para aumentar tu racha.")
        }
    }
    
    // MARK: - Metas Section (Plugin)
    
    @ViewBuilder
    private var metasSection: some View {
        MetaDetailSectionView(
            habit: viewModel.habit,
            dataStore: dataStore,
            showDetail: $showingMetasDetail
        )
    }
    
    // MARK: - Recordatorio Section (Plugin)
    
    @ViewBuilder
    private var recordatorioSection: some View {
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
    }
    
    // MARK: - Estadísticas Section (Core)
    
    @ViewBuilder
    private var estadisticasSection: some View {
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
            
            // Mejor racha solo si el plugin está habilitado
            if pluginManager.isRachasEnabled {
                StatRow(
                    icon: "trophy.fill",
                    iconColor: .yellow,
                    title: "Mejor racha",
                    value: rachaInfo.descripcionMejorRacha
                )
            }
            
            StatRow(
                icon: "clock",
                iconColor: .purple,
                title: "Fecha de creación",
                value: viewModel.habit.fechaCreacion.formatted(date: .abbreviated, time: .omitted)
            )
        }
    }
    
    // MARK: - Acciones Recordatorio Section (Plugin)
    
    @ViewBuilder
    private var accionesRecordatorioSection: some View {
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
    
    // MARK: - Actions
    
    private func reloadHabit() {
        if let updatedHabit = dataStore.habits.first(where: { $0.id == viewModel.habit.id }) {
            viewModel.habit = updatedHabit
        }
    }
    
    private func calcularRacha() {
        rachaInfo = RachaCalculator.shared.calcularRacha(para: viewModel.habit, instancias: dataStore.instances)
    }
    
    private func activateQuickReminder() {
        viewModel.habit.activarRecordatorio(horasAnticipacion: 5)
        viewModel.updateHabit()
        
        // Programar notificaciones a través del plugin
        Task {
            if let instance = dataStore.instances.first(where: {
                $0.habitID == viewModel.habit.id && !$0.completado
            }) {
                await pluginManager.recordatoriosPlugin?.scheduleNotifications(
                    for: viewModel.habit,
                    instance: instance
                )
            }
        }
    }
    
    private func deactivateReminder() {
        viewModel.habit.desactivarRecordatorio()
        viewModel.updateHabit()
        
        // Cancelar notificaciones a través del plugin
        Task {
            await pluginManager.recordatoriosPlugin?.cancelNotifications(for: viewModel.habit)
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
