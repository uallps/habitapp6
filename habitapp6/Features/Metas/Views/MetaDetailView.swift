//
//  MetaDetailView.swift
//  HabitTracker
//
//  Feature: Metas - Vista de detalle de una meta
//

import SwiftUI

/// Vista de detalle completo de una meta
struct MetaDetailView: View {
    
    @ObservedObject var viewModel: MetaViewModel
    @Environment(\.dismiss) private var dismiss
    
    let meta: Meta
    let habit: Habit
    
    @State private var showingDeleteConfirmation = false
    @State private var showingCancelConfirmation = false
    
    private var progreso: MetaProgreso {
        viewModel.progreso(para: meta)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Cabecera
                headerSection
                
                // MARK: - Barra de Progreso Principal
                progressSection
                
                // MARK: - Estadísticas
                statsSection
                
                // MARK: - Información del Período
                periodoSection
                
                // MARK: - Acciones
                if meta.estaActiva {
                    accionesSection
                }
            }
            .padding()
        }
        .navigationTitle("Detalle de Meta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Cerrar") {
                    dismiss()
                }
            }
        }
        .confirmationDialog(
            "¿Eliminar esta meta?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                eliminarMeta()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .confirmationDialog(
            "¿Cancelar esta meta?",
            isPresented: $showingCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancelar Meta", role: .destructive) {
                cancelarMeta()
            }
            Button("Volver", role: .cancel) {}
        } message: {
            Text("La meta quedará marcada como cancelada pero se mantendrá en el historial.")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Icono grande
            ZStack {
                Circle()
                    .fill(meta.estado.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: meta.estado.icon)
                    .font(.system(size: 36))
                    .foregroundColor(meta.estado.color)
            }
            
            // Nombre
            Text(meta.nombre)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Descripción
            if !meta.descripcion.isEmpty {
                Text(meta.descripcion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Chips de estado y período
            HStack(spacing: 8) {
                MetaEstadoChipView(estado: meta.estado)
                MetaPeriodoChipView(periodo: meta.periodo)
            }
            
            // Hábito asociado
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                Text(habit.nombre)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            // Título
            HStack {
                Text("Progreso")
                    .font(.headline)
                Spacer()
                Text(progreso.porcentajeFormateado)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(progreso.colorProgreso)
            }
            
            // Barra de progreso circular grande
            ZStack {
                // Fondo
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                // Progreso
                Circle()
                    .trim(from: 0, to: CGFloat(progreso.porcentaje))
                    .stroke(
                        progreso.colorProgreso,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progreso.porcentaje)
                
                // Texto central
                VStack(spacing: 4) {
                    Text("\(progreso.completadas)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(progreso.colorProgreso)
                    Text("de \(progreso.objetivo)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 180, height: 180)
            .padding()
            
            // Mensaje motivacional
            Text(viewModel.mensajeMotivacional(para: meta))
                .font(.headline)
                .foregroundColor(.primary)
            
            // Barra lineal adicional
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(progreso.colorProgreso)
                            .frame(width: geometry.size.width * CGFloat(progreso.porcentaje))
                            .animation(.easeInOut(duration: 0.5), value: progreso.porcentaje)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(progreso.objetivo)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("Estadísticas")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCardView(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Completadas",
                    value: "\(progreso.completadas)"
                )
                
                StatCardView(
                    icon: "target",
                    iconColor: .purple,
                    title: "Objetivo",
                    value: "\(progreso.objetivo)"
                )
                
                StatCardView(
                    icon: "calendar.badge.clock",
                    iconColor: meta.diasRestantes <= 3 ? .orange : .blue,
                    title: "Días restantes",
                    value: "\(meta.diasRestantes)"
                )
                
                StatCardView(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .orange,
                    title: "Ritmo actual",
                    value: calcularRitmoActual()
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Periodo Section
    
    private var periodoSection: some View {
        VStack(spacing: 12) {
            Text("Período")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inicio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(meta.fechaInicio.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Fin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(meta.fechaFin.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // Barra de tiempo transcurrido
            VStack(alignment: .leading, spacing: 4) {
                Text("Tiempo transcurrido")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(meta.porcentajeTiempoTranscurrido))
                    }
                }
                .frame(height: 8)
                
                Text(String(format: "%.0f%% del tiempo", meta.porcentajeTiempoTranscurrido * 100))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Fecha de completado si aplica
            if let fechaCompletado = meta.fechaCompletado {
                Divider()
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Completada el \(fechaCompletado.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Acciones Section
    
    private var accionesSection: some View {
        VStack(spacing: 12) {
            Button {
                showingCancelConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Cancelar Meta")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
                .cornerRadius(12)
            }
            
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Eliminar Meta")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.15))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // MARK: - Helpers
    
    private func calcularRitmoActual() -> String {
        let diasTranscurridos = max(1, meta.periodo.diasTotales - meta.diasRestantes)
        let porDia = Double(progreso.completadas) / Double(diasTranscurridos)
        
        if porDia >= 1 {
            return String(format: "%.1f/día", porDia)
        } else {
            return String(format: "%.1f/sem", porDia * 7)
        }
    }
    
    private func eliminarMeta() {
        Task {
            await viewModel.eliminarMeta(meta)
            dismiss()
        }
    }
    
    private func cancelarMeta() {
        Task {
            await viewModel.cancelarMeta(meta)
            dismiss()
        }
    }
}

// MARK: - Supporting Views

/// Tarjeta de estadística
struct StatCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#if DEBUG
struct MetaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let habit = Habit(nombre: "Correr", frecuencia: .diario)
        let dataStore = HabitDataStore()
        let viewModel = MetaViewModel(habit: habit, habitDataStore: dataStore)
        let meta = Meta(habitID: habit.id, nombre: "Correr 100 veces", objetivo: 100, periodo: .año)
        
        NavigationView {
            MetaDetailView(viewModel: viewModel, meta: meta, habit: habit)
        }
    }
}
#endif
