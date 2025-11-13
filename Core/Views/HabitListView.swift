// Esta vista muestra el listado de hábitos con su información
import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel

    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        VStack {
            NavigationStack {
                List {
                    ForEach($viewModel.habits) { $habit in
                        habitRow(habit: habit)
                    }
                    .onDelete { indexSet in
                        _Concurrency.Task {
                            await viewModel.removeHabits(atOffsets: indexSet)
                        }
                    }
                }
                .toolbar {
                    Button("Añadir Hábito") {
                        addNewHabit()
                    }
                }
                .navigationTitle("Hábitos")
                .task {
                    await viewModel.loadHabits()
                }
            }
        }
    }

    @ViewBuilder
    private func habitRow(habit: Habit) -> some View {
        NavigationLink(destination: HabitDetailView(
            habit: binding(for: habit),
            onSave: {
                saveHabits()
            }
        )) {
            HabitRowView(habit: habit, toggleCompletion: {
                _Concurrency.Task {
                    await viewModel.toggleCompletion(habit: habit)
                }
            })
            .contextMenu {
                Button("Eliminar Hábito") {
                    deleteHabit(habit)
                }
            }
        }
    }

    private func binding(for habit: Habit) -> Binding<Habit> {
        guard let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) else {
            fatalError("Habit not found")
        }
        return $viewModel.habits[index]
    }

    private func deleteHabit(_ habit: Habit) {
        if let index = viewModel.habits.firstIndex(where: { $0.id == habit.id }) {
            _Concurrency.Task {
                await viewModel.removeHabits(atOffsets: IndexSet(integer: index))
            }
        }
    }

    private func addNewHabit() {
        let newHabit = Habit(name: "Nuevo Hábito", frequency: .daily)
        _Concurrency.Task {
            await viewModel.addHabit(habit: newHabit)
        }
    }

    private func saveHabits() {
        _Concurrency.Task {
            await viewModel.saveHabits()
        }
    }
}

#Preview {
    HabitListView(storageProvider: MockStorageProvider())
}
