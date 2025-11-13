# Árbol de Características

## Listado de Características para la aplicación

- HabitApp (Mandatoria)
  - Núcleo del Hábito (Mandatoria)
    - Nombre (Mandatoria)
    - Frecuencia (Mandatoria)
  - Funcionalidades Adicionales (Grupo OR) - Se puede elegir una o más de las siguientes:
    - Recordatorios (Opcional) - Asignado al Alumno 1
    - Rachas (Streaks) (Opcional) - Asignado al Alumno 2
    - Notas Diarias (Opcional) - Asignado al Alumno 3
    - Categorías (Opcional) - Asignado al Alumno 4
    - Estadísticas (Opcional) - Asignado al Alumno 5
  - Configuración (Mandatoria)
    - Datos (Alternativa - XOR) - Se debe elegir exactamente una:
      - JSON
      - CoreData/SwiftData

## Diagrama en árbol

```mermaid
graph TD
    HabitApp["HabitApp (Mandatoria)"]
    Nucleo["Núcleo del Hábito (Mandatoria)"]
    Nombre["Nombre (Mandatoria)"]
    Frecuencia["Frecuencia (Mandatoria)"]
    
    Funcionalidades["Funcionalidades Adicionales (Opcional, OR)"]
    Recordatorios["Recordatorios (Opcional) - Alumno 1"]
    Rachas["Rachas (Opcional) - Alumno 2"]
    Notas["Notas Diarias (Opcional) - Alumno 3"]
    Categorias["Categorías (Opcional) - Alumno 4"]
    Estadisticas["Estadísticas (Opcional) - Alumno 5"]
    
    Configuracion["Configuración (Mandatoria)"]
    Datos["Datos (Alternativa, XOR)"]
    JSON["JSON"]
    CoreData["CoreData/SwiftData"]
    
    HabitApp --> Nucleo
    Nucleo --> Nombre
    Nucleo --> Frecuencia
    
    HabitApp --> Funcionalidades
    Funcionalidades --> Recordatorios
    Funcionalidades --> Rachas
    Funcionalidades --> Notas
    Funcionalidades --> Categorias
    Funcionalidades --> Estadisticas
    
    HabitApp --> Configuracion
    Configuracion --> Datos
    Datos --> JSON
    Datos --> CoreData

```