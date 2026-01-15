import Foundation
import Combine

// 1. Definimos el protocolo aquí para desacoplar (evita el error de "Type not found")
public protocol HabitSuggestionHandler {
  func addHabit(_ habit: Habit)
  var habits: [Habit] { get }
}

@MainActor
class SuggestionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var sugerenciasDisponibles: [SuggestionInfo] = []
    @Published var isLoading: Bool = false
    @Published var mensajeFeedback: String? = nil
    
    // MARK: - Dependencies
    // 2. Usamos el protocolo en lugar de la clase concreta
    private let habitHandler: HabitSuggestionHandler
    private let generator: SuggestionGenerator
    
    // MARK: - Initialization
    init(habitHandler: HabitSuggestionHandler, generator: SuggestionGenerator = .shared) {
        self.habitHandler = habitHandler
        self.generator = generator
        cargarSugerencias()
    }
    
    // MARK: - Public Methods
    func cargarSugerencias() {
        isLoading = true
        // Simulamos carga breve sin animación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            // Usamos el handler para obtener los hábitos existentes
            let habitosActuales = self.habitHandler.habits
            self.sugerenciasDisponibles = self.generator.obtenerSugerencias(excluyendo: habitosActuales)
            self.isLoading = false
        }
    }
    
    func aceptarSugerencia(_ sugerencia: SuggestionInfo) {
        let nuevoHabito = Habit(
            nombre: sugerencia.nombre,
            frecuencia: sugerencia.frecuencia
        )
        
        // Delegamos el guardado al handler
        habitHandler.addHabit(nuevoHabito)
        
        // Feedback visual simple
        mensajeFeedback = "¡Hábito '\(sugerencia.nombre)' añadido!"
        
        // Eliminar directamente (SIN ANIMACIÓN)
        removerSugerenciaDeLista(sugerencia)
        
        // Ocultar feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.mensajeFeedback = nil
        }
    }
    
    func descartarSugerencia(_ sugerencia: SuggestionInfo) {
        removerSugerenciaDeLista(sugerencia)
    }
    
    // MARK: - Private Methods
    private func removerSugerenciaDeLista(_ sugerencia: SuggestionInfo) {
        // 3. Eliminado el bloque withAnimation
        if let index = sugerenciasDisponibles.firstIndex(where: { $0.id == sugerencia.id }) {
            sugerenciasDisponibles.remove(at: index)
        }
    }
}
