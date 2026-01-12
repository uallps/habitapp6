//
//  NotaEditorView.swift
//  HabitTracker
//
//  Feature: Notas
//  Vista de editor para crear/editar notas
//

import SwiftUI

struct NotaEditorView: View {
    
    @ObservedObject var viewModel: NotaViewModel
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    
    @State private var nuevoTag: String = ""
    @FocusState private var editorFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Información del hábito
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.nombre)
                                .font(.headline)
                            Text(Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Toggle importante
                        Button(action: {
                            // Toggle importante en la nota actual
                        }) {
                            Image(systemName: viewModel.notaActual?.esImportante ?? false ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(viewModel.notaActual?.esImportante ?? false ? .yellow : .gray)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Editor de texto
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tu nota")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $viewModel.textoEditor)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .focused($editorFocused)
                        
                        // Contador de caracteres y palabras
                        HStack {
                            Text("\(contadorPalabras) palabras")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(viewModel.textoEditor.count) caracteres")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Sección de tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Tags actuales
                        if let nota = viewModel.notaActual, !nota.tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(nota.tags, id: \.self) { tag in
                                    TagChip(tag: tag, onDelete: {
                                        Task {
                                            await viewModel.eliminarTag(tag, deNota: nota)
                                        }
                                    })
                                }
                            }
                        }
                        
                        // Agregar nuevo tag
                        HStack {
                            TextField("Nuevo tag...", text: $nuevoTag)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                            
                            Button(action: agregarTag) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(nuevoTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        // Tags sugeridos
                        if !viewModel.tagsDisponibles.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags sugeridos")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(viewModel.tagsDisponibles.prefix(10), id: \.self) { tag in
                                            Button(action: {
                                                nuevoTag = tag
                                            }) {
                                                Text("#\(tag)")
                                                    .font(.caption)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Color.gray.opacity(0.1))
                                                    .foregroundColor(.primary)
                                                    .cornerRadius(16)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(viewModel.notaActual != nil ? "Editar Nota" : "Nueva Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        viewModel.cancelarEdicion()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            await viewModel.guardarNotaActual()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.textoEditor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Listo") {
                            editorFocused = false
                        }
                    }
                }
            }
        }
        .onAppear {
            editorFocused = true
        }
    }
    
    // MARK: - Computed Properties
    
    private var contadorPalabras: Int {
        let palabras = viewModel.textoEditor.components(separatedBy: .whitespacesAndNewlines)
        return palabras.filter { !$0.isEmpty }.count
    }
    
    // MARK: - Methods
    
    private func agregarTag() {
        guard let nota = viewModel.notaActual else { return }
        Task {
            await viewModel.agregarTag(nuevoTag, aNota: nota)
            nuevoTag = ""
        }
    }
}

// MARK: - Supporting Views

struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
            Button(action: onDelete) {
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

// MARK: - Preview

#if DEBUG
struct NotaEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
        let viewModel = NotaViewModel(habit: habit)
        
        NotaEditorView(viewModel: viewModel, habit: habit)
    }
}
#endif
