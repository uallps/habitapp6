//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Punto de entrada de la aplicación - Configuración de plugins SPL
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - App Delegates

#if os(iOS)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupNotifications()
        setupPlugins()
        return true
    }
    
    private func setupNotifications() {
        // Establecer el delegado para manejar notificaciones
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        
        // Limpiar badge al iniciar
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private func setupPlugins() {
        // Inicializar el gestor de plugins
        _ = PluginManager.shared
        print("🚀 Plugins inicializados")
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
    }
}

#elseif os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupNotifications()
        setupPlugins()
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }
    
    private func setupPlugins() {
        _ = PluginManager.shared
        print("🚀 Plugins inicializados")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Limpiar recursos si es necesario
    }
}
#endif

// MARK: - SwiftUI App

@main
struct HabitTrackerApp: App {
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @StateObject private var dataStore = HabitDataStore()
    @StateObject private var appConfig = AppConfig.shared
    @StateObject private var pluginManager = PluginManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(appConfig)
                .environmentObject(pluginManager)
                .task {
                    await setupApp()
                }
        }
    }
    
    private func setupApp() async {
        // Verificar estado de autorización de notificaciones si el plugin está habilitado
        if pluginManager.isRecordatoriosEnabled {
            await NotificationService.shared.checkAuthorizationStatus()
            
            // Programar recordatorios para hábitos activos
            await NotificationService.shared.scheduleAllReminders(
                habits: dataStore.habits,
                instances: dataStore.instances
            )
        }
        
        print("✅ App configurada correctamente")
        print("   - Recordatorios: \(pluginManager.isRecordatoriosEnabled ? "Habilitado" : "Deshabilitado")")
        print("   - Rachas: \(pluginManager.isRachasEnabled ? "Habilitado" : "Deshabilitado")")
    }
}
