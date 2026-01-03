import Foundation

@MainActor
class HabitInstanceViewModel: ObservableObject {
    @Published var instances: [HabitInstance] = []
    
    private var habits: [Habit]
    
    init(habits: [Habit]) {
        self.habits = habits
        generateInstances()
    }
    
    private func generateInstances() {
        let calendar = Calendar.current
        let today = Date()
        
        var newInstances: [HabitInstance] = []
        
        for habit in habits where habit.activo {
            switch habit.frecuencia {
            case .diario:
                if !instances.contains(where: { $0.habitID == habit.id && calendar.isDate($0.fecha, inSameDayAs: today) }) {
                    newInstances.append(HabitInstance(habitID: habit.id, fecha: today))
                }
            case .semanal:
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                if !instances.contains(where: { $0.habitID == habit.id && calendar.isDate($0.fecha, equalTo: startOfWeek, toGranularity: .weekOfYear) }) {
                    newInstances.append(HabitInstance(habitID: habit.id, fecha: startOfWeek))
                }
            }
        }
        
        instances.append(contentsOf: newInstances)
    }
    
    func toggleCompleted(_ instance: HabitInstance) {
        if let index = instances.firstIndex(where: { $0.id == instance.id }) {
            instances[index].completado.toggle()
        }
    }
}
