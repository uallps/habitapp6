//
//  NotaViewModel.swift
//  HabitTracker
//
//  Feature: Notas
//  ViewModel para gestionar la visualización de notas de un hábito
//

import Foundation
import Combine

class NotaViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var notas: [Nota] = []
    @Published var notaActual: Nota?
    @Published var estadisticas: NotaEstadisticas = .empty
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var mostrarEditor: Bool = false
    @Published var textoEditor: String = ""
    @Published var tagsDisponibles: [String] = []
    
    // MARK: - Dependencies
    
    private let storage: NotaStorage
    private let habit: Habit
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var tieneNotas: Bool {
        !notas.isEmpty
    }
    
    var cantidadNotas: Int {
        notas.count
    }
    
    var notasImportantes: [Nota] {
        notas.filter { $0.esImportante }
    }
    
    var notasRecientes: [Nota] {
        Array(notas.prefix(5))
    }
    
    // MARK: - Initialization
    
    init(storage: NotaStorage = NotaStorage.shared, habit: Habit) {
        self.storage = storage
        self.habit = habit
        
        setupBindings()
        Task {
            await cargarNotas()
        }
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observar cambios en el storage
        storage.$notas
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.cargarNotas() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Carga las notas del hábito
    func cargarNotas() async {
        isLoading = true
        errorMessage = nil
        
        do {
            notas = try await storage.obtenerNotas(habitID: habit.id)
            estadisticas = try await storage.calcularEstadisticas(habitID: habit.id)
            tagsDisponibles = storage.obtenerTagsUnicos()
            
            // Cargar nota del día actual si existe
            notaActual = try await storage.obtenerNotaDelDia(habitID: habit.id, fecha: Date())
            if let nota = notaActual {
                textoEditor = nota.contenido
            }
        } catch {
            errorMessage = "Error al cargar notas: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
        
        isLoading = false
    }
    
    /// Obtiene la nota de una fecha específica
    func obtenerNotaDelDia(fecha: Date) async -> Nota? {
        do {
            return try await storage.obtenerNotaDelDia(habitID: habit.id, fecha: fecha)
        } catch {
            print("❌ NotaViewModel: Error al obtener nota: \(error)")
            return nil
        }
    }
    
    /// Guarda o actualiza la nota actual
    func guardarNotaActual() async {
        guard !textoEditor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "La nota no puede estar vacía"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if var nota = notaActual {
                // Actualizar nota existente
                nota.actualizarContenido(textoEditor)
                try await storage.actualizarNota(nota)
            } else {
                // Crear nueva nota
                let nuevaNota = Nota(
                    habitID: habit.id,
                    fecha: Date(),
                    contenido: textoEditor
                )
                try await storage.guardarNota(nuevaNota)
            }
            
            await cargarNotas()
            mostrarEditor = false
        } catch {
            errorMessage = "Error al guardar nota: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
        
        isLoading = false
    }
    
    /// Elimina una nota
    func eliminarNota(_ nota: Nota) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await storage.eliminarNota(id: nota.id)
            await cargarNotas()
        } catch {
            errorMessage = "Error al eliminar nota: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
        
        isLoading = false
    }
    
    /// Marca/desmarca una nota como importante
    func toggleImportante(_ nota: Nota) async {
        var notaActualizada = nota
        notaActualizada.toggleImportante()
        
        do {
            try await storage.actualizarNota(notaActualizada)
            await cargarNotas()
        } catch {
            errorMessage = "Error al actualizar nota: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
    }
    
    /// Añade un tag a una nota
    func agregarTag(_ tag: String, aNota nota: Nota) async {
        var notaActualizada = nota
        notaActualizada.agregarTag(tag)
        
        do {
            try await storage.actualizarNota(notaActualizada)
            await cargarNotas()
        } catch {
            errorMessage = "Error al agregar tag: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
    }
    
    /// Elimina un tag de una nota
    func eliminarTag(_ tag: String, deNota nota: Nota) async {
        var notaActualizada = nota
        notaActualizada.eliminarTag(tag)
        
        do {
            try await storage.actualizarNota(notaActualizada)
            await cargarNotas()
        } catch {
            errorMessage = "Error al eliminar tag: \(error.localizedDescription)"
            print("❌ NotaViewModel: \(error)")
        }
    }
    
    /// Prepara el editor para crear/editar una nota
    func prepararEditor(nota: Nota? = nil) {
        if let nota = nota {
            notaActual = nota
            textoEditor = nota.contenido
        } else {
            notaActual = nil
            textoEditor = ""
        }
        mostrarEditor = true
    }
    
    /// Cancela la edición
    func cancelarEdicion() {
        mostrarEditor = false
        textoEditor = ""
        notaActual = nil
    }
    
    /// Busca notas por texto
    func buscarNotas(texto: String) async -> [Nota] {
        guard !texto.isEmpty else {
            return notas
        }
        
        do {
            let filtro = NotaFiltro(
                textoBusqueda: texto,
                habitIDs: [habit.id]
            )
            return try await storage.obtenerNotas(filtro: filtro)
        } catch {
            print("❌ NotaViewModel: Error al buscar: \(error)")
            return []
        }
    }
    
    /// Obtiene notas filtradas por tags
    func obtenerNotasPorTags(_ tags: [String]) async -> [Nota] {
        do {
            let filtro = NotaFiltro(
                tags: tags,
                habitIDs: [habit.id]
            )
            return try await storage.obtenerNotas(filtro: filtro)
        } catch {
            print("❌ NotaViewModel: Error al filtrar por tags: \(error)")
            return []
        }
    }
}
