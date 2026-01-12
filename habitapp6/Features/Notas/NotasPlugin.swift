//
//  NotasPlugin.swift
//  HabitTracker
//
//  Feature: Notas - Plugin SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

/// Plugin que gestiona las notas de hábitos
@MainActor
class NotasPlugin: DataPlugin, StatisticsPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    var isEnabled: Bool {
        return config.showNotas
    }
    
    let pluginId: String = "com.habittracker.notas"
    let pluginName: String = "Notas"
    let pluginDescription: String = "Añade notas diarias a tus hábitos"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    private let storage: NotaStorage
    
    // MARK: - Initialization
    
    init(config: AppConfig, storage: NotaStorage = .shared) {
        self.config = config
        self.storage = storage
        print("📝 NotasPlugin inicializado - Habilitado: \(isEnabled)")
    }
    
    // MARK: - DataPlugin Methods
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        
        // Si se completó la instancia de hoy, podríamos sugerir agregar una nota
        print("📝 NotasPlugin: Instancia toggleada para '\(habit.nombre)'")
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        
        // Cuando se elimina un hábito, eliminamos sus notas asociadas
        do {
            let notas = try await storage.obtenerNotas(habitID: habitId)
            for nota in notas {
                try await storage.eliminarNota(id: nota.id)
            }
            print("📝 NotasPlugin: Notas del hábito \(habitId) eliminadas")
        } catch {
            print("❌ NotasPlugin: Error al eliminar notas: \(error)")
        }
    }
    
    // MARK: - StatisticsPlugin Methods
    
    typealias StatisticsResult = NotaEstadisticas
    
    nonisolated func calculateStatistics(for habit: Habit, instances: [HabitInstance]) -> NotaEstadisticas {
        // Esta función debe ser nonisolated, así que usamos Task para esperar
        // En la práctica, esto debería ser llamado desde un contexto async
        return NotaEstadisticas.empty
    }
    
    /// Calcula estadísticas de notas para un hábito
    func calcularEstadisticasNotas(habitID: UUID) async -> NotaEstadisticas {
        do {
            return try await storage.calcularEstadisticas(habitID: habitID)
        } catch {
            print("❌ NotasPlugin: Error al calcular estadísticas: \(error)")
            return .empty
        }
    }
    
    // MARK: - View Methods
    
    /// Provee vista badge para la fila del hábito en listas
    @ViewBuilder
    func habitRowBadge(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            NotaBadgeViewWrapper(habit: habit)
        }
    }
    
    /// Provee vista para la fila del hábito con más detalles
    @ViewBuilder
    func habitRowView(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            NotaRowView(habit: habit)
        }
    }
    
    /// Provee vista para el detalle del hábito
    @ViewBuilder
    func habitDetailSection(for habit: Habit, dataStore: HabitDataStore, showDetail: Binding<Bool>) -> some View {
        if isEnabled {
            NotaDetailSectionView(
                habit: habit,
                showDetail: showDetail
            )
        }
    }
    
    /// Provee la vista completa de detalle de notas
    @ViewBuilder
    func notaDetailView(for habit: Habit) -> some View {
        if isEnabled {
            NotaDetailView(habit: habit)
        }
    }
    
    /// Provee la vista de configuración del plugin
    @ViewBuilder
    func settingsView() -> some View {
        Toggle("Mostrar Notas", isOn: Binding(
            get: { self.config.showNotas },
            set: { self.config.showNotas = $0 }
        ))
    }
}

// MARK: - Supporting Views

/// Wrapper para NotaBadgeView que verifica si hay nota
private struct NotaBadgeViewWrapper: View {
    let habit: Habit
    @StateObject private var viewModel: NotaViewModel
    
    init(habit: Habit) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: NotaViewModel(habit: habit))
    }
    
    var body: some View {
        NotaBadgeView(
            tieneNota: viewModel.notaActual != nil,
            esImportante: viewModel.notaActual?.esImportante ?? false
        )
    }
}

/// Sección de notas para HabitDetailView
struct NotaDetailSectionView: View {
    let habit: Habit
    @Binding var showDetail: Bool
    @StateObject private var viewModel: NotaViewModel
    
    init(habit: Habit, showDetail: Binding<Bool>) {
        self.habit = habit
        _showDetail = showDetail
        _viewModel = StateObject(wrappedValue: NotaViewModel(habit: habit))
    }
    
    var body: some View {
        Section {
            Button {
                showDetail = true
            } label: {
                NotaRowView(habit: habit)
            }
            .buttonStyle(.plain)
            
            // Botón rápido para editar/crear nota de hoy
            Button {
                viewModel.prepararEditor(nota: viewModel.notaActual)
            } label: {
                HStack {
                    Image(systemName: viewModel.notaActual != nil ? "pencil" : "plus")
                    Text(viewModel.notaActual != nil ? "Editar nota de hoy" : "Agregar nota de hoy")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            
            // Mini calendario si hay notas
            if viewModel.tieneNotas {
                HStack {
                    Text("Últimos 7 días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    NotasMiniCalendarView(habit: habit)
                }
            }
        } header: {
            HStack {
                Text("Notas")
                Spacer()
                if viewModel.cantidadNotas > 0 {
                    Text("\(viewModel.cantidadNotas)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } footer: {
            Text("Documenta tu progreso con notas diarias sobre este hábito.")
        }
        .sheet(isPresented: $viewModel.mostrarEditor) {
            NotaEditorView(viewModel: viewModel, habit: habit)
        }
    }
}
