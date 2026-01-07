//
//  AppConfig.swift
//  HabitTracker
//
//  Core - Configuración de la aplicación y features activas (Compatible con Swift 5.5)
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
    
    // MARK: - Keys
    
    private enum Keys {
        static let showRecordatorios = "feature.recordatorios.enabled"
        static let showRachas = "feature.rachas.enabled"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Cargar valores guardados o usar defaults
        self.showRecordatorios = UserDefaults.standard.object(forKey: Keys.showRecordatorios) as? Bool ?? true
        self.showRachas = UserDefaults.standard.object(forKey: Keys.showRachas) as? Bool ?? true
        
        print("⚙️ AppConfig inicializado:")
        print("   - Recordatorios: \(showRecordatorios)")
        print("   - Rachas: \(showRachas)")
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
    }
    
    /// Deshabilita todas las features
    func disableAllFeatures() {
        showRecordatorios = false
        showRachas = false
    }
    
    /// Habilita todas las features
    func enableAllFeatures() {
        showRecordatorios = true
        showRachas = true
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let pluginConfigurationChanged = Notification.Name("pluginConfigurationChanged")
}
