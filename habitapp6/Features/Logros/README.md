# Feature: Logros

## Descripción

La feature de Logros introduce un sistema de recompensas en la aplicación HabitApp. Su objetivo es aumentar la motivación de los usuarios mediante medallas que se desbloquean automáticamente al cumplir ciertas acciones de la aplicación, como la creación de hábitos, completar tareas o el mantenimiento de rachas.

## Características Principales

- **Detección Automática**: El usuario no crea los logros; el sistema detecta sus acciones y los desbloquea.
- **Categorías de Éxito**: Logros basados en Creación, Acción (Completar tareas) y Rachas.
- **Feedback Inmediato**: Sistema de alertas globales que notifican al usuario en el momento exacto del desbloqueo.
- **Progreso Visual**: Indicadores de progreso (ej. "1/3") y barras de estado en las tarjetas de logros.


## Catálogo de Logros Disponibles

| Categoría | Logro (ID)    | Título          | Requisito                       |
|-----------|---------------|-----------------|---------------------------------|
| Creación  | creador_1     | El Comienzo     | Crear 1 hábito.                 |
| Creación  | creador_3     | Arquitecto      | Tener 3 hábitos creados.        |
| Acción    | accion_1      | Primer Paso     | Completar 1 tarea (check).      |
| Acción    | accion_3      | Constante       | Completar 3 tareas en total.    |
| Acción    | accion_5      | Experto         | Completar 5 tareas en total.    |
| Racha     | racha_1       | Buena Racha     | Conseguir 1 día de racha.       |

## Arquitectura SPL

Esta feature sigue el patrón de Software Product Line (SPL) y Arquitectura de Plugins. Se inyecta en el núcleo de la aplicación sin acoplamiento fuerte, escuchando eventos a través del PluginManager.

### Estructura de Archivos
```
Features/
└── Logros/
    ├── Models/
    │   └── LogrosModel.swift          # Definición de Logro y Enum TipoLogro
    ├── ViewModels/
    │   └── LogrosViewModel.swift      # Lógica de presentación para la vista
    ├── Views/
    │   ├── LogrosView.swift           # Pantalla principal de rejilla
    │   ├── LogroCard.swift            # Componente visual de tarjeta
    │   └── FelicitacionCard.swift     # Componente visual del Pop-up
    ├── Services/
    │   └── LogrosManager.swift        # Lógica de negocio y persistencia 
        └── LogrosPlugin.swift             # Conector SPL 
```

## Componentes

### 1. Logro (Model)

Modelo de datos que representa una medalla:
```swift
public struct Logro: Identifiable, Codable, Equatable {
    public let id: String
    public let tipo: TipoLogro
    public var desbloqueado: Bool
    public var fechaDesbloqueo: Date?
    public var progresoActual: Int
    public var progresoTotal: Int
}
```

### 2. TipoLogro (Enum)

Define la configuración estática de cada logro (título, descripción, icono, color y meta):
```swift
public enum TipoLogro: String, Codable, CaseIterable {
    case primerHabito, constructor      
    case primeraAccion, constante, experto 
    case inicioRacha                    
}
```

### 3. LogrosManager (Service)

El cerebro de la feature. Es un Singleton (@MainActor) encargado de:

- **Persistencia**: Carga (`loadLogros`) y guarda (`saveLogros`) el estado en JSON.
- **Lógica de Verificación**:
  - `chequearCreacion(cantidadHabitos:)`: Verifica logros de tipo Creador.
  - `chequearAccion(cantidadChecks:maxRacha:)`: Verifica logros de Acción y Racha.
- **Gestión de Alertas**: Administra la cola `logrosRecienDesbloqueados` y provee el método `consumirPrimerLogro()` para evitar alertas duplicadas.

### 4. LogrosPlugin (Plugin)

El adaptador que implementa el protocolo `DataPlugin` del núcleo:
```swift
@MainActor
class LogrosPlugin: DataPlugin {
    // Intercepta eventos del Core
    func didCreateHabit(_ habit: Habit) async {
        // Llama a manager.chequearCreacion
    }
    
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        // Calcula métricas y llama a manager.chequearAccion
    }
    
    // Provee enlace a la UI
    func settingsLink() -> some View { ... }
}
```

### 5. Views

- **LogrosView**: Vista principal con una rejilla que muestra todas las medallas. Diferencia visualmente entre logros bloqueados (grises y con un candado) y desbloqueados (color + icono).
- **FelicitacionCardPopUp**: Overlay modal que aparece sobre ContentView para celebrar un logro recién desbloqueado.

## Integración con el Core

### Flujo de Activación

1. **Configuración**: `AppConfig.shared.showLogros` controla si la feature está activa.
2. **PluginManager**: Si el flag está activo, PluginManager instancia LogrosPlugin y reenvía los eventos (`didCreateHabit`, `didToggleInstance`) a este plugin.

### Flujo de Desbloqueo (Ejemplo: Crear Hábito)

1. Usuario toca "Crear" en `CreateHabitViewModel`.
2. El ViewModel guarda el hábito y llama a `await PluginManager.shared.didCreateHabit(newHabit)`.
3. PluginManager detecta que `isLogrosEnabled` es true y avisa a LogrosPlugin.
4. LogrosPlugin obtiene el conteo total de hábitos y llama a `LogrosManager.chequearCreacion()`.
5. LogrosManager verifica si se cumple el requisito (ej. Total >= 1).
6. Si se cumple:
   - Marca el logro como desbloqueado.
   - Guarda en JSON.
   - Añade el logro a la cola `logrosRecienDesbloqueados`.
7. ContentView (que observa al Manager) detecta el cambio, consume el logro de la cola y muestra la `FelicitacionCardPopUp`.

## Persistencia

Los datos de los logros se almacenan de forma independiente al CoreData de la aplicación para mantener el desacoplamiento.

- **Ubicación**: `Documents/logros_vFinal_Fix.json` (nombre interno del archivo).
- **Formato**: Array JSON de objetos Logro.
- **Estrategia**: Al iniciar la app, si el archivo existe se carga el estado (desbloqueados/progreso). Si no existe, se genera una lista inicial bloqueada basada en el enum `TipoLogro`.

### Ejemplo JSON
```json
[
  {
    "id": "creador_1",
    "tipo": "creador_1",
    "desbloqueado": true,
    "progresoActual": 1,
    "progresoTotal": 1,
    "fechaDesbloqueo": 695843210.0
  }
]
```

## Consideraciones Técnicas

- **Concurrencia**: Todo el manejo de estado se realiza en el `@MainActor` para garantizar la seguridad de hilos y la actualización fluida de la UI (SwiftUI).
- **Estabilidad**: Se ha desacoplado la lógica de escritura en CoreData (usando perform blocks) para evitar colisiones con la lectura de datos necesaria para verificar los logros.

## Dependencias

- **Core**: `Habit`, `HabitInstance`, `HabitDataStore` (para leer el estado actual).
- **Infraestructura**: `AppConfig`, `PluginManager`.
- **SwiftUI & Combine**: Para la interfaz reactiva y observación de eventos.