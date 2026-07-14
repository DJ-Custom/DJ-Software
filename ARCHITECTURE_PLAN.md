# PLAN MAESTRO DE ARQUITECTURA - DJ DASHBOARD ERP

## Estado Actual del Proyecto

**Stack:** Laravel 12 + Vue 3 + Pinia + Vite + MySQL
**Módulos existentes:** 40+ controladores, 44 modelos, 80+ tablas, 49 páginas Vue
**Problemas críticos identificados:** Controladores grasosos, ausencia de servicios, sin SoftDeletes, sin UUIDs, sin permisos por ruta, componentes frontend duplicados masivamente

---

## FASE 0: CIMENTACIÓN (Base para todo el sistema)

### 0.1 Migración de Estructura Base de Tablas

Todas las tablas deben incluir estándar completo:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | BIGINT UNSIGNED AUTO_INCREMENT | PK numérica |
| `uuid` | CHAR(36) | UUID v4 para referencias externas seguras |
| `created_at` | TIMESTAMP | Auditoría temporal |
| `updated_at` | TIMESTAMP | Auditoría temporal |
| `deleted_at` | TIMESTAMP NULL | Soft Delete |
| `created_by` | BIGINT UNSIGNED NULL | FK → usuarios.id |
| `updated_by` | BIGINT UNSIGNED NULL | FK → usuarios.id |

**Archivo:** `database/migrations/2026_07_13_000001_add_standard_columns_to_all_tables.php`

```php
// Agregar columnas faltantes a TODAS las tablas existentes
$tables = [
    'ventas', 'venta_detalle', 'clientes', 'productos', 'producto_variantes',
    'cotizaciones', 'cotizacion_detalle', 'pedidos', 'pedido_detalle',
    'compras', 'compra_detalle', 'proveedores', 'categorias', 'etiquetas',
    'usuarios', 'roles', 'cajas', 'caja_sesiones', 'caja_movimientos',
    'inventario_movimientos', 'inventario_ubicacion', 'traspasos', 'traspaso_detalle',
    'devoluciones', 'devolucion_detalle', 'notas_credito', 'nota_credito_detalle',
    'combos', 'combo_productos', 'cupones', 'promociones',
    'tesoreria_movimientos', 'cuentas_cobrar', 'cuentas_cobrar_pagos',
    'presupuestos', 'presupuesto_detalle',
    'cuentas_contables', 'asientos_contables', 'asiento_detalle',
    'empleados', 'planilla_pagos', 'planilla_configuracion', 'planilla_historial',
    'campanas_email', 'email_templates', 'email_recipients', 'email_analytics',
    'crm_oportunidades', 'crm_etapas', 'crm_actividades',
    'chats', 'chat_mensajes', 'notificaciones', 'notificacion_usos',
    'auditoria', 'productividad_sesiones', 'facturacion_electronica',
    'formularios', 'formulario_respuestas'
];

foreach ($tables as $table) {
    Schema::table($table, function (Blueprint $table) {
        if (!Schema::hasColumn($table, 'uuid')) {
            $table->char('uuid', 36)->after('id')->unique()->index();
        }
        if (!Schema::hasColumn($table, 'deleted_at')) {
            $table->softDeletes()->after('updated_at');
        }
        if (!Schema::hasColumn($table, 'created_by')) {
            $table->unsignedBigInteger('created_by')->nullable()->after('updated_at')->index();
        }
        if (!Schema::hasColumn($table, 'updated_by')) {
            $table->unsignedBigInteger('updated_by')->nullable()->after('created_by')->index();
        }
    });
}
```

### 0.2 Trait Base: `HasStandardFields`

**Archivo:** `app/Traits/HasStandardFields.php`

```php
trait HasStandardFields
{
    protected static function bootHasStandardFields(): void
    {
        static::creating(function ($model) {
            $model->uuid = $model->uuid ?? Str::uuid()->toString();
            $model->created_by = auth()->id();
            $model->updated_by = auth()->id();
        });

        static::updating(function ($model) {
            $model->updated_by = auth()->id();
        });
    }

    public function getRouteKeyName(): string
    {
        return 'uuid';
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }
}
```

### 0.3 Trait Base: `Auditable` (Mejorado)

Se mantiene el trait existente pero se agrega:
- Logging de batch updates (`Model::where()->update()`)
- Logging de read operations críticas
- Correlación de requests (request_id)

**Archivo:** `app/Traits/Auditable.php` (modificación)

### 0.4 Trait Base: `SoftDeletes` (Activar en todos los modelos)

Cada modelo debe usar `SoftDeletes` + `HasStandardFields`:

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Cliente extends Model
{
    use HasStandardFields, Auditable, SoftDeletes;
    // ...
}
```

### 0.5 Trait Base: `Permissible` (Control de Permisos)

**Archivo:** `app/Traits/Permissible.php`

```php
trait Permissible
{
    public function tienePermiso(string $permiso): bool
    {
        if ($this->rol && $this->rol->nombre === 'Administrador') {
            return true;
        }
        return in_array($permiso, $this->permisos ?? []);
    }

    public function tieneAccesoModulo(string $modulo): bool
    {
        if ($this->rol && $this->rol->nombre === 'Administrador') {
            return true;
        }
        return in_array($modulo, $this->modulos_acceso ?? []);
    }
}
```

### 0.6 Middleware: `CheckModuleAccess`

**Archivo:** `app/Http/Middleware/CheckModuleAccess.php`

```php
class CheckModuleAccess
{
    public function handle(Request $request, Closure $next, string $module): Response
    {
        if (!auth()->user()->tieneAccesoModulo($module)) {
            return response()->json(['message' => 'Acceso no autorizado'], 403);
        }
        return $next($request);
    }
}
```

### 0.7 Form Request Base

**Archivos:** `app/Http/Requests/`

```
app/Http/Requests/
├── BaseFormRequest.php          # Clase base con mensajes en español
├── ApiRequest.php               # Para API con JSON responses
├── Auth/
│   ├── LoginRequest.php
├── Clientes/
│   ├── StoreClienteRequest.php
│   └── UpdateClienteRequest.php
├── Productos/
│   ├── StoreProductoRequest.php
│   └── UpdateProductoRequest.php
├── Ventas/
│   ├── StoreVentaRequest.php
│   └── CancelVentaRequest.php
├── Cotizaciones/
│   ├── StoreCotizacionRequest.php
│   └── CambiarEstadoRequest.php
└── ... (una por cada endpoint de escritura)
```

### 0.8 Service Layer Base

**Patrón:** Cada dominio de negocio tiene un Service inyectable.

**Archivos:** `app/Services/`

```
app/Services/
├── BaseService.php              # CRUD genérico + paginación + filtros
├── Venta/
│   ├── VentaService.php
│   └── VentaFacturacionService.php
├── Inventario/
│   ├── InventarioService.php
│   └── StockService.php
├── Cotizacion/
│   ├── CotizacionService.php
│   └── CotizacionEmailService.php
├── Cliente/
│   └── ClienteService.php
├── Producto/
│   ├── ProductoService.php
│   └── CatalogoService.php
├── Caja/
│   ├── CajaService.php
│   └── CajaSesionService.php
├── Reporte/
│   ├── ReporteService.php
│   └── DashboardService.php
├── Email/
│   └── EmailMarketingService.php
├── Planilla/
│   └── PlanillaService.php
└── Auditoria/
    └── AuditoriaService.php
```

**BaseService.php:**

```php
abstract class BaseService
{
    protected $model;
    protected $perPage = 15;

    public function paginate(array $filters = [], array $search = [], int $page = 1, int $perPage = null): array
    {
        $query = $this->model->query();
        $query = $this->applyFilters($query, $filters);
        $query = $this->applySearch($query, $search);
        $query = $this->applySorting($query, $filters['sort'] ?? null, $filters['order'] ?? 'desc');

        $perPage = $perPage ?? $this->perPage;
        $paginator = $query->paginate($perPage, ['*'], 'page', $page);

        return [
            'data' => $paginator->items(),
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'pages' => $paginator->lastPage(),
            'per_page' => $perPage,
        ];
    }

    public function create(array $data): Model
    {
        return $this->model->create($data);
    }

    public function findByUuid(string $uuid): ?Model
    {
        return $this->model->where('uuid', $uuid)->firstOrFail();
    }

    public function update(string $uuid, array $data): Model
    {
        $model = $this->findByUuid($uuid);
        $model->update($data);
        return $model->fresh();
    }

    public function delete(string $uuid): bool
    {
        $model = $this->findByUuid($uuid);
        return $model->delete();
    }

    abstract protected function applyFilters($query, array $filters);
    abstract protected function applySearch($query, string $search);
    protected function applySorting($query, $sort, $order) { /* ... */ }
}
```

### 0.9 Response Helper / API Resource Base

**Archivo:** `app/Http/Resources/ApiResponse.php`

```php
class ApiResponse
{
    public static function success($data, string $message = 'OK', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    public static function error(string $message, int $code = 400, $errors = null): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], $code);
    }

    public static function paginated($paginator): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $paginator->items(),
            'total' => $paginator->total(),
            'page' => $paginator->currentPage(),
            'pages' => $paginator->lastPage(),
        ]);
    }
}
```

### 0.10 Export Service

**Archivo:** `app/Services/ExportService.php`

```php
class ExportService
{
    public function toExcel(Collection $data, array $columns, string $filename): BinaryFileResponse
    {
        return Excel::download(new ExportView($data, $columns), "{$filename}.xlsx");
    }

    public function toPdf(Collection $data, array $columns, string $title, string $filename): Response
    {
        $pdf = Pdf::loadView('exports.pdf-table', compact('data', 'columns', 'title'));
        return $pdf->download("{$filename}.pdf");
    }

    public function toCsv(Collection $data, array $columns, string $filename): StreamedResponse
    {
        return response()->streamDownload(function () use ($data, $columns) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, $columns);
            foreach ($data as $row) {
                fputcsv($handle, collect($columns)->map(fn($col) => $row->{$col} ?? '')->toArray());
            }
            fclose($handle);
        }, "{$filename}.csv");
    }
}
```

---

## FASE 1: COMPONENTES REUTILIZABLES FRONTEND

### 1.1 Componentes Base (CRUD System)

```
resources/js/components/
├── base/
│   ├── DataTable.vue           # Tabla con sorting, empty state, responsive
│   ├── Pagination.vue          # Navegación de páginas
│   ├── FilterBar.vue           # Barra de búsqueda + filtros
│   ├── CrudModal.vue           # Modal crear/editar reutilizable
│   ├── FormField.vue           # Campo de formulario con label + validación
│   ├── FormInput.vue           # Input text genérico
│   ├── FormSelect.vue          # Select genérico
│   ├── FormTextarea.vue        # Textarea genérico
│   ├── FormDatePicker.vue      # DatePicker genérico
│   ├── FormToggle.vue          # Toggle switch genérico
│   ├── StatusBadge.vue         # Badge de estados
│   ├── ConfirmAction.vue       # Botón con confirmación
│   ├── LoadingSpinner.vue      # Indicador de carga
│   ├── EmptyState.vue          # Estado vacío con icono + mensaje
│   ├── SearchInput.vue         # Input de búsqueda con icono + debounce
│   ├── ExportDropdown.vue      # Dropdown de exportación (Excel/PDF/CSV)
│   ├── DeleteButton.vue        # Botón eliminar con confirmación
│   ├── DuplicateButton.vue     # Botón duplicar
│   └── PrintButton.vue         # Botón imprimir
├── layout/
│   ├── AppSidebar.vue          # Sidebar extraído de AppLayout
│   ├── AppHeader.vue           # Header extraído de AppLayout
│   └── MobileNav.vue           # Navegación móvil
└── shared/
    ├── ActivityLog.vue         # Historial de auditoría reutilizable
    ├── InternalNotes.vue       # Notas internas reutilizable
    ├── Attachments.vue         # Adjuntos reutilizable
    └── StateManager.vue        # Manejo de estados reutilizable
```

### 1.2 `DataTable.vue` - Especificación

```vue
<template>
  <div class="data-table-wrapper">
    <div class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col.key"
                :class="{ sortable: col.sortable }"
                @click="col.sortable && $emit('sort', col.key)">
              {{ col.label }}
              <span v-if="sortKey === col.key" class="sort-icon">
                {{ sortOrder === 'asc' ? '▲' : '▼' }}
              </span>
            </th>
            <th v-if="$slots.actions" class="actions-col">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.uuid" @click="$emit('row-click', item)">
            <td v-for="col in columns" :key="col.key" :data-label="col.label">
              <slot :name="`cell-${col.key}`" :item="item" :value="item[col.key]">
                {{ item[col.key] }}
              </slot>
            </td>
            <td v-if="$slots.actions" class="actions-cell" @click.stop>
              <slot name="actions" :item="item" />
            </td>
          </tr>
          <tr v-if="!items.length && !loading">
            <td :colspan="columns.length + ($slots.actions ? 1 : 0)">
              <EmptyState :message="emptyMessage" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <LoadingSpinner v-if="loading" />
  </div>
</template>

<script setup>
defineProps({
  items: { type: Array, default: () => [] },
  columns: { type: Array, required: true },
  loading: { type: Boolean, default: false },
  sortKey: { type: String, default: '' },
  sortOrder: { type: String, default: 'desc' },
  emptyMessage: { type: String, default: 'No hay registros' }
})

defineEmits(['sort', 'row-click'])
</script>

<style scoped>
/* Responsive: tablet */
@media (max-width: 1023px) {
  .data-table thead { display: none; }
  .data-table tbody tr { display: block; margin-bottom: 1rem; border: 1px solid var(--border); border-radius: 8px; }
  .data-table tbody td { display: flex; justify-content: space-between; padding: 0.5rem 1rem; }
  .data-table tbody td::before { content: attr(data-label); font-weight: 600; min-width: 40%; }
}
/* Responsive: móvil */
@media (max-width: 768px) {
  .data-table tbody td { font-size: 0.875rem; }
}
</style>
```

### 1.3 `Pagination.vue` - Especificación

```vue
<template>
  <div class="pagination-wrapper">
    <span class="pagination-info">{{ total }} registros</span>
    <div class="pagination-controls">
      <button @click="$emit('change', page - 1)" :disabled="page <= 1" class="btn btn-sm">
        ← Anterior
      </button>
      <span class="page-indicator">Página {{ page }} de {{ pages }}</span>
      <button @click="$emit('change', page + 1)" :disabled="page >= pages" class="btn btn-sm">
        Siguiente →
      </button>
    </div>
  </div>
</template>
```

### 1.4 `CrudModal.vue` - Especificación

```vue
<template>
  <div class="modal-overlay" :class="{ active: modelValue }" @click.self="$emit('update:modelValue', false)">
    <div class="modal" :style="{ maxWidth }">
      <div class="modal-header">
        <h3>{{ title }}</h3>
        <button @click="$emit('update:modelValue', false)" class="btn-close">×</button>
      </div>
      <div class="modal-body">
        <slot />
      </div>
      <div class="modal-footer">
        <button @click="$emit('update:modelValue', false)" class="btn btn-secondary">Cancelar</button>
        <button @click="$emit('submit')" class="btn btn-primary" :disabled="submitting">
          <LoadingSpinner v-if="submitting" size="sm" />
          {{ submitText }}
        </button>
      </div>
    </div>
  </div>
</template>
```

### 1.5 `FormField.vue` - Especificación

```vue
<template>
  <div class="form-group" :class="{ 'has-error': error }">
    <label v-if="label">{{ label }} <span v-if="required" class="required">*</span></label>
    <slot />
    <span v-if="error" class="error-message">{{ error }}</span>
    <span v-if="hint && !error" class="hint-text">{{ hint }}</span>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  error: String,
  hint: String,
  required: Boolean
})
</script>
```

### 1.6 `usePagination.js` Composable

**Archivo:** `resources/js/composables/usePagination.js`

```javascript
import { ref, reactive } from 'vue'
import api from '../services/api'

export function usePagination(endpoint, options = {}) {
  const items = ref([])
  const total = ref(0)
  const page = ref(1)
  const pages = ref(1)
  const loading = ref(false)
  const busqueda = ref('')
  const filtros = reactive(options.defaultFilters || {})
  const sortKey = ref(options.defaultSort || 'created_at')
  const sortOrder = ref(options.defaultOrder || 'desc')

  async function cargar() {
    loading.value = true
    try {
      const { data } = await api.get(endpoint, {
        params: {
          page: page.value,
          busqueda: busqueda.value,
          sort: sortKey.value,
          order: sortOrder.value,
          ...filtros,
          limit: options.perPage || 15
        }
      })
      items.value = data.data || data
      total.value = data.total || 0
      pages.value = data.pages || 1
    } catch (e) {
      console.error(e)
    } finally {
      loading.value = false
    }
  }

  function debounceSearch() {
    clearTimeout(window._searchTimeout)
    window._searchTimeout = setTimeout(() => {
      page.value = 1
      cargar()
    }, 400)
  }

  function sortBy(key) {
    if (sortKey.value === key) {
      sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
    } else {
      sortKey.value = key
      sortOrder.value = 'asc'
    }
    cargar()
  }

  return {
    items, total, page, pages, loading, busqueda, filtros,
    sortKey, sortOrder, cargar, debounceSearch, sortBy
  }
}
```

---

## FASE 2: MÓDULOS INDIVIDUALES (Orden de Implementación)

### Orden de construcción (dependencias):

```
1. Usuarios y Roles (refactorizar existente)
2. Clientes (refactorizar existente)
3. Productos + Categorías + Etiquetas (refactorizar existente)
4. Proveedores (refactorizar existente)
5. Cotizaciones (refactorizar existente)
6. Pedidos (refactorizar existente)
7. Ventas (refactorizar existente)
8. Caja (refactorizar existente)
9. Compras (refactorizar existente)
10. Inventario (refactorizar existente)
11. Devoluciones + Notas Crédito (refactorizar existente)
12. Tesorería (refactorizar existente)
13. Cuentas por Cobrar (refactorizar existente)
14. Presupuestos (refactorizar existente)
15. Contabilidad (refactorizar existente)
16. CRM (refactorizar existente)
17. Email Marketing (refactorizar existente)
18. Planilla (refactorizar existente)
19. Reportes + BI (refactorizar existente)
20. Auditoría (refactorizar existente)
21. Configuración (refactorizar existante)
22. Chat + Notificaciones (refactorizar existente)
```

### Patrón para CADA módulo (plantilla):

```
CADA MÓDULO DEBE SEGUIR ESTA ESTRUCTURA:

Backend:
├── app/Http/Controllers/Api/{Modulo}Controller.php
│   ├── index()          → Paginación + filtros + búsqueda
│   ├── store()          → FormRequest + Service::create()
│   ├── show($uuid)      → Service::findByUuid()
│   ├── update($uuid)    → FormRequest + Service::update()
│   ├── destroy($uuid)   → SoftDelete + confirmación
│   ├── duplicate($uuid) → Service::duplicate()
│   ├── export()         → ExportService (Excel/PDF/CSV)
│   ├── import()         → ImportService
│   ├── history($uuid)   → AuditoriaService::getHistory()
│   └── stats()          → Estadísticas del dashboard
│
├── app/Services/{Modulo}/{Modulo}Service.php
│   ├── paginate()
│   ├── create()
│   ├── findByUuid()
│   ├── update()
│   ├── delete() (soft)
│   ├── duplicate()
│   ├── getStats()
│   └── applyFilters() / applySearch()
│
├── app/Http/Requests/{Modulo}/
│   ├── Store{Entity}Request.php
│   └── Update{Entity}Request.php
│
├── app/Models/{Entity}.php
│   ├── use HasStandardFields, Auditable, SoftDeletes
│   ├── relationships()
│   ├── scopes()
│   ├── casts()
│   └── accessor/mutators()
│
├── app/Http/Resources/{Modulo}/
│   └── {Entity}Resource.php
│
├── database/migrations/
│   └── (agregar uuid, deleted_at, created_by, updated_by)
│
└── routes/api.php
    └── Route::prefix('{modulo}')->group(function () { ... })

Frontend:
├── resources/js/pages/{Modulo}.vue
│   ├── <DataTable> con columnas definidas
│   ├── <FilterBar> con búsqueda + filtros del módulo
│   ├── <Pagination> reutilizable
│   ├── <CrudModal> para crear/editar
│   ├── <FormField> para cada campo del formulario
│   ├── <StatusBadge> para estados
│   ├── <ExportDropdown> para exportar
│   ├── usePagination() composable
│   └── Validación en tiempo real en formularios
│
└── router/index.js
    └── Ruta con meta: { module: 'modulo_slug' }
```

---

## FASE 3: PATRONES POR MÓDULO

### 3.1 Dashboard del Módulo

Cada módulo principal debe tener un mini-dashboard con:
- KPIs relevantes (totales, promedios, tendencias)
- Gráficas (Chart.js)
- Actividad reciente
- Alertas (stock bajo, vencimientos, etc.)

### 3.2 Manejo de Estados (Máquina de Estados)

```php
// Ejemplo: Cotización
$estados = [
    'borrador'    => ['siguiente' => 'enviada', 'anterior' => null],
    'enviada'     => ['siguiente' => 'aprobada', 'anterior' => 'borrador'],
    'aprobada'    => ['siguiente' => 'facturada', 'anterior' => 'enviada'],
    'rechazada'   => ['siguiente' => null, 'anterior' => null],
    'facturada'   => ['siguiente' => null, 'anterior' => null],
    'cancelada'   => ['siguiente' => null, 'anterior' => null],
];
```

### 3.3 Búsqueda Avanzada

```php
// En cada Service
protected function applySearch($query, string $search)
{
    return $query->where(function ($q) use ($search) {
        $q->where('nombre', 'LIKE', "%{$search}%")
          ->orWhere('email', 'LIKE', "%{$search}%")
          ->orWhere('telefono', 'LIKE', "%{$search}%")
          ->orWhere('cedula', 'LIKE', "%{$search}%");
    });
}
```

### 3.4 Filtros Avanzados

```php
// En cada Service
protected function applyFilters($query, array $filters)
{
    if (!empty($filters['estado'])) {
        $query->where('estado', $filters['estado']);
    }
    if (!empty($filters['fecha_desde'])) {
        $query->where('created_at', '>=', $filters['fecha_desde']);
    }
    if (!empty($filters['fecha_hasta'])) {
        $query->where('created_at', '<=', $filters['fecha_hasta']);
    }
    if (!empty($filters['categoria_id'])) {
        $query->where('categoria_id', $filters['categoria_id']);
    }
    return $query;
}
```

### 3.5 Notificaciones

```php
// Servicio base de notificaciones
class NotificacionService
{
    public function enviar(string $titulo, string $mensaje, int $usuarioId, string $tipo = 'info'): void
    {
        Notificacion::create([
            'uuid' => Str::uuid(),
            'titulo' => $titulo,
            'mensaje' => $mensaje,
            'tipo' => $tipo,
            'usuario_id' => $usuarioId,
        ]);

        // Broadcast en tiempo real
        broadcast(new NuevaNotificacion($usuarioId, $titulo, $mensaje))->toOthers();
    }
}
```

### 3.6 Importación

```php
// Excel Import
class ProductoImport implements ToCollection, WithHeadingRow
{
    public function collection(Collection $rows)
    {
        foreach ($rows as $row) {
            Producto::updateOrCreate(
                ['codigo' => $row['codigo']],
                [
                    'nombre' => $row['nombre'],
                    'precio' => $row['precio'],
                    'stock' => $row['stock'],
                ]
            );
        }
    }
}
```

---

## FASE 4: SEGURIDAD Y AUDITORÍA

### 4.1 Auditoría Mejorada

```php
// En cada Controller
public function store(StoreVentaRequest $request)
{
    $venta = DB::transaction(function () use ($request) {
        $venta = $this->ventaService->create($request->validated());

        AuditoriaService::registrar(
            accion: 'crear',
            entidad: 'Venta',
            entidad_id: $venta->id,
            datos_nuevos: $venta->toArray(),
            ip: $request->ip(),
            user_agent: $request->userAgent()
        );

        return $venta;
    });

    return ApiResponse::success(new VentaResource($venta), 'Venta creada', 201);
}
```

### 4.2 Rate Limiting

```php
// routes/api.php
Route::middleware('throttle:60,1')->group(function () {
    Route::post('/ventas', [VentaController::class, 'store']);
    Route::post('/cotizaciones', [CotizacionController::class, 'store']);
    // ...
});
```

### 4.3 Validación de Permisos por Ruta

```php
// routes/api.php
Route::middleware(['auth:sanctum', 'module:ventas'])->group(function () {
    Route::get('/ventas', [VentaController::class, 'index']);
    Route::post('/ventas', [VentaController::class, 'store']);
    // ...
});
```

---

## FASE 5: TESTING

### 5.1 Estructura de Tests

```
tests/
├── Unit/
│   ├── Models/
│   │   ├── ClienteTest.php
│   │   ├── VentaTest.php
│   │   └── ProductoTest.php
│   └── Services/
│       ├── VentaServiceTest.php
│       └── InventarioServiceTest.php
├── Feature/
│   ├── Api/
│   │   ├── AuthTest.php
│   │   ├── ClienteApiTest.php
│   │   ├── VentaApiTest.php
│   │   └── CotizacionApiTest.php
│   └── Middleware/
│       ├── AuditLogTest.php
│       └── CheckModuleAccessTest.php
└── TestCase.php
```

### 5.2 Tests Críticos por Módulo

- CRUD completo (crear, leer, actualizar, eliminar)
- Soft delete y restauración
- Validación de permisos
- Búsqueda y filtros
- Paginación
- Estados y transiciones
- Exportación
- Auditoría de cambios

---

## RESUMEN DE ARCHIVOS A CREAR/MODIFICAR

### Backend - Nuevos:
1. `app/Traits/HasStandardFields.php`
2. `app/Traits/Permissible.php`
3. `app/Http/Middleware/CheckModuleAccess.php`
4. `app/Services/BaseService.php`
5. `app/Services/ExportService.php`
6. `app/Services/ImportService.php`
7. `app/Services/AuditoriaService.php`
8. `app/Services/NotificacionService.php`
9. `app/Http/Resources/ApiResponse.php`
10. `app/Http/Requests/BaseFormRequest.php`
11. `app/Http/Requests/` (una por cada endpoint)
12. `app/Services/` (uno por cada dominio)
13. `database/migrations/2026_07_13_000001_add_standard_columns.php`

### Backend - Modificar:
14. Todos los 44 modelos → agregar HasStandardFields + SoftDeletes
15. Todos los 40 controladores → refactorizar a Service Layer
16. `routes/api.php` → agregar middleware de permisos + rate limiting
17. `app/Traits/Auditable.php` → mejorar logging

### Frontend - Nuevos:
18. `resources/js/components/base/DataTable.vue`
19. `resources/js/components/base/Pagination.vue`
20. `resources/js/components/base/FilterBar.vue`
21. `resources/js/components/base/CrudModal.vue`
22. `resources/js/components/base/FormField.vue`
23. `resources/js/components/base/FormInput.vue`
24. `resources/js/components/base/FormSelect.vue`
25. `resources/js/components/base/FormTextarea.vue`
26. `resources/js/components/base/StatusBadge.vue`
27. `resources/js/components/base/LoadingSpinner.vue`
28. `resources/js/components/base/EmptyState.vue`
29. `resources/js/components/base/SearchInput.vue`
30. `resources/js/components/base/ExportDropdown.vue`
31. `resources/js/components/base/DeleteButton.vue`
32. `resources/js/composables/usePagination.js`
33. `resources/js/composables/useCrud.js`
34. `resources/js/composables/useExport.js`

### Frontend - Modificar:
35. Todas las 49 páginas → refactorizar usando componentes base
36. `resources/js/App.vue` → eliminar duplicación de popstate
37. `resources/js/router/index.js` → agregar 404 page + permisos
38. `resources/js/AppLayout.vue` → extraer sidebar y header

---

## ORDEN DE EJECUCIÓN RECOMENDADO

1. **Fase 0** (Cimentación) → 1-2 días
2. **Fase 1** (Componentes base) → 2-3 días
3. **Fase 2** (Refactorizar módulo Usuarios) → 1 día
4. **Fase 2** (Refactorizar módulo Clientes) → 1 día
5. **Fase 2** (Refactorizar módulo Productos) → 1 día
6. Continuar con módulos en orden de dependencia...

**Tiempo estimado total:** 15-20 días para refactorización completa
**Prioridad:** Fase 0 + Fase 1 primero (fundamentos), luego módulos uno por uno
