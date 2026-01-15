import SwiftUI

struct CreateHabitView: View {
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: CreateHabitViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: CreateHabitViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Nuevo Hábito") {
                    TextField("Nombre del hábito", text: $viewModel.nombre)
                    
                    Picker("Frecuencia", selection: $viewModel.frecuencia) {
                        ForEach(Frecuencia.allCases, id: \.self) { frecuencia in
                            Text(frecuencia.rawValue.capitalized).tag(frecuencia)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Crear Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        viewModel.createHabit()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
