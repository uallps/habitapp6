
//
// SuggestionCardView.swift
// HabitTracker
//
// Feature: Sugerencias
// Componente visual compacto para mostrar una tarjeta de sugerencia
//

import SwiftUI

struct SuggestionCardView: View {
    
    let sugerencia: SuggestionInfo
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // Icono / Emoji de categoría
            ZStack {
                Circle()
                    .fill(colorCategoria.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(sugerencia.categoria.emoji)
                    .font(.title2)
            }
            
            // Contenido de texto
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(sugerencia.nombre)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(sugerencia.frecuencia.rawValue.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                
                Text(sugerencia.impacto)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                    Text(sugerencia.descripcionDificultad)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(colorDificultad)
                .padding(.top, 4)
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 12) {
                Button(action: onAccept) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.callout)
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
    
    // MARK: - Computed Colors
    
    private var colorCategoria: Color {
        switch sugerencia.colorName {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "yellow": return .yellow
        case "orange": return .orange
        default: return .gray
        }
    }
    
    private var colorDificultad: Color {
        switch sugerencia.nivelDificultad {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
}
