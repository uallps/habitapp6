import SwiftUI

struct SuggestionListView: View {
   
  // Eliminamos la dependencia fuerte a HabitListViewModel
  // El ViewModel interno ya se encarga de todo.
  @StateObject private var viewModel: SuggestionViewModel
   
  // El init recibe el PROTOCOLO, no la clase concreta
  init(habitHandler: HabitSuggestionHandler) {
    _viewModel = StateObject(wrappedValue: SuggestionViewModel(habitHandler: habitHandler))
  }
   
  var body: some View {
    ZStack {
      Color(.systemGroupedBackground).ignoresSafeArea()
       
      if viewModel.isLoading {
        ProgressView("Buscando ideas...")
 } else if viewModel.sugerenciasDisponibles.isEmpty {
         // Vista vacía
         VStack(spacing: 20) {
           Image(systemName: "checkmark.circle.badge.questionmark")
             .font(.system(size: 50))
             .foregroundColor(.gray)
           Text("No hay sugerencias nuevas")
             .font(.headline)
             .foregroundColor(.secondary)
         }
      } else {
        ScrollView {
          LazyVStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
              Text("Inspiración para ti")
                .font(.title2)
                .fontWeight(.bold)
              Text("Descubre nuevos hábitos para mejorar tu rutina.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
             
            // Lista de tarjetas
            ForEach(viewModel.sugerenciasDisponibles) { sugerencia in
              SuggestionCardView(
                sugerencia: sugerencia,
                onAccept: { viewModel.aceptarSugerencia(sugerencia) },
                onDismiss: { viewModel.descartarSugerencia(sugerencia) }
              )
            }
          }
          .padding()
        }
      }
       
      // Feedback Overlay
      if let mensaje = viewModel.mensajeFeedback {
        VStack {
          Spacer()
          HStack {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
            Text(mensaje)
              .fontWeight(.medium)
          }
          .padding()
          .background(.ultraThinMaterial)
          .cornerRadius(20)
          .shadow(radius: 5)
          .padding(.bottom, 20)
        }
      }
    }
    .navigationTitle("Explorar Hábitos")
    .navigationBarTitleDisplayMode(.inline)
  }
}
