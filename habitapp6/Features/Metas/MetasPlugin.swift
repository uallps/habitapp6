//
//  MetasPlugin.swift
//  HabitTracker
//
//  Feature: Metas - Plugin SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

/// Plugin que gestiona las metas de hábitos
@MainActor
class MetasPlugin: DataPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    var isEnabled: Bool {
        return config.showMetas
    }
    
    let pluginId: String = "com.habittracker.metas"
    let pluginName: String = "Metas"
    let pluginDescription: String = "Define objetivos a cumplir para tus hábitos en diferentes períodos de tiempo"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    private let metaStore: MetaDataStore
    
    // MARK: - Initialization
    
    init(config: AppConfig) {
        self.config = config
        self.metaStore = MetaDataStore.shared
        print("🎯 MetasPlugin inicializado - Habilitado: \(isEnabled)")
    }
    
    // MARK: - DataPlugin Methods
    
    func willCreateHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        print("🎯 MetasPlugin: Se creará hábito '\(habit.nombre)'")
    }
    
    func didCreateHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        print("🎯 MetasPlugin: Hábito '\(habit.nombre)' creado")
    }
    
    func willDeleteHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        print("🎯 MetasPlugin: Hábito '\(habit.nombre)' será eliminado - eliminando metas asociadas")
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        // Eliminar todas las metas del hábito eliminado
        await metaStore.deleteMetasForHabit(habitId: habitId)
        print("🎯 MetasPlugin: Metas del hábito \(habitId) eliminadas")
    }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        
        // Verificar si alguna meta se ha completado
        let habitDataStore = await MainActor.run { HabitDataStore() }
        let instances = await MainActor.run { habitDataStore.instances }
        await metaStore.verificarEstadoMetas(instancias: instances)
        
        print("🎯 MetasPlugin: Instancia toggleada para '\(habit.nombre)' - verificando metas")
    }
    
    // MARK: - View Methods
    
    /// Provee badge de metas para la fila del hábito en listas
    @ViewBuilder
    func habitRowBadge(for habit: Habit) -> some View {
        if isEnabled {
            let metasActivas = metaStore.metasActivasParaHabito(habit.id).count
            MetaBadgeView(metasActivas: metasActivas)
        }
    }
    
    /// Provee la sección de metas para el detalle del hábito
    @ViewBuilder
    func habitDetailSection(for habit: Habit, dataStore: HabitDataStore, showDetail: Binding<Bool>) -> some View {
        if isEnabled {
            MetaDetailSectionView(
                habit: habit,
                dataStore: dataStore,
                showDetail: showDetail
            )
        }
    }
    
    /// Provee la vista completa de lista de metas
    @ViewBuilder
    func metasListView(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            MetasListView(habit: habit, dataStore: dataStore)
        }
    }
    
    /// Provee la vista de felicitación por metas completadas
    @ViewBuilder
    func felicitacionOverlay(viewModel: MetasCompletadasViewModel) -> some View {
        if isEnabled {
            MetaFelicitacionOverlayView(viewModel: viewModel)
        }
    }
    
    /// Provee la vista de configuración del plugin
    @ViewBuilder
    func settingsView() -> some View {
        Toggle("Mostrar Metas", isOn: Binding(
            get: { self.config.showMetas },
            set: { self.config.showMetas = $0 }
        ))
    }
    
    // MARK: - Helper Methods
    
    /// Obtiene las metas activas de un hábito
    func metasActivas(para habitId: UUID) -> [Meta] {
        guard isEnabled else { return [] }
        return metaStore.metasActivasParaHabito(habitId)
    }
    
    /// Obtiene todas las metas de un hábito
    func metas(para habitId: UUID) -> [Meta] {
        guard isEnabled else { return [] }
        return metaStore.metasParaHabito(habitId)
    }
    
    /// Cuenta las metas activas de un hábito
    func contarMetasActivas(para habitId: UUID) -> Int {
        guard isEnabled else { return 0 }
        return metaStore.metasActivasParaHabito(habitId).count
    }
    
    /// Obtiene las estadísticas generales de metas
    func estadisticas() -> MetaEstadisticas {
        guard isEnabled else {
            return MetaEstadisticas(activas: 0, completadas: 0, fallidas: 0, total: 0, tasaExito: 0)
        }
        return metaStore.estadisticas()
    }
    
    /// Verifica el estado de todas las metas (para llamar periódicamente)
    func verificarMetas(instancias: [HabitInstance]) async {
        guard isEnabled else { return }
        await metaStore.verificarEstadoMetas(instancias: instancias)
    }
}

// MARK: - Supporting Views

/// Sección de metas para HabitDetailView
struct MetaDetailSectionView: View {
    let habit: Habit
    @ObservedObject var dataStore: HabitDataStore
    @Binding var showDetail: Bool
    
    @State private var metas: [Meta] = []
    
    private var metaStore: MetaDataStore {
        MetaDataStore.shared
    }
    
    var body: some View {
        Section {
            if metas.isEmpty {
                // Estado vacío con botón para crear meta
                Button {
                    showDetail = true
                } label: {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.purple)
                        Text("Crear primera meta")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.purple)
                    }
                }
            } else {
                // Mostrar metas activas
                ForEach(metasActivas) { meta in
                    let progreso = meta.calcularProgreso(instancias: dataStore.instances)
                    MetaRowCompactView(meta: meta, progreso: progreso)
                }
                
                // Botón para ver todas las metas
                Button {
                    showDetail = true
                } label: {
                    HStack {
                        Text("Ver todas las metas")
                            .font(.subheadline)
                        Spacer()
                        Text("\(metas.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            HStack {
                Text("Metas")
                Spacer()
                if !metasActivas.isEmpty {
                    MetaBadgeView(metasActivas: metasActivas.count)
                }
            }
        } footer: {
            Text("Define objetivos específicos como completar el hábito un número determinado de veces en un período de tiempo.")
        }
        .onAppear {
            loadMetas()
        }
        .onChange(of: dataStore.instances.count) { _ in
            loadMetas()
        }
    }
    
    private var metasActivas: [Meta] {
        metas.filter { $0.estaActiva }
    }
    
    private func loadMetas() {
        metas = metaStore.metasParaHabito(habit.id)
    }
}

/// Vista de resumen de metas para la pantalla principal
struct MetasResumenView: View {
    @ObservedObject var dataStore: HabitDataStore
    
    private var metaStore: MetaDataStore {
        MetaDataStore.shared
    }
    
    @State private var estadisticas: MetaEstadisticas = MetaEstadisticas(
        activas: 0, completadas: 0, fallidas: 0, total: 0, tasaExito: 0
    )
    
    var body: some View {
        if estadisticas.activas > 0 {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Metas activas")
                            .font(.subheadline)
                        Text("\(estadisticas.activas)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Completadas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(estadisticas.completadas)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            } header: {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.purple)
                    Text("Metas")
                }
            }
            .onAppear {
                estadisticas = metaStore.estadisticas()
            }
        }
    }
}
