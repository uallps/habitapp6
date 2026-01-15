//
//  MetaDataStore.swift
//  HabitTracker
//
//  Feature: Metas - Gestión de datos de metas
//

import Foundation
import Combine

/// Almacén de datos para las metas de hábitos
@MainActor
class MetaDataStore: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = MetaDataStore()
    
    // MARK: - Published Properties
    
    @Published private(set) var metas: [Meta] = []
    @Published private(set) var metasCompletadasRecientes: [Meta] = []
    
    // MARK: - Private Properties
    
    private let fileURL: URL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("metas.json")
        
        Task {
            await loadMetas()
        }
        
        print("🎯 MetaDataStore inicializado")
    }
    
    // MARK: - CRUD Operations
    
    /// Carga las metas desde el almacenamiento persistente
    func loadMetas() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            metas = try decoder.decode([Meta].self, from: data)
            print("🎯 Cargadas \(metas.count) metas")
        } catch {
            print("🎯 No se pudieron cargar metas (puede ser primera ejecución): \(error)")
            metas = []
        }
    }
    
    /// Guarda las metas en el almacenamiento persistente
    func saveMetas() async {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(metas)
            try data.write(to: fileURL)
            print("🎯 Guardadas \(metas.count) metas")
        } catch {
            print("❌ Error guardando metas: \(error)")
        }
    }
    
    /// Añade una nueva meta
    func addMeta(_ meta: Meta) async {
        metas.append(meta)
        await saveMetas()
        print("🎯 Meta añadida: \(meta.nombre)")
    }
    
    /// Actualiza una meta existente
    func updateMeta(_ meta: Meta) async {
        if let index = metas.firstIndex(where: { $0.id == meta.id }) {
            metas[index] = meta
            await saveMetas()
            print("🎯 Meta actualizada: \(meta.nombre)")
        }
    }
    
    /// Elimina una meta
    func deleteMeta(_ meta: Meta) async {
        metas.removeAll { $0.id == meta.id }
        await saveMetas()
        print("🎯 Meta eliminada: \(meta.nombre)")
    }
    
    /// Elimina todas las metas de un hábito
    func deleteMetasForHabit(habitId: UUID) async {
        let count = metas.filter { $0.habitID == habitId }.count
        metas.removeAll { $0.habitID == habitId }
        await saveMetas()
        print("🎯 Eliminadas \(count) metas del hábito \(habitId)")
    }
    
    // MARK: - Query Methods
    
    /// Obtiene todas las metas de un hábito
    func metasParaHabito(_ habitId: UUID) -> [Meta] {
        return metas.filter { $0.habitID == habitId }
    }
    
    /// Obtiene las metas activas de un hábito
    func metasActivasParaHabito(_ habitId: UUID) -> [Meta] {
        return metas.filter { $0.habitID == habitId && $0.estaActiva }
    }
    
    /// Obtiene todas las metas activas
    func metasActivas() -> [Meta] {
        return metas.filter { $0.estaActiva }
    }
    
    /// Obtiene las metas completadas
    func metasCompletadas() -> [Meta] {
        return metas.filter { $0.estado == .completada }
    }
    
    /// Obtiene las metas fallidas
    func metasFallidas() -> [Meta] {
        return metas.filter { $0.estado == .fallida }
    }
    
    // MARK: - Progress Methods
    
    /// Verifica y actualiza el estado de todas las metas activas
    func verificarEstadoMetas(instancias: [HabitInstance]) async {
        var metasActualizadas = false
        var nuevasCompletadas: [Meta] = []
        
        for meta in metas where meta.estaActiva {
            let progreso = meta.calcularProgreso(instancias: instancias)
            
            // Verificar si se completó
            if progreso.estaCompletada && meta.estado != .completada {
                meta.marcarCompletada()
                nuevasCompletadas.append(meta)
                metasActualizadas = true
                print("🎯 ¡Meta completada!: \(meta.nombre)")
            }
            // Verificar si expiró
            else if meta.haExpirado {
                meta.marcarFallida()
                metasActualizadas = true
                print("🎯 Meta expirada: \(meta.nombre)")
            }
        }
        
        if metasActualizadas {
            await saveMetas()
        }
        
        // Actualizar metas completadas recientes para mostrar felicitación
        if !nuevasCompletadas.isEmpty {
            metasCompletadasRecientes = nuevasCompletadas
        }
    }
    
    /// Limpia la lista de metas completadas recientes (después de mostrar el mensaje)
    func limpiarMetasCompletadasRecientes() {
        metasCompletadasRecientes = []
    }
    
    /// Calcula el progreso de una meta
    func calcularProgreso(meta: Meta, instancias: [HabitInstance]) -> MetaProgreso {
        return meta.calcularProgreso(instancias: instancias)
    }
    
    // MARK: - Statistics
    
    /// Estadísticas generales de metas
    func estadisticas() -> MetaEstadisticas {
        let activas = metas.filter { $0.estaActiva }.count
        let completadas = metas.filter { $0.estado == .completada }.count
        let fallidas = metas.filter { $0.estado == .fallida }.count
        let total = metas.count
        
        let tasaExito = total > 0 ? Double(completadas) / Double(completadas + fallidas) : 0
        
        return MetaEstadisticas(
            activas: activas,
            completadas: completadas,
            fallidas: fallidas,
            total: total,
            tasaExito: tasaExito
        )
    }
}

/// Estadísticas de metas
struct MetaEstadisticas {
    let activas: Int
    let completadas: Int
    let fallidas: Int
    let total: Int
    let tasaExito: Double
    
    var tasaExitoFormateada: String {
        return String(format: "%.0f%%", tasaExito * 100)
    }
}
