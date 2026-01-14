
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
            guard let habit = dataStore.habits.first(where: { $0.id == instance.habitID }), habit.activo else { return nil }
            let isToday: Bool
            switch habit.frecuencia {
            case .diario: isToday = Calendar.current.isDate(instance.fecha, inSameDayAs: today)
            case .semanal:
                let ws = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                let isw = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: instance.fecha)
                isToday = ws == isw
            }
            return isToday ? (habit, instance) : nil
        }
    }
    
    func toggleInstance(_ instance: HabitInstance) {
        if let index = dataStore.instances.firstIndex(where: { $0.id == instance.id }) {
            dataStore.instances[index].completado.toggle()
            objectWillChange.send()
            
            Task {
                await dataStore.saveData()          
                let totalChecks = dataStore.instances.filter { $0.completado }.count
                
                var maxRacha = 0
                if dataStore.instances[index].completado {
                    maxRacha = 1
                }
                
                LogrosManager.shared.chequearAccion(cantidadChecks: totalChecks, maxRacha: maxRacha)
            }
        }
    }
    
    func refreshInstances() {
        Task { await dataStore.generateTodayInstances() }
    }
}
