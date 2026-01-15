//
//  RecordatorioConfigView.swift
//  HabitTracker
//
//  Feature: Recordatorios
//  Vista para configurar los recordatorios de un hábito
//

import SwiftUI

struct RecordatorioConfigView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: RecordatorioViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let habit: Habit
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        self.habit = habit
        _viewModel = StateObject(wrappedValue: RecordatorioViewModel(
            dataStore: dataStore,
            habit: habit
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Estado de Notificaciones
                notificationStatusSection
                
                // MARK: - Configuración Principal
                mainConfigSection
                
                // MARK: - Configuración Avanzada
                if viewModel.recordatorioActivo {
                    advancedConfigSection
                }
                
                // MARK: - Información
                infoSection
                
                // MARK: - Acciones de Prueba
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
            .alert("Notificaciones No Autorizadas", isPresented: $viewModel.showingAuthorizationAlert) {
                Button("Abrir Configuración") {
                    openAppSettings()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Para recibir recordatorios, debes autorizar las notificaciones en la configuración de tu dispositivo.")
            }
        }
    }
    
    // MARK: - Sections
    
    private var notificationStatusSection: some View {
        Section {
            HStack {
                Image(systemName: viewModel.notificacionesAutorizadas ? "bell.badge.fill" : "bell.slash.fill")
                    .foregroundColor(viewModel.notificacionesAutorizadas ? .green : .red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estado de Notificaciones")
                        .font(.headline)
                    Text(viewModel.notificacionesAutorizadas ? "Autorizadas" : "No autorizadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !viewModel.notificacionesAutorizadas {
                    Button("Autorizar") {
                        Task {
                            await viewModel.requestNotificationAuthorization()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Permisos")
        }
    }
    
    private var mainConfigSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.recordatorioActivo },
                set: { _ in
                    Task {
                        await viewModel.toggleRecordatorio()
                    }
                }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activar Recordatorio")
                        .font(.headline)
                    Text("Recibe una notificación antes de que termine el período")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .disabled(!viewModel.notificacionesAutorizadas)
        } header: {
            Text("Recordatorio para \(habit.nombre)")
        } footer: {
            if !viewModel.notificacionesAutorizadas {
                Text("Debes autorizar las notificaciones para activar recordatorios.")
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var advancedConfigSection: some View {
        Section {
            // Selector de horas de anticipación
            Picker("Anticipación", selection: Binding(
                get: { viewModel.horasAnticipacion },
                set: { newValue in
                    Task {
                        await viewModel.updateHorasAnticipacion(newValue)
                    }
                }
            )) {
                ForEach(viewModel.horasAnticipacionOptions, id: \.self) { horas in
                    Text("\(horas) hora\(horas == 1 ? "" : "s") antes")
                        .tag(horas)
                }
            }
            .pickerStyle(.menu)
            
            // Información sobre cuándo se enviará
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Momento del recordatorio")
                        .font(.subheadline)
                    Text(reminderTimingDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            
        } header: {
            Text("Configuración")
        } footer: {
            Text("El recordatorio se enviará \(viewModel.horasAnticipacion) horas antes de que termine el período del hábito (\(habit.frecuencia.rawValue)).")
        }
    }
    
    private var infoSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cómo funcionan los recordatorios")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(infoText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            
            if viewModel.pendingNotificationsCount > 0 {
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.orange)
                    Text("\(viewModel.pendingNotificationsCount) recordatorio(s) programado(s)")
                        .font(.subheadline)
                }
            }
        } header: {
            Text("Información")
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section {
            Button {
                Task {
                    await viewModel.sendTestNotification()
                }
            } label: {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Enviar notificación de prueba")
                }
            }
            
            Button {
                Task {
                    await viewModel.updatePendingNotificationsCount()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Actualizar contador de notificaciones")
                }
            }
        } header: {
            Text("Debug")
        } footer: {
            Text("Esta sección solo aparece en modo Debug.")
        }
    }
    #endif
    
    // MARK: - Computed Properties
    
    private var reminderTimingDescription: String {
        switch habit.frecuencia {
        case .diario:
            let endHour = 24 - viewModel.horasAnticipacion
            return "Aproximadamente a las \(endHour):00"
        case .semanal:
            return "\(viewModel.horasAnticipacion)h antes del fin de semana"
        }
    }
    
    private var infoText: String {
        switch habit.frecuencia {
        case .diario:
            return "Para hábitos diarios, el recordatorio se envía antes de la medianoche, cuando se genera la siguiente instancia del hábito."
        case .semanal:
            return "Para hábitos semanales, el recordatorio se envía antes del fin de semana, cuando se genera la siguiente instancia del hábito."
        }
    }
    
    // MARK: - Actions
    
    private func openAppSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

// MARK: - Preview

#if DEBUG
struct RecordatorioConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore()
        let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
        
        RecordatorioConfigView(dataStore: dataStore, habit: habit)
    }
}
#endif
