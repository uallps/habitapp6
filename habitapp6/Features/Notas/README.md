# Feature: Notas

## Descripción

La feature de **Notas** permite a los usuarios documentar su progreso en hábitos mediante notas diarias de texto. Cada nota puede incluir reflexiones, observaciones, sensaciones y cualquier contexto relevante sobre cómo fue el progreso del hábito ese día. Las notas son completamente opcionales y ofrecen un espacio para la introspección y el seguimiento cualitativo del progreso.

## Arquitectura SPL

Esta feature sigue el patrón de **Software Product Line (SPL)**, permitiendo que sea activada o desactivada sin afectar el core de la aplicación.

### Estructura de Archivos

```
Features/
└── Notas/
    ├── Models/
    │   └── Nota.swift                     # Modelos de nota y estadísticas
    ├── ViewModels/
    │   └── NotaViewModel.swift            # Lógica de negocio
    ├── Views/
    │   ├── NotaBadgeView.swift            # Componentes visuales
    │   ├── NotaDetailView.swift           # Vista de detalle
    │   └── NotaEditorView.swift           # Editor de notas
    ├── Services/
    │   └── NotaStorage.swift              # Persistencia de notas
    └── NotasPlugin.swift                  # Plugin SPL
```

## Componentes

### 1. Nota (Model)

Modelo principal que representa una nota asociada a un hábito:

```swift
public struct Nota: Identifiable, Codable {
    public let id: UUID                     // Identificador único
    public let habitID: UUID                // Referencia al hábito
    public let fecha: Date                  // Fecha de la nota
    public var contenido: String            // Texto de la nota
    public let fechaCreacion: Date          // Cuándo se creó
    public var fechaModificacion: Date      // Última edición
    public var esImportante: Bool           // Marcada como importante
    public var tags: [String]               // Etiquetas para categorizar
}
```

### 2. NotaEstadisticas (Model)

Estructura que agrega estadísticas sobre las notas de un hábito:

```swift
public struct NotaEstadisticas: Codable {
    public let totalNotas: Int              // Total de notas
    public let notasImportantes: Int        // Notas marcadas importante
    public let totalPalabras: Int           // Palabras totales
    public let totalCaracteres: Int         // Caracteres totales
    public let diasConNotas: Int            // Días únicos con notas
    public let tagsPopulares: [String: Int] // Tags más usados
}
```

### 3. NotaFiltro (Model)

Estructura para filtrar y buscar notas:

```swift
public struct NotaFiltro {
    public var rangoFechas: ClosedRange<Date>?  // Filtro por rango de fechas
    public var soloImportantes: Bool             // Solo notas importantes
    public var tags: [String]                    // Filtrar por tags
    public var textoBusqueda: String?            // Búsqueda de texto
    public var habitIDs: [UUID]                  // Filtro por hábitos
}
```

### 4. NotaStorage (Service)

Servicio singleton que gestiona la persistencia de notas en almacenamiento local (JSON):

**Métodos principales:**
- `guardarNota(_:)`: Crea o actualiza una nota
- `obtenerNota(id:)`: Recupera una nota específica
- `obtenerNotas(habitID:)`: Todas las notas de un hábito
- `obtenerNotas(filtro:)`: Notas con filtros aplicados
- `eliminarNota(id:)`: Elimina una nota
- `calcularEstadisticas(habitID:)`: Genera estadísticas
- `obtenerNotaDelDia(habitID:fecha:)`: Nota de un día específico

**Características:**
- Persistencia automática en JSON
- Búsqueda y filtrado avanzado
- Cálculo de estadísticas en tiempo real
- Manejo de errores robusto

### 5. NotaViewModel (ViewModel)

Conecta el servicio con la UI y gestiona el estado:

**Propiedades Published:**
- `notas`: Lista de notas del hábito actual
- `notaActual`: Nota siendo editada o de hoy
- `estadisticas`: Estadísticas agregadas
- `textoEditor`: Contenido del editor
- `tagsDisponibles`: Tags sugeridos

**Métodos:**
- `cargarNotas()`: Carga las notas del hábito
- `guardarNotaActual()`: Persiste la nota en edición
- `eliminarNota(_:)`: Elimina una nota
- `toggleImportante(_:)`: Marca/desmarca como importante
- `agregarTag(_:aNota:)`: Añade un tag
- `buscarNotas(texto:)`: Búsqueda por texto
- `obtenerNotasPorTags(_:)`: Filtrado por tags

### 6. Views

#### **NotaBadgeView.swift**

Componentes visuales compactos para mostrar notas:

- **`NotaBadgeView`**: Badge indicador para listas
- **`NotaRowView`**: Vista de fila de hábito con detalles de nota de hoy
- **`NotaCompactView`**: Vista compacta para resúmenes
- **`NotaCardView`**: Card individual con contenido y acciones
- **`NotaPreviewView`**: Preview pequeño de nota
- **`NotasMiniCalendarView`**: Calendario de 7 días con indicadores

#### **NotaDetailView.swift**

Vista principal detallada de notas:

- Lista completa de notas del hábito
- Estadísticas visuales (total, importantes, palabras, caracteres, días)
- Búsqueda en tiempo real
- Filtros avanzados
- Empty state cuando no hay notas
- **`NotaDetailSheet`**: Sheet para ver nota completa con opciones de edición
- **`EstadisticaNotaItem`**: Item visual para estadísticas

#### **NotaEditorView.swift**

Editor de texto para crear/editar notas:

- Editor de texto con altura dinámica
- Contador de palabras y caracteres en tiempo real
- Sistema de tags con sugerencias automáticas
- Toggle de importancia
- Validación de contenido antes de guardar
- Botón rápido en teclado para finalizar edición

## Características Principales

### 1. **Notas Diarias**
Una nota por día por hábito. Si hay una nota existente para ese día, se actualiza en lugar de crear duplicado.

### 2. **Sistema de Tags**
- Agregar múltiples tags a cada nota
- Tags sugeridos basados en uso anterior
- Filtrado por tags
- Contador de tags populares

### 3. **Marcado de Importancia**
- Marcar notas como importantes
- Vista especial para notas importantes
- Indicador visual con estrella

### 4. **Estadísticas**
- Total de notas
- Notas importantes
- Total de palabras y caracteres
- Días con notas
- Tags más populares
- Fecha de primera y última nota

### 5. **Búsqueda y Filtrado**
- Búsqueda de texto en tiempo real
- Filtro por rango de fechas
- Filtro por tags
- Filtro por importancia
- Combinación de múltiples filtros

### 6. **Visualización**
- Calendario de 7 días con indicadores
- Previews del contenido (primeros 100 caracteres)
- Información de edición (si fue editada)
- Contador de palabras y caracteres por nota

### 7. **Persistencia**
- Almacenamiento local en JSON
- Carga automática al iniciar
- Sincronización automática con cambios

## Integración con el Core

### Modificaciones al modelo Habit

Se asume que el modelo `Habit` ya existe en el core. Las notas se referencian por `habitID`:

```swift
public class Habit {
    // ... propiedades existentes ...
    public var id: UUID        // Necesario para asociar notas
    public var nombre: String
    public var frecuencia: Frecuencia
}
```

### Integración en vistas

1. **HabitDetailView**: Añade sección de notas con:
   - Botón rápido para crear/editar nota de hoy
   - Mini calendario de últimos 7 días
   - Contador de notas

2. **HabitsListView**: Muestra badges indicadores en filas de hábitos

3. **ContentView/TodayView**: Puede incluir notaCompactView para nota diaria

## Configuración de la App

### Estructura de carpetas requerida

Asegúrate de que existan las siguientes carpetas en `Features/Notas/`:

```
Features/Notas/
├── Models/          (✓ creada)
├── Services/        (✓ creada)
├── ViewModels/      (✓ creada)
├── Views/           (✓ creada)
└── README.md        (este archivo)
```

### Almacenamiento

Las notas se guardan en:
```
~/Documents/notas.json
```

## Uso

### Crear una nota desde código

```swift
// Crear nueva nota
let nota = Nota(
    habitID: habit.id,
    fecha: Date(),
    contenido: "Hoy tuve un gran entrenamiento"
)

// Guardar
try await NotaStorage.shared.guardarNota(nota)
```

### Crear desde UI

1. Ir a detalle del hábito
2. Tocar "Agregar nota de hoy" o el botón (+)
3. Escribir contenido
4. Agregar tags (opcional)
5. Marcar como importante (opcional)
6. Tocar "Guardar"

### Obtener notas de un hábito

```swift
let notas = try await NotaStorage.shared.obtenerNotas(habitID: habitID)
```

### Filtrar notas

```swift
let filtro = NotaFiltro(
    textoBusqueda: "ejercicio",
    soloImportantes: true,
    tags: ["motivado"]
)

let notasFiltradas = try await NotaStorage.shared.obtenerNotas(filtro: filtro)
```

### Calcular estadísticas

```swift
let stats = try await NotaStorage.shared.calcularEstadisticas(habitID: habitID)
print("Total notas: \(stats.totalNotas)")
print("Palabras: \(stats.totalPalabras)")
```

## Testing

### Crear datos de prueba

```swift
// En preview o debug
let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)

// Crear varias notas de prueba
for i in 0..<5 {
    let fecha = Date().addingTimeInterval(-TimeInterval(i * 86400))
    let nota = Nota(
        habitID: habit.id,
        fecha: fecha,
        contenido: "Nota de prueba #\(i)",
        tags: ["test", "debug"]
    )
    try await NotaStorage.shared.guardarNota(nota)
}
```

### Preview

Las vistas incluyen previews para testing en Xcode:

```swift
#if DEBUG
struct NotaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
            NotaDetailView(habit: habit)
        }
    }
}
#endif
```

## Consideraciones

### 1. **Privacidad de Datos**
Las notas se guardan localmente en el dispositivo. No se envían a servidores externos.

### 2. **Almacenamiento**
Las notas se persisten en JSON. Para proyectos grandes, considerar Core Data o SQLite.

### 3. **Rendimiento**
- Las búsquedas se hacen en memoria (suficiente para < 10,000 notas)
- Para aplicaciones a escala, implementar indexación

### 4. **Eliminación de Datos**
Cuando se elimina un hábito, automáticamente se eliminan sus notas asociadas (en el plugin).

### 5. **Límites de texto**
No hay límite técnico de caracteres, pero se recomienda mantener notas < 10,000 palabras para mejor UX.

### 6. **Sincronización**
Para múltiples dispositivos, extender `NotaStorage` para soportar CloudKit o Firebase.

## Dependencias

- **Foundation**: Para fecha, codificación JSON
- **SwiftUI**: Para toda la capa de UI
- **Combine**: Para bindings reactivos con `@Published`
- Core de HabitTracker:
  - `Habit`: Modelo de hábito
  - `HabitInstance`: Instancias completadas
  - `HabitDataStore`: Data store principal

## Compatibilidad

- **iOS**: 14.0+
- **macOS**: 11.0+
- **tvOS**: 14.0+
- **watchOS**: 7.0+
- **Swift**: 5.5+

## Roadmap Futuro

Posibles mejoras para versiones futuras:

- [ ] Exportar notas a PDF
- [ ] Sync con iCloud/CloudKit
- [ ] Búsqueda de texto completo
- [ ] Análisis de sentimiento
- [ ] Plantillas de notas
- [ ] Notas de voz (transcripción)
- [ ] Integración con fotos
- [ ] Notas colaborativas
- [ ] Historial de cambios
- [ ] Backup automático

## Soporte

Para reportar bugs o sugerir mejoras del feature de Notas, contacta al equipo de desarrollo.
