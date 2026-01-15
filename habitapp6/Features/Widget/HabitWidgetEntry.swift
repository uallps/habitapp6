import WidgetKit
import Foundation

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let pendingHabits: [HabitSnapshot]
    let streak: Int
    let bestStreak: Int
}

struct HabitSnapshot: Identifiable, Hashable {
    let id: UUID
    let nombre: String
    let completado: Bool
}