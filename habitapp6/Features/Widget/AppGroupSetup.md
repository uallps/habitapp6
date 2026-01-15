# Feature: App Group para Widget

## Descripción

Esta guía documenta la configuración necesaria para que la app y el widget compartan datos mediante un **App Group**. El widget lee el snapshot exportado por la app (ver `WidgetDataExporter`) y sin App Group no puede acceder al archivo compartido.

## Estado actual

- La app y el widget ya escriben/leen el snapshot, pero el identificador de App Group está en `"TODO"` y no se ha podido reemplazar porque no hay una cuenta de Apple Developer activa para crear el grupo.
- Mientras no se configure el App Group, el acceso al contenedor compartido fallará al intentar resolver la URL con `containerURL(forSecurityApplicationGroupIdentifier:)`.

## Requisitos

- Cuenta de Apple Developer con permisos de creación de App Groups.
- Identificador de equipo (Team ID) asociado al proyecto.
- Acceso a Xcode para actualizar Signing & Capabilities de los targets `habitapp6` y `HabitWidgetExtension`.

## Pasos de configuración en Xcode

1. Abre el proyecto en Xcode y selecciona el target **habitapp6**.
2. Ve a **Signing & Capabilities** y pulsa **+ Capability** → añade **App Groups**.
3. Crea un identificador de App Group (ejemplo: `group.com.tuempresa.habitapp6`) y márcalo como activo en el listado.
4. Repite los pasos 1-3 para el target **HabitWidgetExtension**, seleccionando el **mismo** App Group.
5. Comprueba que el archivo de entitlements (`habitapp6.entitlements` y el del widget) contiene la clave `com.apple.security.application-groups` con el grupo creado.
6. Limpia y vuelve a compilar el proyecto para que los perfiles de aprovisionamiento incluyan el nuevo grupo.

## Ajustes de código

- En `WidgetDataExporter`, actualiza `containerURL(forSecurityApplicationGroupIdentifier: "TODO")` para usar el identificador real del App Group creado (p. ej. `group.com.tuempresa.habitapp6`).
- Verifica que el nombre de archivo compartido (`widget_snapshot.json`) se mantiene consistente entre la app y el widget.
- No se requieren cambios adicionales en la lógica de exportación/lectura; solo el identificador correcto del grupo.

## Validación

- Ejecuta la app en un dispositivo físico (los App Groups no funcionan en simulador sin cuenta real) y completa/crea hábitos para disparar `saveData()`.
- Abre el widget y confirma que muestra los datos recientes; también puedes revisar los logs `📤 [Widget Export]` y `📥 [Widget Import]` en consola para asegurar que el contenedor se resuelve correctamente.

## Por qué no se ha configurado

No se ha podido crear ni habilitar el App Group porque en este entorno no hay una cuenta de Apple Developer disponible para registrar el identificador y generar los perfiles de aprovisionamiento correspondientes.

## Compatibilidad

- Requiere iOS 17+ para el widget actual.
- Necesita la misma versión de App Group habilitada tanto en la app como en la extensión de widget.
