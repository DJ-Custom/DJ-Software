# PLAN DE REFACTORIZACIÓN - DJ DASHBOARD ERP

## Objetivo
Mejorar la arquitectura del sistema existente sin romper funcionalidad. Cada cambio debe ser incremental y verificable.

---

## ORDEN DE EJECUCIÓN (15 fases)

### FASE 1: Migración de Estándares de Tablas
**Archivos:** 1 migración nueva
**Objetivo:** Agregar uuid, deleted_at, created_by, updated_by a todas las tablas existentes

### FASE 2: Traits Base
**Archivos:** 2-3 traits nuevos en app/Traits/
**Objetivo:** HasStandardFields, mejorar Auditable, verificar SoftDeletes en modelos

### FASE 3: Form Requests
**Archivos:** 15-20 archivos en app/Http/Requests/
**Objetivo:** Validación centralizada para cada endpoint de escritura

### FASE 4: Service Layer - Dominios Core
**Archivos:** 5-7 servicios en app/Services/
**Objetivo:** VentaService, InventarioService, CajaService, CotizacionService, ClienteService, ProductoService

### FASE 5: Refactorizar Controladores Core
**Archivos:** 5-7 controladores modificados
**Objetivo:** Mover lógica de negocio a servicios, usar Form Requests, usar ApiResponse

### FASE 6: Middleware de Permisos
**Archivos:** 1 middleware nuevo + routes/api.php modificado
**Objetivo:** CheckModuleAccess + Apply en todas las rutas

### FASE 7: Componentes Base Frontend
**Archivos:** 10-12 componentes en resources/js/components/base/
**Objetivo:** DataTable, Pagination, FilterBar, CrudModal, FormField, StatusBadge, etc.

### FASE 8: Composables
**Archivos:** 2-3 composables nuevos
**Objetivo:** usePagination, useCrud, useExport

### FASE 9: Refactorizar Páginas Vue - Lote 1
**Archivos:** 5 páginas modificadas
**Objetivo:** Clientes, Productos, Proveedores, Usuarios, Roles

### FASE 10: Refactorizar Páginas Vue - Lote 2
**Archivos:** 5 páginas modificadas
**Objetivo:** Ventas, Cotizaciones, Pedidos, Compras, Caja

### FASE 11: Refactorizar Páginas Vue - Lote 3
**Archivos:** 5 páginas modificadas
**Objetivo:** Devoluciones, NotasCredito, Traspasos, AjustesInventario, Inventario

### FASE 12: Refactorizar Páginas Vue - Lote 4
**Archivos:** 5 páginas modificadas
**Objetivo:** Tesoreria, CuentasCobrar, Presupuestos, Contabilidad, Reportes

### FASE 13: Refactorizar Páginas Vue - Lote 5
**Archivos:** 5 páginas modificadas
**Objetivo:** CRM, EmailMarketing, Planilla, Auditoria, Configuracion

### FASE 14: Router y Layout
**Archivos:** router/index.js + AppLayout.vue + App.vue
**Objetivo:** 404 page, permisos por ruta, extraer sidebar/header

### FASE 15: Testing
**Archivos:** Tests en tests/
**Objetivo:** Tests de unit y feature para módulos core

---

## DETALLE POR FASE

Ver ARCHITECTURE_PLAN.md para especificaciones completas de cada componente, servicio, y patrón a implementar.
