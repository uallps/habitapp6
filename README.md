# 🎯 HabitApp 6 

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.5+-orange?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue?style=for-the-badge&logo=apple&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-12.0+-purple?style=for-the-badge&logo=apple&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Tu compañero definitivo para construir hábitos que duran** 🚀

[Features](#-features) • [Arquitectura](#-arquitectura) • [Instalación](#-instalación) • [Equipo](#-equipo)

</div>

---

## 🤔 ¿Qué es HabitApp?

HabitApp es una aplicación iOS/macOS diseñada para ayudarte a **crear, seguir y mantener hábitos** de forma sencilla y motivadora. 

> *"Hablar es fácil. Muestrame los commits."* — Linus Torvalds (probablemente)

### ✨ ¿Por qué HabitApp?

- 📱 **Multiplataforma** — iOS y macOS con una sola base de código
- 🧩 **Modular** — Arquitectura SPL (Software Product Lines)
- 🎨 **Bonita** — Porque los ojos también importan
- 🔒 **Privada** — Tus datos se quedan contigo

---

## 🚀 Features

### 📦 Core (Siempre incluido)

| Feature | Descripción |
|---------|-------------|
| ✏️ **Crear Hábitos** | Define hábitos con nombre personalizado |
| 📅 **Frecuencia** | Diario, semanal, mensual... tú decides |
| ✅ **Check diario** | Marca tus hábitos como completados |
| 📊 **Historial** | Visualiza tu progreso |

### 🌟 Features Variables

| Feature | Descripción |
|---------|-------------|-------|
| 🔔 **Recordatorios** | Notificaciones para no olvidar ningún hábito |
| 🔥 **Rachas** | Mantén tu racha de días consecutivos |
| 📝 **Notas** | Añade notas a tus completados |
| 🏷️ **Categorías** | Organiza tus hábitos por categorías |

### 💎 Features Premium (Las nuestras)

| Feature | Descripción | Autor |
|---------|-------------|-------|
| 🏆 **Logros** | Sistema de medallas y recompensas | Sergio Gómez Vico |
| 🎯 **Metas** | Define objetivos específicos para tus hábitos | Raúl Martínez Gutiérrez |
| 💡 **Sugerencias** | Recomendaciones personalizadas de nuevos hábitos | Andrés Ruiz Andújar |
| 📲 **Widget** | Widget para tu pantalla de inicio | Adrián Martínez Granados |

---

## 🏗️ Arquitectura

HabitApp está construida siguiendo los principios de **Software Product Lines (SPL)**:

```
┌─────────────────────────────────────────────────────────┐
│                      🎯 HabitApp                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │                 📦 CORE                          │   │
│  │         Hábitos + Frecuencia + Check            │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                              │
│         ┌────────────────┼────────────────┐            │
│         ▼                ▼                ▼            │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐      │
│  │  🔌 Plugin │    │  🔌 Plugin │    │  🔌 Plugin │      │
│  │   Metas   │    │   Logros  │    │  Widget   │      │
│  └───────────┘    └───────────┘    └───────────┘      │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  💾 Persistencia: JSON ◄──XOR──► CoreData              │
└─────────────────────────────────────────────────────────┘
```

### 🔧 Patrones Utilizados

| Patrón | Uso |
|--------|-----|
| 🚩 **Feature Flags** | Activar/desactivar features en runtime |
| 🔌 **Plugin Architecture** | Módulos independientes y desacoplados |
| 🎭 **Strategy Pattern** | Intercambiar persistencia (JSON/CoreData) |
| 🏭 **Compilation Flags** | Generar diferentes productos |

---

## 📦 Versiones del Producto

| Versión | Features | Para quién |
|---------|----------|------------|
| 🥉 **Base** | Solo Core | Minimalistas |
| 🥇 **Premium** | Core + Variables + Propias | Power users |
| 🛠️ **Develop** | TODO activado | Desarrolladores |

---

## 🛠️ Instalación

### Requisitos

- Xcode 14.0+
- iOS 15.0+ / macOS 12.0+
- Swift 5.5+
- Ganas de mejorar tu vida 💪

### Clonar y ejecutar

```bash
# Clona el repositorio
git clone https://github.com/[TU-USUARIO]/habitapp6.git

# Abre el proyecto
cd habitapp6
open habitapp6.xcodeproj

# Selecciona el scheme que quieras:
# - habitapp6 (Base)
# - HabitApp-Premium
# - HabitApp-Develop
# - etc.

# ¡Dale al Play! ▶️
```

---


## 👥 Equipo

<div align="center">

| 🧑‍💻 | Nombre | Feature | GitHub |
|:---:|--------|---------|--------|
| 📲 | `Adrián Martínez Granados` | Widget | [@ualamg538](https://github.com/ualamg538) |
| 🎯 | `Raúl Martínez Gutiérrez` | Metas | [@ualrmg429](https://github.com/ualrmg429) |
| 🏆 | `Sergio Gómez Vico` | Logros | [@ualsgv396](https://github.com/ualsgv396) |
| 💡 | `Andrés Ruiz Andújar` | Sugerencias | [@UALara584](https://github.com/UALara584) |


</div>

---

## 📚 Estructura del Proyecto

```
habitapp6/
├── 📁 Application/
│   ├── AppConfig.swift        # 🚩 Feature Flags
│   ├── PluginManager.swift    # 🔌 Gestor de plugins
│   └── habitapp6App.swift     # 🚀 Entry point
│
├── 📁 Core/
│   ├── 📁 Models/             # 📦 Habit, Frecuencia
│   ├── 📁 ViewModels/         # 🧠 Lógica de presentación
│   └── 📁 Views/              # 🎨 Vistas principales
│
├── 📁 Features/
│   ├── 📁 Categorias/         # 🏷️
│   ├── 📁 Logros/             # 🏆
│   ├── 📁 Metas/              # 🎯
│   ├── 📁 Notas/              # 📝
│   ├── 📁 Rachas/             # 🔥
│   ├── 📁 Recordatorios/      # 🔔
│   ├── 📁 Sugerencias/        # 💡
│   └── 📁 Widget/             # 📲
│
├── 📁 Infrastructure/
│   ├── StorageProvider.swift       # 🎭 Protocolo
│   ├── JSONStorageProvider.swift   # 📄 Implementación JSON
│   └── CoreDataStorageProvider.swift # 💾 Implementación CoreData
│
└── 📁 .github/workflows/      # 🔄 CI/CD
```

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Básicamente: haz lo que quieras, pero no nos culpes si algo sale mal 😅



