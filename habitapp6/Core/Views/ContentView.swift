import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = HabitDataStore()
    
    var body: some View {
        TabView {
            TodayView(dataStore: dataStore)
                .tabItem {
                    Label("Hoy", systemImage: "checkmark.circle")
                }
            
            HabitsListView(dataStore: dataStore)
                .tabItem {
                    Label("Hábitos", systemImage: "list.bullet")
                }
            
            SettingsView()
                .environmentObject(dataStore)
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape.fill")
                }
        }
    }
}
