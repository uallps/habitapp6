//
//  MetaBadgeView.swift
//  HabitTracker
//
//  Feature: Metas - Vista badge para mostrar en listas
//

import SwiftUI

/// Badge que muestra el número de metas activas de un hábito
struct MetaBadgeView: View {
    let metasActivas: Int
    
    var body: some View {
        if metasActivas > 0 {
            HStack(spacing: 2) {
                Image(systemName: "target")
                    .font(.caption2)
                Text("\(metasActivas)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.purple)
            )
        }
    }
}

/// Badge que muestra el progreso de una meta
struct MetaProgressBadgeView: View {
    let progreso: MetaProgreso
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: progreso.estaCompletada ? "checkmark.circle.fill" : "target")
                .font(.caption2)
            Text(progreso.porcentajeFormateado)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(progreso.colorProgreso)
        )
    }
}

/// Vista compacta de una meta para mostrar en listas
struct MetaRowCompactView: View {
    let meta: Meta
    let progreso: MetaProgreso
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: meta.estado.icon)
                    .foregroundColor(meta.estado.color)
                    .font(.caption)
                
                Text(meta.nombre)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                MetaProgressBadgeView(progreso: progreso)
            }
            
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(progreso.colorProgreso)
                        .frame(width: geometry.size.width * CGFloat(progreso.porcentaje), height: 4)
                }
            }
            .frame(height: 4)
            
            HStack {
                Text(progreso.descripcionProgreso)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if meta.estaActiva {
                    Text("\(meta.diasRestantes) días restantes")
                        .font(.caption2)
                        .foregroundColor(meta.diasRestantes <= 3 ? .orange : .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// Chip de estado de meta
struct MetaEstadoChipView: View {
    let estado: EstadoMeta
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: estado.icon)
                .font(.caption2)
            Text(estado.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(estado.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(estado.color.opacity(0.15))
        )
    }
}

/// Chip de período de meta
struct MetaPeriodoChipView: View {
    let periodo: PeriodoMeta
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: periodo.icon)
                .font(.caption2)
            Text(periodo.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(periodo.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(periodo.color.opacity(0.15))
        )
    }
}

// MARK: - Previews

#if DEBUG
struct MetaBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MetaBadgeView(metasActivas: 3)
            
            MetaProgressBadgeView(progreso: MetaProgreso(
                meta: Meta(habitID: UUID(), nombre: "Test", objetivo: 100, periodo: .mes),
                completadas: 75,
                objetivo: 100,
                porcentaje: 0.75,
                diasRestantes: 10
            ))
            
            MetaEstadoChipView(estado: .activa)
            MetaEstadoChipView(estado: .completada)
            MetaEstadoChipView(estado: .fallida)
            
            MetaPeriodoChipView(periodo: .semana)
            MetaPeriodoChipView(periodo: .año)
        }
        .padding()
    }
}
#endif
