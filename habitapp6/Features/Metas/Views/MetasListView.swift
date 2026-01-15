//
//  MetasListView.swift
//  HabitTracker
//
//  Feature: Metas - Vista de lista de metas de un hábito
//

import SwiftUI

/// Vista que muestra todas las metas de un hábito
struct MetasListView: View {
    
    @StateObject private var viewModel: MetaViewModel
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    let dataStore: HabitDataStore
    
    @State private var selectedTab = 0
    @State private var metaParaDetalle: Meta?
    
    init(habit: Habit, dataStore: HabitDataStore) {
        self.habit = habit
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: MetaViewModel(habit: habit, habitDataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Picker para filtrar metas
                Picker("Filtro", selection: $selectedTab) {
                    Text("Activas (\(viewModel.metasActivas.count))").tag(0)
                    Text("Completadas (\(viewModel.metasCompletadas.count))").tag(1)
                    Text("Todas (\(viewModel.metas.count))").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Lista de metas
                if filteredMetas.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredMetas) { meta in
                            MetaRowView(meta: meta, progreso: viewModel.progreso(para: meta))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    metaParaDetalle = meta
                                }
                        }
                        .onDelete(perform: deleteMetas)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Metas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingCrearMeta = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCrearMeta) {
                CrearMetaView(viewModel: viewModel, habit: habit)
            }
            .sheet(item: $metaParaDetalle) { meta in
                NavigationView {
                    MetaDetailView(viewModel: viewModel, meta: meta, habit: habit)
                }
            }
            .onAppear {
                viewModel.loadMetas()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredMetas: [Meta] {
        switch selectedTab {
        case 0:
            return viewModel.metasActivas
        case 1:
            return viewModel.metasCompletadas
        default:
            return viewModel.metas
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(emptyStateMessage)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if selectedTab == 0 {
                Button {
                    viewModel.showingCrearMeta = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Crear primera meta")
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0:
            return "No tienes metas activas.\n¡Crea una nueva meta para motivarte!"
        case 1:
            return "No has completado ninguna meta aún.\n¡Sigue trabajando!"
        default:
            return "No hay metas para este hábito."
        }
    }
    
    // MARK: - Actions
    
    private func deleteMetas(at offsets: IndexSet) {
        let metasToDelete = offsets.map { filteredMetas[$0] }
        Task {
            for meta in metasToDelete {
                await viewModel.eliminarMeta(meta)
            }
        }
    }
}

/// Fila de meta para la lista
struct MetaRowView: View {
    let meta: Meta
    let progreso: MetaProgreso
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cabecera
            HStack {
                Image(systemName: meta.estado.icon)
                    .foregroundColor(meta.estado.color)
                
                Text(meta.nombre)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                MetaEstadoChipView(estado: meta.estado)
            }
            
            // Descripción
            if !meta.descripcion.isEmpty {
                Text(meta.descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Barra de progreso
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progreso.colorProgreso)
                            .frame(width: geometry.size.width * CGFloat(progreso.porcentaje))
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text(progreso.descripcionProgreso)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(progreso.porcentajeFormateado)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(progreso.colorProgreso)
                }
            }
            
            // Info adicional
            HStack {
                MetaPeriodoChipView(periodo: meta.periodo)
                
                Spacer()
                
                if meta.estaActiva {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(meta.diasRestantes) días")
                            .font(.caption)
                    }
                    .foregroundColor(meta.diasRestantes <= 3 ? .orange : .secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#if DEBUG
struct MetasListView_Previews: PreviewProvider {
    static var previews: some View {
        let habit = Habit(nombre: "Correr", frecuencia: .diario)
        let dataStore = HabitDataStore()
        
        MetasListView(habit: habit, dataStore: dataStore)
    }
}
#endif
