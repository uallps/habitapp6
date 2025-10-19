# Sesión 3 - Diseño del Modelo y Diagrama de Características

## Diagrama de Características de HabitApp6

![Diagrama de características](img/DiagramaCaracterísticas.svg)

## Código del modelo

```swift
// Core

struct Habito {
  let id: UUID = UUID()
  var nombre: String
  var completado: Bool = false
}

struct ListarHabitos {
  var clasificarHabitos : Bool
  var marcarEstadoHabito : Bool
  var editarHabito : EditarHabito

  // Opcionales
    var anadirNota: Bool? = nil
    var previsualizarCalendario: Bool? = nil
}

struct EditarHabito {
    var descripcion: String? 
}

struct EliminarHabito {

}

struct CrearTipoHabito {

}

struct CrearTipoHabito {

}

struct AnadirHabito {
    var requiereEditarHabito: EditarHabito

    // Opcional
    var ofrecerOpcionesMasHabituales: Bool? = nil
}

struct Achievement {
  
}


```