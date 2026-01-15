//
//  AppConfig.swift
//  HabitTracker
//
//  Core - Configuración de la aplicación y features activas
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppConfig: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppConfig()

    // MARK: - Keys
    private enum Keys {
        static let showRecordatorios = "feature.recordatorios.enabled"
        static let showRachas = "feature.rachas.enabled"
        static let showCategorias = "feature.categorias.enabled"
        static let showMetas = "feature.metas.enabled"
        static let showNotas = "feature.notas.enabled"
        static let showSugerencias = "feature.sugerencias.enabled"
        static let showLogros = "feature.logros.enabled"
    }

    // MARK: - Feature Flags (Propiedades Publicadas)

    @Published var showRecordatorios: Bool {
        didSet { save(key: Keys.showRecordatorios, value: showRecordatorios) }
    }

    @Published var showRachas: Bool {
        didSet { save(key: Keys.showRachas, value: showRachas) }
    }

    @Published var showCategorias: Bool {
        didSet { save(key: Keys.showCategorias, value: showCategorias) }
    }

    @Published var showMetas: Bool {
        didSet { save(key: Keys.showMetas, value: showMetas) }
    }

    @Published var showNotas: Bool {
        didSet { save(key: Keys.showNotas, value: showNotas) }
    }

    @Published var showSugerencias: Bool {
        didSet { save(key: Keys.showSugerencias, value: showSugerencias) }
    }

    @Published var showLogros: Bool {
        didSet { save(key: Keys.showLogros, value: showLogros) }
    }

    // MARK: - Initialization
    private init() {
        // Cargamos el estado guardado o usamos 'true' por defecto
        self.showRecordatorios = UserDefaults.standard.object(forKey: Keys.showRecordatorios) as? Bool ?? true
        self.showRachas = UserDefaults.standard.object(forKey: Keys.showRachas) as? Bool ?? true
        self.showCategorias = UserDefaults.standard.object(forKey: Keys.showCategorias) as? Bool ?? true
        self.showMetas = UserDefaults.standard.object(forKey: Keys.showMetas) as? Bool ?? true
        self.showNotas = UserDefaults.standard.object(forKey: Keys.showNotas) as? Bool ?? true
        self.showSugerencias = UserDefaults.standard.object(forKey: Keys.showSugerencias) as? Bool ?? true
        self.showLogros = UserDefaults.standard.object(forKey: Keys.showLogros) as? Bool ?? true

        #if METAS_ONLY
        disableAllFeatures()
        showMetas = true
        #elseif DEVELOP || PREMIUM
        // Features activas por defecto, no hacer nada
        #else
        disableAllFeatures()
        #endif
        
        print("⚙️ AppConfig inicializado:")
        print("   - Recordatorios: \(showRecordatorios)")
        print("   - Rachas: \(showRachas)")
        print("   - Categorías: \(showCategorias)")
        print("   - Metas: \(showMetas)")
        print("   - Notas: \(showNotas)")
        print("   - Sugerencias: \(showSugerencias)")
        print("   - Logros: \(showLogros)")
    }

    // MARK: - Helper Methods

    /// Guarda el valor en UserDefaults y notifica al sistema
    private func save(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        NotificationCenter.default.post(name: .pluginConfigurationChanged, object: nil)
    }

    /// Restaura toda la configuración a los valores por defecto (todo activado)
    func resetToDefaults() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true
        showNotas = true
        showSugerencias = true
        showLogros = true
    }

    /// Desactiva todas las features (Modo "Core" puro)
    func disableAllFeatures() {
        showRecordatorios = false
        showRachas = false
        showCategorias = false
        showMetas = false
        showNotas = false
        showSugerencias = false
        showLogros = false
    }

    /// Activa todas las features (Modo "Premium")
    func enableAllFeatures() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true
        showNotas = true
        showSugerencias = true
        showLogros = true
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    /// Notificación que se envía cuando cambia cualquier configuración de features
    static let pluginConfigurationChanged = Notification.Name("pluginConfigurationChanged")
}
