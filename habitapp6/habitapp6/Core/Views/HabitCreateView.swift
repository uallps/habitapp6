import SwiftUI

struct HabitCreateView: View {
    @ObservedObject var viewModel: HabitListViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nombre: String = ""
    @State private var frecuencia: Frecuencia = .diario
    
    var body: some View {
        Form {
            TextField("Nombre del hábito", text: $nombre)
            
            Picker("Frecuencia", selection: $frecuencia) {
                ForEach(Frecuencia.allCases, id: \.self) { freq in
                    Text(freq.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button("Guardar") {
                let habit = Habit(nombre: nombre, frecuencia: frecuencia)
                viewModel.addHabit(habit)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Crear Hábito")
    }
}


