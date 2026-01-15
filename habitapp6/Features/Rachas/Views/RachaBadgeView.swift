//
//  RachaBadgeView.swift
//  HabitTracker
//
//  Feature: Rachas
//  Componentes visuales compactos para mostrar rachas
//

import SwiftUI

/// Badge compacto de racha para mostrar en listas
struct RachaBadgeView: View {
    
    let rachaActual: Int
    let frecuencia: Frecuencia
    
    private var unidad: String {
        switch frecuencia {
        case .diario:
            return rachaActual == 1 ? "d" : "d"
        case .semanal:
            return rachaActual == 1 ? "sem" : "sem"
        }
    }
    
    var body: some View {
        if rachaActual > 0 {
            HStack(spacing: 2) {
                Text("🔥")
                    .font(.caption2)
                Text("\(rachaActual)\(unidad)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(colorRacha)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(colorRacha.opacity(0.15))
            )
        }
    }
    
    private var colorRacha: Color {
        if rachaActual >= 30 {
            return .purple
        } else if rachaActual >= 7 {
            return .orange
        }
        return .blue
    }
}

/// Vista de racha para mostrar en la fila de un hábito
struct RachaRowView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    let habit: Habit
    
    @State private var rachaInfo: RachaInfo = .empty
    
    var body: some View {
        HStack(spacing: 8) {
            // Icono de fuego
            if rachaInfo.rachaActual > 0 {
                Text("🔥")
                    .font(.title3)
            } else {
                Image(systemName: "flame")
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(rachaInfo.rachaActual > 0 ? "Racha: \(rachaInfo.descripcionRacha)" : "Sin racha")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if rachaInfo.rachaEnRiesgo && rachaInfo.rachaActual > 0 {
                    Text("⚠️ ¡No pierdas tu racha!")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else if rachaInfo.esNuevoRecord && rachaInfo.rachaActual > 0 {
                    Text("🏆 ¡Tu mejor racha!")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            // Indicador de milestone
            if let milestone = RachaMilestone.milestoneActual(para: rachaInfo.rachaActual) {
                Text(milestone.emoji)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            calcularRacha()
        }
        .onChange(of: dataStore.instances.count) { _ in
            calcularRacha()
        }
    }
    
    private func calcularRacha() {
        rachaInfo = RachaCalculator.shared.calcularRacha(para: habit, instancias: dataStore.instances)
    }
}

/// Vista compacta de racha para el resumen de hoy
struct RachaCompactView: View {
    
    let rachaActual: Int
    let enRiesgo: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if rachaActual > 0 {
                Text("🔥")
                Text("\(rachaActual)")
                    .fontWeight(.bold)
                
                if enRiesgo {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            } else {
                Image(systemName: "flame")
                    .foregroundColor(.gray)
                Text("0")
                    .foregroundColor(.gray)
            }
        }
        .font(.subheadline)
    }
}

/// Indicador circular de racha
struct RachaCircularView: View {
    
    let rachaActual: Int
    let mejorRacha: Int
    let size: CGFloat
    
    private var progreso: Double {
        guard mejorRacha > 0 else { return 0 }
        return min(Double(rachaActual) / Double(mejorRacha), 1.0)
    }
    
    var body: some View {
        ZStack {
            // Círculo de fondo
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.1)
            
            // Círculo de progreso
            Circle()
                .trim(from: 0, to: progreso)
                .stroke(
                    colorRacha,
                    style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progreso)
            
            // Contenido central
            VStack(spacing: 0) {
                if rachaActual > 0 {
                    Text("🔥")
                        .font(.system(size: size * 0.25))
                }
                Text("\(rachaActual)")
                    .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    .foregroundColor(colorRacha)
            }
        }
        .frame(width: size, height: size)
    }
    
    private var colorRacha: Color {
        if rachaActual >= 30 {
            return .purple
        } else if rachaActual >= 7 {
            return .orange
        } else if rachaActual > 0 {
            return .blue
        }
        return .gray
    }
}

/// Vista de mini-calendario mostrando racha
struct RachaMiniCalendarView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    let habit: Habit
    let diasMostrar: Int
    
    init(dataStore: HabitDataStore, habit: Habit, diasMostrar: Int = 7) {
        self.dataStore = dataStore
        self.habit = habit
        self.diasMostrar = diasMostrar
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(ultimosDias, id: \.self) { fecha in
                let completado = estaCompletado(fecha: fecha)
                
                VStack(spacing: 2) {
                    Text(letraDia(fecha))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(completado ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .overlay(
                            completado ?
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                : nil
                        )
                }
            }
        }
    }
    
    private var ultimosDias: [Date] {
        let calendar = Calendar.current
        let hoy = Date()
        
        return (0..<diasMostrar).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: hoy)
        }.reversed()
    }
    
    private func estaCompletado(fecha: Date) -> Bool {
        let calendar = Calendar.current
        return dataStore.instances.contains { instancia in
            instancia.habitID == habit.id &&
            instancia.completado &&
            calendar.isDate(instancia.fecha, inSameDayAs: fecha)
        }
    }
    
    private func letraDia(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "es_ES")
        return String(formatter.string(from: fecha).prefix(1)).uppercased()
    }
}

// MARK: - Previews

#if DEBUG
struct RachaViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Group {
                Text("RachaBadgeView").font(.headline)
                HStack(spacing: 10) {
                    RachaBadgeView(rachaActual: 0, frecuencia: .diario)
                    RachaBadgeView(rachaActual: 5, frecuencia: .diario)
                    RachaBadgeView(rachaActual: 14, frecuencia: .diario)
                    RachaBadgeView(rachaActual: 45, frecuencia: .semanal)
                }
            }
            
            Divider()
            
            Group {
                Text("RachaCompactView").font(.headline)
                HStack(spacing: 20) {
                    RachaCompactView(rachaActual: 0, enRiesgo: false)
                    RachaCompactView(rachaActual: 7, enRiesgo: false)
                    RachaCompactView(rachaActual: 12, enRiesgo: true)
                }
            }
            
            Divider()
            
            Group {
                Text("RachaCircularView").font(.headline)
                HStack(spacing: 20) {
                    RachaCircularView(rachaActual: 0, mejorRacha: 10, size: 60)
                    RachaCircularView(rachaActual: 5, mejorRacha: 10, size: 60)
                    RachaCircularView(rachaActual: 10, mejorRacha: 10, size: 60)
                    RachaCircularView(rachaActual: 35, mejorRacha: 50, size: 60)
                }
            }
        }
        .padding()
    }
}
#endif
