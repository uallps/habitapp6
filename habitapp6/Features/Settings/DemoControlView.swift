//
//  DemoControlView.swift
//  habitapp6
//
//  Panel de control para demos - permite simular el paso del tiempo
//

import SwiftUI

struct DemoControlView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @ObservedObject private var timeConfig = TimeConfiguration.shared
    @ObservedObject private var demoTime = DemoTimeProvider.shared
    
    var body: some View {
        Form {
            // MARK: - Activación
            Section {
                Toggle("Activar Modo Demo", isOn: $timeConfig.isDemoMode)
                    .onChange(of: timeConfig.isDemoMode) { newValue in
                        if newValue {
                            DemoTimeProvider.shared.reset()
                        }
                        refreshData()
                    }
            } header: {
                Text("Modo Demo")
            } footer: {
                Text("Al activar, podrás controlar la fecha que ve la aplicación para demostrar funciones como rachas.")
            }
            
            // MARK: - Estado Actual
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: timeConfig.isDemoMode ? "clock.badge.checkmark" : "clock")
                            .foregroundColor(timeConfig.isDemoMode ? .green : .gray)
                        Text(timeConfig.isDemoMode ? "MODO DEMO ACTIVO" : "Modo Normal")
                            .font(.headline)
                            .foregroundColor(timeConfig.isDemoMode ? .green : .primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Fecha actual:")
                        Spacer()
                        Text(formattedDate)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    if timeConfig.isDemoMode {
                        HStack {
                            Text("Fecha real:")
                            Spacer()
                            Text(formattedRealDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Estado")
            }
            
            // MARK: - Controles de Tiempo
            if timeConfig.isDemoMode {
                Section {
                    // Botones de días
                    HStack {
                        Button {
                            demoTime.goBackDays(1)
                            refreshData()
                        } label: {
                            Label("-1 día", systemImage: "minus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            demoTime.advanceDays(1)
                            refreshData()
                        } label: {
                            Label("+1 día", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    
                    // Botones de semanas
                    HStack {
                        Button {
                            demoTime.goBackDays(7)
                            refreshData()
                        } label: {
                            Label("-7 días", systemImage: "minus.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            demoTime.advanceDays(7)
                            refreshData()
                        } label: {
                            Label("+7 días", systemImage: "plus.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    
                    // Reset
                    Button {
                        demoTime.reset()
                        refreshData()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Volver a fecha real")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                } header: {
                    Text("Control de Tiempo")
                } footer: {
                    Text("Usa estos botones para avanzar o retroceder en el tiempo durante la demo.")
                }
                
                // MARK: - Guía Rápida
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        GuideRow(
                            step: "1",
                            title: "Crea un hábito",
                            description: "Ve a Hábitos y crea uno nuevo"
                        )
                        
                        GuideRow(
                            step: "2",
                            title: "Márcalo completado",
                            description: "En la vista Hoy, marca el hábito"
                        )
                        
                        GuideRow(
                            step: "3",
                            title: "Avanza el tiempo",
                            description: "Usa +1 día y repite el paso 2"
                        )
                        
                        GuideRow(
                            step: "4",
                            title: "Verifica la racha",
                            description: "Verás la racha acumulada 🔥"
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Guía para Demo de Rachas")
                }
            }
        }
        .navigationTitle("Modo Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helpers
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: timeConfig.now)
    }
    
    private var formattedRealDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: Date())
    }
    
    private func refreshData() {
        Task {
            await dataStore.generateTodayInstances()
        }
    }
}

// MARK: - Guide Row Component

struct GuideRow: View {
    let step: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(step)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DemoControlView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DemoControlView()
                .environmentObject(HabitDataStore())
        }
    }
}
#endif
