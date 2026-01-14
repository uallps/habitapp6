
import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var dataStore: HabitDataStore
    @ObservedObject private var config = AppConfig.shared
    @ObservedObject private var pluginManager = PluginManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Demo Section
                Section {
                    NavigationLink {
                        DemoControlView()
                            .environmentObject(dataStore)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.purple)
                            Text("Modo Demo (Control de Tiempo)")
                        }
                    }
                } header: {
                    Text("Demostración")
                } footer: {
                    Text("Permite simular el paso del tiempo para demostrar rachas y otras funciones.")
                }
                
                // MARK: - Features Section
                Section {
                    PluginToggleRowView(name: "Recordatorios", description: "Notificaciones", icon: "bell.badge.fill", activeColor: .orange, isEnabled: $config.showRecordatorios)
                    
                    PluginToggleRowView(name: "Rachas", description: "Consistencia", icon: "flame.fill", activeColor: .red, isEnabled: $config.showRachas)
                    
                    PluginToggleRowView(name: "Categorías", description: "Organización", icon: "folder.fill", activeColor: .blue, isEnabled: $config.showCategorias)
                    
                    PluginToggleRowView(name: "Metas", description: "Objetivos a largo plazo", icon: "target", activeColor: .purple, isEnabled: $config.showMetas)
                    
                    PluginToggleRowView(name: "Sugerencias", description: "Recomendaciones", icon: "lightbulb.fill", activeColor: .yellow, isEnabled: $config.showSugerencias)
                    
                    PluginToggleRowView(name: "Logros", description: "Medallas y premios", icon: "trophy.fill", activeColor: .orange, isEnabled: $config.showLogros)
                    
                    PluginToggleRowView(name: "Notas", description: "Notas y recordatorios personales", icon: "note.text", activeColor: .indigo, isEnabled: $config.showNotas)
                } header: {
                    Text("Features")
                } footer: {
                    Text("Activa o desactiva las funcionalidades de la aplicación. Los cambios se aplican inmediatamente.")
                }
                
                // MARK: - Extensiones Activas
                Section {
                    
                    // Enlace Logros
                    if let logrosPlugin = PluginManager.shared.logrosPlugin {
                        logrosPlugin.settingsLink()
                    }
                    
                } header: { Text("Extensiones Activas") }
                
                // MARK: - Acciones Rápidas
                Section {
                    Button { config.enableAllFeatures() } label: { HStack { Image(systemName: "checkmark.circle.fill").foregroundColor(.green); Text("Activar todas las features") } }
                    Button { config.disableAllFeatures() } label: { HStack { Image(systemName: "xmark.circle.fill").foregroundColor(.red); Text("Desactivar todas las features") } }
                    Button { config.resetToDefaults() } label: { HStack { Image(systemName: "arrow.counterclockwise").foregroundColor(.blue); Text("Restaurar valores por defecto") } }
                } header: { Text("Acciones Rápidas") }
                
                // MARK: - Info
                Section {
                    HStack {
                        Text("Features activas")
                        Spacer()
                        Text("\(enabledFeaturesCount) de 7")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.secondary)
                    }
                } header: { Text("Información") }
                
                // MARK: - About SPL
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "puzzlepiece.extension")
                                .foregroundColor(.purple)
                            Text("Arquitectura SPL")
                                .font(.headline)
                        }
                        
                        Text("Esta aplicación utiliza una arquitectura de Software Product Line (SPL) que permite activar y desactivar funcionalidades de forma modular sin afectar el núcleo de la aplicación.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Acerca de")
                }
            }
            .navigationTitle("Configuración")
            .toolbar {
                Button("Cerrar") { dismiss() }
            }
        }
    }
    
    private var enabledFeaturesCount: Int {
        var count = 0
        if config.showRecordatorios { count += 1 }
        if config.showRachas { count += 1 }

        if config.showSugerencias { count += 1 }
        if config.showCategorias { count += 1 }
        if config.showMetas { count += 1 }
        if config.showSugerencias { count += 1 }
        if config.showLogros { count += 1 }
        return count
    }
}


// MARK: - Plugin Toggle Row View
struct PluginToggleRowView: View {
    let name: String
    let description: String
    let icon: String
    let activeColor: Color
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? activeColor : .gray)
                .font(.title2)
                .frame(width: 30)
                .font(.title2).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline)
                Text(description).font(.caption).foregroundColor(.secondary).lineLimit(2)
            }
            Spacer()
        
            Toggle("", isOn: $isEnabled).labelsHidden()

        }
        .padding(.vertical, 4)
    }
}
