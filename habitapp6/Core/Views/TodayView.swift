import SwiftUI

struct TodayView: View {
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: TodayViewModel
    @StateObject private var metasCompletadasVM = MetasCompletadasViewModel()
    @ObservedObject private var pluginManager = PluginManager.shared
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: TodayViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if viewModel.todayInstances.isEmpty {
                        Text("No hay hábitos para hoy")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.todayInstances, id: \.instance.id) { item in
                            TodayHabitRowView(
                                item: item,
                                viewModel: viewModel,
                                dataStore: dataStore,
                                pluginManager: pluginManager
                            )
                        }
                    }
                }
                .navigationTitle("Hoy")
                .onAppear {
                    viewModel.refreshInstances()
                }
                
                // Overlay de felicitación por metas completadas
                if pluginManager.isMetasEnabled {
                    MetaFelicitacionOverlayView(viewModel: metasCompletadasVM)
                }
            }
        }
    }
}

/// Vista separada para cada fila de hábito - permite que SwiftUI detecte cambios correctamente
struct TodayHabitRowView: View {
    let item: (habit: Habit, instance: HabitInstance)
    @ObservedObject var viewModel: TodayViewModel
    @ObservedObject var dataStore: HabitDataStore
    @ObservedObject var pluginManager: PluginManager
    
    /// Obtiene el estado actual de completado desde el dataStore
    private var isCompleted: Bool {
        dataStore.instances.first(where: { $0.id == item.instance.id })?.completado ?? false
    }
    
    var body: some View {
        HStack {
            Button {
                viewModel.toggleInstance(item.instance)
                // Verificar metas al completar
                if pluginManager.isMetasEnabled {
                    Task {
                        await pluginManager.metasPlugin?.verificarMetas(instancias: dataStore.instances)
                    }
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(item.habit.nombre)
                    .font(.headline)
                    .strikethrough(isCompleted)
                Text(item.habit.frecuencia.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Mostrar badge de metas si está habilitado
            if pluginManager.isMetasEnabled {
                let metasActivas = pluginManager.metasPlugin?.contarMetasActivas(para: item.habit.id) ?? 0
                MetaBadgeView(metasActivas: metasActivas)
            }
        }
    }
}
