import Foundation
import SwiftUI

class AppConfig: ObservableObject {
    @AppStorage("activarRecordatorios")
    var activarRecordatorios: Bool = true
    
#if PREMIUM

#else
    
#endif
    
}

