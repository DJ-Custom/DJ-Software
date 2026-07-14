<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex gap-sm">
        <input v-model="filtro" class="form-control filter-input" :placeholder="i18n.t('pedidos_buscar')" @input="cargar">
        <select v-model="estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="pendiente">{{ i18n.t('pendiente') }}</option>
          <option value="en_proceso">{{ i18n.t('pedidos_filtro_en_proceso') }}</option>
          <option value="listo">{{ i18n.t('pedidos_filtro_listo') }}</option>
          <option value="entregado">{{ i18n.t('entregado') }}</option>
          <option value="cancelado">{{ i18n.t('cancelada') }}</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="abrirNuevo"><i class="fas fa-plus"></i> {{ i18n.t('nuevo_pedido') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('numero') }}</th><th>{{ i18n.t('cliente') }}</th><th>{{ i18n.t('total') }}</th><th>{{ i18n.t('pedidos_adelanto') }}</th><th>{{ i18n.t('pedidos_pendiente') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('pedidos_fecha_entrega') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in items" :key="p.id">
                <td :data-label="i18n.t('numero')"><strong>{{ p.numero_pedido }}</strong></td>
                <td :data-label="i18n.t('cliente')">{{ p.cliente_nombre || i18n.t('pedidos_sin_cliente') }}</td>
                <td :data-label="i18n.t('total')">{{ formatMoney(p.total) }}</td>
                <td :data-label="i18n.t('pedidos_adelanto')">{{ formatMoney(p.monto_adelanto) }}</td>
                <td :data-label="i18n.t('pedidos_pendiente')">{{ formatMoney(p.monto_pendiente) }}</td>
                <td :data-label="i18n.t('estado')"><span :class="['badge', badgeEstado(p.estado)]">{{ p.estado }}</span></td>
                <td :data-label="i18n.t('pedidos_fecha_entrega')">{{ p.fecha_entrega_estimada || '-' }}</td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" :title="i18n.t('ver')" @click="verDetalle(p.id)"><i class="fas fa-eye"></i></button>
                  <button class="btn btn-sm btn-ghost" :title="i18n.t('editar')" @click="editar(p)"><i class="fas fa-edit"></i></button>
                  <button v-if="p.estado==='pendiente'" class="btn btn-sm btn-ghost" :title="i18n.t('pedidos_iniciar')" @click="cambiarEstado(p.id,'en_proceso')"><i class="fas fa-play"></i></button>
                  <button class="btn btn-sm btn-ghost btn-danger-icon" :title="i18n.t('eliminar')" @click="eliminar(p)"><i class="fas fa-trash"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="8" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('sin_pedidos') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nuevo/Editar Pedido -->
    <div class="modal-overlay" :class="{active:showForm}" @click.self="showForm=false">
      <div class="modal" style="max-width:min(90vw,800px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingId ? i18n.t('pedidos_editar') : i18n.t('nuevo_pedido') }}</h3>
          <button class="modal-close" @click="showForm=false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="grid-2 mb-md">
            <div class="form-group"><label>{{ i18n.t('cliente') }}</label><input v-model="form.cliente_nombre" class="form-control" :placeholder="i18n.t('buscar_clientes')"></div>
            <div class="form-group"><label>{{ i18n.t('pedidos_fecha_entrega') }}</label><input v-model="form.fecha_entrega_estimada" type="date" class="form-control"></div>
            <div class="form-group"><label>Tipo Entrega</label><select v-model="form.tipo_entrega" class="form-control"><option value="en_tienda">En Tienda</option><option value="domicilio">A Domicilio</option></select></div>
            <div class="form-group"><label>{{ i18n.t('pedidos_adelanto') }}</label><input v-model.number="form.monto_adelanto" type="number" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label><input v-model="buscarProd" class="form-control" :placeholder="i18n.t('pedidos_buscar_producto')" @input="buscarProductos"></div>
          <div v-if="prodResults.length" class="mb-md" style="max-height:150px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="p in prodResults" :key="p.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);" @click="agregarItem(p)">{{ p.nombre }} - {{ formatMoney(p.precio_venta) }} (Stock: {{ p.stock }})</div>
          </div>
          <table class="data-table mb-md" v-if="form.items.length">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('precio') }}</th><th>{{ i18n.t('subtotal') }}</th><th></th></tr></thead>
              <tbody><tr v-for="(item,i) in form.items" :key="i"><td>{{ item.nombre }}</td><td><input v-model.number="item.cantidad" type="number" min="1" class="form-control table-num-input"></td><td>{{ formatMoney(item.precio_unitario) }}</td><td>{{ formatMoney(item.cantidad*item.precio_unitario) }}</td><td><button class="btn btn-sm btn-danger" @click="form.items.splice(i,1)"><i class="fas fa-trash"></i></button></td></tr></tbody>
          </table>
          <div class="text-right"><strong>{{ i18n.t('total') }}: {{ formatMoney(totalForm) }}</strong></div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showForm=false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardar" :disabled="!form.items.length || isSubmitting">
            <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
            <span v-if="isSubmitting">{{ i18n.t('guardando') }}</span>
            <span v-else>{{ editingId ? i18n.t('pedidos_actualizar') : i18n.t('nuevo_pedido') }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDetalle}" @click.self="showDetalle=false">
      <div class="modal" style="max-width:min(90vw,700px);">
        <div class="modal-header"><h3 class="modal-title">{{ detalle?.numero_pedido }}</h3><button class="modal-close" @click="showDetalle=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="detalle">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('cliente') }}:</strong> {{ detalle.cliente_nombre || 'N/A' }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge',badgeEstado(detalle.estado)]">{{ detalle.estado }}</span></div>
            <div><strong>{{ i18n.t('pedidos_fecha_entrega') }}:</strong> {{ detalle.fecha_entrega_estimada || 'No definida' }}</div>
            <div><strong>{{ i18n.t('pedidos_pendiente') }}:</strong> {{ formatMoney(detalle.monto_pendiente) }}</div>
          </div>
          <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('precio') }}</th><th>{{ i18n.t('subtotal') }}</th></tr></thead>
            <tbody><tr v-for="item in detalle.items" :key="item.id"><td>{{ item.producto_nombre }}</td><td>{{ item.cantidad }}</td><td>{{ formatMoney(item.precio_unitario) }}</td><td>{{ formatMoney(item.subtotal) }}</td></tr></tbody>
          </table>
          <div class="mt-md text-right" style="font-size:18px;"><strong>{{ i18n.t('total') }}: {{ formatMoney(detalle.total) }}</strong></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';
import { useSubmitLock } from '../composables/useSubmitLock';

const i18n = useI18nStore();
const { fm: formatMoney } = useCurrency();
const toast = useToastStore();
const confirm = useConfirmStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando') });

const items = ref([]); const filtro = ref(''); const estado = ref('');
const showForm = ref(false); const showDetalle = ref(false); const detalle = ref(null);
const editingId = ref(null);
const form = ref({ cliente_id:null, cliente_nombre:'', fecha_entrega_estimada:'', tipo_entrega:'en_tienda', monto_adelanto:0, items:[], notas:'' });
const buscarProd = ref(''); const prodResults = ref([]);
const totalForm = computed(() => form.value.items.reduce((s,i) => s + i.cantidad*i.precio_unitario, 0));

onMounted(() => cargar());

function resetForm() {
  editingId.value = null;
  form.value = { cliente_id:null, cliente_nombre:'', fecha_entrega_estimada:'', tipo_entrega:'en_tienda', monto_adelanto:0, items:[], notas:'' };
}

function abrirNuevo() {
  resetForm();
  showForm.value = true;
}

async function cargar() { try { const { data } = await api.get('/pedidos', { params: { q: filtro.value, estado: estado.value } }); items.value = data.data||[]; } catch(e){} }
async function buscarProductos() { if(buscarProd.value.length<2){prodResults.value=[];return;} try { const {data} = await api.get('/productos/buscar',{params:{q:buscarProd.value}}); prodResults.value=data.productos||[]; } catch(e){} }
function agregarItem(p) { form.value.items.push({producto_id:p.id,nombre:p.nombre,cantidad:1,precio_unitario:p.precio_venta,descuento:0}); buscarProd.value=''; prodResults.value=[]; }

async function editar(p) {
  editingId.value = p.id;
  try {
    const { data } = await api.get(`/pedidos/${p.id}`);
    const ped = data.pedido;
    form.value = {
      cliente_id: ped.cliente_id,
      cliente_nombre: ped.cliente_nombre || '',
      fecha_entrega_estimada: ped.fecha_entrega_estimada || '',
      tipo_entrega: ped.tipo_entrega || 'en_tienda',
      monto_adelanto: ped.monto_adelanto || 0,
      notas: ped.notas || '',
      items: (ped.items || []).map(it => ({
        producto_id: it.producto_id,
        nombre: it.producto_nombre,
        cantidad: it.cantidad,
        precio_unitario: it.precio_unitario,
        descuento: it.descuento || 0,
      })),
    };
    showForm.value = true;
  } catch(e) {
    toast.error(i18n.t('error'));
  }
}

async function guardar() {
  try {
    await execute(async () => {
      if (editingId.value) {
        await api.put(`/pedidos/${editingId.value}`, form.value);
        toast.success(i18n.t('pedidos_actualizado'));
      } else {
        await api.post('/pedidos', form.value);
        toast.success(i18n.t('pedidos_creado'));
      }
      showForm.value = false;
      resetForm();
      cargar();
    });
  } catch(e) {
    if (e.response?.status === 429) {
      toast.warning(i18n.t('solicitud_procesando'));
    } else {
      toast.error(e.response?.data?.error||i18n.t('error'));
    }
  }
}

async function eliminar(p) {
  if (!await confirm.ask({ message: i18n.tp('pedidos_confirmar_eliminar', { numero: p.numero_pedido }), confirmText: i18n.t('eliminar'), type: 'danger' })) return;
  try {
    await api.delete(`/pedidos/${p.id}`);
    toast.success(i18n.t('pedidos_eliminado'));
    cargar();
  } catch(e) {
    toast.error(e.response?.data?.error || i18n.t('error'));
  }
}

async function verDetalle(id) { try { const {data} = await api.get(`/pedidos/${id}`); detalle.value=data.pedido; showDetalle.value=true; } catch(e){} }
async function cambiarEstado(id, est) { try { await api.post(`/pedidos/${id}/estado`, {estado:est}); cargar(); } catch(e){} }
function badgeEstado(e) { return {pendiente:'badge-warning',en_proceso:'badge-info',listo:'badge-success',entregado:'badge-success',cancelado:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
.filter-input { width: 100%; max-width: 250px; min-width: 0; }
.filter-select { width: 100%; max-width: 150px; min-width: 0; }
.table-num-input { width: 100%; max-width: 70px; min-width: 0; }
.btn-danger-icon { color: var(--danger, #ef4444); }

@media (max-width: 1023px) {
  .filter-input { max-width: 200px; }
}

@media (max-width: 768px) {
  .flex.gap-sm { flex-wrap: wrap; gap: 8px; }
  .filter-input,
  .filter-select {
    max-width: 100% !important;
    min-width: 0 !important;
    min-height: 44px;
    font-size: 16px;
  }
  .table-num-input { max-width: 80px; min-width: 0; }
  .grid-2 { grid-template-columns: 1fr; }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 600px; }
}

@media (max-width: 480px) {
  .btn { min-height: 44px; width: 100%; font-size: 15px; }
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
