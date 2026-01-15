# Feature: Sugerencias

## Descripción

La feature de Sugerencias ofrece a los usuarios un catálogo curado e inteligente de hábitos predefinidos para inspirar y facilitar la creación de nuevas rutinas. Al pulsar el icono de "bombilla", el sistema presenta una biblioteca de hábitos organizados por categorías y dificultad, filtrando automáticamente aquellos que el usuario ya tiene activos.

## Características Principales

- **Biblioteca Curada**: Más de 50 hábitos predefinidos y variados.
- **Categorización Temática**: Organización por áreas (Salud, Productividad, Mindfulness, etc.).
- **Niveles de Dificultad**: Indicadores visuales de esfuerzo (Fácil, Medio, Desafiante).
- **Filtrado Inteligente**: No sugiere hábitos que ya existen en tu lista.
- **Impacto Motivacional**: Cada sugerencia incluye una descripción del beneficio ("Por qué hacerlo").
- **Añadido Rápido**: Integración en un solo toque para añadir a "Mis Hábitos".
- **Feedback Visual**: Sistema de tarjetas con colores y emojis temáticos.

## Categorías Disponibles

| Categoría | Emoji | Enfoque | Color UI |
|-----------|-------|---------|----------|
| Salud | ❤️ | Bienestar físico y alimentación | Verde |
| Productividad | ⚡️ | Eficiencia y organización | Azul |
| Mindfulness | 🧘 | Salud mental y desconexión | Púrpura |
| Finanzas | 💰 | Ahorro y gestión económica | Amarillo |
| Hogar | 🏠 | Orden y limpieza | Naranja |

## Arquitectura SPL

Esta feature sigue el patrón de Software Product Line (SPL). Aunque se integra visualmente en la lista de hábitos, su lógica está desacoplada mediante protocolos, permitiendo que el módulo de sugerencias funcione independientemente de la implementación concreta del almacenamiento de datos.

### Estructura de Archivos

```
Features/
└── Sugerencias/
    ├── Models/
    │   └── SuggestionInfo.swift       
    ├── Services/
    │   ├── SuggestionGenerator.swift  
    │   └── HabitDataStore+Suggestions.swift 
    ├── ViewModels/
    │   └── SuggestionViewModel.swift  
        ├── SuggestionCardView.swift   
        ├── SuggestionListView.swift   
        └── SugerenciasPlugin.swift    
```

## Componentes

### 1. SuggestionInfo (Model)

Modelo que representa la información inmutable de una sugerencia:

```swift
public struct SuggestionInfo: Identifiable, Codable {
    public let id: UUID
    public let nombre: String
    public let frecuencia: Frecuencia
    public let categoria: SuggestionCategory
    public let impacto: String          
    public let nivelDificultad: Int     
    
    public var descripcionDificultad: String { ... }
    public var colorName: String { ... }
}
```

### 2. SuggestionCategory (Enum)

Define las temáticas disponibles y sus representaciones visuales:

```swift
public enum SuggestionCategory: String, Codable, CaseIterable {
    case salud, productividad, mindfulness, finanzas, hogar
    
    var emoji: String { ... }
}
```

### 3. SuggestionGenerator (Service)

Actúa como el repositorio de datos. Contiene la biblioteca estática de hábitos (Hardcoded Data) y la lógica de filtrado.

- `obtenerSugerencias(excluyendo: [Habit])`: Devuelve la lista de sugerencias eliminando las que coinciden por nombre con los hábitos existentes del usuario.
- `bibliotecaSugerencias`: Array privado con los 50+ hábitos predefinidos.

### 4. SuggestionViewModel (ViewModel)

Gestiona el estado de la UI y la comunicación entre la vista y el generador.

- **Dependencia**: Usa el protocolo `HabitSuggestionHandler` en lugar de una clase concreta.
- `cargarSugerencias()`: Simula una carga asíncrona y aplica el filtro.
- `aceptarSugerencia(_:)`: Convierte un `SuggestionInfo` en un `Habit` real y lo guarda.
- `descartarSugerencia(_:)`: Elimina la tarjeta de la lista visualmente.

### 5. Views

**SuggestionCardView**: Tarjeta visualmente rica que muestra:
- Icono de categoría
- Nombre y Frecuencia
- Texto de impacto (motivación)
- Barra de dificultad
- Botones de acción (Añadir/Descartar)

**SuggestionListView**: Vista modal (Sheet) que presenta el grid o lista de tarjetas. Maneja estados de carga (`isLoading`) y estados vacíos.

## Integración con el Core

La integración se realiza mediante el patrón Protocol Witness para evitar dependencias circulares fuertes.

### Protocolo de Manejo

Definido en el módulo de sugerencias para especificar qué necesita del Core:

```swift
public protocol HabitSuggestionHandler {
    func addHabit(_ habit: Habit)
    var habits: [Habit] { get }
}
```

### Implementación en el Core (HabitDataStore+Suggestions.swift)

El HabitDataStore principal se conforma a este protocolo mediante una extensión:

```swift
extension HabitDataStore: HabitSuggestionHandler {
    @MainActor
    public func addHabit(_ habit: Habit) {
        self.habits.append(habit)
        Task {
            await self.generateTodayInstances()
            await self.saveData()
        }
    }
}
```

### Modificaciones a las Vistas Principales

**HabitsListView**: Se añade un botón (Bombilla) en la toolbar y un modificador `.sheet` para presentar la vista:

```swift
.sheet(isPresented: $showingSuggestions) {
    SuggestionListView(habitHandler: dataStore)
}
```

## Configuración

**PluginManager**: La feature puede ser controlada mediante flags en el PluginManager o AppConfig si se desea desactivar globalmente, aunque por defecto está integrada en la vista de lista.

## Uso

### Flujo de Usuario

1. El usuario navega a la pestaña "Hábitos".
2. Toca el icono de la bombilla amarilla 💡 en la barra superior.
3. Se abre una modal con "Inspiración para ti".
4. El usuario explora tarjetas como "Beber 2L de agua" o "Leer 15 min".
5. Al tocar el botón (+):
   - El hábito se crea en la base de datos principal.
   - Aparece un mensaje de confirmación ("¡Hábito añadido!").
   - La tarjeta desaparece de la lista de sugerencias.
6. Al tocar el botón (x), la sugerencia se descarta temporalmente de la vista.

### Persistencia

- **Origen**: Las sugerencias son estáticas (in-memory) en `SuggestionGenerator`. No requieren persistencia propia.
- **Destino**: Al aceptar una sugerencia, se convierte en un objeto `Habit` estándar y se persiste en `habits.json` a través del `HabitDataStore` del Core.

## Consideraciones

- **Sin Duplicados**: El sistema normaliza los nombres (lowercased) para evitar sugerir "Meditar" si el usuario ya tiene "meditar".
- **Rendimiento**: La lista se carga en un hilo secundario y se presenta en el MainActor para no bloquear la UI.
- **Escalabilidad**: Añadir nuevas sugerencias es tan sencillo como agregar una línea en el array `bibliotecaSugerencias` del Generador.

## Compatibilidad

- **iOS**: 15.0+ (Uso de Task, Async/Await y modificadores de vista modernos)
- **Swift**: 5.5+
- **Dependencias**:
  - Core Models (Habit, Frecuencia)
  - Protocolo ObservableObject para el ViewModel