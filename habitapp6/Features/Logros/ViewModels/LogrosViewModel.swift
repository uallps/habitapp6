
import Foundation
import Combine

@MainActor
class LogrosViewModel: ObservableObject {
    
    @Published var logros: [Logro] = []
    @Published var showingFelicitacion = false
    @Published var logroParaMostrar: Logro?
    
    private let manager = LogrosManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        manager.$logros
            .assign(to: \.logros, on: self)
            .store(in: &cancellables)
            
        // Escuchar nuevos desbloqueos
        manager.$logrosRecienDesbloqueados
            .sink { [weak self] nuevos in
                if let primero = nuevos.first {
                    self?.logroParaMostrar = primero
                    self?.showingFelicitacion = true
                }
            }
            .store(in: &cancellables)
    }
    
    func cerrarFelicitacion() {
        showingFelicitacion = false
        logroParaMostrar = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.manager.limpiarRecienDesbloqueados()
        }
    }
    
    var desbloqueadosCount: Int { logros.filter { $0.desbloqueado }.count }
    var totalCount: Int { logros.count }
    
    func resetearParaDemo() {
        manager.debugResetearTodo()
    }
    
    func simularLogro(_ tipo: TipoLogro) {
        manager.debugForzarDesbloqueo(tipo: tipo)
    }
}
