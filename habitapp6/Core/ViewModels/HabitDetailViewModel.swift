import Foundation

@MainActor
class HabitDetailViewModel: ObservableObject {
    @Published var dataStore: HabitDataStore
    @Published var habit: Habit
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        self.habit = habit
    }
    
    func updateHabit() {
        if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
            dataStore.habits[index] = habit
            Task {
                await dataStore.saveData()

            }
        }
    }
}

