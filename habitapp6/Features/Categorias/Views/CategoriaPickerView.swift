//
//  CategoriaPickerView.swift
//  HabitTracker
//
//  Feature: Categorias - Selector de categoría para hábitos
//

import SwiftUI

/// Vista para seleccionar la categoría de un hábito
struct CategoriaPickerView: View {
    @Binding var selectedCategoria: Categoria
    
    var body: some View {
        Picker("Categoría", selection: $selectedCategoria) {
            ForEach(Categoria.allCases) { categoria in
                HStack {
                    Image(systemName: categoria.icon)
                        .foregroundColor(categoria.color)
                    Text(categoria.displayName)
                }
                .tag(categoria)
            }
        }
    }
}

/// Vista de selección de categoría en formato de lista
struct CategoriaSelectionView: View {
    @Binding var selectedCategoria: Categoria
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Categoria.allCases) { categoria in
                    Button {
                        selectedCategoria = categoria
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            // Icono con color
                            Image(systemName: categoria.icon)
                                .font(.title2)
                                .foregroundColor(categoria.color)
                                .frame(width: 32)
                            
                            // Info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(categoria.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(categoria.descripcion)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Checkmark si está seleccionada
                            if selectedCategoria == categoria {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Sección de categoría para mostrar en detalles del hábito
struct CategoriaDetailSectionView: View {
    @Binding var categoria: Categoria
    @State private var showingPicker = false
    
    var body: some View {
        Section {
            Button {
                showingPicker = true
            } label: {
                HStack {
                    // Icono y nombre de la categoría
                    HStack(spacing: 12) {
                        Image(systemName: categoria.icon)
                            .font(.title2)
                            .foregroundColor(categoria.color)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(categoria.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(categoria.descripcion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        } header: {
            HStack {
                Text("Categoría")
                Spacer()
                if categoria != .ninguno {
                    CategoriaBadgeView(categoria: categoria)
                }
            }
        } footer: {
            Text("Agrupa tus hábitos por categorías para organizarlos mejor.")
        }
        .sheet(isPresented: $showingPicker) {
            CategoriaSelectionView(selectedCategoria: $categoria)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CategoriaPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            CategoriaPickerView(selectedCategoria: .constant(.fisicos))
        }
    }
}

struct CategoriaSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriaSelectionView(selectedCategoria: .constant(.aprendizaje))
    }
}
#endif
