# Feature: Metas

## Descripción

La feature de **Metas** permite a los usuarios definir objetivos específicos para sus hábitos. Una meta consiste en completar un hábito una cierta cantidad de veces dentro de un período de tiempo determinado. Por ejemplo, "Correr 100 veces este año" o "Meditar 30 veces este mes".

## Características Principales

- **Períodos Flexibles**: Desde 1 semana hasta 1 año
- **Objetivos Ajustables**: Define cuántas veces quieres completar el hábito
- **Barra de Progreso**: Visualiza tu avance hacia la meta
- **Múltiples Metas por Hábito**: Un hábito puede tener cero, una o muchas metas
- **Historial de Metas**: Las metas completadas se mantienen como registro
- **Felicitaciones**: Mensaje de celebración al completar una meta

## Períodos de Tiempo Disponibles

| Período | Duración | Tipo de Plazo |
|---------|----------|---------------|
| 1 Semana | 7 días | Corto plazo |
| 1 Mes | 30 días | Medio-corto plazo |
| 3 Meses | 90 días | Medio plazo |
| 6 Meses | 180 días | Largo plazo |
| 9 Meses | 270 días | Largo plazo |
| 1 Año | 365 días | Muy largo plazo |

## Arquitectura SPL

Esta feature sigue el patrón de **Software Product Line (SPL)**, permitiendo que sea activada o desactivada sin afectar el core de la aplicación.

### Estructura de Archivos

```
Features/
└── Metas/
    ├── Models/
    │   └── Meta.swift                 # Modelo de meta y tipos relacionados
    ├── ViewModels/
    │   └── MetaViewModel.swift        # Lógica de negocio
    ├── Views/
    │   ├── MetaBadgeView.swift        # Badges y chips
    │   ├── CrearMetaView.swift        # Formulario de creación
    │   ├── MetaDetailView.swift       # Detalle con barra de progreso
    │   ├── MetasListView.swift        # Lista de metas
    │   └── MetaFelicitacionView.swift # Celebración de logros
    ├── Services/
    │   └── MetaDataStore.swift        # Persistencia de datos
    └── MetasPlugin.swift              # Plugin SPL principal
```

## Componentes

### 1. Meta (Model)

Modelo que representa una meta de hábito:

```swift
public class Meta: Identifiable, Codable {
    public let id: UUID
    public let habitID: UUID
    public var nombre: String
    public var descripcion: String
    public var objetivo: Int                    // Veces a completar
    public var periodo: PeriodoMeta             // Duración
    public var fechaInicio: Date
    public var fechaFin: Date
    public var estado: EstadoMeta               // activa/completada/fallida/cancelada
    public var fechaCompletado: Date?
}
```

### 2. PeriodoMeta (Enum)

Define los períodos de tiempo disponibles:

```swift
enum PeriodoMeta: String, CaseIterable, Codable {
    case semana = "1_semana"
    case mes = "1_mes"
    case tresMeses = "3_meses"
    case seisMeses = "6_meses"
    case nueveMeses = "9_meses"
    case año = "1_año"
}
```

### 3. EstadoMeta (Enum)

Estados posibles de una meta:

```swift
enum EstadoMeta: String, Codable {
    case activa       // En progreso
    case completada   // Objetivo alcanzado
    case fallida      // Período terminó sin alcanzar objetivo
    case cancelada    // Cancelada por el usuario
}
```

### 4. MetaDataStore (Service)

Gestión de persistencia de metas:

- `loadMetas()`: Carga metas desde JSON
- `saveMetas()`: Guarda metas en JSON
- `addMeta(_:)`: Añade nueva meta
- `updateMeta(_:)`: Actualiza meta existente
- `deleteMeta(_:)`: Elimina una meta
- `verificarEstadoMetas(instancias:)`: Verifica si hay metas completadas o expiradas

### 5. MetaViewModel (ViewModel)

Gestiona la lógica de UI:

- `crearMeta(nombre:descripcion:objetivo:periodo:)`: Crea nueva meta
- `eliminarMeta(_:)`: Elimina una meta
- `cancelarMeta(_:)`: Cancela meta activa
- `progreso(para:)`: Obtiene progreso de una meta

### 6. Views

- **MetaBadgeView**: Badge mostrando número de metas activas
- **CrearMetaView**: Formulario para crear nueva meta con:
  - Selector de período
  - Slider para objetivo
  - Sugerencias basadas en la frecuencia del hábito
  - Resumen con cálculo de ritmo necesario
- **MetaDetailView**: Detalle completo con:
  - Barra de progreso circular
  - Estadísticas (completadas, días restantes, ritmo)
  - Información del período
  - Acciones (cancelar, eliminar)
- **MetasListView**: Lista filtrable (activas/completadas/todas)
- **MetaFelicitacionView**: Overlay de celebración

## Integración con el Core

### Plugin de Metas

```swift
@MainActor
class MetasPlugin: DataPlugin {
    // Implementa todos los métodos del protocolo DataPlugin
    func didToggleInstance(_ instance: HabitInstance, habit: Habit) async {
        // Verifica si alguna meta se completó
    }
    
    func didDeleteHabit(habitId: UUID) async {
        // Elimina metas del hábito eliminado
    }
}
```

### Modificaciones a las Vistas

1. **HabitDetailView**: Añade sección de metas
2. **TodayView**: Muestra badges de metas y felicitaciones

## Configuración

### AppConfig

```swift
/// Habilita/deshabilita la feature de Metas
@Published var showMetas: Bool
```

### PluginManager

```swift
/// Plugin de Metas
@Published private(set) var metasPlugin: MetasPlugin?

/// Verifica si la feature de Metas está habilitada
var isMetasEnabled: Bool {
    config.showMetas
}
```

## Uso

### Crear una meta desde código

```swift
let meta = Meta(
    habitID: habit.id,
    nombre: "Correr 100 veces",
    descripcion: "Meta anual de running",
    objetivo: 100,
    periodo: .año
)
await MetaDataStore.shared.addMeta(meta)
```

### Verificar progreso

```swift
let progreso = meta.calcularProgreso(instancias: dataStore.instances)
print("Completadas: \(progreso.completadas) de \(progreso.objetivo)")
print("Porcentaje: \(progreso.porcentajeFormateado)")
```

### Crear desde UI

1. Ir al detalle del hábito
2. En la sección "Metas", tocar "Crear primera meta" o "Ver todas las metas"
3. Configurar nombre, período y objetivo
4. Tocar "Crear"

## Flujo de Completado

1. Usuario completa una instancia del hábito
2. `TodayViewModel.toggleInstance()` actualiza la instancia
3. Se notifica a `MetasPlugin.didToggleInstance()`
4. `MetaDataStore.verificarEstadoMetas()` recalcula progresos
5. Si una meta alcanza 100%, se marca como completada
6. `MetasCompletadasViewModel` recibe la notificación
7. `MetaFelicitacionView` muestra el overlay de celebración

## Persistencia

Las metas se guardan en un archivo JSON independiente:

- Ubicación: `Documents/metas.json`
- Formato: JSON con codificación ISO8601 para fechas

```json
[
  {
    "id": "uuid-1",
    "habitID": "uuid-habit",
    "nombre": "Correr 100 veces",
    "objetivo": 100,
    "periodo": "1_año",
    "estado": "activa",
    "fechaInicio": "2024-01-01T00:00:00Z",
    "fechaFin": "2025-01-01T00:00:00Z"
  }
]
```

## Consideraciones

1. **Independencia**: Las metas se almacenan por separado de los hábitos
2. **Limpieza**: Al eliminar un hábito, se eliminan sus metas asociadas
3. **Historial**: Las metas completadas/fallidas se mantienen como registro
4. **Sin modificación**: Una vez creada, solo se puede cancelar o eliminar
5. **Progreso**: Se calcula dinámicamente contando instancias completadas

## Compatibilidad

- iOS 14.0+
- macOS 11.0+
- Swift 5.0+

## Dependencias

- Core de HabitTracker (Habit, HabitInstance, HabitDataStore)
- SwiftUI
- Combine (para bindings reactivos)
