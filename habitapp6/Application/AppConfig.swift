//
//  AppConfig.swift
//  HabitTracker
//
//  Core - Configuración de la aplicación y features activas
//

import Foundation
import SwiftUI

/// Configuración global de la aplicación
/// Controla qué features/plugins están habilitados
@MainActor
class AppConfig: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AppConfig()
    
    // MARK: - Feature Flags
    
    /// Habilita/deshabilita la feature de Recordatorios
    @Published var showRecordatorios: Bool {
        didSet {
            UserDefaults.standard.set(showRecordatorios, forKey: Keys.showRecordatorios)
            notifyPluginsChanged()
        }
    }
    
    /// Habilita/deshabilita la feature de Rachas
    @Published var showRachas: Bool {
        didSet {
            UserDefaults.standard.set(showRachas, forKey: Keys.showRachas)
            notifyPluginsChanged()
        }
    }
    
    /// Habilita/deshabilita la feature de Categorías
    @Published var showCategorias: Bool {
        didSet {
            UserDefaults.standard.set(showCategorias, forKey: Keys.showCategorias)
            notifyPluginsChanged()
        }
    }
    
    /// Habilita/deshabilita la feature de Metas (Del Código 1)
    @Published var showMetas: Bool {
        didSet {
            UserDefaults.standard.set(showMetas, forKey: Keys.showMetas)
            notifyPluginsChanged()
        }
    }
    
    // 👇 NUEVO: Feature Flag para Sugerencias (Del Código 1)
    /// Habilita/deshabilita la feature de Sugerencias
    @Published var showSugerencias: Bool {
        didSet {
            UserDefaults.standard.set(showSugerencias, forKey: Keys.showSugerencias)
            notifyPluginsChanged()
        }
    }

    /// Habilita/deshabilita la feature de Notas (Del Código 2)
    @Published var showNotas: Bool {
        didSet {
            UserDefaults.standard.set(showNotas, forKey: Keys.showNotas)
            notifyPluginsChanged()
        }
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let showRecordatorios = "feature.recordatorios.enabled"
        static let showRachas = "feature.rachas.enabled"
        static let showCategorias = "feature.categorias.enabled"
        static let showMetas = "feature.metas.enabled"     // Código 1
        // 👇 NUEVO: Clave para Sugerencias
        static let showSugerencias = "feature.sugerencias.enabled" // Código 1
        static let showNotas = "feature.notas.enabled"       // Código 2
    }
    
    // MARK: - Initialization
    
    private init() {
        // Cargar valores guardados o usar defaults
        self.showRecordatorios = UserDefaults.standard.object(forKey: Keys.showRecordatorios) as? Bool ?? true
        self.showRachas = UserDefaults.standard.object(forKey: Keys.showRachas) as? Bool ?? true
        self.showCategorias = UserDefaults.standard.object(forKey: Keys.showCategorias) as? Bool ?? true
        
        // Cargas del Código 1
        self.showMetas = UserDefaults.standard.object(forKey: Keys.showMetas) as? Bool ?? true
        // 👇 NUEVO: Carga inicial de Sugerencias
        self.showSugerencias = UserDefaults.standard.object(forKey: Keys.showSugerencias) as? Bool ?? true
        
        // Cargas del Código 2
        self.showNotas = UserDefaults.standard.object(forKey: Keys.showNotas) as? Bool ?? true
        
        // Lógica de entorno (Importante mantenerla del Código 2 para gestión de versiones)
        #if DEVELOP || PREMIUM
        #else
        disableAllFeatures()
        #endif
        
        print("⚙️ AppConfig inicializado:")
        print("   - Recordatorios: \(showRecordatorios)")
        print("   - Rachas: \(showRachas)")
        print("   - Categorías: \(showCategorias)")
        print("   - Metas: \(showMetas)")
        // 👇 NUEVO: Log
        print("   - Sugerencias: \(showSugerencias)")
        print("   - Notas: \(showNotas)")
    }
    
    // MARK: - Methods
    
    /// Notifica que la configuración de plugins ha cambiado
    private func notifyPluginsChanged() {
        NotificationCenter.default.post(name: .pluginConfigurationChanged, object: nil)
    }
    
    /// Resetea todas las features a sus valores por defecto
    func resetToDefaults() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true       // Código 1
        showSugerencias = true // Código 1
        showNotas = true       // Código 2
    }
    
    /// Deshabilita todas las features
    func disableAllFeatures() {
        showRecordatorios = false
        showRachas = false
        showCategorias = false
        showMetas = false       // Código 1
        showSugerencias = false // Código 1
        showNotas = false       // Código 2
    }
    
    /// Habilita todas las features
    func enableAllFeatures() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true       // Código 1
        showSugerencias = true // Código 1
        showNotas = true       // Código 2
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let pluginConfigurationChanged = Notification.Name("pluginConfigurationChanged")
}
