import Foundation

class JSONStorageProvider: StorageProvider {

    static var shared: StorageProvider = JSONStorageProvider()

    private let fileURL: URL
    
    init(filename: String = "habits.json") {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documents Directory: \(documentsDirectory.path)")
        self.fileURL = documentsDirectory.appendingPathComponent(filename)
    }
    
    func loadHabits() async throws -> [Habit] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return [] // Si no existe el archivo, devolvemos lista vacía
        }
        let data = try Data(contentsOf: fileURL)
        let habits = try JSONDecoder().decode([Habit].self, from: data)
        return habits
    }
    
    func saveHabits(_ habits: [Habit]) async throws {
        let data = try JSONEncoder().encode(habits)
        try data.write(to: fileURL)
    }
}
