//
//  CategoriaBadgeView.swift
//  HabitTracker
//
//  Feature: Categorias - Badge de categoría para mostrar en listas
//

import SwiftUI

/// Badge compacto que muestra la categoría de un hábito
struct CategoriaBadgeView: View {
    let categoria: Categoria
    var showText: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: categoria.icon)
                .font(.caption)
            
            if showText {
                Text(categoria.displayName)
                    .font(.caption)
            }
        }
        .foregroundColor(categoria.color)
        .padding(.horizontal, showText ? 8 : 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(categoria.color.opacity(0.15))
        )
    }
}

/// Badge para mostrar en la fila de un hábito
struct CategoriaRowBadgeView: View {
    let habit: Habit
    
    var body: some View {
        if habit.tieneCategoria {
            CategoriaBadgeView(categoria: habit.categoriaEnum)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CategoriaBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Badges sin texto
            HStack(spacing: 10) {
                ForEach(Categoria.allCases) { categoria in
                    CategoriaBadgeView(categoria: categoria)
                }
            }
            
            // Badges con texto
            VStack(spacing: 10) {
                ForEach(Categoria.allCases) { categoria in
                    CategoriaBadgeView(categoria: categoria, showText: true)
                }
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
