import Foundation

/// Thin reader that reuses your storage + calculator.
/// For real data, point `storageProvider` to the same persistence you use in-app.
/// Without an App Group, the widget sandbox will need a mirrored file (e.g., JSON export).
struct HabitWidgetDataSource {
    static let shared = HabitWidgetDataSource()
    
    private let storageProvider: StorageProvider
    private let calendar = Calendar.current
    
    init(storageProvider: StorageProvider = JSONStorageProvider.shared) {
        self.storageProvider = storageProvider
    }
    
    func loadSnapshot() async -> HabitWidgetEntry {
        do {
            let habits = try await storageProvider.loadHabits()
            let instances = try await storageProvider.loadInstances()
            
            // Pending habits for “today” (daily) or current week (weekly)
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
            
            // Simple streak from first habit (or 0 if none)
            let streak: Int
            let best: Int
            if let first = habits.first {
                let info = RachaCalculator.shared.calcularRacha(para: first, instancias: instances)
                streak = info.rachaActual
                best = info.mejorRacha
            } else {
                streak = 0; best = 0
            }
            
            return HabitWidgetEntry(date: Date(), pendingHabits: pending, streak: streak, bestStreak: best)
        } catch {
            return placeholder()
        }
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