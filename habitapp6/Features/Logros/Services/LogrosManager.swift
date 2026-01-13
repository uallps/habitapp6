
import Foundation
import Combine

@MainActor
class LogrosManager: ObservableObject {
    static let shared = LogrosManager()
    
    @Published var logros: [Logro] = []
    @Published var logrosRecienDesbloqueados: [Logro] = []
    
    private init() {
        self.logros = TipoLogro.allCases.map { tipo in
            Logro(tipo: tipo, progresoTotal: getMeta(tipo))
        }
    }
    
    private func getMeta(_ tipo: TipoLogro) -> Int {
        switch tipo {
        case .primerHabito: return 1
        case .constructor: return 3
        case .primeraAccion: return 1
        case .constante: return 3
        case .experto: return 5
        case .inicioRacha: return 1
        }
    }
    
    func chequearCreacion(cantidadHabitos: Int) {
        actualizarLogro(tipo: .primerHabito, valorActual: cantidadHabitos)
        actualizarLogro(tipo: .constructor, valorActual: cantidadHabitos)
    }
    
    func chequearAccion(cantidadChecks: Int, maxRacha: Int) {
        actualizarLogro(tipo: .primeraAccion, valorActual: cantidadChecks)
        actualizarLogro(tipo: .constante, valorActual: cantidadChecks)
        actualizarLogro(tipo: .experto, valorActual: cantidadChecks)
        actualizarLogro(tipo: .inicioRacha, valorActual: maxRacha)
    }
    
    private func actualizarLogro(tipo: TipoLogro, valorActual: Int) {
        guard let index = logros.firstIndex(where: { $0.tipo == tipo }) else { return }
        
        if logros[index].desbloqueado { return }
        
        logros[index].progresoActual = min(valorActual, logros[index].progresoTotal)
        
        if valorActual >= logros[index].progresoTotal {
            logros[index].desbloqueado = true
            logros[index].fechaDesbloqueo = Date()
            
            if !self.logrosRecienDesbloqueados.contains(where: { $0.id == self.logros[index].id }) {
                DispatchQueue.main.async {
                    self.logrosRecienDesbloqueados.append(self.logros[index])
                }
            }
        }
    }
    
    func limpiarRecienDesbloqueados() {
        logrosRecienDesbloqueados.removeAll()
    }
    
    func consumirPrimerLogro() -> Logro? {
        guard !logrosRecienDesbloqueados.isEmpty else { return nil }
        return logrosRecienDesbloqueados.removeFirst()
    }
}
