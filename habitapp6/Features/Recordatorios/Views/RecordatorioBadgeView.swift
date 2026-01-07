//
//  RecordatorioBadgeView.swift
//  HabitTracker
//
//  Feature: Recordatorios
//  Componente visual para indicar el estado de recordatorio de un hábito
//

import SwiftUI

/// Badge pequeño para mostrar en listas de hábitos
struct RecordatorioBadgeView: View {
    
    let habit: Habit
    
    var body: some View {
        if let recordatorio = habit.recordar, recordatorio.activo {
            HStack(spacing: 2) {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                Text("\(recordatorio.horasAnticipacion)h")
                    .font(.caption2)
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.15))
            )
        }
    }
}

/// Vista más detallada del estado de recordatorio
struct RecordatorioStatusView: View {
    
    let habit: Habit
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Icono animado si está activo
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.title3)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    habit.recordar?.activo == true ?
                        Animation.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true) : nil,
                    value: isAnimating
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(statusDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Indicador visual
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
        .onAppear {
            if habit.recordar?.activo == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimating = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var iconName: String {
        guard let recordatorio = habit.recordar else {
            return "bell.slash"
        }
        return recordatorio.activo ? "bell.badge.fill" : "bell.slash"
    }
    
    private var iconColor: Color {
        guard let recordatorio = habit.recordar, recordatorio.activo else {
            return .gray
        }
        return .orange
    }
    
    private var statusTitle: String {
        guard let recordatorio = habit.recordar, recordatorio.activo else {
            return "Sin recordatorio"
        }
        return "Recordatorio activo"
    }
    
    private var statusDescription: String {
        guard let recordatorio = habit.recordar, recordatorio.activo else {
            return "Toca para configurar"
        }
        return "\(recordatorio.horasAnticipacion) horas antes del fin del período"
    }
    
    private var indicatorColor: Color {
        guard let recordatorio = habit.recordar, recordatorio.activo else {
            return .gray.opacity(0.5)
        }
        return .green
    }
}

/// Botón para acceder rápidamente a configuración de recordatorios
struct RecordatorioQuickButton: View {
    
    let habit: Habit
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: buttonIcon)
                    .font(.caption)
                
                if let recordatorio = habit.recordar, recordatorio.activo {
                    Text("\(recordatorio.horasAnticipacion)h")
                        .font(.caption)
                }
            }
            .foregroundColor(buttonColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var buttonIcon: String {
        if let recordatorio = habit.recordar, recordatorio.activo {
            return "bell.fill"
        }
        return "bell"
    }
    
    private var buttonColor: Color {
        if let recordatorio = habit.recordar, recordatorio.activo {
            return .orange
        }
        return .gray
    }
    
    private var backgroundColor: Color {
        if let recordatorio = habit.recordar, recordatorio.activo {
            return .orange.opacity(0.1)
        }
        return .gray.opacity(0.1)
    }
    
    private var borderColor: Color {
        if let recordatorio = habit.recordar, recordatorio.activo {
            return .orange.opacity(0.3)
        }
        return .gray.opacity(0.2)
    }
}

// MARK: - Previews

#if DEBUG
struct RecordatorioViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Habit sin recordatorio
            let habitSinRecordatorio = Habit(nombre: "Leer", frecuencia: .diario)
            
            // Habit con recordatorio activo
            let habitConRecordatorio = Habit(
                nombre: "Ejercicio",
                frecuencia: .diario,
                recordar: RecordatorioManager(activo: true, horasAnticipacion: 5)
            )
            
            // Habit con recordatorio inactivo
            let habitRecordatorioInactivo = Habit(
                nombre: "Meditar",
                frecuencia: .semanal,
                recordar: RecordatorioManager(activo: false)
            )
            
            Group {
                Text("RecordatorioBadgeView").font(.headline)
                HStack {
                    RecordatorioBadgeView(habit: habitSinRecordatorio)
                    RecordatorioBadgeView(habit: habitConRecordatorio)
                    RecordatorioBadgeView(habit: habitRecordatorioInactivo)
                }
            }
            
            Divider()
            
            Group {
                Text("RecordatorioStatusView").font(.headline)
                RecordatorioStatusView(habit: habitSinRecordatorio)
                RecordatorioStatusView(habit: habitConRecordatorio)
            }
            .padding(.horizontal)
            
            Divider()
            
            Group {
                Text("RecordatorioQuickButton").font(.headline)
                HStack {
                    RecordatorioQuickButton(habit: habitSinRecordatorio) {}
                    RecordatorioQuickButton(habit: habitConRecordatorio) {}
                }
            }
        }
        .padding()
    }
}
#endif
