import Foundation

@MainActor
class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let storage: StorageProvider
    
    init(storage: StorageProvider = JSONStorageProvider.shared) {
        self.storage = storage
        Task { await loadHabits() }
    }
    
    func loadHabits() async {
        do {
            habits = try await storage.loadHabits()
        } catch {
            print("Error loading habits: \(error)")
            habits = []
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        save()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            save()
        }
    }
    
    func removeHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        Task { try? await storage.saveHabits(habits) }
    }
}

