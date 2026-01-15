//
//  RachaDetailView.swift
//  HabitTracker
//
//  Feature: Rachas
//  Vista detallada de la racha de un hábito
//

import SwiftUI

struct RachaDetailView: View {
    
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: RachaViewModel
    
    private let habit: Habit
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        self.habit = habit
        _viewModel = StateObject(wrappedValue: RachaViewModel(dataStore: dataStore, habit: habit))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Racha Principal
                rachaCardPrincipal
                
                // Milestone actual y progreso
                if viewModel.tieneRachaActiva {
                    milestoneProgressCard
                }
                
                // Estadísticas
                estadisticasCard
                
                // Mensaje motivacional
                mensajeMotivacionalCard
            }
            .padding()
        }
        .navigationTitle("Racha de \(habit.nombre)")
        .navigationBarTitleDisplayMode(.inline)
        .alert("🎉 ¡Nuevo Logro!", isPresented: $viewModel.mostrarCelebracion) {
            Button("¡Genial!") {
                viewModel.mostrarCelebracion = false
            }
        } message: {
            if let milestone = viewModel.milestoneActual {
                Text("Has alcanzado \(milestone.emoji) \(milestone.titulo): \(milestone.descripcion)")
            }
        }
    }
    
    // MARK: - Racha Card Principal
    
    private var rachaCardPrincipal: some View {
        VStack(spacing: 16) {
            // Icono de fuego/racha
            ZStack {
                Circle()
                    .fill(colorRacha.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                if viewModel.rachaInfo.rachaActual > 0 {
                    Text("🔥")
                        .font(.system(size: 50))
                } else {
                    Image(systemName: "flame")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
            }
            
            // Número de racha
            VStack(spacing: 4) {
                Text("\(viewModel.rachaInfo.rachaActual)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(colorRacha)
                
                Text(viewModel.rachaInfo.unidadTiempo)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Badge de estado
            if viewModel.rachaInfo.esNuevoRecord && viewModel.tieneRachaActiva {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("¡Mejor racha!")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(20)
            }
            
            // Indicador de riesgo
            if viewModel.rachaInfo.rachaEnRiesgo && viewModel.tieneRachaActiva {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("¡Completa hoy para mantener tu racha!")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
    }
    
    // MARK: - Milestone Progress Card
    
    private var milestoneProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progreso")
                    .font(.headline)
                Spacer()
                if let milestone = viewModel.milestoneActual {
                    Text("\(milestone.emoji) \(milestone.titulo)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Barra de progreso hacia siguiente milestone
            if let proximo = viewModel.proximoMilestone {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Siguiente: \(proximo.emoji) \(proximo.titulo)")
                            .font(.subheadline)
                        Spacer()
                        Text("\(viewModel.rachaInfo.rachaActual)/\(proximo.valor)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Fondo
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                            
                            // Progreso
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [colorRacha, colorRacha.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.progresoMilestone, height: 12)
                        }
                    }
                    .frame(height: 12)
                    
                    Text(proximo.descripcion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                // Ha alcanzado todos los milestones
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("¡Has alcanzado todos los logros!")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    // MARK: - Estadísticas Card
    
    private var estadisticasCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estadísticas")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                EstadisticaItem(
                    icono: "trophy.fill",
                    color: .yellow,
                    titulo: "Mejor Racha",
                    valor: viewModel.rachaInfo.descripcionMejorRacha
                )
                
                EstadisticaItem(
                    icono: "checkmark.circle.fill",
                    color: .green,
                    titulo: "Completados",
                    valor: "\(viewModel.rachaInfo.totalCompletados)"
                )
                
                EstadisticaItem(
                    icono: "calendar",
                    color: .blue,
                    titulo: "Total Períodos",
                    valor: "\(viewModel.rachaInfo.totalPeriodos)"
                )
                
                EstadisticaItem(
                    icono: "percent",
                    color: .purple,
                    titulo: "Tasa Éxito",
                    valor: String(format: "%.0f%%", viewModel.rachaInfo.porcentajeCompletado)
                )
            }
            
            // Fecha inicio racha
            if let inicio = viewModel.rachaInfo.inicioRachaActual, viewModel.tieneRachaActiva {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.secondary)
                    Text("Racha iniciada: \(inicio, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    // MARK: - Mensaje Motivacional Card
    
    private var mensajeMotivacionalCard: some View {
        HStack {
            Text(viewModel.mensajeMotivacional)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorRacha.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var colorRacha: Color {
        switch viewModel.colorRacha {
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        default: return .gray
        }
    }
}

// MARK: - Supporting Views

struct EstadisticaItem: View {
    let icono: String
    let color: Color
    let titulo: String
    let valor: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icono)
                .font(.title2)
                .foregroundColor(color)
            
            Text(valor)
                .font(.headline)
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#if DEBUG
struct RachaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let dataStore = HabitDataStore()
            let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
            
            RachaDetailView(dataStore: dataStore, habit: habit)
        }
    }
}
#endif
