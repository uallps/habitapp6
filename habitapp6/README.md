# Feature: Recordatorios

## Descripción

La feature de **Recordatorios** permite a los usuarios configurar notificaciones locales para sus hábitos. Cuando un hábito tiene recordatorios activos, el sistema envía una notificación X horas antes de que termine el período del hábito (día para hábitos diarios, semana para hábitos semanales).

## Arquitectura SPL

Esta feature sigue el patrón de **Software Product Line (SPL)**, permitiendo que sea activada o desactivada sin afectar el core de la aplicación.

### Estructura de Archivos

```
Features/
└── Recordatorios/
    ├── Models/
    │   └── RecordatorioManager.swift      # Modelo de configuración
    ├── ViewModels/
    │   └── RecordatorioViewModel.swift    # Lógica de negocio
    ├── Views/
    │   ├── RecordatorioConfigView.swift   # Vista de configuración
    │   └── RecordatorioBadgeView.swift    # Componentes visuales
    └── Services/
        └── NotificationService.swift       # Servicio de notificaciones
```

## Componentes

### 1. RecordatorioManager (Model)

Modelo que almacena la configuración de recordatorio de un hábito:

```swift
public class RecordatorioManager: Codable {
    public var activo: Bool                    // Recordatorio habilitado
    public var horaRecordatorio: Date          // Hora preferida
    public var horasAnticipacion: Int          // Horas antes del fin del período
    public var notificationIdentifier: String  // ID único para notificaciones
}
```

### 2. NotificationService (Service)

Servicio singleton que gestiona las notificaciones del sistema:

- `requestAuthorization()`: Solicita permisos de notificación
- `scheduleHabitReminder(for:instance:)`: Programa un recordatorio
- `cancelReminder(for:)`: Cancela recordatorios de un hábito
- `checkPendingNotifications()`: Lista notificaciones pendientes

### 3. RecordatorioViewModel (ViewModel)

Conecta el servicio con la UI:

- Gestiona el estado de autorización
- Permite activar/desactivar recordatorios
- Configura horas de anticipación
- Envía notificaciones de prueba

### 4. Views

- **RecordatorioConfigView**: Vista principal de configuración
- **RecordatorioBadgeView**: Badge para mostrar en listas
- **RecordatorioStatusView**: Estado detallado del recordatorio
- **RecordatorioQuickButton**: Botón de acceso rápido

## Lógica de Notificaciones

### Cuándo se envía la notificación

La notificación se programa para enviarse **X horas antes** del final del período del hábito:

- **Hábitos diarios**: X horas antes de medianoche
- **Hábitos semanales**: X horas antes del domingo a medianoche

Por defecto, X = 5 horas.

### Ejemplo

Un hábito diario con recordatorio de 5 horas:
- Fin del período: 23:59:59 del día actual
- Notificación programada: ~19:00 del mismo día

## Integración con el Core

### Modificaciones al modelo Habit

```swift
public class Habit {
    // ... propiedades existentes ...
    public var recordar: RecordatorioManager?
    
    // Helpers
    public var tieneRecordatorioActivo: Bool
    public func activarRecordatorio(horasAnticipacion: Int)
    public func desactivarRecordatorio()
}
```

### Modificaciones a las vistas

1. **HabitDetailView**: Añade sección de recordatorios
2. **HabitsListView**: Muestra badges de recordatorio

## Configuración de la App

### Info.plist

Asegúrate de añadir las siguientes claves para notificaciones:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### Permisos

El servicio solicita automáticamente permisos de notificación cuando el usuario intenta activar un recordatorio.

## Uso

### Activar recordatorio desde código

```swift
// Crear hábito con recordatorio
let habit = Habit(nombre: "Ejercicio", frecuencia: .diario)
habit.activarRecordatorio(horasAnticipacion: 5)

// Programar notificación
await NotificationService.shared.scheduleHabitReminder(for: habit, instance: instance)
```

### Activar desde UI

1. Ir a detalle del hábito
2. Tocar la sección "Recordatorio"
3. Activar toggle y configurar anticipación

## Testing

### Notificación de prueba

En modo DEBUG, la vista de configuración incluye un botón para enviar una notificación de prueba que llega en 5 segundos.

### Verificar notificaciones pendientes

```swift
let pending = await NotificationService.shared.checkPendingNotifications()
print("Notificaciones pendientes: \(pending.count)")
```

## Consideraciones

1. **Persistencia**: La configuración de recordatorios se guarda junto con el hábito en el DataStore
2. **Cancelación automática**: Los recordatorios se cancelan cuando se elimina un hábito
3. **Regeneración**: Al abrir la app, se reprograman los recordatorios activos
4. **Badge**: El icono de la app muestra un badge cuando hay recordatorios pendientes

## Dependencias

- `UserNotifications` framework (iOS/macOS)
- `Combine` para bindings reactivos
- Core de HabitTracker (Habit, HabitInstance, HabitDataStore)

## Compatibilidad

- iOS 14.0+
- macOS 11.0+
- Swift 5.0+
