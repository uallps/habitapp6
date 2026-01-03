import Foundation

class JSONStorageProvider: StorageProvider {
    static var shared: StorageProvider = JSONStorageProvider()
    
    private let habitsFileURL: URL
    private let instancesFileURL: URL
    
    init(habitsFilename: String = "habits.json", instancesFilename: String = "instances.json") {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documents Directory: \(documentsDirectory.path)")
        self.habitsFileURL = documentsDirectory.appendingPathComponent(habitsFilename)
        self.instancesFileURL = documentsDirectory.appendingPathComponent(instancesFilename)
    }
    
    func loadHabits() async throws -> [Habit] {
        guard FileManager.default.fileExists(atPath: habitsFileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: habitsFileURL)
        let habits = try JSONDecoder().decode([Habit].self, from: data)
        return habits
    }
    
    func saveHabits(_ habits: [Habit]) async throws {
        let data = try JSONEncoder().encode(habits)
        try data.write(to: habitsFileURL)
    }
    
    func loadInstances() async throws -> [HabitInstance] {
        guard FileManager.default.fileExists(atPath: instancesFileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: instancesFileURL)
        let instances = try JSONDecoder().decode([HabitInstance].self, from: data)
        return instances
    }
    
    func saveInstances(_ instances: [HabitInstance]) async throws {
        let data = try JSONEncoder().encode(instances)
        try data.write(to: instancesFileURL)
    }
}
