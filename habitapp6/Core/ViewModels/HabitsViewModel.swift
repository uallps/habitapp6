
import Foundation

@MainActor
class HabitsViewModel: ObservableObject {
    @Published var dataStore: HabitDataStore
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
    }
    
    func toggleHabitActive(_ habit: Habit) {
        if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
            dataStore.habits[index].activo.toggle()
            Task {
                await dataStore.saveData()

            }
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        dataStore.habits.removeAll { $0.id == habit.id }
        dataStore.instances.removeAll { $0.habitID == habit.id }
        Task {
            await dataStore.saveData()

        }
    }
}
