import Foundation

struct ListarHabitos {
  var clasificarHabitos : Bool
  var marcarEstadoHabito : Bool
  var editarHabito : EditarHabito

  // Opcionales
    var anadirNota: Bool? = nil
    var previsualizarCalendario: Bool? = nil
}
