import Foundation
#if !WIDGET_EXTENSION
import SwiftUI
#endif

/// Helper para testing y debugging del widget
/// Úsalo en una vista temporal para verificar que los datos se exportan correctamente
struct WidgetDebugHelper {
    
    /// Exporta datos manualmente y verifica que se guardaron
    @MainActor
    static func debugExportData(habits: [Habit], instances: [HabitInstance]) async {
        print("🔍 [Widget Debug] Exportando \(habits.count) hábitos y \(instances.count) instancias...")
        
        do {
            try await WidgetDataExporter.shared.exportDataForWidget(habits, instances)
            print("✅ [Widget Debug] Datos exportados exitosamente")
            
            // Intenta leerlos de vuelta
            let loaded = try await WidgetDataExporter.shared.loadWidgetSnapshot()
            print("✅ [Widget Debug] Snapshot verificado: \(loaded.habits.count) hábitos")
            print("📊 [Widget Debug] Timestamp: \(loaded.timestamp)")
            
        } catch {
            print("❌ [Widget Debug] Error: \(error.localizedDescription)")
        }
    }
    
    /// Obtén la ruta donde se guardan los datos del widget
    static func getWidgetDataPath() -> String? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent("widget_snapshot.json").path
    }
    
    /// Muestra información de debugging sobre la exportación
    #if !WIDGET_EXTENSION
        @MainActor
        
        static func printDebugInfo(dataStore: HabitDataStore) {
            print("\n🔍 === WIDGET DEBUG INFO ===")
            print("📱 Hábitos activos: \(dataStore.habits.filter { $0.activo }.count)")
            print("📅 Instancias totales: \(dataStore.instances.count)")
            
            let today = Calendar.current.startOfDay(for: Date())
            let todayInstances = dataStore.instances.filter {
                Calendar.current.isDate($0.fecha, inSameDayAs: today)
            }
            print("📍 Instancias de hoy: \(todayInstances.count)")
            
            if let path = getWidgetDataPath() {
                print("📂 Archivo widget: \(path)")
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: path) {
                    do{
                        let attributes = try fileManager.attributesOfItem(atPath: path)
                        if let size = attributes[.size] as? Int {
                            print("Tamaño: \(size) bytes")
                        }
                        if let modDate = attributes[.modificationDate] as? Date{
                            print("Ultima actualizacion: \(modDate)")
                        }
                    } catch {
                        print("Error leyendo atributos: \(error)")
                    }
                } else {
                    print("⚠️ Archivo no encontrado")
                }
            }
            print("========================\n")
        }
    #endif
}

// MARK: - Preview / Testing View (comentado, usar solo para debug)

/*
struct WidgetDebugView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var debugMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Widget Debug")
                .font(.headline)
            
            Button(action: {
                Task {
                    await WidgetDebugHelper.debugExportData(
                        habits: dataStore.habits,
                        instances: dataStore.instances
                    )
                    debugMessage = "✅ Datos exportados"
                }
            }) {
                Text("Exportar datos al widget")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                WidgetDebugHelper.printDebugInfo(dataStore: dataStore)
                debugMessage = "ℹ️ Ver consola para info"
            }) {
                Text("Mostrar info debug")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if !debugMessage.isEmpty {
                Text(debugMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}
*/
