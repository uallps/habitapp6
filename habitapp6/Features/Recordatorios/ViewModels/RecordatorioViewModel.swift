//
//  RecordatorioViewModel.swift
//  HabitTracker
//
//  Feature: Recordatorios
//  ViewModel para gestionar la configuración de recordatorios de un hábito
//

import Foundation
import Combine
import UserNotifications

@MainActor
class RecordatorioViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recordatorioActivo: Bool = false
    @Published var horaRecordatorio: Date = RecordatorioManager.defaultHora()
    @Published var horasAnticipacion: Int = 5
    @Published var notificacionesAutorizadas: Bool = false
    @Published var showingAuthorizationAlert: Bool = false
    @Published var pendingNotificationsCount: Int = 0
    
    // MARK: - Dependencies
    
    private let dataStore: HabitDataStore
    private let notificationService: NotificationService
    private var habit: Habit
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var horasAnticipacionOptions: [Int] {
        [1, 2, 3, 4, 5, 6, 8, 12]
    }
    
    var recordatorioDescripcion: String {
        if !recordatorioActivo {
            return "Sin recordatorio configurado"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let horaStr = formatter.string(from: horaRecordatorio)
        
        return "Recordatorio \(horasAnticipacion)h antes del fin del período"
    }
    
    // MARK: - Initialization
    
    init(dataStore: HabitDataStore, habit: Habit, notificationService: NotificationService = .shared) {
        self.dataStore = dataStore
        self.habit = habit
        self.notificationService = notificationService
        
        loadRecordatorioState()
        setupBindings()
        
        Task {
            await checkNotificationAuthorization()
            await updatePendingNotificationsCount()
        }
    }
    
    // MARK: - Setup
    
    private func loadRecordatorioState() {
        if let recordatorio = habit.recordar {
            recordatorioActivo = recordatorio.activo
            horaRecordatorio = recordatorio.horaRecordatorio
            horasAnticipacion = recordatorio.horasAnticipacion
        } else {
            recordatorioActivo = false
            horaRecordatorio = RecordatorioManager.defaultHora()
            horasAnticipacion = 5
        }
    }
    
    private func setupBindings() {
        // Observar cambios en el estado de autorización del servicio
        notificationService.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorized in
                self?.notificacionesAutorizadas = isAuthorized
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authorization
    
    func checkNotificationAuthorization() async {
        await notificationService.checkAuthorizationStatus()
        notificacionesAutorizadas = notificationService.isAuthorized
    }
    
    func requestNotificationAuthorization() async {
        let granted = await notificationService.requestAuthorization()
        notificacionesAutorizadas = granted
        
        if !granted {
            showingAuthorizationAlert = true
        }
    }
    
    // MARK: - Recordatorio Actions
    
    /// Activa o desactiva el recordatorio
    func toggleRecordatorio() async {
        // Si está intentando activar, verificar permisos primero
        if !recordatorioActivo && !notificacionesAutorizadas {
            await requestNotificationAuthorization()
            if !notificacionesAutorizadas {
                return
            }
        }
        
        recordatorioActivo.toggle()
        await saveRecordatorio()
    }
    
    /// Actualiza la hora del recordatorio
    func updateHoraRecordatorio(_ nuevaHora: Date) async {
        horaRecordatorio = nuevaHora
        await saveRecordatorio()
    }
    
    /// Actualiza las horas de anticipación
    func updateHorasAnticipacion(_ horas: Int) async {
        horasAnticipacion = horas
        await saveRecordatorio()
    }
    
    /// Guarda la configuración del recordatorio
    func saveRecordatorio() async {
        if recordatorioActivo {
            // Crear o actualizar el recordatorio
            if habit.recordar == nil {
                habit.recordar = RecordatorioManager(
                    activo: true,
                    horaRecordatorio: horaRecordatorio,
                    horasAnticipacion: horasAnticipacion
                )
            } else {
                habit.recordar?.activo = recordatorioActivo
                habit.recordar?.horaRecordatorio = horaRecordatorio
                habit.recordar?.horasAnticipacion = horasAnticipacion
            }
            
            // Reprogramar notificaciones
            await scheduleNotifications()
        } else {
            // Desactivar recordatorio
            habit.recordar?.activo = false
            
            // Cancelar notificaciones existentes
            notificationService.cancelReminder(for: habit)
        }
        
        // Actualizar en el dataStore
        updateHabitInDataStore()
        
        await updatePendingNotificationsCount()
    }
    
    /// Programa las notificaciones para el hábito
    private func scheduleNotifications() async {
        // Cancelar notificaciones anteriores
        notificationService.cancelReminder(for: habit)
        
        // Buscar instancia pendiente para hoy
        let todayInstances = dataStore.instances.filter { instance in
            instance.habitID == habit.id && !instance.completado
        }
        
        for instance in todayInstances {
            await notificationService.scheduleHabitReminder(for: habit, instance: instance)
        }
    }
    
    /// Actualiza el hábito en el dataStore
    private func updateHabitInDataStore() {
        if let index = dataStore.habits.firstIndex(where: { $0.id == habit.id }) {
            dataStore.habits[index] = habit
            Task {
                await dataStore.saveData()
            }
        }
    }
    
    // MARK: - Notification Queries
    
    func updatePendingNotificationsCount() async {
        let pending = await notificationService.checkPendingNotifications()
        let habitNotifications = pending.filter { request in
            guard let recordatorio = habit.recordar else { return false }
            return request.identifier.contains(recordatorio.notificationIdentifier)
        }
        pendingNotificationsCount = habitNotifications.count
    }
    
    func hasPendingReminder() async -> Bool {
        return await notificationService.hasPendingReminder(for: habit)
    }
    
    // MARK: - Test Notification
    
    /// Envía una notificación de prueba inmediata
    func sendTestNotification() async {
        guard notificacionesAutorizadas else {
            await requestNotificationAuthorization()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Notificación de Prueba"
        content.body = "¡Los recordatorios para '\(habit.nombre)' están funcionando correctamente!"
        content.sound = .default
        
        // Trigger inmediato (5 segundos)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test_\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Notificación de prueba programada para 5 segundos")
        } catch {
            print("❌ Error enviando notificación de prueba: \(error)")
        }
    }
}
