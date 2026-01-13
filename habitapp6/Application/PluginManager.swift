
import Foundation
import SwiftUI
import Combine

/// Gestor central que coordina todos los plugins de la aplicación
@MainActor
class PluginManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = PluginManager()
    
    // MARK: - Properties
    private let config: AppConfig
    private var cancellables = Set<AnyCancellable>()
    
    /// Plugin de Recordatorios
    @Published private(set) var recordatoriosPlugin: RecordatoriosPlugin?
    
    /// Plugin de Rachas
    @Published private(set) var rachasPlugin: RachasPlugin?
    
    /// Plugin de Categorías
    @Published private(set) var categoriasPlugin: CategoriasPlugin?
    
    /// Plugin de Logros
    @Published private(set) var logrosPlugin: LogrosPlugin?
    
    // MARK: - Initialization
    private init() {
        self.config = AppConfig.shared
        registerPlugins()
        setupBindings()
        
        print("🔌 PluginManager inicializado")
        logPluginStatus()
    }
    
    // MARK: - Plugin Registration
    private func registerPlugins() {
        recordatoriosPlugin = RecordatoriosPlugin(config: config)
        rachasPlugin = RachasPlugin(config: config)
        categoriasPlugin = CategoriasPlugin(config: config)
        logrosPlugin = LogrosPlugin(config: config)
    }
    
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
        print("   - Logros: \(isLogrosEnabled ? "✅" : "❌")")
    }
    
    // MARK: - Feature Checks
    var isRecordatoriosEnabled: Bool { config.showRecordatorios }
    var isRachasEnabled: Bool { config.showRachas }
    var isCategoriasEnabled: Bool { config.showCategorias }
    var isLogrosEnabled: Bool { config.showLogros }
    
    // MARK: - Data Plugin Methods (AQUÍ ESTABA EL FALLO)
    
    /// Notifica a todos los plugins que se creó un hábito
    func didCreateHabit(_ habit: Habit) async {
        print("🔌 PluginManager: Distribuyendo evento 'didCreateHabit'...")
        
        if isRecordatoriosEnabled { await recordatoriosPlugin?.didCreateHabit(habit) }
        if isRachasEnabled { await rachasPlugin?.didCreateHabit(habit) }
        if isCategoriasEnabled { await categoriasPlugin?.didCreateHabit(habit) }
        
        // ¡ESTA LÍNEA FALTABA! AHORA AVISA A LOGROS
        if isLogrosEnabled {
            print("   -> Avisando a LogrosPlugin")
            await logrosPlugin?.didCreateHabit(habit)
        }
    }
    
    /// Notifica a todos los plugins que se completó/descompletó una tarea
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        print("🔌 PluginManager: Distribuyendo evento 'didToggleInstance'...")
        
        if isRecordatoriosEnabled { await recordatoriosPlugin?.didToggleInstance(instance, habit: habit) }
        if isRachasEnabled { await rachasPlugin?.didToggleInstance(instance, habit: habit) }
        if isCategoriasEnabled { await categoriasPlugin?.didToggleInstance(instance, habit: habit) }
        
        if isLogrosEnabled {
            print("   -> Avisando a LogrosPlugin")
            await logrosPlugin?.didToggleInstance(instance, habit: habit)
        }
    }
    
    func willCreateHabit(_ habit: Habit) async {
        if isRecordatoriosEnabled { await recordatoriosPlugin?.willCreateHabit(habit) }
        if isRachasEnabled { await rachasPlugin?.willCreateHabit(habit) }
        if isCategoriasEnabled { await categoriasPlugin?.willCreateHabit(habit) }
        if isLogrosEnabled { await logrosPlugin?.willCreateHabit(habit) }
    }
    
    func willDeleteHabit(_ habit: Habit) async {
        if isRecordatoriosEnabled { await recordatoriosPlugin?.willDeleteHabit(habit) }
        if isRachasEnabled { await rachasPlugin?.willDeleteHabit(habit) }
        if isCategoriasEnabled { await categoriasPlugin?.willDeleteHabit(habit) }
        if isLogrosEnabled { await logrosPlugin?.willDeleteHabit(habit) }
    }
    
    func didDeleteHabit(habitId: UUID) async {
        if isRecordatoriosEnabled { await recordatoriosPlugin?.didDeleteHabit(habitId: habitId) }
        if isRachasEnabled { await rachasPlugin?.didDeleteHabit(habitId: habitId) }
        if isCategoriasEnabled { await categoriasPlugin?.didDeleteHabit(habitId: habitId) }
        if isLogrosEnabled { await logrosPlugin?.didDeleteHabit(habitId: habitId) }
    }
}
