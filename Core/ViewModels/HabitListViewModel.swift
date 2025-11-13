// Esta clase esta diseñada para configurar el
// comportamiento de la vista HabitListView.
import Foundation
import Combine
import SwiftUI

@MainActor
class HabitListViewModel: ObservableObject {
    
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    // Lista de hábitos publicada para actualizar la UI automáticamente
    @Published var habits: [Habit] = [
        Habit(name: "Beber agua", frequency: .daily),
        Habit(name: "Hacer ejercicio", frequency: .daily),
        Habit(name: "Leer un libro", frequency: .weekly)
    ]
    
    // Cargar hábitos desde el storage
    func loadHabits() async {
        do {
            habits = try await storageProvider.loadHabits()
        } catch {
            print("Error loading habits: \(error)")
        }
    }
    
    // Añadir un nuevo hábito
    func addHabit(habit: Habit) async {
        habits.append(habit)
        try? await storageProvider.saveHabits(habits: habits)
    }
    
    // Eliminar hábitos en los offsets indicados
    func removeHabits(atOffsets offsets: IndexSet) async {
        let habitsToDelete = offsets.map { habits[$0] }
        
        // Notificar a los plugins ANTES de eliminar los hábitos
        for habit in habitsToDelete {
            await PluginRegistry.shared.notifyHabitWillBeDeleted(habit)
        }
        
        // Eliminar los hábitos
        habits.remove(atOffsets: offsets)
        try? await storageProvider.saveHabits(habits: habits)
        
        // Notificar a los plugins DESPUÉS de eliminar los hábitos
        for habit in habitsToDelete {
            await PluginRegistry.shared.notifyHabitDidDelete(habitId: habit.id)
        }
    }
    
    // Alternar completado de un hábito
    func toggleCompletion(habit: Habit) async {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
            try? await storageProvider.saveHabits(habits: habits)
        }
    }
    
    // Guardar todos los hábitos
    func saveHabits() async {
        try? await storageProvider.saveHabits(habits: habits)
    }
}
