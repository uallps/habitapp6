//

//  PluginManager.swift

//  HabitTracker

//

//  Core - Gestor central de plugins (Compatible con Swift 5.5)

//



import Foundation

import SwiftUI

import Combine



/// Gestor central que coordina todos los plugins de la aplicación

@MainActor

class PluginManager: ObservableObject {

    

    // MARK: - Singleton

    

    // 👇 NUEVO: Plugin de Sugerencias
    @Published private(set) var sugerenciasPlugin: SugerenciasPlugin?
    /// Plugin de Notas
    @Published private(set) var notasPlugin: NotasPlugin?
    

    // MARK: - Properties

    

    private let config: AppConfig

    private var cancellables = Set<AnyCancellable>()

    

    /// Plugin de Recordatorios

    @Published private(set) var recordatoriosPlugin: RecordatoriosPlugin?

    

    /// Plugin de Rachas
        
        // 👇 NUEVO: Inicializar Sugerencias
        sugerenciasPlugin = SugerenciasPlugin(config: config)
        notasPlugin = NotasPlugin(config: config)
    @Published private(set) var rachasPlugin: RachasPlugin?

    

    /// Plugin de Categorías

    @Published private(set) var categoriasPlugin: CategoriasPlugin?

    

    // 👇 NUEVO: Plugin de Sugerencias

    @Published private(set) var sugerenciasPlugin: SugerenciasPlugin?

    

    // MARK: - Initialization

        // 👇 NUEVO: Log de estado
        print("   - Sugerencias: \(isSugerenciasEnabled ? "✅" : "❌")")
        print("   - Notas: \(isNotasEnabled ? "✅" : "❌")")

    private init() {

        self.config = AppConfig.shared

        registerPlugins()

        setupBindings()

        

        print("🔌 PluginManager inicializado")

        logPluginStatus()

    }

    

    // 👇 NUEVO: Check para Sugerencias
    /// Verifica si la feature de Sugerencias está habilitada
    var isSugerenciasEnabled: Bool {
        config.showSugerencias
    /// Verifica si la feature de Notas está habilitada
    var isNotasEnabled: Bool {
        config.showNotas

    /// Registra todos los plugins disponibles

    private func registerPlugins() {

        recordatoriosPlugin = RecordatoriosPlugin(config: config)

        rachasPlugin = RachasPlugin(config: config)

        categoriasPlugin = CategoriasPlugin(config: config)

        

        // 👇 NUEVO: Inicializar Sugerencias

        sugerenciasPlugin = SugerenciasPlugin(config: config)

    }

    

    /// Configura los bindings para reaccionar a cambios de configuración

    private func setupBindings() {

        NotificationCenter.default.publisher(for: .pluginConfigurationChanged)

            .receive(on: DispatchQueue.main)

            .sink { [weak self] _ in

                self?.objectWillChange.send()

                self?.logPluginStatus()

            }

            .store(in: &cancellables)

    }

    

    private func logPluginStatus() {

        print("🔌 Estado de plugins:")

        print("   - Recordatorios: \(isRecordatoriosEnabled ? "✅" : "❌")")

        print("   - Rachas: \(isRachasEnabled ? "✅" : "❌")")

        print("   - Categorías: \(isCategoriasEnabled ? "✅" : "❌")")

        // 👇 NUEVO: Log de estado

        print("   - Sugerencias: \(isSugerenciasEnabled ? "✅" : "❌")")

    }

    

    // MARK: - Feature Checks

    

    /// Verifica si la feature de Recordatorios está habilitada

    var isRecordatoriosEnabled: Bool {

        config.showRecordatorios

    }

    

    /// Verifica si la feature de Rachas está habilitada

    var isRachasEnabled: Bool {

        config.showRachas

    }
        // 👇 NUEVO
        if isSugerenciasEnabled {
            await sugerenciasPlugin?.didToggleInstance(instance, habit: habit)
        if isNotasEnabled {
            await notasPlugin?.didToggleInstance(instance, habit: habit)
    /// Verifica si la feature de Categorías está habilitada

    var isCategoriasEnabled: Bool {

        config.showCategorias

    }

    

    // 👇 NUEVO: Check para Sugerencias

    /// Verifica si la feature de Sugerencias está habilitada

    var isSugerenciasEnabled: Bool {

        config.showSugerencias

    }

    

    // MARK: - Data Plugin Methods

    

    /// Notifica a todos los DataPlugins que se va a crear un hábito

    func willCreateHabit(_ habit: Habit) async {

        if isRecordatoriosEnabled {

            await recordatoriosPlugin?.willCreateHabit(habit)

        }

        if isRachasEnabled {

            await rachasPlugin?.willCreateHabit(habit)

        }

        if isCategoriasEnabled {

            await categoriasPlugin?.willCreateHabit(habit)

        }

        // 👇 NUEVO

        if isSugerenciasEnabled {

            await sugerenciasPlugin?.willCreateHabit(habit)

        }

    }

    

    /// Notifica a todos los DataPlugins que se creó un hábito

    func didCreateHabit(_ habit: Habit) async {

        if isRecordatoriosEnabled {

            await recordatoriosPlugin?.didCreateHabit(habit)

        }

        if isRachasEnabled {

            await rachasPlugin?.didCreateHabit(habit)

        }

        if isCategoriasEnabled {

            await categoriasPlugin?.didCreateHabit(habit)

        }

        // 👇 NUEVO

        if isSugerenciasEnabled {

            await sugerenciasPlugin?.didCreateHabit(habit)

        }

    }

    

    /// Notifica a todos los DataPlugins que se va a eliminar un hábito

    func willDeleteHabit(_ habit: Habit) async {

        if isRecordatoriosEnabled {

            await recordatoriosPlugin?.willDeleteHabit(habit)

        }

        if isRachasEnabled {

            await rachasPlugin?.willDeleteHabit(habit)

        }

        if isCategoriasEnabled {

            await categoriasPlugin?.willDeleteHabit(habit)

        }

        // 👇 NUEVO

        if isSugerenciasEnabled {

            await sugerenciasPlugin?.willDeleteHabit(habit)

        }

    }

    

    /// Notifica a todos los DataPlugins que se eliminó un hábito

    func didDeleteHabit(habitId: UUID) async {

        if isRecordatoriosEnabled {

            await recordatoriosPlugin?.didDeleteHabit(habitId: habitId)

        }

        if isRachasEnabled {

            await rachasPlugin?.didDeleteHabit(habitId: habitId)

        }

        if isCategoriasEnabled {

            await categoriasPlugin?.didDeleteHabit(habitId: habitId)

        }

        // 👇 NUEVO

        if isSugerenciasEnabled {

            await sugerenciasPlugin?.didDeleteHabit(habitId: habitId)

        }

    }

    

    /// Notifica a todos los DataPlugins que se toggleó una instancia

    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {

        if isRecordatoriosEnabled {

            await recordatoriosPlugin?.didToggleInstance(instance, habit: habit)

        }

        if isRachasEnabled {

            await rachasPlugin?.didToggleInstance(instance, habit: habit)

        }

        if isCategoriasEnabled {

            await categoriasPlugin?.didToggleInstance(instance, habit: habit)

        }

        // 👇 NUEVO

        if isSugerenciasEnabled {

            await sugerenciasPlugin?.didToggleInstance(instance, habit: habit)

        }

    }

}



