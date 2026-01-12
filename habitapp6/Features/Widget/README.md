# Feature: Widget de Hábitos

## Descripción

El widget muestra los hábitos pendientes del día y la racha más alta, reutilizando los datos de la app. Lee un snapshot exportado por la aplicación y se refresca de forma periódica en pantalla de inicio.

## Características Principales

- **Pendientes de hoy**: Lista compacta (máx. 3) de hábitos activos y su estado.
- **Rachas**: Muestra racha actual y mejor racha agregada de todos los hábitos.
- **Actualización periódica**: Timeline con refresco cada 30 minutos.
- **Placeholder seguro**: Estado de reserva cuando no hay datos o permisos.
- **Fallback a JSON**: Si falta el snapshot, lee directamente de almacenamiento JSON.

## Arquitectura SPL

La feature está desacoplada del core mediante el exportador y un data source dedicado para el widget, sin afectar la lógica principal de la app.

### Estructura de Archivos

```
Features/
└── Widget/
    ├── HabitWidget.swift           # Declaración del widget y timeline provider
    ├── HabitWidgetEntry.swift      # Modelo de entrada para el timeline
    ├── HabitWidgetDataSource.swift # Lectura de snapshot / JSON y procesamiento
    ├── HabitWidgetViews.swift      # Vista SwiftUI del widget
    ├── AppGroupSetup.md            # Guía de configuración del App Group
    └── README.md                   # Este documento

HabitWidget/                        # Target de extensión (widget + live activity/control)
├── HabitWidget.swift               # Entrada principal del target
├── HabitWidgetLiveActivity.swift   # Live Activity / Dynamic Island
├── HabitWidgetControl.swift        # Control Widget (App Intents)
└── Info.plist                      # NSExtension settings
```

## Componentes

### 1. TimelineProvider (`HabitWidgetProvider`)
- Construye el placeholder, snapshot y timeline.
- Refresca el timeline cada 30 minutos.

### 2. Data Source (`HabitWidgetDataSource`)
- Intenta leer el snapshot compartido (`WidgetDataExporter`).
- Fallback a `JSONStorageProvider` si no hay snapshot.
- Procesa hábitos e instancias para generar `HabitWidgetEntry`.

### 3. Modelo (`HabitWidgetEntry`, `HabitSnapshot`)
- Entrada para WidgetKit con fecha, hábitos pendientes y rachas.

### 4. Vista (`HabitWidgetView`)
- Renderiza header con rachas y lista de pendientes.
- Usa `StreakChip` para mostrar racha actual y mejor racha.

### 5. Exportador (`WidgetDataExporter`)
- Vive en `Infraestructure/WidgetDataExporter.swift`.
- Escribe `widget_snapshot.json` en el contenedor de App Group.

### 6. Target `HabitWidget` (extensión)
- Es un target separado del app target `habitapp6` y produce la extensión `HabitWidgetExtension.appex`.
- Contiene la implementación de WidgetKit, Live Activities y Control Widgets ubicadas en la carpeta de raíz `HabitWidget/`.
- Debe compartir el mismo App Group y Team ID que el target de la app para acceder al snapshot.

## Integración con el Core

1. `HabitDataStore.saveData()` exporta hábitos e instancias hacia el snapshot y recarga timelines de WidgetKit.
2. El widget lee el snapshot; si falla, intenta JSON directo (mismo modelo que la app).
3. Las rachas se calculan con `RachaCalculator` reutilizando la lógica existente.

## Configuración

- Requiere App Group para compartir `widget_snapshot.json` entre app y widget. Ver [AppGroupSetup](AppGroupSetup.md) para pasos en Xcode.
- Actualiza el identificador de App Group en `WidgetDataExporter` (valor actual `"TODO"`).

## Uso

1. Abrir la app y crear/actualizar hábitos para generar instancias del día.
2. `HabitDataStore.saveData()` exporta el snapshot (disparado tras guardado o generación diaria).
3. Añadir el widget a la pantalla de inicio; se mostrará la lista de pendientes y rachas.

## Validación y Debug

- Logs en consola: `📤 [Widget Export]`, `📥 [Widget Import]`, `⚠️ No hay snapshot`.
- `WidgetDebugHelper` permite exportar y leer el snapshot manualmente.
- Probar en dispositivo físico con App Group configurado.

## Persistencia

- Snapshot compartido: `widget_snapshot.json` en contenedor de App Group.
- Fallback: `habits.json` y `instances.json` en Documents (vía `JSONStorageProvider`).

## Compatibilidad

- Requiere iOS 17+ para el widget actual.
- App y extensión deben usar el mismo App Group y team provisioning.
