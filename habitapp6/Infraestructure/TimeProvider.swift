import Foundation

// MARK: - Protocolo

/// Protocolo para abstraer el tiempo - permite testing y demos
protocol TimeProviding {
    var now: Date { get }
    var calendar: Calendar { get }
}

// MARK: - Implementación Real

/// Implementación real para producción
class RealTimeProvider: TimeProviding {
    static let shared = RealTimeProvider()
    
    var now: Date { Date() }
    var calendar: Calendar { .current }
}

// MARK: - Implementación Demo

/// Implementación para demos - permite "viajar en el tiempo"
class DemoTimeProvider: TimeProviding, ObservableObject {
    static let shared = DemoTimeProvider()
    
    @Published var simulatedDate: Date = Date()
    var calendar: Calendar { .current }
    
    var now: Date { simulatedDate }
    
    /// Avanza el tiempo simulado X días
    func advanceDays(_ days: Int) {
        simulatedDate = calendar.date(byAdding: .day, value: days, to: simulatedDate) ?? simulatedDate
    }
    
    /// Retrocede el tiempo simulado X días
    func goBackDays(_ days: Int) {
        advanceDays(-days)
    }
    
    /// Resetea al tiempo real
    func reset() {
        simulatedDate = Date()
    }
    
    /// Establece una fecha específica
    func setDate(_ date: Date) {
        simulatedDate = date
    }
}

// MARK: - Configuración Global

/// Singleton que controla qué proveedor de tiempo usar
class TimeConfiguration: ObservableObject {
    static let shared = TimeConfiguration()
    
    /// Cambia a true para modo demo
    @Published var isDemoMode: Bool = false
    
    var provider: TimeProviding {
        isDemoMode ? DemoTimeProvider.shared : RealTimeProvider.shared
    }
    
    /// Atajo para obtener la fecha actual según el modo
    var now: Date {
        provider.now
    }
}
