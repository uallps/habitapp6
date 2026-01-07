//
//  AppDelegate.swift
//  HabitTracker
//
//  Configuración de la aplicación - Incluye setup de notificaciones
//

import Foundation
import UserNotifications

#if os(iOS)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configurar el delegado de notificaciones
        setupNotifications()
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
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Manejar notificaciones remotas si se implementan en el futuro
        completionHandler(.noData)
    }
}

#elseif os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Establecer el delegado para manejar notificaciones
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Limpiar recursos si es necesario
    }
}
#endif

// MARK: - SwiftUI App Integration

import SwiftUI

@main
struct HabitTrackerApp: App {
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @StateObject private var dataStore = HabitDataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .task {
                    await setupApp()
                }
        }
    }
    
    private func setupApp() async {
        // Verificar estado de autorización de notificaciones
        await NotificationService.shared.checkAuthorizationStatus()
        
        // Programar recordatorios para hábitos activos
        await NotificationService.shared.scheduleAllReminders(
            habits: dataStore.habits,
            instances: dataStore.instances
        )
    }
}
