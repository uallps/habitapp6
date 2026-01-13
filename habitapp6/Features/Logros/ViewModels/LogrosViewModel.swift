
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
    }
    
    func cerrarFelicitacion() {
        showingFelicitacion = false
        logroParaMostrar = nil
    }
    
    var desbloqueadosCount: Int { logros.filter { $0.desbloqueado }.count }
    var totalCount: Int { logros.count }
}
