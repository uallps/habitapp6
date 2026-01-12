
//
//  AppConfig.swift
//  HabitTracker
//
//  Core - Configuración de la aplicación y features activas
//

import Foundation
import SwiftUI

@MainActor
class AppConfig: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppConfig()
    
    // MARK: - Feature Flags
    
    @Published var showRecordatorios: Bool {
        didSet {
            UserDefaults.standard.set(showRecordatorios, forKey: Keys.showRecordatorios)
            notifyPluginsChanged()
        }
    }
    
    @Published var showRachas: Bool {
        didSet {
            UserDefaults.standard.set(showRachas, forKey: Keys.showRachas)
            notifyPluginsChanged()
        }
    }
    
    @Published var showCategorias: Bool {
        didSet {
            UserDefaults.standard.set(showCategorias, forKey: Keys.showCategorias)
            notifyPluginsChanged()
        }
    }
    
    @Published var showMetas: Bool {
        didSet {
            UserDefaults.standard.set(showMetas, forKey: Keys.showMetas)
            notifyPluginsChanged()
        }
    }
    
    @Published var showSugerencias: Bool {
        didSet {
            UserDefaults.standard.set(showSugerencias, forKey: Keys.showSugerencias)
            notifyPluginsChanged()
        }
    }
    
    @Published var showLogros: Bool {
        didSet {
            UserDefaults.standard.set(showLogros, forKey: Keys.showLogros)
            notifyPluginsChanged()
        }
    }
    
    // MARK: - Keys
    private enum Keys {
        static let showRecordatorios = "feature.recordatorios.enabled"
        static let showRachas = "feature.rachas.enabled"
        static let showCategorias = "feature.categorias.enabled"
        static let showMetas = "feature.metas.enabled"
        static let showSugerencias = "feature.sugerencias.enabled"
        static let showLogros = "feature.logros.enabled"
    }
    
    // MARK: - Initialization
    private init() {
        self.showRecordatorios = UserDefaults.standard.object(forKey: Keys.showRecordatorios) as? Bool ?? true
        self.showRachas = UserDefaults.standard.object(forKey: Keys.showRachas) as? Bool ?? true
        self.showCategorias = UserDefaults.standard.object(forKey: Keys.showCategorias) as? Bool ?? true
        self.showMetas = UserDefaults.standard.object(forKey: Keys.showMetas) as? Bool ?? true
        self.showSugerencias = UserDefaults.standard.object(forKey: Keys.showSugerencias) as? Bool ?? true
        self.showLogros = UserDefaults.standard.object(forKey: Keys.showLogros) as? Bool ?? true
    }
    
    // MARK: - Methods
    private func notifyPluginsChanged() {
        NotificationCenter.default.post(name: .pluginConfigurationChanged, object: nil)
    }
    
    func resetToDefaults() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true
        showSugerencias = true
        showLogros = true
    }
    
    func disableAllFeatures() {
        showRecordatorios = false
        showRachas = false
        showCategorias = false
        showMetas = false
        showSugerencias = false
        showLogros = false
    }
    
    func enableAllFeatures() {
        showRecordatorios = true
        showRachas = true
        showCategorias = true
        showMetas = true
        showSugerencias = true
        showLogros = true
    }
}

extension Notification.Name {
    static let pluginConfigurationChanged = Notification.Name("pluginConfigurationChanged")
}
