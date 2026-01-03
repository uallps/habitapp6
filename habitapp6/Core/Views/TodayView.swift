import SwiftUI

struct TodayView: View {
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: TodayViewModel
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: TodayViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.todayInstances.isEmpty {
                    Text("No hay hábitos para hoy")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.todayInstances, id: \.instance.id) { item in
                        HStack {
                            Button {
                                viewModel.toggleInstance(item.instance)
                            } label: {
                                Image(systemName: item.instance.completado ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.instance.completado ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading) {
                                Text(item.habit.nombre)
                                    .font(.headline)
                                    .strikethrough(item.instance.completado)
                                Text(item.habit.frecuencia.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Hoy")
            .onAppear {
                viewModel.refreshInstances()
            }
        }
    }
}
