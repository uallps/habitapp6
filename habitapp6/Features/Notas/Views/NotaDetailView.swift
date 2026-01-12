//
//  NotaDetailView.swift
//  HabitTracker
//
//  Feature: Notas
//  Vista detallada de las notas de un hábito
//

import SwiftUI

struct NotaDetailView: View {
    
    let habit: Habit
    @StateObject private var viewModel: NotaViewModel
    @State private var busqueda: String = ""
    @State private var mostrarFiltros: Bool = false
    @State private var notaSeleccionada: Nota?
    
    init(habit: Habit) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: NotaViewModel(habit: habit))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Estadísticas
                if viewModel.tieneNotas {
                    estadisticasCard
                }
                
                // Botón para nueva nota
                Button(action: {
                    viewModel.prepararEditor()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(viewModel.notaActual != nil ? "Editar nota de hoy" : "Agregar nota de hoy")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Búsqueda
                if viewModel.tieneNotas {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Buscar en notas...", text: $busqueda)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Lista de notas
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.tieneNotas {
                    notasListSection
                } else {
                    emptyStateView
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Notas de \(habit.nombre)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.mostrarEditor) {
            NotaEditorView(
                viewModel: viewModel,
                habit: habit
            )
        }
        .sheet(item: $notaSeleccionada) { nota in
            NotaDetailSheet(
                nota: nota,
                viewModel: viewModel
            )
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
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
                EstadisticaNotaItem(
                    icono: "note.text",
                    color: .blue,
                    titulo: "Total Notas",
                    valor: "\(viewModel.estadisticas.totalNotas)"
                )
                
                EstadisticaNotaItem(
                    icono: "star.fill",
                    color: .yellow,
                    titulo: "Importantes",
                    valor: "\(viewModel.estadisticas.notasImportantes)"
                )
                
                EstadisticaNotaItem(
                    icono: "text.word.spacing",
                    color: .green,
                    titulo: "Palabras",
                    valor: "\(viewModel.estadisticas.totalPalabras)"
                )
                
                EstadisticaNotaItem(
                    icono: "calendar",
                    color: .purple,
                    titulo: "Días con Notas",
                    valor: "\(viewModel.estadisticas.diasConNotas)"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Notas List Section
    
    private var notasListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(notasFiltradas) { nota in
                NotaCardView(
                    nota: nota,
                    onTap: {
                        notaSeleccionada = nota
                    },
                    onToggleImportante: {
                        Task {
                            await viewModel.toggleImportante(nota)
                        }
                    },
                    onDelete: {
                        Task {
                            await viewModel.eliminarNota(nota)
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No hay notas todavía")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Comienza a documentar tu progreso con notas diarias")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Computed Properties
    
    private var notasFiltradas: [Nota] {
        if busqueda.isEmpty {
            return viewModel.notas
        } else {
            return viewModel.notas.filter {
                $0.contenido.lowercased().contains(busqueda.lowercased())
            }
        }
    }
}

// MARK: - Supporting Views

struct EstadisticaNotaItem: View {
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

/// Sheet para ver detalle completo de una nota
struct NotaDetailSheet: View {
    
    let nota: Nota
    @ObservedObject var viewModel: NotaViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header con fecha e importante
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(nota.fecha, style: .date)
                                .font(.headline)
                            Text(nota.fecha, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await viewModel.toggleImportante(nota)
                            }
                        }) {
                            Image(systemName: nota.esImportante ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(nota.esImportante ? .yellow : .gray)
                        }
                    }
                    
                    Divider()
                    
                    // Contenido
                    Text(nota.contenido)
                        .font(.body)
                    
                    Divider()
                    
                    // Estadísticas
                    HStack(spacing: 20) {
                        StatItem(icono: "text.word.spacing", valor: "\(nota.cantidadPalabras)", titulo: "Palabras")
                        StatItem(icono: "character", valor: "\(nota.cantidadCaracteres)", titulo: "Caracteres")
                    }
                    
                    // Tags
                    if !nota.tags.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(nota.tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                            .font(.caption)
                                        Button(action: {
                                            Task {
                                                await viewModel.eliminarTag(tag, deNota: nota)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    // Info de modificación
                    if nota.fueEditada {
                        Divider()
                        
                        HStack {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.secondary)
                            Text("Editada: \(nota.fechaModificacion, style: .relative)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalle de Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.prepararEditor(nota: nota)
                        dismiss()
                    }) {
                        Text("Editar")
                    }
                }
            }
        }
    }
}

struct StatItem: View {
    let icono: String
    let valor: String
    let titulo: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icono)
                .foregroundColor(.secondary)
            Text(valor)
                .font(.headline)
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Layout para organizar tags en flow
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NotaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
            NotaDetailView(habit: habit)
        }
    }
}
#endif
