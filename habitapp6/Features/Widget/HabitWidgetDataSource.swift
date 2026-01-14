import Foundation

/// Data source para el widget que reusa la arquitectura existente
/// Intenta leer desde el snapshot que la app exporta, sino carga desde JSON
struct HabitWidgetDataSource {
    static let shared = HabitWidgetDataSource()
    
    private let calendar = Calendar.current
    
    func loadSnapshot() async -> HabitWidgetEntry {
        // Primero intentar leer el snapshot que la app exportó
        do {
            let widgetSnapshot = try await WidgetDataExporter.shared.loadWidgetSnapshot()
            #if DEBUG
            print("[Widget] ✅ Snapshot cargado desde app")
            #endif
            return processData(habits: widgetSnapshot.habits, instances: widgetSnapshot.instances)
        } catch {
            #if DEBUG
            print("[Widget] ⚠️ No hay snapshot de la app, intentando JSON directo: \(error)")
            #endif
            // Fallback: intentar cargar desde JSON directamente
            return await loadFromJSON()
        }
    }
    
    private func loadFromJSON() async -> HabitWidgetEntry {
        do {
            let habits = try await JSONStorageProvider.shared.loadHabits()
            let instances = try await JSONStorageProvider.shared.loadInstances()
            #if DEBUG
            print("[Widget] ✅ JSON cargado como fallback")
            #endif
            return processData(habits: habits, instances: instances)
        } catch {
            #if DEBUG
            print("[Widget] ❌ Error cargando desde JSON: \(error.localizedDescription)")
            #endif
            return placeholder()
        }
    }
    
    private func processData(habits: [Habit], instances: [HabitInstance]) -> HabitWidgetEntry {
        // Si no hay hábitos, retornar placeholder
        guard !habits.isEmpty else {
            #if DEBUG
            print("[Widget] ⚠️ Sin hábitos, mostrando placeholder")
            #endif
            return placeholder()
        }
        
        // Hábitos pendientes para hoy
        let today = calendar.startOfDay(for: Date())
        let pending = habits.filter { $0.activo }.map { habit -> HabitSnapshot in
            let isDone: Bool
            switch habit.frecuencia {
            case .diario:
                isDone = instances.contains {
                    $0.habitID == habit.id &&
                    calendar.isDate($0.fecha, inSameDayAs: today) &&
                    $0.completado
                }
            case .semanal:
                let week = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                isDone = instances.contains {
                    guard $0.habitID == habit.id else { return false }
                    let instWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.fecha)
                    return instWeek == week && $0.completado
                }
            }
            return HabitSnapshot(id: habit.id, nombre: habit.nombre, completado: isDone)
        }
        
        // Calcular la mejor racha de TODOS los hábitos
        //let allStreaks = habits.map { habit in
            //RachaCalculator.shared.calcularRacha(para: habit, instancias: instances)
        //}
        
        //let streak = allStreaks.map { $0.rachaActual }.max() ?? 0
        //let best = allStreaks.map { $0.mejorRacha }.max() ?? 0
        
        let streak = 0
        let best = 0
        
        #if DEBUG
        print("[Widget] 📊 Mostrar: \(pending.count) pendientes, racha: \(streak)/\(best)")
        #endif
        
        return HabitWidgetEntry(date: Date(), pendingHabits: pending, streak: streak, bestStreak: best)
    }
    
    func placeholder() -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            pendingHabits: [
                HabitSnapshot(id: UUID(), nombre: "Beber agua", completado: false),
                HabitSnapshot(id: UUID(), nombre: "Caminar 20 min", completado: true),
                HabitSnapshot(id: UUID(), nombre: "Leer 10 min", completado: false)
            ],
            streak: 5,
            bestStreak: 12
        )
    }
}
