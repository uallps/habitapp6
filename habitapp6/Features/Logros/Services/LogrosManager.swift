

import Foundation
import Combine

@MainActor
class LogrosManager: ObservableObject {
    
    static let shared = LogrosManager()
    
    @Published private(set) var logros: [Logro] = []
    @Published var logrosRecienDesbloqueados: [Logro] = []
    
    private let fileURL: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsPath.appendingPathComponent("logros_demo.json")
        
        Task { await loadLogros() }
    }
    
    func loadLogros() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Logro].self, from: data)
            self.logros = mergeLogros(saved: decoded)
        } catch {
            self.logros = TipoLogro.allCases.map {
                Logro(tipo: $0, progresoTotal: getObjetivo(para: $0))
            }
        }
    }
    
    func saveLogros() {
        do {
            let data = try JSONEncoder().encode(logros)
            try data.write(to: fileURL)
        } catch {
            print("❌ Error guardando logros: \(error)")
        }
    }
    
    private func mergeLogros(saved: [Logro]) -> [Logro] {
        var merged: [Logro] = []
        for tipo in TipoLogro.allCases {
            if let existing = saved.first(where: { $0.tipo == tipo }) {
                merged.append(existing)
            } else {
                merged.append(Logro(tipo: tipo, progresoTotal: getObjetivo(para: tipo)))
            }
        }
        return merged
    }
    
    private func getObjetivo(para tipo: TipoLogro) -> Int {
        switch tipo {
        case .primerHabito: return 1
        case .multicreator: return 3
        case .primeraAccion: return 1
        case .rachaExpress: return 3
        case .imparable: return 5
        }
    }
    
    // MARK: - EL CEREBRO DE LA DEMO
    func verificarLogros(habitos: [Habit], instancias: [HabitInstance]) {
        var huboCambios = false
        var nuevos: [Logro] = []
        
        let totalHabitosCreados = habitos.count
        let totalCompletados = instancias.filter { $0.completado }.count
        
        for index in logros.indices {
            if logros[index].desbloqueado { continue }
            
            var nuevoProgreso = 0
            
            switch logros[index].tipo {
            case .primerHabito:
                nuevoProgreso = totalHabitosCreados
            case .multicreator:
                nuevoProgreso = totalHabitosCreados
            case .primeraAccion, .rachaExpress, .imparable:
                nuevoProgreso = totalCompletados
            }
            
            if nuevoProgreso != logros[index].progresoActual {
                logros[index].progresoActual = min(nuevoProgreso, logros[index].progresoTotal)
                huboCambios = true
            }
            
            if nuevoProgreso >= logros[index].progresoTotal {
                logros[index].desbloqueado = true
                logros[index].fechaDesbloqueo = Date()
                nuevos.append(logros[index])
                huboCambios = true
            }
        }
        
        if huboCambios { saveLogros() }
        if !nuevos.isEmpty { self.logrosRecienDesbloqueados.append(contentsOf: nuevos) }
    }
    
    func limpiarRecienDesbloqueados() {
        logrosRecienDesbloqueados.removeAll()
    }
    
    func debugResetearTodo() {
        self.logros = TipoLogro.allCases.map {
            Logro(tipo: $0, progresoTotal: getObjetivo(para: $0))
        }
        saveLogros()
    }
    
    func debugForzarDesbloqueo(tipo: TipoLogro) {
        if let index = logros.firstIndex(where: { $0.tipo == tipo }) {
            logros[index].desbloqueado = true
            logros[index].progresoActual = logros[index].progresoTotal
            logros[index].fechaDesbloqueo = Date()
            logrosRecienDesbloqueados.append(logros[index])
            saveLogros()
        }
    }
}
