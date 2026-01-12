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
