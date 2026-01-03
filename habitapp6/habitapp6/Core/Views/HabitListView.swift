import SwiftUI

struct HabitListView: View {
    @StateObject var viewModel = HabitListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.habits) { habit in
                        VStack(alignment: .leading) {
                            HStack {
                                NavigationLink(destination: HabitDetailView(viewModel: viewModel, habit: habit)) {
                                    Text(habit.nombre)
                                        .font(.headline)
                                    Spacer()
                                    Text(habit.frecuencia.rawValue.capitalized)
                                        .foregroundColor(.gray)
                                    Image(systemName: habit.activo ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(habit.activo ? .green : .gray)
                                }
                            }
                            // Botón para ir a las instancias
                            NavigationLink(destination: HabitInstanceListView(viewModel: HabitInstanceViewModel(habits: [habit]), habits: [habit])) {
                                Text("Ver instancias")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        Task { @MainActor in
                            viewModel.removeHabit(at: offsets)
                        }
                    }
                }
                
                NavigationLink("Crear Hábito", destination: HabitCreateView(viewModel: viewModel))
                    .padding()
            }
            .navigationTitle("Hábitos")
        }
    }
}



struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        HabitListView()
    }
}
