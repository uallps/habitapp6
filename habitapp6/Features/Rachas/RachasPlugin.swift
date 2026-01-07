//
//  RachasPlugin.swift
//  HabitTracker
//
//  Feature: Rachas - Plugin SPL (Compatible con Swift 5.5)
//

import Foundation
import SwiftUI

/// Plugin que gestiona las rachas de hábitos
@MainActor
class RachasPlugin: DataPlugin, StatisticsPlugin {
    
    // MARK: - FeaturePlugin Properties
    
    var isEnabled: Bool {
        return config.showRachas
    }
    
    let pluginId: String = "com.habittracker.rachas"
    let pluginName: String = "Rachas"
    let pluginDescription: String = "Muestra tu consistencia y rachas de hábitos completados"
    
    // MARK: - Private Properties
    
    private let config: AppConfig
    private let calculator: RachaCalculator
    
    // MARK: - Initialization
    
    init(config: AppConfig) {
        self.config = config
        self.calculator = RachaCalculator.shared
        print("🔥 RachasPlugin inicializado - Habilitado: \(isEnabled)")
    }
    
    // MARK: - DataPlugin Methods
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        
        // Aquí podríamos hacer algo cuando cambia una instancia
        // Por ejemplo, verificar si se alcanzó un nuevo milestone
        print("🔥 RachasPlugin: Instancia toggleada para '\(habit.nombre)'")
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        print("📝 RachasPlugin: Hábito \(habitId) eliminado")
    }
    
    // MARK: - StatisticsPlugin Methods
    
    typealias StatisticsResult = RachaInfo
    
    nonisolated func calculateStatistics(for habit: Habit, instances: [HabitInstance]) -> RachaInfo {
        return RachaCalculator.shared.calcularRacha(para: habit, instancias: instances)
    }
    
    /// Calcula solo la racha actual
    nonisolated func calculateCurrentStreak(for habit: Habit, instances: [HabitInstance]) -> Int {
        return RachaCalculator.shared.calcularRachaActual(para: habit, instancias: instances)
    }
    
    /// Calcula la mejor racha
    nonisolated func calculateBestStreak(for habit: Habit, instances: [HabitInstance]) -> Int {
        return RachaCalculator.shared.calcularMejorRacha(para: habit, instancias: instances)
    }
    
    // MARK: - View Methods
    
    /// Provee vista badge para la fila del hábito en listas
    @ViewBuilder
    func habitRowBadge(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            RachaBadgeViewWrapper(habit: habit, dataStore: dataStore)
        }
    }
    
    /// Provee vista para la fila del hábito con más detalles
    @ViewBuilder
    func habitRowView(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            RachaRowView(dataStore: dataStore, habit: habit)
        }
    }
    
    /// Provee vista para el detalle del hábito
    @ViewBuilder
    func habitDetailSection(for habit: Habit, dataStore: HabitDataStore, showDetail: Binding<Bool>) -> some View {
        if isEnabled {
            RachaDetailSectionView(
                habit: habit,
                dataStore: dataStore,
                showDetail: showDetail
            )
        }
    }
    
    /// Provee la vista completa de detalle de racha
    @ViewBuilder
    func rachaDetailView(for habit: Habit, dataStore: HabitDataStore) -> some View {
        if isEnabled {
            RachaDetailView(dataStore: dataStore, habit: habit)
        }
    }
    
    /// Provee la vista de configuración del plugin
    @ViewBuilder
    func settingsView() -> some View {
        Toggle("Mostrar Rachas", isOn: Binding(
            get: { self.config.showRachas },
            set: { self.config.showRachas = $0 }
        ))
    }
}

// MARK: - Supporting Views

/// Wrapper para RachaBadgeView que calcula la racha
private struct RachaBadgeViewWrapper: View {
    let habit: Habit
    @ObservedObject var dataStore: HabitDataStore
    
    @State private var rachaActual: Int = 0
    
    var body: some View {
        RachaBadgeView(rachaActual: rachaActual, frecuencia: habit.frecuencia)
            .onAppear { calcularRacha() }
            .onChange(of: dataStore.instances.count) { _ in calcularRacha() }
    }
    
    private func calcularRacha() {
        rachaActual = RachaCalculator.shared.calcularRachaActual(
            para: habit,
            instancias: dataStore.instances
        )
    }
}

/// Sección de racha para HabitDetailView
struct RachaDetailSectionView: View {
    let habit: Habit
    @ObservedObject var dataStore: HabitDataStore
    @Binding var showDetail: Bool
    
    @State private var rachaInfo: RachaInfo = .empty
    
    var body: some View {
        Section {
            Button {
                showDetail = true
            } label: {
                RachaRowView(dataStore: dataStore, habit: habit)
            }
            .buttonStyle(.plain)
            
            // Mini calendario para hábitos diarios
            if habit.frecuencia == .diario {
                HStack {
                    Text("Últimos 7 días")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    RachaMiniCalendarView(dataStore: dataStore, habit: habit)
                }
            }
        } header: {
            HStack {
                Text("Racha")
                Spacer()
                RachaBadgeView(rachaActual: rachaInfo.rachaActual, frecuencia: habit.frecuencia)
            }
        } footer: {
            Text("Mantén la constancia completando el hábito cada \(habit.frecuencia == .diario ? "día" : "semana") para aumentar tu racha.")
        }
        .onAppear { calcularRacha() }
        .onChange(of: dataStore.instances.count) { _ in calcularRacha() }
    }
    
    private func calcularRacha() {
        rachaInfo = RachaCalculator.shared.calcularRacha(
            para: habit,
            instancias: dataStore.instances
        )
    }
}
