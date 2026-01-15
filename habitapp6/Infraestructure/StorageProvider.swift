import Foundation

protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(_ habits: [Habit]) async throws
    func loadInstances() async throws -> [HabitInstance]
    func saveInstances(_ instances: [HabitInstance]) async throws
}
