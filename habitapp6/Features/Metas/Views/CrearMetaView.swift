//
//  CrearMetaView.swift
//  HabitTracker
//
//  Feature: Metas - Vista para crear nuevas metas
//

import SwiftUI

/// Vista para crear una nueva meta
struct CrearMetaView: View {
    
    @ObservedObject var viewModel: MetaViewModel
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    
    @State private var nombre: String = ""
    @State private var descripcion: String = ""
    @State private var objetivo: Int = 10
    @State private var periodoSeleccionado: PeriodoMeta = .mes
    
    // Rango de objetivos según el período
    private var rangoObjetivos: ClosedRange<Int> {
        switch periodoSeleccionado {
        case .semana: return 1...50
        case .mes: return 1...200
        case .tresMeses: return 1...500
        case .seisMeses: return 1...1000
        case .nueveMeses: return 1...1500
        case .año: return 1...2000
        }
    }
    
    // Sugerencia de objetivo basada en la frecuencia del hábito
    private var objetivoSugerido: Int {
        switch habit.frecuencia {
        case .diario:
            return periodoSeleccionado.diasTotales
        case .semanal:
            return periodoSeleccionado.diasTotales / 7
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Información del Hábito
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(habit.nombre)
                            .fontWeight(.medium)
                        Spacer()
                        Text(habit.frecuencia.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Hábito")
                }
                
                // MARK: - Nombre de la Meta
                Section {
                    TextField("Nombre de la meta", text: $nombre)
                    
                    TextField("Descripción (opcional)", text: $descripcion)
                } header: {
                    Text("Información de la Meta")
                } footer: {
                    Text("Dale un nombre descriptivo a tu meta, por ejemplo: \"Correr 100 veces este año\"")
                }
                
                // MARK: - Período de Tiempo
                Section {
                    Picker("Período", selection: $periodoSeleccionado) {
                        ForEach(PeriodoMeta.allCases) { periodo in
                            HStack {
                                Image(systemName: periodo.icon)
                                Text(periodo.displayName)
                            }
                            .tag(periodo)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: periodoSeleccionado) { newValue in
                        // Ajustar el objetivo al cambiar el período
                        objetivo = min(objetivo, rangoObjetivos.upperBound)
                        objetivo = max(objetivo, rangoObjetivos.lowerBound)
                    }
                    
                    HStack {
                        Text("Tipo de plazo")
                            .foregroundColor(.secondary)
                        Spacer()
                        MetaPeriodoChipView(periodo: periodoSeleccionado)
                    }
                    
                    HStack {
                        Text("Duración")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(periodoSeleccionado.diasTotales) días")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Período de Tiempo")
                }
                
                // MARK: - Objetivo
                Section {
                    Stepper(value: $objetivo, in: rangoObjetivos) {
                        HStack {
                            Text("Completar")
                            Spacer()
                            Text("\(objetivo) veces")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Slider para ajuste rápido
                    VStack(alignment: .leading, spacing: 4) {
                        Slider(
                            value: Binding(
                                get: { Double(objetivo) },
                                set: { objetivo = Int($0) }
                            ),
                            in: Double(rangoObjetivos.lowerBound)...Double(rangoObjetivos.upperBound),
                            step: 1
                        )
                        .tint(.purple)
                        
                        HStack {
                            Text("\(rangoObjetivos.lowerBound)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(rangoObjetivos.upperBound)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        objetivo = objetivoSugerido
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Usar sugerencia: \(objetivoSugerido) veces")
                        }
                    }
                } header: {
                    Text("Objetivo")
                } footer: {
                    Text("Define cuántas veces quieres completar el hábito en el período seleccionado.")
                }
                
                // MARK: - Resumen
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.purple)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(nombre.isEmpty ? "Nueva Meta" : nombre)
                                    .font(.headline)
                                Text("Completar \(habit.nombre) \(objetivo) veces en \(periodoSeleccionado.displayName.lowercased())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Inicio")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(Date().formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Fin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(periodoSeleccionado.fechaFin(desde: Date()).formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                        }
                        
                        // Ritmo necesario
                        let ritmoNecesario = calcularRitmoNecesario()
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.orange)
                            Text("Ritmo necesario: \(ritmoNecesario)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Resumen")
                }
            }
            .navigationTitle("Nueva Meta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        crearMeta()
                    }
                    .disabled(nombre.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func calcularRitmoNecesario() -> String {
        let dias = periodoSeleccionado.diasTotales
        let porDia = Double(objetivo) / Double(dias)
        let porSemana = porDia * 7
        
        if porDia >= 1 {
            return String(format: "%.1f veces/día", porDia)
        } else {
            return String(format: "%.1f veces/semana", porSemana)
        }
    }
    
    private func crearMeta() {
        let nombreFinal = nombre.isEmpty ? "\(habit.nombre) - \(objetivo) veces" : nombre
        
        Task {
            await viewModel.crearMeta(
                nombre: nombreFinal,
                descripcion: descripcion,
                objetivo: objetivo,
                periodo: periodoSeleccionado
            )
            dismiss()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CrearMetaView_Previews: PreviewProvider {
    static var previews: some View {
        let habit = Habit(nombre: "Correr", frecuencia: .diario)
        let dataStore = HabitDataStore()
        let viewModel = MetaViewModel(habit: habit, habitDataStore: dataStore)
        
        CrearMetaView(viewModel: viewModel, habit: habit)
    }
}
#endif
