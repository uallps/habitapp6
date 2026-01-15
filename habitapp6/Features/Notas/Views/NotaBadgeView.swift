//
//  NotaBadgeView.swift
//  HabitTracker
//
//  Feature: Notas
//  Componentes visuales compactos para mostrar notas
//

import SwiftUI

/// Badge compacto de nota para mostrar en listas
struct NotaBadgeView: View {
    
    let tieneNota: Bool
    let esImportante: Bool
    
    var body: some View {
        if tieneNota {
            HStack(spacing: 2) {
                Image(systemName: esImportante ? "note.text.badge.plus" : "note.text")
                    .font(.caption2)
            }
            .foregroundColor(esImportante ? .orange : .blue)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill((esImportante ? Color.orange : Color.blue).opacity(0.15))
            )
        }
    }
}

/// Vista de nota para mostrar en la fila de un hábito
struct NotaRowView: View {
    
    let habit: Habit
    @StateObject private var viewModel: NotaViewModel
    
    init(habit: Habit) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: NotaViewModel(habit: habit))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Icono de nota
            Image(systemName: viewModel.notaActual != nil ? "note.text" : "note")
                .font(.title3)
                .foregroundColor(viewModel.notaActual != nil ? .blue : .gray.opacity(0.5))
            
            VStack(alignment: .leading, spacing: 2) {
                if let nota = viewModel.notaActual {
                    Text("Nota de hoy")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(nota.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Sin nota hoy")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Toca para agregar una nota")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Indicador de importante
            if let nota = viewModel.notaActual, nota.esImportante {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            // Contador de notas
            if viewModel.cantidadNotas > 0 {
                Text("\(viewModel.cantidadNotas)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Circle().fill(Color.blue))
            }
        }
        .padding(.vertical, 4)
    }
}

/// Vista compacta de nota para el resumen de hoy
struct NotaCompactView: View {
    
    let tieneNota: Bool
    let preview: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tieneNota ? "note.text" : "note")
                .foregroundColor(tieneNota ? .blue : .gray)
            
            if tieneNota {
                Text(preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text("Sin nota")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

/// Vista de card de nota
struct NotaCardView: View {
    
    let nota: Nota
    let onTap: () -> Void
    let onToggleImportante: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header con fecha y acciones
            HStack {
                Text(nota.fecha, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onToggleImportante) {
                    Image(systemName: nota.esImportante ? "star.fill" : "star")
                        .foregroundColor(nota.esImportante ? .yellow : .gray)
                }
                .buttonStyle(.plain)
            }
            
            // Contenido
            Text(nota.contenido)
                .font(.body)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
            
            // Footer con stats y tags
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "text.word.spacing")
                        .font(.caption2)
                    Text("\(nota.cantidadPalabras)")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                
                if nota.fueEditada {
                    Image(systemName: "pencil")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Tags
                if !nota.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(nota.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
}

/// Vista de preview de nota (más pequeña)
struct NotaPreviewView: View {
    
    let nota: Nota
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(nota.fecha, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if nota.esImportante {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(nota.preview)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

/// Vista de mini calendario con indicadores de notas
struct NotasMiniCalendarView: View {
    
    let habit: Habit
    let diasMostrar: Int
    @StateObject private var viewModel: NotaViewModel
    
    init(habit: Habit, diasMostrar: Int = 7) {
        self.habit = habit
        self.diasMostrar = diasMostrar
        _viewModel = StateObject(wrappedValue: NotaViewModel(habit: habit))
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(ultimosDias, id: \.self) { fecha in
                VStack(spacing: 2) {
                    Text(letraDia(fecha))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(tieneNota(fecha: fecha) ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .overlay(
                            tieneNota(fecha: fecha) ?
                                Image(systemName: "note.text")
                                    .font(.system(size: 8))
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
    
    private func tieneNota(fecha: Date) -> Bool {
        let calendar = Calendar.current
        return viewModel.notas.contains { nota in
            calendar.isDate(nota.fecha, inSameDayAs: fecha)
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
struct NotaViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Group {
                Text("NotaBadgeView").font(.headline)
                HStack(spacing: 10) {
                    NotaBadgeView(tieneNota: false, esImportante: false)
                    NotaBadgeView(tieneNota: true, esImportante: false)
                    NotaBadgeView(tieneNota: true, esImportante: true)
                }
            }
            
            Divider()
            
            Group {
                Text("NotaCompactView").font(.headline)
                VStack(spacing: 10) {
                    NotaCompactView(tieneNota: false, preview: "")
                    NotaCompactView(tieneNota: true, preview: "Esta es una nota de ejemplo...")
                }
            }
            
            Divider()
            
            Group {
                Text("NotaCardView").font(.headline)
                let nota = Nota(
                    habitID: UUID(),
                    contenido: "Hoy fue un gran día para hacer ejercicio. Me sentí con mucha energía.",
                    esImportante: true,
                    tags: ["energía", "motivado"]
                )
                NotaCardView(
                    nota: nota,
                    onTap: {},
                    onToggleImportante: {},
                    onDelete: {}
                )
            }
        }
        .padding()
    }
}
#endif
