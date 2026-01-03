import SwiftUI

struct HabitInstanceListView: View {
    @StateObject var viewModel: HabitInstanceViewModel
    let habits: [Habit] // para mapear habitID a nombre

    var body: some View {
        List {
            ForEach(viewModel.instances) { instance in
                HStack {
                    // Mostrar nombre del hábito en lugar de UUID
                    Text(habits.first(where: { $0.id == instance.habitID })?.nombre ?? "Hábito")
                        .font(.body)
                    Spacer()
                    Button(action: {
                        viewModel.toggleCompleted(instance)
                    }) {
                        Image(systemName: instance.completado ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(instance.completado ? .green : .gray)
                            .imageScale(.large)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Instancias de Hábito")
    }
}

// MARK: - Preview

struct HabitInstanceListView_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos hábitos de prueba
        let sampleHabits = [
            Habit(nombre: "Beber agua"),
            Habit(nombre: "Ejercicio diario", frecuencia: .diario),
            Habit(nombre: "Leer libro", frecuencia: .semanal)
        ]
        
        // Creamos instancias de prueba
        let sampleInstances = [
            HabitInstance(habitID: sampleHabits[0].id, fecha: Date(), completado: false),
            HabitInstance(habitID: sampleHabits[1].id, fecha: Date(), completado: true),
            HabitInstance(habitID: sampleHabits[2].id, fecha: Date(), completado: false)
        ]
        
        // Creamos ViewModel de prueba
        let viewModel = HabitInstanceViewModel(habits: sampleHabits)
        viewModel.instances = sampleInstances
        
        return NavigationView {
            HabitInstanceListView(viewModel: viewModel, habits: sampleHabits)
        }
    }
}
