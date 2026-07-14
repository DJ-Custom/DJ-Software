<template>
  <div>
    <!-- Dashboard Stats -->
    <div class="grid-4 gap-md mb-lg">
      <div class="card stat-card">
        <div class="stat-icon" style="background: rgba(59,130,246,0.12); color: #3b82f6;"><i class="fas fa-cubes"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.stock_total }}</div>
          <div class="stat-label">{{ i18n.t('inventario_ubicacion_stock_total') }}</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background: rgba(245,158,11,0.12); color: #f59e0b;"><i class="fas fa-warehouse"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.stock_reservado }}</div>
          <div class="stat-label">{{ i18n.t('inventario_ubicacion_stock_reservado') }}</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background: rgba(239,68,68,0.12); color: #ef4444;"><i class="fas fa-times-circle"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.productos_agotados }}</div>
          <div class="stat-label">{{ i18n.t('inventario_ubicacion_productos_agotados') }}</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background: rgba(16,185,129,0.12); color: #10b981;"><i class="fas fa-arrow-trend-up"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.productos_bajo_stock }}</div>
          <div class="stat-label">{{ i18n.t('inventario_ubicacion_stock_bajo') }}</div>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="card mb-lg">
      <div class="card-body">
        <div class="flex flex-wrap gap-md items-end">
          <div class="form-group" style="min-width:200px; flex:1; max-width:100%;">
            <label class="form-label">{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label>
            <div class="input-icon-wrapper">
              <i class="fas fa-search"></i>
              <input v-model="filtros.q" type="text" class="form-control" :placeholder="i18n.t('inventario_ubicacion_buscar_producto')" @input="debounceCargar" style="padding-left:44px; width:100%; min-width:0;" />
            </div>
          </div>
          <div class="form-group" style="width:100%; max-width:180px; min-width:0;">
            <label class="form-label">{{ i18n.t('ubicacion') }}</label>
            <select v-model="filtros.ubicacion_id" class="form-control" @change="cambioUbicacion">
              <option value="">{{ i18n.t('inventario_ubicacion_todas_las_ubicaciones') }}</option>
              <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:180px; min-width:0;">
            <label class="form-label">{{ i18n.t('categoria') }}</label>
            <select v-model="filtros.categoria_id" class="form-control" @change="page=1; cargar()">
              <option value="">{{ i18n.t('todas_categorias') }}</option>
              <option v-for="c in categorias" :key="c.id" :value="c.id">{{ c.nombre }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:180px; min-width:0;">
            <label class="form-label">{{ i18n.t('inventario_ubicacion_disponible') }}</label>
            <select v-model="filtros.disponibilidad" class="form-control" @change="page=1; cargar()">
              <option value="">{{ i18n.t('todas_categorias') }}</option>
              <option value="disponible">{{ i18n.t('inventario_ubicacion_disponible') }}</option>
              <option value="stock_bajo">{{ i18n.t('inventario_ubicacion_stock_bajo') }}</option>
              <option value="agotados">{{ i18n.t('inventario_ubicacion_productos_agotados') }}</option>
            </select>
          </div>
          <button class="btn btn-primary" style="flex-shrink:0;" @click="showTransferir=true; resetTransferir()"><i class="fas fa-exchange-alt"></i> {{ i18n.t('inventario_ubicacion_transferir') }}</button>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-boxes-stacked" style="margin-right:8px;"></i>{{ i18n.t('inventario_ubicacion') }}</h3>
        <span class="badge badge-info">{{ total }} {{ i18n.t('resultados') }}</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('inventario_ubicacion_producto') }}</th>
                <th v-if="!filtros.ubicacion_id">{{ i18n.t('inventario_ubicacion_ubicacion') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_disponible') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_reservado') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_minimo') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_maximo') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_estado') }}</th>
                <th>{{ i18n.t('modificado') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in productos" :key="p.id + (filtros.ubicacion_id || '')" class="animate-fade-in">
                <td>
                  <div style="display:flex; align-items:center; gap:8px;">
                    <div style="width:36px; height:36px; border-radius:6px; background:var(--bg-hover); display:flex; align-items:center; justify-content:center; overflow:hidden;">
                      <img v-if="p.imagen" :src="p.imagen" style="width:100%; height:100%; object-fit:cover;">
                      <i v-else class="fas fa-box" style="color:var(--text-muted);"></i>
                    </div>
                    <div>
                      <div style="font-weight:600;">{{ p.nombre }}</div>
                      <div style="font-size:12px; color:var(--text-muted);">{{ p.codigo || 'Sin código' }} — {{ p.categoria_nombre || '-' }}</div>
                    </div>
                  </div>
                </td>
                <td v-if="!filtros.ubicacion_id">
                  <div v-if="p.inventario_ubicaciones?.length" class="flex flex-wrap gap-xs">
                    <span v-for="iu in p.inventario_ubicaciones.slice(0,3)" :key="iu.id" class="badge badge-info" style="font-size:11px;">
                      {{ iu.ubicacion?.nombre || iu.ubicacion_nombre }}: {{ iu.cantidad }}
                    </span>
                    <span v-if="p.inventario_ubicaciones.length > 3" class="badge badge-secondary" style="font-size:11px;">+{{ p.inventario_ubicaciones.length - 3 }}</span>
                  </div>
                  <span v-else class="badge badge-danger">{{ i18n.t('sin_stock') }}</span>
                </td>
                <td>
                  <div style="display:flex; align-items:center; gap:8px;">
                    <span style="font-weight:700; min-width:28px;">{{ p.stock_disponible }}</span>
                    <div class="progress-bar-bg" style="width:80px;">
                      <div class="progress-bar-fill" :style="{ width: porcentajeStock(p) + '%', background: colorStock(p) }"></div>
                    </div>
                  </div>
                </td>
                <td>{{ p.stock_reservado }}</td>
                <td>{{ p.stock_minimo_loc ?? '-' }}</td>
                <td>{{ p.stock_maximo_loc ?? '-' }}</td>
                <td>
                  <span :class="['badge', badgeEstado(p.estado_stock)]">
                    {{ textoEstado(p.estado_stock) }}
                  </span>
                </td>
                <td style="font-size:12px; color:var(--text-muted);">
                  {{ p.ultima_actualizacion ? formatDate(p.ultima_actualizacion) : '-' }}
                </td>
                <td>
                  <button class="btn btn-sm btn-ghost" :title="i18n.t('ver_detalles')" @click="verMovimientos(p)"><i class="fas fa-history"></i></button>
                  <button class="btn btn-sm btn-ghost" :title="i18n.t('editar')" @click="editarStock(p)"><i class="fas fa-edit"></i></button>
                </td>
              </tr>
              <tr v-if="!productos.length && !loading">
                <td :colspan="filtros.ubicacion_id ? 8 : 9" style="text-align:center; padding:40px; color: var(--text-muted);">{{ i18n.t('inventario_ubicacion_sin_productos') }}</td>
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

    <!-- Modal Movimientos -->
    <div class="modal-overlay" :class="{ active: showMovimientos }" @click.self="showMovimientos = false">
      <div class="modal" style="max-width: min(90vw, 900px);">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-history" style="margin-right:8px;"></i>{{ i18n.t('modificado') }}</h3>
          <button class="modal-close" @click="showMovimientos = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div v-if="movimientoProducto" class="mb-md" style="display:flex; gap:12px; align-items:center;">
            <div style="font-weight:700;">{{ movimientoProducto.nombre }}</div>
            <span class="badge badge-secondary">{{ movimientoProducto.codigo }}</span>
          </div>
          <div class="table-container" style="max-height:400px;">
            <table class="data-table" style="font-size:13px;">
              <thead><tr><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('contabilidad_tipo') }}</th><th>{{ i18n.t('ubicacion') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('ajustes_stock_anterior') }}</th><th>{{ i18n.t('ajustes_stock_nuevo') }}</th><th>{{ i18n.t('referencia') }}</th><th>{{ i18n.t('usuario') }}</th></tr></thead>
              <tbody>
                <tr v-for="m in movimientos.data" :key="m.id">
                  <td style="white-space:nowrap;">{{ formatDateTime(m.created_at) }}</td>
                  <td><span :class="['badge', badgeTipoMovimiento(m.tipo)]">{{ m.tipo }}</span></td>
                  <td>
                    <span v-if="m.ubicacion">{{ m.ubicacion.nombre }}</span>
                    <span v-if="m.ubicacion_destino" style="color:var(--text-muted);">→ {{ m.ubicacion_destino.nombre }}</span>
                    <span v-if="!m.ubicacion && !m.ubicacion_destino">-</span>
                  </td>
                  <td style="font-weight:700;">{{ m.cantidad }}</td>
                  <td>{{ m.stock_anterior }}</td>
                  <td>{{ m.stock_nuevo }}</td>
                  <td style="color:var(--text-muted);">{{ m.referencia_tipo || '-' }}</td>
                  <td>{{ m.usuario?.nombre || '-' }}</td>
                </tr>
                <tr v-if="!movimientos.data?.length"><td colspan="8" style="text-align:center; padding:24px;">{{ i18n.t('sin_datos') }}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Editar Stock -->
    <div class="modal-overlay" :class="{ active: showEditarStock }" @click.self="showEditarStock = false">
      <div class="modal" style="max-width: min(90vw, 500px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ i18n.t('ajustes_stock_nuevo') }} - {{ i18n.t('ubicacion') }}</h3>
          <button class="modal-close" @click="showEditarStock = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" v-if="editarForm.producto">
          <div class="mb-md" style="font-weight:600;">{{ editarForm.producto.nombre }}</div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('ubicacion') }}</label>
            <select v-model="editarForm.ubicacion_id" class="form-control" @change="onCambioUbicacionEditar">
              <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select>
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cantidad') }} {{ i18n.t('total') }}</label>
              <input v-model.number="editarForm.cantidad" type="number" min="0" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cantidad') }} {{ i18n.t('inventario_ubicacion_reservado') }}</label>
              <input v-model.number="editarForm.cantidad_reservada" type="number" min="0" class="form-control" />
            </div>
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('stock_minimo') }}</label>
              <input v-model.number="editarForm.stock_minimo" type="number" min="0" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('inventario_ubicacion_maximo') }}</label>
              <input v-model.number="editarForm.stock_maximo" type="number" min="0" class="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('inventario_ubicacion_disponible') }}</label>
            <div class="form-control" style="background:var(--bg-hover);">{{ Math.max(0, (editarForm.cantidad || 0) - (editarForm.cantidad_reservada || 0)) }}</div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showEditarStock = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardarStock" :disabled="isSavingStock"><i v-if="isSavingStock" class="fas fa-spinner fa-spin"></i> <span v-if="isSavingStock">{{ i18n.t('actualizando') }}</span><span v-else>{{ i18n.t('guardar') }}</span></button>
        </div>
      </div>
    </div>

    <!-- Modal Transferir -->
    <div class="modal-overlay" :class="{ active: showTransferir }" @click.self="showTransferir = false">
      <div class="modal" style="max-width: min(90vw, 600px);">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-exchange-alt" style="margin-right:8px;"></i>{{ i18n.t('inventario_ubicacion_transferir') }}</h3>
          <button class="modal-close" @click="showTransferir = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">{{ i18n.t('producto') }}</label>
            <input v-model="transferirBuscar" class="form-control" :placeholder="i18n.t('traspasos_buscar_producto')" @input="buscarProductosTransferir" />
            <div v-if="transferirProductos.length" style="max-height:150px; overflow:auto; border:1px solid var(--bg-hover); border-radius:8px; margin-top:4px;">
              <div v-for="p in transferirProductos" :key="p.id" class="p-sm" style="cursor:pointer; border-bottom:1px solid var(--bg-hover);" @click="seleccionarProductoTransferir(p)">
                {{ p.nombre }} ({{ i18n.t('stock') }}: {{ p.stock }})
              </div>
            </div>
            <div v-if="transferirForm.producto" class="mt-sm">
              <span class="badge badge-primary">{{ transferirForm.producto.nombre }}</span>
            </div>
          </div>
          <div class="grid-2 gap-md">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('inventario_ubicacion_ubicacion_origen') }}</label>
              <select v-model="transferirForm.ubicacion_origen_id" class="form-control">
                <option value="">{{ i18n.t('seleccionar') }}...</option>
                <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('inventario_ubicacion_ubicacion_destino') }}</label>
              <select v-model="transferirForm.ubicacion_destino_id" class="form-control">
                <option value="">{{ i18n.t('seleccionar') }}...</option>
                <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cantidad') }}</label>
            <input v-model.number="transferirForm.cantidad" type="number" min="1" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('nota') }}</label>
            <textarea v-model="transferirForm.notas" class="form-control" rows="2"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showTransferir = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="confirmarTransferir" :disabled="!transferirForm.producto || !transferirForm.ubicacion_origen_id || !transferirForm.ubicacion_destino_id || !transferirForm.cantidad || isTransferring">
            <i v-if="isTransferring" class="fas fa-spinner fa-spin"></i>
            <span v-if="isTransferring">{{ i18n.t('procesando') }}</span>
            <span v-else>{{ i18n.t('inventario_ubicacion_transferir') }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';
import { useSubmitLock } from '../composables/useSubmitLock';

const i18n = useI18nStore();
const toast = useToastStore();
const { isSubmitting: isSavingStock, execute: executeStock } = useSubmitLock({ loadingText: i18n.t('actualizando') });
const { isSubmitting: isTransferring, execute: executeTransfer } = useSubmitLock({ loadingText: i18n.t('procesando') });

const productos = ref([]);
const total = ref(0);
const page = ref(1);
const pages = ref(1);
const loading = ref(false);
const categorias = ref([]);
const ubicaciones = ref([]);

const filtros = reactive({ q: '', ubicacion_id: '', categoria_id: '', disponibilidad: '' });

const stats = reactive({
  stock_total: 0,
  stock_reservado: 0,
  productos_agotados: 0,
  productos_bajo_stock: 0,
});

const showMovimientos = ref(false);
const movimientos = ref({ data: [] });
const movimientoProducto = ref(null);

const showEditarStock = ref(false);
const editarForm = reactive({ producto: null, ubicacion_id: '', cantidad: 0, cantidad_reservada: 0, stock_minimo: null, stock_maximo: null });

const showTransferir = ref(false);
const transferirForm = reactive({ producto: null, ubicacion_origen_id: '', ubicacion_destino_id: '', cantidad: 1, notas: '' });
const transferirBuscar = ref('');
const transferirProductos = ref([]);

let searchTimeout = null;

onMounted(() => {
  cargarUbicaciones();
  cargarCategorias();
  cargar();
  cargarStats();
});

async function cargar() {
  loading.value = true;
  try {
    const params = { page: page.value, ...filtros };
    const { data } = await api.get('/inventario', { params });
    productos.value = data.productos;
    total.value = data.total;
    pages.value = data.pages;
  } catch (e) { console.error(e); }
  loading.value = false;
}

async function cargarStats() {
  try {
    const { data } = await api.get('/inventario/dashboard', { params: { ubicacion_id: filtros.ubicacion_id } });
    stats.stock_total = data.stock_total;
    stats.stock_reservado = data.stock_reservado;
    stats.productos_agotados = data.productos_agotados;
    stats.productos_bajo_stock = data.productos_bajo_stock;
  } catch (e) { console.error(e); }
}

async function cargarUbicaciones() {
  try {
    const { data } = await api.get('/configuracion/ubicaciones');
    ubicaciones.value = data.ubicaciones || [];
  } catch (e) { console.error(e); }
}

async function cargarCategorias() {
  try {
    const { data } = await api.get('/productos/categorias');
    categorias.value = data.categorias || [];
  } catch (e) { console.error(e); }
}

function debounceCargar() {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => { page.value = 1; cargar(); }, 400);
}

function cambioUbicacion() {
  page.value = 1;
  cargar();
  cargarStats();
}

function porcentajeStock(p) {
  const max = p.stock_maximo_loc || Math.max(p.stock_disponible, p.stock_total, 10);
  if (max <= 0) return 0;
  return Math.min(100, Math.round((p.stock_disponible / max) * 100));
}

function colorStock(p) {
  if (p.estado_stock === 'agotado') return '#ef4444';
  if (p.estado_stock === 'bajo') return '#f59e0b';
  if (p.estado_stock === 'alto') return '#10b981';
  return '#3b82f6';
}

function badgeEstado(estado) {
  return { agotado: 'badge-danger', bajo: 'badge-warning', medio: 'badge-info', alto: 'badge-success' }[estado] || 'badge-secondary';
}

function textoEstado(estado) {
  return { agotado: i18n.t('sin_stock'), bajo: i18n.t('bajo_stock'), medio: i18n.t('suficiente'), alto: i18n.t('activo') }[estado] || estado;
}

function formatDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function formatDateTime(d) {
  if (!d) return '-';
  return new Date(d).toLocaleString('es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

async function verMovimientos(p) {
  movimientoProducto.value = { nombre: p.nombre, codigo: p.codigo };
  showMovimientos.value = true;
  try {
    const params = { producto_id: p.id };
    if (filtros.ubicacion_id) params.ubicacion_id = filtros.ubicacion_id;
    const { data } = await api.get('/inventario/movimientos', { params });
    movimientos.value = data;
  } catch (e) { console.error(e); }
}

function badgeTipoMovimiento(tipo) {
  return { entrada: 'badge-success', salida: 'badge-danger', transferencia: 'badge-info', ajuste: 'badge-warning' }[tipo] || 'badge-secondary';
}

function editarStock(p) {
  editarForm.producto = p;
  editarForm.ubicacion_id = filtros.ubicacion_id || (p.inventario_ubicaciones?.[0]?.ubicacion_id) || (ubicaciones.value[0]?.id) || '';
  onCambioUbicacionEditar();
  showEditarStock.value = true;
}

function onCambioUbicacionEditar() {
  if (!editarForm.producto) return;
  const inv = editarForm.producto.inventario_ubicaciones?.find(iu => iu.ubicacion_id == editarForm.ubicacion_id);
  if (inv) {
    editarForm.cantidad = inv.cantidad;
    editarForm.cantidad_reservada = inv.cantidad_reservada || 0;
    editarForm.stock_minimo = inv.stock_minimo;
    editarForm.stock_maximo = inv.stock_maximo;
  } else {
    editarForm.cantidad = 0;
    editarForm.cantidad_reservada = 0;
    editarForm.stock_minimo = null;
    editarForm.stock_maximo = null;
  }
}

async function guardarStock() {
  try {
    await executeStock(async () => {
      await api.post('/inventario/actualizar-stock', {
        producto_id: editarForm.producto.id,
        ubicacion_id: editarForm.ubicacion_id,
        cantidad: editarForm.cantidad,
        cantidad_reservada: editarForm.cantidad_reservada,
        stock_minimo: editarForm.stock_minimo,
        stock_maximo: editarForm.stock_maximo,
      });
      toast.success(i18n.t('registro_guardado'));
      showEditarStock.value = false;
      cargar();
      cargarStats();
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning(i18n.t('solicitud_procesando'));
    } else {
      toast.error(e.response?.data?.error || i18n.t('error_guardar'));
    }
  }
}

function resetTransferir() {
  transferirForm.producto = null;
  transferirForm.ubicacion_origen_id = '';
  transferirForm.ubicacion_destino_id = '';
  transferirForm.cantidad = 1;
  transferirForm.notas = '';
  transferirBuscar.value = '';
  transferirProductos.value = [];
}

async function buscarProductosTransferir() {
  if (transferirBuscar.value.length < 2) { transferirProductos.value = []; return; }
  try {
    const { data } = await api.get('/productos/buscar', { params: { q: transferirBuscar.value } });
    transferirProductos.value = data.productos || [];
  } catch (e) {}
}

function seleccionarProductoTransferir(p) {
  transferirForm.producto = p;
  transferirBuscar.value = p.nombre;
  transferirProductos.value = [];
}

async function confirmarTransferir() {
  try {
    await executeTransfer(async () => {
      await api.post('/inventario/transferir', {
        producto_id: transferirForm.producto.id,
        ubicacion_origen_id: transferirForm.ubicacion_origen_id,
        ubicacion_destino_id: transferirForm.ubicacion_destino_id,
        cantidad: transferirForm.cantidad,
        notas: transferirForm.notas,
      });
      toast.success(i18n.t('registro_guardado'));
      showTransferir.value = false;
      resetTransferir();
      cargar();
      cargarStats();
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning(i18n.t('solicitud_procesando'));
    } else {
      toast.error(e.response?.data?.error || i18n.t('error_guardar'));
    }
  }
}
</script>

<style scoped>
.stat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
}
.stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}
.stat-value {
  font-size: 22px;
  font-weight: 700;
  line-height: 1;
}
.stat-label {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 2px;
}
.progress-bar-bg {
  height: 8px;
  background: var(--bg-hover);
  border-radius: 4px;
  overflow: hidden;
}
.progress-bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.4s ease;
}
.gap-xs { gap: 4px; }

@media (max-width: 1023px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .flex.flex-wrap.gap-md.items-end {
    flex-wrap: wrap;
    gap: 8px;
  }
  .flex.flex-wrap.gap-md.items-end > .form-group {
    flex: 1 1 calc(50% - 8px);
    min-width: 0;
    max-width: 100% !important;
  }
}

@media (max-width: 768px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .progress-bar-bg { width: 60px; }
  .flex.flex-wrap.gap-md.items-end {
    flex-direction: column;
    gap: 8px;
  }
  .flex.flex-wrap.gap-md.items-end > .form-group,
  .flex.flex-wrap.gap-md.items-end > .btn {
    flex: 1 1 100%;
    min-width: 100%;
    max-width: 100% !important;
  }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 700px; }
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
  .grid-4 { grid-template-columns: 1fr; }
  .btn { min-height: 44px; width: 100%; font-size: 15px; }
  .progress-bar-bg { width: 50px; }
  .data-table thead { display: none; }
  .data-table tbody tr {
    display: flex; flex-direction: column; padding: 12px; margin: 8px;
    border: 1px solid var(--border); border-radius: 8px;
    background: var(--bg-card); gap: 4px;
  }
  .data-table tbody td {
    display: flex; justify-content: space-between; align-items: center;
    padding: 4px 0; font-size: 14px; white-space: normal; border: none;
  }
  .data-table tbody td::before {
    content: attr(data-label); font-weight: 600; color: var(--text-secondary); min-width: 40%;
  }
  .data-table { min-width: 100%; }
  .modal-body { overflow-y: auto; }
}
</style>
