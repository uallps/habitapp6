import Foundation
import WidgetKit

@MainActor
class HabitDataStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var instances: [HabitInstance] = []
    
    private let storageProvider: StorageProvider
    
    // Dependency injection: puedes cambiar el provider fácilmente
    init(storageProvider: StorageProvider = CoreDataStorageProvider.shared) {
        self.storageProvider = storageProvider
        Task {
            await loadData()
            await generateTodayInstances()
        }
    }
    
    func loadData() async {
        do {
            habits = try await storageProvider.loadHabits()
            instances = try await storageProvider.loadInstances()
        } catch {
            print("Error loading data: \(error)")
        }
    }
    
    func saveData() async {
        print("Probando SaveData")
        do {
            print("Se hace SaveData")
            try await storageProvider.saveHabits(habits)
            try await storageProvider.saveInstances(instances)
            
            try (storageProvider as? CoreDataStorageProvider)?.persistChanges()

            // Widget export
            try await WidgetDataExporter.shared.exportDataForWidget(habits, instances)

            //#if !WIDGET_EXTENSION
            //try await WidgetDataExporter.shared.exportDataForWidget(habits, instances)
            //#endif
            
            //#if !WIDGET_EXTENSION
            //WidgetCenter.shared.reloadAllTimelines()
            //#endif
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func generateTodayInstances() async {
        let today = Calendar.current.startOfDay(for: Date())
        let activeHabits = habits.filter { $0.activo }
        
        for habit in activeHabits {
            let shouldGenerate: Bool
            
            switch habit.frecuencia {
            case .diario:
                shouldGenerate = !instances.contains {
                    $0.habitID == habit.id && Calendar.current.isDate($0.fecha, inSameDayAs: today)
                }
            case .semanal:
                let weekStart = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                shouldGenerate = !instances.contains {
                    guard $0.habitID == habit.id else { return false }
                    let instanceWeek = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.fecha)
                    return weekStart == instanceWeek
                }
            }
            
            if shouldGenerate {
                let newInstance = HabitInstance(habitID: habit.id, fecha: today)
                instances.append(newInstance)
            }
        }
        await saveData()
        

    }
}
