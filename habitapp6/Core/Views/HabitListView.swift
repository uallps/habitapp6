import SwiftUI

struct HabitsListView: View {
    @ObservedObject var dataStore: HabitDataStore
    @StateObject private var viewModel: HabitsViewModel
    @State private var showingCreateView = false
    
    init(dataStore: HabitDataStore) {
        self.dataStore = dataStore
        _viewModel = StateObject(wrappedValue: HabitsViewModel(dataStore: dataStore))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.habits) { habit in
                    NavigationLink(destination: HabitDetailView(dataStore: dataStore, habit: habit)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(habit.nombre)
                                    .font(.headline)
                                Text(habit.frecuencia.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { habit.activo },
                                set: { _ in viewModel.toggleHabitActive(habit) }
                            ))
                            .labelsHidden()
                        }
                    }
                }
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("Mis Hábitos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreateHabitView(dataStore: dataStore)
            }
        }
    }
    
    func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteHabit(dataStore.habits[index])
        }
    }
}
