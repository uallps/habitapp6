import Foundation

/// Utilidad que exporta un snapshot de datos desde la app para que el widget los lea
/// Sin App Groups, esta es la forma de compartir datos entre la app y el widget
class WidgetDataExporter {
    static let shared = WidgetDataExporter()
    
    private let fileManager = FileManager.default
    private let widgetFileName = "widget_snapshot.json"
    
    /// Ruta donde se guardan los datos del widget (accessible por ambos)
    private var widgetDataURL: URL {
        // Usamos el directorio de documentos por ahora. Cambia a App Group cuando lo configures.
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(widgetFileName)
        
        /// Descomentar cuando se define el App Group y cambiar "TODO"
        // if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "TODO") {
        //     return containerURL.appendingPathComponent(widgetFileName)
        // } else {
        //     fatalError("App Group container no encontrado")
        // }
    }
    
    /// Estructura que contiene el snapshot para el widget
    struct WidgetSnapshot: Codable {
        let habits: [Habit]
        let instances: [HabitInstance]
        let timestamp: Date
    }
    
    /// Exporta los datos actuales para que el widget los lea
    func exportDataForWidget(_ habits: [Habit], _ instances: [HabitInstance]) async throws {
        let snapshot = WidgetSnapshot(
            habits: habits,
            instances: instances,
            timestamp: Date()
        )
        
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: widgetDataURL)
        
        #if DEBUG
        print("📤 [Widget Export] Datos exportados: \(habits.count) hábitos, \(instances.count) instancias")
        #endif
    }
    
    /// Carga el snapshot que la app exportó
    func loadWidgetSnapshot() async throws -> WidgetSnapshot {
        guard fileManager.fileExists(atPath: widgetDataURL.path) else {
            throw NSError(domain: "WidgetDataExporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Widget snapshot not found"])
        }
        
        let data = try Data(contentsOf: widgetDataURL)
        let snapshot = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        
        #if DEBUG
        print("📥 [Widget Import] Snapshot cargado: \(snapshot.habits.count) hábitos")
        #endif
        
        return snapshot
    }
}
