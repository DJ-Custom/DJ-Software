<template>
  <div>
      <div class="flex items-center justify-between mb-lg">
      <div class="flex items-center gap-md" style="flex-wrap:wrap; gap:8px; flex:1; min-width:0;">
        <div class="input-icon-wrapper" style="flex:1; min-width:200px; max-width:300px;">
          <i class="fas fa-search"></i>
          <input v-model="busqueda" type="text" class="form-control" :placeholder="i18n.t('buscar_productos')" style="padding-left:44px; width:100%; min-width:0;" @input="debounceSearch" />
        </div>
        <select v-model="filtros.categoria_id" class="form-control" style="width:100%; max-width:180px; min-width:0;" @change="cargar">
          <option value="">{{ i18n.t('todas_categorias') }}</option>
          <option v-for="c in categorias" :key="c.id" :value="c.id">{{ c.nombre }}</option>
        </select>
        <select v-model="filtros.stock_estado" class="form-control" style="width:100%; max-width:170px; min-width:0;" @change="cargar">
          <option value="">{{ i18n.t('todos_stocks') }}</option>
          <option value="sin_stock">{{ i18n.t('sin_stock') }}</option>
          <option value="bajo_stock">{{ i18n.t('bajo_stock') }}</option>
          <option value="suficiente">{{ i18n.t('suficiente') }}</option>
        </select>
        <select v-model="filtros.ubicacion_id" class="form-control" style="width:100%; max-width:180px; min-width:0;" @change="cargar">
          <option value="">{{ i18n.t('todas_ubicaciones') }}</option>
          <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
        </select>
      </div>
      <button class="btn btn-primary" style="flex-shrink:0;" @click="showModal = true; resetForm()">
        <i class="fas fa-plus"></i> {{ i18n.t('nuevo_producto') }}
      </button>
    </div>

    <div class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-boxes-stacked" style="margin-right:8px;"></i>{{ i18n.t('productos') }}</h3>
        <span class="badge badge-info">{{ total }} total</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('codigo') }}</th>
                <th>{{ i18n.t('nombre') }}</th>
                <th>{{ i18n.t('categoria') }}</th>
                <th>{{ i18n.t('proveedor_label') }}</th>
                <th>{{ i18n.t('precio') }}</th>
                <th v-if="filtros.ubicacion_id">{{ i18n.t('cant_ubic') }}</th>
                <th v-else>{{ i18n.t('stock') }}</th>
                <th v-if="filtros.ubicacion_id">{{ i18n.t('min_ubic') }}</th>
                <th v-else>{{ i18n.t('min') }}</th>
                <th>{{ i18n.t('estado') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in productos" :key="p.id" class="animate-fade-in">
                <td :data-label="i18n.t('codigo')"><code>{{ p.codigo }}</code></td>
                <td :data-label="i18n.t('nombre')"><strong>{{ p.nombre }}</strong></td>
                <td :data-label="i18n.t('categoria')">{{ p.categoria_nombre || '-' }}</td>
                <td :data-label="i18n.t('proveedor_label')">{{ p.proveedor_nombre || '-' }}</td>
                <td :data-label="i18n.t('precio')">{{ formatMoney(p.precio_venta) }}</td>
                <td v-if="filtros.ubicacion_id" :data-label="i18n.t('cant_ubic')">
                  <span :class="['badge',
                    (p.ubicacion_cantidad ?? 0) <= 0 ? 'badge-danger' : ((p.ubicacion_cantidad ?? 0) <= ((p.ubicacion_stock_minimo ?? p.stock_minimo) || 0) ? 'badge-warning' : 'badge-success')]"
                    style="font-weight:700; min-width:28px; display:inline-block; text-align:center;">
                    {{ p.ubicacion_cantidad ?? 0 }}
                  </span>
                </td>
                <td v-else :data-label="i18n.t('stock')">
                  <span :class="['badge',
                    p.stock <= 0 ? 'badge-danger' : (p.stock <= p.stock_minimo ? 'badge-warning' : 'badge-success')]"
                    :title="p.stock <= 0 ? i18n.t('sin_stock') : (p.stock <= p.stock_minimo ? i18n.t('bajo_stock') : 'Stock OK')"
                    style="font-weight:700; min-width:28px; display:inline-block; text-align:center;">
                    {{ p.stock }}
                  </span>
                </td>
                <td v-if="filtros.ubicacion_id" :data-label="i18n.t('min_ubic')"><span style="font-size:12px; color:var(--text-muted);">{{ (p.ubicacion_stock_minimo ?? p.stock_minimo) || 0 }}</span></td>
                <td v-else :data-label="i18n.t('min')"><span style="font-size:12px; color:var(--text-muted);">{{ p.stock_minimo || 0 }}</span></td>
                <td :data-label="i18n.t('estado')">
                  <template v-if="filtros.ubicacion_id">
                    <span v-if="(p.ubicacion_cantidad ?? 0) <= 0" class="badge badge-danger"><i class="fas fa-times-circle" style="margin-right:4px;"></i>{{ i18n.t('sin_stock') }}</span>
                    <span v-else-if="(p.ubicacion_cantidad ?? 0) <= ((p.ubicacion_stock_minimo ?? p.stock_minimo) || 0)" class="badge badge-warning"><i class="fas fa-exclamation-triangle" style="margin-right:4px;"></i>{{ i18n.t('bajo_stock') }}</span>
                    <span v-else class="badge badge-success"><i class="fas fa-check-circle" style="margin-right:4px;"></i>OK</span>
                  </template>
                  <template v-else>
                    <span v-if="p.stock <= 0" class="badge badge-danger"><i class="fas fa-times-circle" style="margin-right:4px;"></i>{{ i18n.t('sin_stock') }}</span>
                    <span v-else-if="p.stock <= p.stock_minimo" class="badge badge-warning"><i class="fas fa-exclamation-triangle" style="margin-right:4px;"></i>{{ i18n.t('bajo_stock') }}</span>
                    <span v-else class="badge badge-success"><i class="fas fa-check-circle" style="margin-right:4px;"></i>OK</span>
                  </template>
                </td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" @click="editar(p)"><i class="fas fa-edit"></i></button>
                  <button class="btn btn-sm btn-danger" @click="deleteItem(p, 'productos', cargar)"><i class="fas fa-trash"></i></button>
                </td>
              </tr>
              <tr v-if="!productos.length && !loading">
                <td colspan="9" style="text-align:center; padding:40px; color: var(--text-muted);">{{ i18n.t('no_hay_productos') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer flex justify-between items-center" v-if="pages > 1">
        <span style="font-size:13px; color: var(--text-secondary);">{{ i18n.tp('pagina_de', { n: page, total: pages }) }}</span>
        <div class="flex gap-sm">
          <button class="btn btn-sm btn-secondary" :disabled="page <= 1" @click="page--; cargar()">{{ i18n.t('anterior') }}</button>
          <button class="btn btn-sm btn-secondary" :disabled="page >= pages" @click="page++; cargar()">{{ i18n.t('siguiente') }}</button>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal" style="max-width: min(90vw, 600px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingId ? i18n.t('editar_producto') : i18n.t('nuevo_producto') }}</h3>
          <button class="modal-close" @click="showModal = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('codigo') }} *</label>
              <input v-model="form.codigo" class="form-control" placeholder="SKU-001" required/>
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('codigo_barras') }}</label>
              <input v-model="form.codigo_barras" class="form-control" placeholder="7501234567890" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('nombre') }} *</label>
            <input v-model="form.nombre" class="form-control" :placeholder="i18n.t('nombre')" required />
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('categoria') }}</label>
              <select v-model="form.categoria_id" class="form-control">
                <option value="">{{ i18n.t('sin_categoria') }}</option>
                <option v-for="c in categorias" :key="c.id" :value="c.id">{{ c.nombre }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('proveedor_label') }}</label>
              <select v-model="form.proveedor_id" class="form-control">
                <option value="">{{ i18n.t('sin_proveedor') }}</option>
                <option v-for="pr in proveedores" :key="pr.id" :value="pr.id">{{ pr.nombre }}</option>
              </select>
            </div>
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('precio_compra') }}</label>
              <input v-model="form.precio_compra" type="number" :min="0" step="0.01" class="form-control" @input="normalizarMinimo(form, 'precio_compra', 0)" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('precio_venta') }}</label>
              <input v-model.number="form.precio_venta" type="number" :min="0" step="0.01" class="form-control" required @input="normalizarMinimo(form, 'precio_venta', 0)" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('margen_ganancia') }}</label>
            <div class="form-control" style="display:flex;align-items:center;justify-content:space-between;background:var(--bg-card);">
              <span :class="['badge', margenGanancia >= 30 ? 'badge-success' : margenGanancia >= 10 ? 'badge-info' : 'badge-danger']" style="font-size:14px;">
                {{ margenGanancia.toFixed(2) }}%
              </span>
              <span style="font-size:12px;color:var(--text-muted);">
                {{ formatMoney((Number(form.precio_venta) || 0) - (Number(form.precio_compra) || 0)) }} {{ i18n.t('utilidad') }}
              </span>
            </div>
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('stock_minimo') }}</label>
              <input v-model="form.stock_minimo" type="number" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('impuesto_pct') }}</label>
              <input v-model="form.impuesto" type="number" step="0.01" class="form-control" />
            </div>
          </div>
          <div class="mt-md">
            <div class="flex items-center justify-between mb-sm">
              <label class="form-label">{{ editingId ? i18n.t('inventario_por_ubicacion') : i18n.t('stock_inicial_ubicacion') }}</label>
            </div>
            <div class="table-container" style="max-height:260px;">
              <table class="data-table" style="font-size:13px;">
                <thead>
                  <tr>
                    <th>{{ i18n.t('ubicacion') }}</th>
                    <th style="width:90px;">{{ i18n.t('cantidad') }}</th>
                    <th style="width:90px;">{{ i18n.t('reserv') }}</th>
                    <th style="width:80px;">{{ i18n.t('min') }}</th>
                    <th style="width:80px;">{{ i18n.t('max') }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="inv in form.inventario_ubicaciones" :key="inv.ubicacion_id">
                    <td>{{ inv.ubicacion_nombre }}</td>
                    <td><input v-model.number="inv.cantidad" type="number" min="0" class="form-control" style="padding:4px 8px; font-size:13px;" /></td>
                    <td><input v-model.number="inv.cantidad_reservada" type="number" min="0" class="form-control" style="padding:4px 8px; font-size:13px;" /></td>
                    <td><input v-model.number="inv.stock_minimo" type="number" min="0" class="form-control" style="padding:4px 8px; font-size:13px;" placeholder="-" /></td>
                    <td><input v-model.number="inv.stock_maximo" type="number" min="0" class="form-control" style="padding:4px 8px; font-size:13px;" placeholder="-" /></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showModal = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardar" :disabled="isSubmitting">
            <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
            <span v-if="isSubmitting">{{ i18n.t('guardando') }}</span>
            <span v-else>{{ editingId ? i18n.t('guardar') : i18n.t('crear') }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useSubmitLock } from '../composables/useSubmitLock';
import { useConfirmStore } from '../stores/confirm';
import { useI18nStore } from '../stores/i18n';
import common from '../composables/common.js';

const { 
  formatMoney,
  deleteItem,
  normalizarMinimo
} = common;

const toast = useToastStore();
const confirm = useConfirmStore();
const i18n = useI18nStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: 'Guardando producto...' });
const productos = ref([]);
const categorias = ref([]);
const proveedores = ref([]);
const ubicaciones = ref([]);
const total = ref(0);
const page = ref(1);
const pages = ref(1);
const loading = ref(false);
const busqueda = ref('');
const filtros = ref({ categoria_id: '', stock_estado: '', ubicacion_id: '' });
const showModal = ref(false);
const editingId = ref(null);
const form = ref({});
const margenGanancia = computed(() => {
    const compra = Number(form.value.precio_compra) || 0;
    const venta = Number(form.value.precio_venta) || 0;
    if (venta <= 0) return 0;
    return ((venta - compra) / venta) * 100;
});

// Computed keys for the location inventory section label
const inventario_por_ubicacion = computed(() => i18n.t('inventario_por_ubicacion'));
const stock_inicial_ubicacion = computed(() => i18n.t('stock_inicial_ubicacion'));

let searchTimeout = null;

onMounted(() => { cargar(); cargarCategorias(); cargarProveedores(); cargarUbicaciones(); });

async function cargar() {
    loading.value = true;
    try {
        const params = { page: page.value, q: busqueda.value, ...filtros.value };
        const { data } = await api.get('/productos', { params });
        productos.value = data.productos;
        total.value = data.total;
        pages.value = data.pages;
    } catch (e) { console.error(e); }
    loading.value = false;
}

async function cargarCategorias() {
    try {
        const { data } = await api.get('/productos/categorias');
        categorias.value = data.categorias;
    } catch (e) { console.error(e); }
}

async function cargarProveedores() {
    try {
        const { data } = await api.get('/proveedores/buscar', { params: { q: '' } });
        proveedores.value = data.proveedores || [];
    } catch (e) { console.error(e); }
}

async function cargarUbicaciones() {
    try {
        const { data } = await api.get('/configuracion/ubicaciones');
        ubicaciones.value = (data.ubicaciones || []).filter(u => u.activo);
    } catch (e) { console.error(e); }
}

function debounceSearch() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => { page.value = 1; cargar(); }, 400);
}

function resetForm() {
    editingId.value = null;
    form.value = { codigo: '', codigo_barras: '', nombre: '', categoria_id: '', proveedor_id: '', precio_compra: 0, precio_venta: 0, stock: 0, stock_minimo: 5, impuesto: 13, activo: 1, inventario_ubicaciones: [] };
    inicializarInventarioUbicaciones();
}

function inicializarInventarioUbicaciones() {
    if (!form.value.inventario_ubicaciones) form.value.inventario_ubicaciones = [];
    ubicaciones.value.forEach(u => {
        const existe = form.value.inventario_ubicaciones.find(iu => iu.ubicacion_id == u.id);
        if (!existe) {
            form.value.inventario_ubicaciones.push({
                ubicacion_id: u.id,
                ubicacion_nombre: u.nombre,
                cantidad: 0,
                cantidad_reservada: 0,
                stock_minimo: null,
                stock_maximo: null,
            });
        } else if (!existe.ubicacion_nombre) {
            existe.ubicacion_nombre = u.nombre;
        }
    });
}

async function editar(p) {
    editingId.value = p.id;
    try {
        form.value = { ...p };
        if (!form.value.inventario_ubicaciones) form.value.inventario_ubicaciones = [];
        inicializarInventarioUbicaciones();
        showModal.value = true;
    } catch (e) {
        toast.error(i18n.t('error_guardar'));
        console.error(e);
    }
}

async function guardar() {
    try {
        await execute(async () => {
              let url = editingId.value ? `/productos/${editingId.value}` : '/productos';
              await api.post(url, { ...form.value, _method: editingId.value ? 'PUT' : 'POST' });
              toast.success(editingId.value ? i18n.t('producto_actualizado') : i18n.t('producto_creado'));
            showModal.value = false;
            cargar();
        });
    } catch (e) {
        const data = e.response?.data || {};

        if (data?.errors) {
            const mensajes = Object.values(data.errors)
                .flat()
                .join('\n');

            toast.error(mensajes);
            return;
        }
        toast.error(data?.message || data?.error || i18n.t('error_guardar'));
    }
}

</script>

<style scoped>
.fa-search {
    color: #ffffff;
    margin-right: -30px;
    position: relative;
    z-index: 10;
}
[data-theme="dark"] .fa-search {
    color: #051322;
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
}

@media (max-width: 1023px) {
  .filter-bar { gap: 8px; }
  .flex.items-center.gap-md {
    flex-wrap: wrap;
    gap: 8px;
  }
  .flex.items-center.gap-md > .form-control,
  .flex.items-center.gap-md > select {
    max-width: 200px !important;
  }
}

@media (max-width: 768px) {
  .flex.items-center.gap-md {
    flex-wrap: wrap;
    gap: 8px;
  }
  .flex.items-center.gap-md > * {
    flex: 1 1 100%;
    min-width: 0;
    max-width: 100% !important;
  }
  .filter-bar {
    flex-direction: column;
    align-items: stretch;
  }
  .filter-bar .form-control,
  .filter-bar select {
    width: 100% !important;
    max-width: 100% !important;
  }
  .btn {
    min-height: 44px;
    -webkit-tap-highlight-color: transparent;
  }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 600px; }
  .data-table thead { display: none; }
  .data-table tbody tr {
    display: block;
    margin-bottom: 12px;
    padding: 12px;
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 8px;
  }
  .data-table tbody td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 0;
    border: none;
    border-bottom: 1px solid var(--border-color);
    text-align: right;
  }
  .data-table tbody td:last-child {
    border-bottom: none;
    justify-content: flex-end;
    gap: 8px;
  }
  .data-table tbody td::before {
    content: attr(data-label);
    font-weight: 600;
    color: var(--text-secondary);
    text-align: left;
    margin-right: auto;
    padding-right: 12px;
  }
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 12px 16px;
  }
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .filter-bar { gap: 6px; }
  .btn {
    min-height: 48px;
    width: 100%;
    font-size: 14px;
    -webkit-tap-highlight-color: transparent;
  }
  .page-header .btn { flex: 1 1 100%; }
  .data-table tbody tr { margin-bottom: 8px; padding: 10px; }
  .data-table tbody td { padding: 5px 0; font-size: 13px; }
  .card-body { padding: 8px !important; }
  .data-table { min-width: 100%; }
  .modal-body { overflow-y: auto; }
}
</style>
