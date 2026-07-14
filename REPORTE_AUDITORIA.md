# Reporte de Auditoria y Corrección del Sistema

**Fecha:** 2026-06-19
**Proyecto:** Software DJ D+J
**Auditor:** OpenCode

---

## 1. Resumen Ejecutivo

| Item | Detalle |
|------|---------|
| **Total de problemas encontrados** | 8 |
| **Total de problemas corregidos** | 8 |
| **Problemas pendientes** | 0 |
| **Nivel de impacto más alto** | Alto |

### Problemas encontrados por impacto:
*   **Alto (2):** Inconsistencia en cálculo de horas extras, Error SQL en Dashboard
*   **Medio (4):** Campo periodo sin validación de fecha, Duplicidad de tabs en Configuración, Límite de archivos no validado, Inconsistencia en Notificaciones
*   **Bajo (2):** Detalles menores de UI, Configuración de sesión

---

## 2. Módulo de Registro de Pagos (Planilla)

### Problema: Campo "periodo" sin validación de fecha
*   **Causa raíz:** El campo `periodo` en la tabla `planilla_pagos` era de tipo `string`, permitiendo cualquier texto libre. El backend validaba solo que fuera `required|string`, y el frontend usaba un `<input type="text">`.
*   **Solución implementada:**
    *   Se cambió el tipo de dato en la migración a `date`.
    *   Se actualizó la validación del backend en `PlanillaController.php` a `required|date`.
    *   Se cambió el frontend en `Planilla.vue` a `<input type="date">`.
*   **Archivos modificados:**
    *   `database/migrations/2026_06_11_000000_create_all_tables_consolidated.php`
    *   `app/Http/Controllers/Api/PlanillaController.php`
    *   `resources/js/pages/Planilla.vue`

### Problema: Campo "monto_horas_extras" no existía / Cálculo inconsistente
*   **Causa raíz:** La tabla `planilla_pagos` no tenía una columna para la cantidad de horas extras. El backend intentaba guardar `monto_horas_extra` y `horas_extra`, pero la lógica de cálculo no existía. El frontend permitía ingresar el monto manualmente.
*   **Solución implementada:**
    *   Se agregó la columna `horas_extra_cantidad` a la migración para almacenar la cantidad de horas.
    *   Se actualizó el backend para calcular automáticamente el monto: `(salario_base / 30 / jornada_laboral) * 1.5 * horas_extra_cantidad`.
    *   Se actualizó el frontend para que el usuario ingrese solo la cantidad de horas y la jornada laboral; el monto se calcula y despliega automáticamente y el campo está deshabilitado (`disabled`).
*  anuales. El frontend muestra un Date Picker. Validación dual.*   **Archivos modificados:** (Mismos que arriba)

---

## 3. Sistema de Notificaciones

### Problema: Inconsistencia en la obtención de notificaciones para usuarios normales
*   **Causa raíz:** En `NotificacionPersonalizadaController.php`, la consulta para obtener las notificaciones de un usuario normal estaba incompleta y contenía un error de sintaxis (`DB::table('notnow()...`) que habría resultado en un fallo. La lógica de filtrado de notificaciones descartadas también necesitaba refinamiento para asegurar que solo se muestren notificaciones activas para el usuario.
*   **Solución implementada:**
    *   Se corrigió y completó la consulta del método `index` en `NotificacionPersonalizadaController.php`.
    *   Se aseguró el filtrado correcto de notificaciones globales y personales, excluyendo las descartadas.
    *   Se mantuvo la estructura existente de `NotificacionController.php` (notificaciones dinámicas del sistema) y se verificó que el modelo `Notificacion.php` y el Evento `NuevaNotificacion.php` estuvieran correctamente definidos para soportar broadcasts.
*   **Archivos modificados:**
    *   `app/Http/Controllers/Api/NotificacionPersonalizadaController.php`

---

## 4. Expiración de Sesión

### Problema: Falta de manejo de expiración de sesión en el frontend y configuración duplicada
*   **Causa raíz:** El archivo `config/session.php` tenía una clave `'expire_on_close'` duplicada. El frontend no proporcionaba una retroalimentación clara al usuario cuando su sesión (token de Sanctum) expiraba o era invalidada, simplemente redirigía al login.
*   **Solución implementada:**
    *   Se eliminó la clave duplicada `'expire_on_close'` en `config/session.php`.
    *   Se actualizó el interceptor de respuestas 401 en `resources/js/services/api.js` para mostrar una alerta al usuario (`alert('Su sesión ha expirado...')`) antes de redirigirlo a la página de login.
*   **Archivos modificados:**
    *   `config/session.php`
    *   `resources/js/services/api.js`

---

## 5. Configuración: Tabs "Empresa" y "General"

### Problema: Duplicidad funcional entre tabs
*   **Causa raíz:** Los tabs "Empresa" y "General" en `Configuracion.vue` presentaban información y funcionalidades que se solapaban o eran manejadas de forma redundante.
*   **Solución implementada:**
    *   Se consolidó la funcionalidad removiendo el tab "General" del frontend.
    *   Se eliminó el bloque de template `<div v-if="tab === 'general'">...</div>` de `resources/js/pages/Configuracion.vue`.
    *   Se mantiene el tab "Empresa" como la sección principal para configuraciones del negocio.
*   **Archivos modificados:**
    *   `resources/js/pages/Configuracion.vue`

---

## 6. Límite de Archivos en el Chat

### Problema: Falta de validación de tamaño de archivos en chat
*   **Causa raíz:** El módulo de chat permitía subir archivos sin un límite de tamaño definido explícitamente en el backend o una validación previa en el frontend, lo que podría causar errores de carga o consumo excesivo de recursos.
*   **Solución implementada:**
    *   **Frontend:** Se añadió validación en `ChatDrawer.vue` para verificar el tamaño del archivo antes de permitir su selección. Si el archivo excede 3 MB, se muestra un mensaje de error. Se actualizó el tooltip del botón de adjuntar.
    *   **Backend:** Se añadió validación en `ChatController.php` (método `enviarMensaje`) para rechazar archivos mayores a 3 MB. Se ajustó la regla de validación de Laravel a `'max:3072'` (KB).
*   **Archivos modificados:**
    *   `app/Http/Controllers/Api/ChatController.php`
    *   `resources/js/components/ChatDrawer.vue`
flutter.*   **Archivos modificados:** (Mismos que arriba)

---

## 7. Auditoría General - Logs y Errores Detectados

### Error SQL en DashboardController (GROUP BY)
*   **Problema:** El método `stats` en `DashboardController.php` contenía una subconsulta para contar clientes recurrentes que utilizaba `groupBy` dentro de una subconsulta SQL sin especificar un alias de tabla para el `COUNT`, lo que generaba un error `Syntax error or access violation: 1055 'software_dj.ventas.id' isn't in GROUP BY` en MySQL strict mode.
*   **Solución:** Se refactorizó la consulta para realizar el `GROUP BY` y `HAVING` directamente sobre la tabla principal, evitando la subconsulta problemática y utilizando `get()->count()` para obtener el conteo final.
*   **Archivo modificado:** `app/Http/Controllers/Api/DashboardController.php`

---

## 8. Archivos Modificados

| # | Archivo | Tipo de Cambio |
|---|---------|----------------|
| 1 | `database/migrations/2026_06_11_000000_create_all_tables_consolidated.php` | Modificado |
| 2 | `app/Http/Controllers/Api/PlanillaController.php` | Modificado |
 Pecador| 3 | `resources/js/pages/Planilla.vue` | Modificado |
| 4 | `app/Http/Controllers/Api/NotificacionPersonalizadaController.php` | Modificado |
| 5 | `config/session.php` | Modificado |
| 6 | `resources/js/services/api.js` | Modificado |
| 7 | `resources/js/pages/Configuracion.vue` | Modificado |
| 8 | `app/Http/Controllers/Api/ChatController.php` | Modificado |
| 9 | `resources/js/components/ChatDrawer.vue` | Modificado |
| 10 | `app/Http/Controllers/Api/DashboardController.php` | Modificado |
| 11 | `REPORTE_AUDITORIA.md` | Creado |

---

## 9. Riesgos Pendientes

*   **Revisión de Testing:** Se recomienda realizar pruebas manuales exhaustivas en todos los módulos modificados, especialmente en el cálculo de horas extras y la carga de archivos en chat, para verificar que los cambios funcionen correctamente en un entorno de staging o producción.
*   **Refactorización de Notificaciones:** Si bien se corrigió la consistencia de datos, no se implementaron cambios estructurales mayores en el módulo de notificaciones (como WebSockets para tiempo real). Esto puede ser considerado en auditorías futuras.