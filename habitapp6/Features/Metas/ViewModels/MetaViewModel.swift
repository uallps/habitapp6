//
//  MetaViewModel.swift
//  HabitTracker
//
//  Feature: Metas - ViewModel para gestión de metas
//

import Foundation
import SwiftUI
import Combine

/// ViewModel para gestionar las metas de un hábito
@MainActor
class MetaViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var metas: [Meta] = []
    @Published var progresos: [UUID: MetaProgreso] = [:]
    @Published var metaSeleccionada: Meta?
    @Published var showingCrearMeta = false
    @Published var showingDetalleMeta = false
    
    // MARK: - Private Properties
    
    private let metaStore: MetaDataStore
    private let habitDataStore: HabitDataStore
    private let habit: Habit
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(habit: Habit, habitDataStore: HabitDataStore) {
        self.habit = habit
        self.habitDataStore = habitDataStore
        self.metaStore = MetaDataStore.shared
        
        setupBindings()
        loadMetas()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observar cambios en las metas
        metaStore.$metas
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadMetas()
            }
            .store(in: &cancellables)
        
        // Observar cambios en las instancias para actualizar progresos
        habitDataStore.$instances
            .receive(on: DispatchQueue.main)
            .sink { [weak self] instances in
                self?.actualizarProgresos(instances: instances)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadMetas() {
        metas = metaStore.metasParaHabito(habit.id)
        actualizarProgresos(instances: habitDataStore.instances)
    }
    
    private func actualizarProgresos(instances: [HabitInstance]) {
        for meta in metas {
            let progreso = meta.calcularProgreso(instancias: instances)
            progresos[meta.id] = progreso
        }
    }
    
    // MARK: - Computed Properties
    
    /// Metas activas del hábito
    var metasActivas: [Meta] {
        return metas.filter { $0.estaActiva }
    }
    
    /// Metas completadas del hábito
    var metasCompletadas: [Meta] {
        return metas.filter { $0.estado == .completada }
    }
    
    /// Metas fallidas del hábito
    var metasFallidas: [Meta] {
        return metas.filter { $0.estado == .fallida }
    }
    
    /// Indica si hay metas activas
    var tieneMetas: Bool {
        return !metas.isEmpty
    }
    
    /// Indica si hay metas activas
    var tieneMetasActivas: Bool {
        return !metasActivas.isEmpty
    }
    
    // MARK: - CRUD Operations
    
    /// Crea una nueva meta
    func crearMeta(nombre: String, descripcion: String, objetivo: Int, periodo: PeriodoMeta) async {
        let meta = Meta(
            habitID: habit.id,
            nombre: nombre,
            descripcion: descripcion,
            objetivo: objetivo,
            periodo: periodo
        )
        await metaStore.addMeta(meta)
        loadMetas()
    }
    
    /// Actualiza una meta existente
    func actualizarMeta(_ meta: Meta) async {
        await metaStore.updateMeta(meta)
        loadMetas()
    }
    
    /// Elimina una meta
    func eliminarMeta(_ meta: Meta) async {
        await metaStore.deleteMeta(meta)
        loadMetas()
    }
    
    /// Cancela una meta activa
    func cancelarMeta(_ meta: Meta) async {
        meta.cancelar()
        await metaStore.updateMeta(meta)
        loadMetas()
    }
    
    // MARK: - Progress
    
    /// Obtiene el progreso de una meta
    func progreso(para meta: Meta) -> MetaProgreso {
        return progresos[meta.id] ?? meta.calcularProgreso(instancias: habitDataStore.instances)
    }
    
    /// Verifica si una meta está próxima a vencer (menos de 3 días)
    func estaProximaAVencer(_ meta: Meta) -> Bool {
        return meta.diasRestantes <= 3 && meta.estaActiva
    }
    
    /// Mensaje motivacional según el progreso
    func mensajeMotivacional(para meta: Meta) -> String {
        let progreso = self.progreso(para: meta)
        
        if progreso.estaCompletada {
            return "🎉 ¡Meta completada!"
        } else if progreso.porcentaje >= 0.9 {
            return "🔥 ¡Ya casi lo logras!"
        } else if progreso.porcentaje >= 0.75 {
            return "💪 ¡Vas muy bien!"
        } else if progreso.porcentaje >= 0.5 {
            return "📈 ¡Buen progreso!"
        } else if progreso.porcentaje >= 0.25 {
            return "🚀 ¡Sigue así!"
        } else {
            return "🎯 ¡Empieza hoy!"
        }
    }
}

// MARK: - MetaViewModel for Today View

/// ViewModel para gestionar metas completadas recientes (para TodayView)
@MainActor
class MetasCompletadasViewModel: ObservableObject {
    
    @Published var metasCompletadas: [Meta] = []
    @Published var showingFelicitacion = false
    
    private let metaStore: MetaDataStore
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.metaStore = MetaDataStore.shared
        setupBindings()
    }
    
    private func setupBindings() {
        metaStore.$metasCompletadasRecientes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metas in
                if !metas.isEmpty {
                    self?.metasCompletadas = metas
                    self?.showingFelicitacion = true
                }
            }
            .store(in: &cancellables)
    }
    
    func cerrarFelicitacion() {
        showingFelicitacion = false
        metaStore.limpiarMetasCompletadasRecientes()
    }
}
