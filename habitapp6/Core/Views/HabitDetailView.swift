import SwiftUI

struct HabitDetailView: View {
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(dataStore: HabitDataStore, habit: Habit) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(dataStore: dataStore, habit: habit))
    }
    
    var body: some View {
        Form {
            Section("Información") {
                TextField("Nombre", text: $viewModel.habit.nombre)
                
                Picker("Frecuencia", selection: $viewModel.habit.frecuencia) {
                    ForEach(Frecuencia.allCases, id: \.self) { frecuencia in
                        Text(frecuencia.rawValue.capitalized).tag(frecuencia)
                    }
                }
                
                Toggle("Activo", isOn: $viewModel.habit.activo)
            }
            
            Section("Estadísticas") {
                let completedCount = dataStore.instances.filter {
                    $0.habitID == viewModel.habit.id && $0.completado
                }.count
                
                HStack {
                    Text("Veces completado")
                    Spacer()
                    Text("\(completedCount)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Fecha de creación")
                    Spacer()
                    Text(viewModel.habit.fechaCreacion, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Detalles")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    viewModel.updateHabit()
                    dismiss()
                }
            }
        }
    }
}


