//
//  RachaViewModel.swift
//  HabitTracker
//
//  Feature: Rachas
//  ViewModel para gestionar la visualización de rachas de un hábito
//

import Foundation
import Combine

@MainActor
class RachaViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var rachaInfo: RachaInfo = .empty
    @Published var milestoneActual: RachaMilestone?
    @Published var proximoMilestone: RachaMilestone?
    @Published var progresoMilestone: Double = 0
    @Published var isLoading: Bool = false
    @Published var mostrarCelebracion: Bool = false
    
    // MARK: - Dependencies
    
    private let dataStore: HabitDataStore
    private let calculator: RachaCalculator
    private let habit: Habit
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var tieneRachaActiva: Bool {
        rachaInfo.rachaActual > 0
    }
    
    var mensajeMotivacional: String {
        if rachaInfo.rachaActual == 0 {
            return "¡Completa hoy para empezar una racha!"
        }
        
        if rachaInfo.rachaEnRiesgo {
            return "⚠️ ¡Completa hoy para mantener tu racha!"
        }
        
        if rachaInfo.esNuevoRecord {
            return "🎉 ¡Estás en tu mejor racha!"
        }
        
        if let proximo = proximoMilestone {
            let faltan = proximo.valor - rachaInfo.rachaActual
            return "¡Solo \(faltan) más para \(proximo.emoji) \(proximo.titulo)!"
        }
        
        return "¡Sigue así, lo estás haciendo genial!"
    }
    
    var colorRacha: String {
        if rachaInfo.rachaActual == 0 {
            return "gray"
        }
        if rachaInfo.rachaEnRiesgo {
            return "orange"
        }
        if rachaInfo.rachaActual >= 30 {
            return "purple"
        }
        if rachaInfo.rachaActual >= 7 {
            return "green"
        }
        return "blue"
    }
    
    // MARK: - Initialization
    
    init(dataStore: HabitDataStore, habit: Habit, calculator: RachaCalculator = .shared) {
        self.dataStore = dataStore
        self.habit = habit
        self.calculator = calculator
        
        setupBindings()
        calcularRacha()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observar cambios en las instancias para recalcular
        dataStore.$instances
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.calcularRacha()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Recalcula la información de racha
    func calcularRacha() {
        isLoading = true
        
        let rachaAnterior = rachaInfo.rachaActual
        
        // Calcular nueva racha
        rachaInfo = calculator.calcularRacha(para: habit, instancias: dataStore.instances)
        
        // Actualizar milestones
        milestoneActual = RachaMilestone.milestoneActual(para: rachaInfo.rachaActual)
        proximoMilestone = RachaMilestone.proximoMilestone(para: rachaInfo.rachaActual)
        progresoMilestone = RachaMilestone.progresoHaciaProximo(racha: rachaInfo.rachaActual)
        
        // Verificar si alcanzó un nuevo milestone
        if rachaInfo.rachaActual > rachaAnterior {
            verificarNuevoMilestone(rachaAnterior: rachaAnterior, rachaNueva: rachaInfo.rachaActual)
        }
        
        isLoading = false
    }
    
    /// Verifica si se alcanzó un nuevo milestone y muestra celebración
    private func verificarNuevoMilestone(rachaAnterior: Int, rachaNueva: Int) {
        let milestonesAlcanzados = RachaMilestone.milestones.filter { milestone in
            milestone.valor > rachaAnterior && milestone.valor <= rachaNueva
        }
        
        if !milestonesAlcanzados.isEmpty {
            mostrarCelebracion = true
        }
    }
    
    /// Obtiene el historial de rachas (para gráficos futuros)
    func obtenerHistorialRachas() -> [(fecha: Date, racha: Int)] {
        // Implementación simplificada - se puede expandir
        var historial: [(fecha: Date, racha: Int)] = []
        
        let instanciasHabito = dataStore.instances
            .filter { $0.habitID == habit.id && $0.completado }
            .sorted { $0.fecha < $1.fecha }
        
        var rachaActual = 0
        for instancia in instanciasHabito {
            rachaActual += 1
            historial.append((instancia.fecha, rachaActual))
        }
        
        return historial
    }
}
