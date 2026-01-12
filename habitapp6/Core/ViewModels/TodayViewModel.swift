import Foundation

@MainActor
class TodayViewModel: ObservableObject {
    @Published var dataStore: HabitDataStore
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
    }
    
    var todayInstances: [(habit: Habit, instance: HabitInstance)] {
        let today = TimeConfiguration.shared.now
        return dataStore.instances.compactMap { instance in
            guard let habit = dataStore.habits.first(where: { $0.id == instance.habitID }),
                  habit.activo else { return nil }
            
            let isToday: Bool
            switch habit.frecuencia {
            case .diario:
                isToday = Calendar.current.isDate(instance.fecha, inSameDayAs: today)
            case .semanal:
                let weekStart = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                let instanceWeek = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: instance.fecha)
                isToday = weekStart == instanceWeek
            }
            
            return isToday ? (habit, instance) : nil
        }
    }
    
    func toggleInstance(_ instance: HabitInstance) {
        if let index = dataStore.instances.firstIndex(where: { $0.id == instance.id }) {
            dataStore.instances[index].completado.toggle()
            Task {
                await dataStore.saveData()
            }
        }
    }
    
    func refreshInstances() {
        Task {
            await dataStore.generateTodayInstances()
        }
    }
}
