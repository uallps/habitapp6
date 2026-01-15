
import Foundation
import SwiftUI

@MainActor
class LogrosPlugin: DataPlugin {
    
    var isEnabled: Bool { return config.showLogros }
    let pluginId: String = "com.habittracker.logros"
    let pluginName: String = "Sistema de Logros"
    let pluginDescription: String = "Gamificación mediante medallas."
    
    private let config: AppConfig
    private let manager: LogrosManager
    
    init(config: AppConfig) {
        self.config = config
        self.manager = LogrosManager.shared
    }
    
    func didCreateHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        let habitStore = HabitDataStore.shared
        let total = habitStore.habits.count
        manager.chequearCreacion(cantidadHabitos: total)
    }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        let habitStore = HabitDataStore.shared
        let totalChecks = habitStore.instances.filter { $0.completado }.count
        
        var racha = 0
        if instance.completado {
            racha = 1
        }
        
        manager.chequearAccion(cantidadChecks: totalChecks, maxRacha: racha)
    }
    
    func didDeleteHabit(habitId: UUID) async {
        guard isEnabled else { return }
        let habitStore = HabitDataStore.shared
        manager.chequearCreacion(cantidadHabitos: habitStore.habits.count)
    }
    
    func willCreateHabit(_ habit: Habit) async {}
    func willDeleteHabit(_ habit: Habit) async {}
    
    @ViewBuilder
    func settingsLink() -> some View {
        if isEnabled {
            NavigationLink {
                LogrosView()
            } label: {
                HStack {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("Mis Logros")
                }
            }
        }
    }
}
