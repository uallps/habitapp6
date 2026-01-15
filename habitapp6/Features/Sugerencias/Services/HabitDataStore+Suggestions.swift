
extension HabitDataStore: HabitSuggestionHandler {
    
    // AÑADIMOS @MainActor AQUÍ para eliminar el warning amarillo
    @MainActor
    public func addHabit(_ habit: Habit) {
        // Añadimos el hábito a la lista principal
        self.habits.append(habit)
        
        // Generamos las instancias para hoy
        Task {
            await self.generateTodayInstances()
            await self.saveData()
        }
    }
}
