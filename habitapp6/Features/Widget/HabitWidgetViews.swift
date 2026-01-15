import SwiftUI
import WidgetKit

struct HabitWidgetView: View {
    let entry: HabitWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Hoy")
                    .font(.headline)
                Spacer()
                StreakChip(streak: entry.streak, best: entry.bestStreak)
            }
            
            // Habits list (up to 3)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.pendingHabits.prefix(3)) { habit in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(habit.completado ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                        Text(habit.nombre)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: habit.completado ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(habit.completado ? .green : .secondary)
                    }
                }
                if entry.pendingHabits.isEmpty {
                    Text("Sin hábitos pendientes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct StreakChip: View {
    let streak: Int
    let best: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill").foregroundColor(.orange)
            Text("\(streak)")
                .font(.headline)
            if best > 0 {
                Text(" / \(best)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
    }
}