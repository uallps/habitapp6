import SwiftUI

struct HabitDetailView: View {
    @ObservedObject var viewModel: HabitListViewModel
    @State var habit: Habit
    
    var body: some View {
        Form {
            TextField("Nombre", text: $habit.nombre)
            
            Picker("Frecuencia", selection: $habit.frecuencia) {
                ForEach(Frecuencia.allCases, id: \.self) { freq in
                    Text(freq.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Toggle("Activo", isOn: $habit.activo)
            
            Button("Guardar Cambios") {
                viewModel.updateHabit(habit)
            }
        }
        .navigationTitle("Detalles")
    }
}


