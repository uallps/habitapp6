//
//  LogrosPlugin.swift
//  habitapp6
//
//  Created by Aula03 on 12/1/26.
//

import Foundation
import SwiftUI

@MainActor
class LogrosPlugin: DataPlugin {
    
    var isEnabled: Bool {
        return config.showLogros
    }
    
    let pluginId: String = "com.habittracker.logros"
    let pluginName: String = "Logros"
    let pluginDescription: String = "Gana medallas al completar hábitos."
    
    private let config: AppConfig
    private let manager: LogrosManager
    
    init(config: AppConfig) {
        self.config = config
        self.manager = LogrosManager.shared
        print("🏆 LogrosPlugin inicializado")
    }
    
    func didCreateHabit(_ habit: Habit) async {
        guard isEnabled else { return }
        await verificarEstado()
    }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        guard isEnabled else { return }
        await verificarEstado()
    }
    
    func willCreateHabit(_ habit: Habit) async {}
    func willDeleteHabit(_ habit: Habit) async {}
    func didDeleteHabit(habitId: UUID) async {}
    
    private func verificarEstado() async {
        let habitStore = HabitDataStore.shared
        manager.verificarLogros(habitos: habitStore.habits, instancias: habitStore.instances)
    }
    
    @ViewBuilder
    func settingsLink() -> some View {
        if isEnabled {
            NavigationLink {
                LogrosView()
            } label: {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.orange)
                    Text("Mis Logros")
                }
            }
        }
    }
}
