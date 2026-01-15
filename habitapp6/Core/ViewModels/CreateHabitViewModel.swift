
import Foundation

@MainActor
class CreateHabitViewModel: ObservableObject {
    @Published var nombre: String = ""
    @Published var frecuencia: Frecuencia = .diario
    var dataStore: HabitDataStore
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
    }
    
    func createHabit() {
        let newHabit = Habit(nombre: nombre, frecuencia: frecuencia)
        dataStore.habits.append(newHabit) // 1. Añadir
        
        Task {
            await dataStore.generateTodayInstances()
            await dataStore.saveData()
        
            let total = dataStore.habits.count
            LogrosManager.shared.chequearCreacion(cantidadHabitos: total)
        }
    }
    
    var isValid: Bool { !nombre.trimmingCharacters(in: .whitespaces).isEmpty }
}
