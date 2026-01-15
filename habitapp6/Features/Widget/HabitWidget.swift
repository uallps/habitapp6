import WidgetKit
import SwiftUI

struct HabitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetDataSource.shared.placeholder()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        Task {
            completion(await HabitWidgetDataSource.shared.loadSnapshot())
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        Task {
            let entry = await HabitWidgetDataSource.shared.loadSnapshot()
            // Refresh every 30 minutes
            let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

@main
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Hábitos de hoy")
        .description("Muestra tus pendientes y la racha actual.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}