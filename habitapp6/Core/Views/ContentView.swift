
import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = HabitDataStore()
    @StateObject private var appConfig = AppConfig.shared
    @StateObject private var pluginManager = PluginManager.shared
    @ObservedObject private var logrosManager = LogrosManager.shared
    
    @State private var showingFelicitacion = false
    @State private var logroDesbloqueado: Logro?
    
    var body: some View {
        ZStack {
            TabView {
                TodayView(dataStore: dataStore)
                    .tabItem {
                        Label("Hoy", systemImage: "checkmark.circle")
                    }
                
                HabitsListView(dataStore: dataStore)
                    .tabItem {
                        Label("Hábitos", systemImage: "list.bullet")
                    }
            }
            .zIndex(0)
            
            if showingFelicitacion, let logro = logroDesbloqueado {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { cerrarFelicitacion() }
                    .zIndex(1)
                
                FelicitacionCard(logro: logro) {
                    cerrarFelicitacion()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .onReceive(logrosManager.$logrosRecienDesbloqueados) { _ in
            procesarColaLogros()
        }
    }
    
    private func procesarColaLogros() {
        if showingFelicitacion { return }
        
        if let siguienteLogro = logrosManager.consumirPrimerLogro() {
            self.logroDesbloqueado = siguienteLogro
            withAnimation(.spring()) {
                self.showingFelicitacion = true
            }
        }
    }
    
    private func cerrarFelicitacion() {
        withAnimation {
            showingFelicitacion = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.logroDesbloqueado = nil
            self.procesarColaLogros()
            #if DEVELOP
            SettingsView()
                .environmentObject(dataStore)
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
            #endif
        }
    }
}
