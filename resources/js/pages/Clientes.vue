<template>
  <div>
    <div class="flex items-center justify-between mb-lg clientes-topbar">
      <div class="flex items-center gap-md clientes-filtros">
        <div class="input-icon-wrapper search-wrapper">
          <i class="fas fa-search"></i>
          <input v-model="busqueda" type="text" class="form-control search-input" :placeholder="i18n.t('buscar_clientes')" @input="debounceSearch" />
        </div>
        <select v-model="filtros.cliente_categoria_id" class="form-control select-filtro" @change="cargar">
          <option value="">{{ i18n.t('todas_categorias_clientes') }}</option>
          <option v-for="cat in clienteCategorias" :key="cat.id" :value="cat.id">{{ cat.nombre }}</option>
        </select>
      </div>
      <div class="flex items-center gap-sm">
        <DateRangeDownloader :fetch-data="fetchClientesRange" filename="clientes" :columns="clientesColumns" />
        <button class="btn btn-primary btn-nuevo" @click="abrirModalNuevo()">
          <i class="fas fa-plus"></i> {{ i18n.t('nuevo_cliente') }}
        </button>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-users" style="margin-right:8px;"></i>{{ i18n.t('clientes') }}</h3>
        <span class="badge badge-info">{{ total }} {{ i18n.t('total') }}</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('cliente_nombre') }}</th>
                <th>{{ i18n.t('cliente_cedula') }}</th>
                <th>{{ i18n.t('cliente_telefono') }}</th>
                <th>{{ i18n.t('cliente_email') }}</th>
                <th>{{ i18n.t('cliente_clasificacion') }}</th>
                <th>{{ i18n.t('cliente_compras') }}</th>
                <th>{{ i18n.t('ultima_nota') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in clientes" :key="c.id" class="animate-fade-in">
                <td><strong>{{ c.nombre }}</strong></td>
                <td>{{ c.cedula || '-' }}</td>
                <td>{{ c.telefono || '-' }}</td>
                <td>{{ c.email || '-' }}</td>
                <td>
                  <span :class="['badge', classBadge(c.clasificacion)]">{{ c.cliente_categoria?.nombre || c.clasificacion || '-' }}</span>
                </td>
                <td>
                  <div>{{ c.compras_count || 0 }} {{ i18n.t('cliente_compras') }}</div>
                  <div class="text-muted-sm">{{ formatMoney(c.compras_total || 0) }}</div>
                </td>
                <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" :title="c.ultima_nota?.contenido">
                  <div v-if="c.ultima_nota" style="font-size:12px;">
                    <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ c.ultima_nota.contenido }}</div>
                    <div style="color:var(--text-muted);font-size:11px;">{{ c.ultima_nota.usuario_nombre }} · {{ formatDate(c.ultima_nota.created_at) }}</div>
                  </div>
                  <span v-else style="color:var(--text-muted);">-</span>
                </td>
                <td>
                  <button class="btn btn-sm btn-ghost" @click="editar(c)"><i class="fas fa-edit"></i></button>
                  <button class="btn btn-sm btn-ghost btn-danger-icon" @click="eliminar(c)"><i class="fas fa-trash"></i></button>
                </td>
              </tr>
              <tr v-if="!clientes.length && !loading">
                <td colspan="8" class="empty-state-cell">{{ i18n.t('cliente_no_hay') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer flex justify-between items-center" v-if="pages > 1">
        <span class="text-muted-sm">{{ i18n.t('pagina') }} {{ page }} / {{ pages }}</span>
        <div class="flex gap-sm">
          <button class="btn btn-sm btn-secondary" :disabled="page <= 1" @click="page--; cargar()">{{ i18n.t('anterior') }}</button>
          <button class="btn btn-sm btn-secondary" :disabled="page >= pages" @click="page++; cargar()">{{ i18n.t('siguiente') }}</button>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal modal-responsive">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingId ? i18n.t('editar_cliente') : i18n.t('nuevo_cliente') }}</h3>
          <button class="modal-close" @click="showModal = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cliente_nombre') }} *</label>
            <input v-model="form.nombre" class="form-control" :placeholder="i18n.t('cliente_nombre')" required />
          </div>
          <div class="grid-2 gap-md form-grid-responsive">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_cedula') }}</label>
              <input v-model="form.cedula" class="form-control" placeholder="0-0000-0000" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_telefono') }}</label>
              <input v-model="form.telefono" class="form-control" placeholder="8888-8888" />
            </div>
          </div>
          <div class="grid-2 gap-md form-grid-responsive">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_empresa') }}</label>
              <input v-model="form.empresa" class="form-control" :placeholder="i18n.t('cliente_empresa')" />
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_cedula_juridica') }}</label>
              <input v-model="form.cedula_juridica" class="form-control" placeholder="3-101-XXXXXX" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cliente_email') }}</label>
            <input v-model="form.email" type="email" class="form-control" placeholder="correo@email.com" />
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cliente_direccion') }}</label>
            <textarea v-model="form.direccion" class="form-control" rows="2" :placeholder="i18n.t('cliente_direccion')"></textarea>
          </div>
          <div class="grid-2 gap-md form-grid-responsive">
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_clasificacion') }}</label>
              <select v-model="form.cliente_categoria_id" class="form-control">
                <option value="" disabled>— Seleccionar —</option>
                <option v-for="cat in clienteCategorias" :key="cat.id" :value="cat.id">{{ cat.nombre }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">{{ i18n.t('cliente_credito') }} ({{ $simbolo }})</label>
              <input v-model="form.credito_tienda" type="number" class="form-control" placeholder="0" />
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cliente_ciudad') }}</label>
            <input v-model="form.ciudad" class="form-control" />
          </div>
          <div v-if="ultimaNota" class="form-group">
            <label class="form-label">{{ i18n.t('cliente_ultima_nota') }}</label>
            <div class="nota-readonly">
              <div class="nota-readonly-contenido">{{ ultimaNota.contenido }}</div>
              <div class="nota-readonly-meta">{{ ultimaNota.usuario_nombre }} · {{ formatDate(ultimaNota.created_at) }}</div>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('cliente_nueva_nota') }}</label>
            <textarea v-model="nuevaNota" class="form-control" rows="3" :placeholder="i18n.t('cliente_nueva_nota_placeholder')"></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">Etiquetas</label>
            <div class="etiquetas-selector">
              <div
                v-for="e in etiquetasDisponibles"
                :key="e.id"
                class="etiqueta-chip"
                :class="{ active: (form.etiqueta_ids || []).includes(e.id) }"
                :style="{ borderColor: e.color, color: (form.etiqueta_ids || []).includes(e.id) ? '#fff' : e.color, backgroundColor: (form.etiqueta_ids || []).includes(e.id) ? e.color : 'transparent' }"
                @click="toggleEtiqueta(e.id)"
              >
                {{ e.nombre }}
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary btn-mobile-full" @click="showModal = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary btn-mobile-full" @click="guardar" :disabled="isSubmitting">
            <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
            <span v-if="isSubmitting">{{ i18n.t('cliente_guardando') }}</span>
            <span v-else>{{ editingId ? i18n.t('editar') : i18n.t('crear') }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useSubmitLock } from '../composables/useSubmitLock';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';
import DateRangeDownloader from '../components/DateRangeDownloader.vue';

const i18n = useI18nStore();
const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const confirm = useConfirmStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('cliente_guardando') });
const clientes = ref([]);
const total = ref(0);
const page = ref(1);
const pages = ref(1);
const loading = ref(false);
const busqueda = ref('');
const filtros = ref({ cliente_categoria_id: '' });
const showModal = ref(false);
const editingId = ref(null);
const form = ref({});
const etiquetasDisponibles = ref([]);
const clienteCategorias = ref([]);
const notasRecientes = ref([]);
const ultimaNota = ref(null);
const nuevaNota = ref('');

const clientesColumns = [
  { key: 'nombre', label: 'Nombre' },
  { key: 'cedula', label: 'Cédula' },
  { key: 'telefono', label: 'Teléfono' },
  { key: 'email', label: 'Email' },
  { key: 'clasificacion', label: 'Clasificación' },
  { key: 'compras_count', label: 'Compras' },
  { key: 'compras_total', label: 'Total Compras' },
];

async function fetchClientesRange(desde, hasta) {
  const { data } = await api.get('/clientes', { params: { limit: 10000 } });
  return (data.clientes || []).map(c => ({
    nombre: c.nombre, cedula: c.cedula || '', telefono: c.telefono || '',
    email: c.email || '', clasificacion: c.clasificacion || '',
    compras_count: c.compras_count || 0, compras_total: c.compras_total || 0,
  }));
}

function formatDate(d) {
  if (!d) return '';
  return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', year: 'numeric' });
}

let searchTimeout = null;

onMounted(async () => {
    cargar();
    try {
        const [{ data: etiquetasData }] = await Promise.all([
            api.get('/etiquetas'),
            loadClienteCategorias()
        ]);
        etiquetasDisponibles.value = etiquetasData.etiquetas || [];
    } catch (e) { console.error(e); }
});

async function cargar() {
    loading.value = true;
    try {
        const params = { page: page.value, q: busqueda.value, ...filtros.value };
        const [clientesRes, notasRes] = await Promise.all([
            api.get('/clientes', { params }),
            api.get('/clientes/notas-recientes')
        ]);
        const clientesData = clientesRes.data.clientes || [];
        const notasData = notasRes.data.notas || [];
        const notasMap = {};
        notasData.forEach(n => { notasMap[n.cliente_id] = n; });
        clientes.value = clientesData.map(c => ({ ...c, ultima_nota: notasMap[c.id] || null }));
        total.value = clientesRes.data.total;
        pages.value = clientesRes.data.pages;
    } catch (e) { console.error(e); }
    loading.value = false;
}

function debounceSearch() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => { page.value = 1; cargar(); }, 400);
}

async function loadClienteCategorias() {
    try {
        const { data } = await api.get('/configuracion/cliente-categorias');
        clienteCategorias.value = data.categorias || [];
        console.log('Categorías cargadas:', clienteCategorias.value);
    } catch (e) {
        console.error('Error cargando categorías de clientes:', e);
    }
}

function resetForm() {
    editingId.value = null;
    const defaultCatId = clienteCategorias.value.length ? clienteCategorias.value[0].id : '';
    form.value = { nombre: '', cedula: '', empresa: '', cedula_juridica: '', telefono: '', email: '', direccion: '', ciudad: '', cliente_categoria_id: defaultCatId, credito_tienda: '', activo: 1, etiqueta_ids: [] };
    ultimaNota.value = null;
    nuevaNota.value = '';
}

async function abrirModalNuevo() {
    if (!clienteCategorias.value.length) await loadClienteCategorias();
    resetForm();
    showModal.value = true;
}

async function editar(c) {
    if (!clienteCategorias.value.length) await loadClienteCategorias();
    editingId.value = c.id;
    nuevaNota.value = '';
    try {
        const { data } = await api.get(`/clientes/${c.id}`);
        const cliente = data.cliente;
        form.value = {
            nombre: cliente.nombre || '',
            cedula: cliente.cedula || '',
            empresa: cliente.empresa || '',
            cedula_juridica: cliente.cedula_juridica || '',
            telefono: cliente.telefono || '',
            email: cliente.email || '',
            direccion: cliente.direccion || '',
            ciudad: cliente.ciudad || '',
            cliente_categoria_id: cliente.cliente_categoria_id || '',
            credito_tienda: cliente.credito_tienda || '',
            activo: cliente.activo ?? 1,
            etiqueta_ids: (cliente.etiquetas || []).map(e => e.id),
        };
        ultimaNota.value = data.ultima_nota || null;
    } catch {
        form.value = { ...c, etiqueta_ids: [] };
        ultimaNota.value = null;
    }
    showModal.value = true;
}

async function guardar() {
    if (!form.value.nombre) { toast.error(i18n.t('cliente_nombre_req')); return; }
    try {
        await execute(async () => {
            let clienteId = editingId.value;
            if (editingId.value) {
                await api.put(`/clientes/${editingId.value}`, form.value);
                toast.success(i18n.t('cliente_actualizado'));
            } else {
                const { data } = await api.post('/clientes', form.value);
                clienteId = data.cliente?.id;
                toast.success(i18n.t('cliente_creado'));
            }
            if (clienteId && nuevaNota.value.trim()) {
                await api.post(`/clientes/${clienteId}/notas`, { contenido: nuevaNota.value.trim() });
            }
            showModal.value = false;
            cargar();
        });
    } catch (e) {
        if (e.response?.status === 429) {
            toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
        } else {
            toast.error(e.response?.data?.error || i18n.t('cliente_error_guardar'));
        }
    }
}

function toggleEtiqueta(id) {
    const ids = form.value.etiqueta_ids || [];
    if (ids.includes(id)) {
        form.value.etiqueta_ids = ids.filter(x => x !== id);
    } else {
        form.value.etiqueta_ids = [...ids, id];
    }
}

async function eliminar(c) {
    if (!await confirm.ask({ message: i18n.tp('cliente_confirmar_eliminar', { nombre: c.nombre }), confirmText: i18n.t('eliminar'), type: 'danger' })) return;
    try {
        await api.delete(`/clientes/${c.id}`);
        toast.success(i18n.t('cliente eliminado'));
        cargar();
    } catch (e) {
        toast.error(e.response?.data?.error || i18n.t('cliente_error_eliminar'));
    }
}

function classBadge(clasificacion) {
    const map = { vip: 'badge-warning', mayorista: 'badge-info', nuevo: 'badge-success' };
    return map[clasificacion] || 'badge-info';
}

</script>

<style scoped>
  .fa-search {
    color: var(--text-primary);
    margin-right: -30px;
  }
  .form-control::placeholder {
    color: var(--text-primary) !important;
  }

  .search-input {
    padding-left: 44px;
    width: 100%;
    max-width: 300px;
  }

  .select-filtro {
    width: 100%;
    max-width: 180px;
  }

  .btn-danger-icon {
    color: var(--danger, #ef4444);
  }

  .text-muted-sm {
    font-size: 11px;
    color: var(--text-muted);
  }

  .empty-state-cell {
    text-align: center;
    padding: 40px;
    color: var(--text-muted);
  }

  .table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }

  .modal-responsive {
    max-width: min(90vw, 600px);
  }

  .btn-mobile-full {
    min-height: 44px;
  }

  .etiquetas-selector {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }
  .etiqueta-chip {
    display: inline-flex;
    align-items: center;
    padding: 6px 12px;
    border-radius: 9999px;
    border: 2px solid;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    user-select: none;
    -webkit-tap-highlight-color: transparent;
  }
  .etiqueta-chip:hover {
    opacity: 0.85;
    transform: translateY(-1px);
  }
  .etiqueta-chip.active {
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
  }

  .nota-readonly {
    background: rgba(255, 255, 255, 0.5);
    border: 2px solid transparent;
    border-radius: var(--radius-md, 12px);
    padding: 12px 16px;
    color: var(--text-primary, #1a2332);
  }
  [data-theme="dark"] .nota-readonly {
    background: rgba(255, 255, 255, 0.25);
    color: #ffffff;
  }
  .nota-readonly-contenido {
    font-size: 14px;
    color: inherit;
    white-space: pre-wrap;
    word-break: break-word;
  }
  .nota-readonly-meta {
    font-size: 11px;
    color: var(--text-muted, #b7c0cc);
    margin-top: 6px;
  }

  @media (max-width: 1023px) {
    .search-input { max-width: 220px; }
    .select-filtro { max-width: 160px; }
  }

  @media (max-width: 768px) {
    * {
      -webkit-tap-highlight-color: transparent;
    }

    .clientes-topbar {
      flex-direction: column;
      align-items: stretch;
      gap: 12px;
    }
    .clientes-filtros {
      flex-direction: column;
      gap: 10px;
    }
    .search-input {
      max-width: 100%;
      min-height: 44px;
    }
    .select-filtro {
      max-width: 100%;
      min-height: 44px;
    }
    .btn-nuevo {
      width: 100%;
      min-height: 44px;
    }
    .form-grid-responsive {
      grid-template-columns: 1fr;
    }
    .form-control {
      min-height: 44px;
      font-size: 16px;
    }
    select.form-control {
      min-height: 44px;
    }
    textarea.form-control {
      min-height: 80px;
    }
    .modal-responsive {
      max-width: 100vw;
      max-height: 100vh;
      margin: 0;
      border-radius: 0;
    }
    .modal-footer {
      flex-direction: column;
      gap: 8px;
    }
    .modal-footer .btn {
      width: 100%;
      min-height: 48px;
      font-size: 15px;
    }
    .etiquetas-selector {
      gap: 6px;
    }
    .etiqueta-chip {
      padding: 8px 14px;
      font-size: 14px;
      min-height: 36px;
    }

    /* Card-style table conversion */
    .data-table thead {
      display: none;
    }
    .data-table tbody {
      display: block;
      width: 100%;
    }
    .data-table tbody tr {
      display: block;
      background: var(--bg-secondary, #fff);
      border: 1px solid var(--border-color, #e5e7eb);
      border-radius: 8px;
      margin-bottom: 10px;
      padding: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    }
    .data-table tbody td {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 6px 0;
      border: none;
      border-bottom: 1px solid var(--border-light, #f3f4f6);
      font-size: 14px;
      text-align: left;
      min-height: 32px;
    }
    .data-table tbody td:last-child {
      border-bottom: none;
      justify-content: flex-end;
      gap: 8px;
      padding-top: 8px;
    }
    .data-table tbody td::before {
      content: attr(data-label);
      font-weight: 600;
      font-size: 12px;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.03em;
      margin-right: 12px;
      flex-shrink: 0;
    }
    .data-table tbody td[data-label] {
      padding-left: 0;
    }
    .data-table tbody td .text-muted-sm {
      font-size: 10px;
    }
    .empty-state-cell {
      padding: 24px 12px;
      font-size: 14px;
    }
    .table-responsive {
      padding: 0 4px;
    }
  }

  @media (max-width: 480px) {
    .clientes-topbar {
      gap: 8px;
    }
    .clientes-filtros {
      gap: 8px;
    }
    .search-input {
      max-width: 100%;
    }
    .select-filtro {
      max-width: 100%;
    }
    .btn-nuevo {
      width: 100%;
      min-height: 44px;
      font-size: 14px;
    }
    .card-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 8px;
      padding: 12px;
    }
    .card-header .badge {
      align-self: flex-start;
    }
    .card-body {
      padding: 0 !important;
    }
    .card-footer {
      flex-direction: column;
      gap: 8px;
      align-items: stretch;
      padding: 12px;
    }
    .card-footer .flex {
      justify-content: center;
    }
    .card-footer .btn {
      width: 100%;
      min-height: 44px;
    }
    .modal-responsive {
      width: 100vw;
      max-width: 100vw;
      border-radius: 0;
    }
    .modal-header {
      padding: 12px;
    }
    .modal-title {
      font-size: 16px;
    }
    .modal-body {
      padding: 12px;
      gap: 10px;
    }
    .modal-body .form-group {
      margin-bottom: 12px;
    }
    .modal-body .form-label {
      font-size: 13px;
      margin-bottom: 4px;
    }
    .modal-footer {
      padding: 12px;
      gap: 6px;
    }
    .modal-footer .btn {
      font-size: 14px;
      min-height: 48px;
    }
    .form-grid-responsive {
      grid-template-columns: 1fr;
      gap: 10px;
    }
    .data-table tbody tr {
      padding: 10px;
      margin-bottom: 8px;
    }
    .data-table tbody td {
      font-size: 13px;
      padding: 5px 0;
    }
    .data-table tbody td::before {
      font-size: 11px;
    }
    .etiquetas-selector {
      gap: 5px;
    }
    .etiqueta-chip {
      padding: 7px 12px;
      font-size: 13px;
      min-height: 34px;
    }
  }
</style>
