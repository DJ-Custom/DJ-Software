<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex gap-sm">
        <input v-model="filtro" class="form-control filter-input" placeholder="Buscar devolución..." @input="cargar">
        <select v-model="estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="pendiente">{{ i18n.t('pendiente') }}</option>
          <option value="completada">{{ i18n.t('completada') }}</option>
          <option value="rechazada">{{ i18n.t('rechazada') }}</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="showNueva=true"><i class="fas fa-plus"></i> {{ i18n.t('nueva_devolucion') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('numero') }}</th><th>{{ i18n.t('factura_label') }}</th><th>{{ i18n.t('cliente') }}</th><th>{{ i18n.t('monto') }}</th><th>Estado</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="d in items" :key="d.id">
                <td :data-label="i18n.t('numero')"><strong>{{ d.numero_devolucion }}</strong></td>
                <td :data-label="i18n.t('factura_label')">{{ d.numero_factura }}</td>
                <td :data-label="i18n.t('cliente')">{{ d.cliente_nombre || 'N/A' }}</td>
                <td :data-label="i18n.t('monto')">{{ formatMoney(d.monto_total) }}</td>
                <td :data-label="'Estado'"><span :class="['badge', badgeEstado(d.estado)]">{{ d.estado }}</span></td>
                <td :data-label="i18n.t('fecha')">{{ formatDate(d.created_at) }}</td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(d.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="d.estado==='pendiente'" class="btn btn-sm btn-success" @click="aprobar(d.id)" :title="i18n.t('aprobar')"><i class="fas fa-check"></i></button>
                  <button v-if="d.estado==='pendiente'" class="btn btn-sm btn-danger" @click="rechazar(d.id)" :title="i18n.t('rechazar')"><i class="fas fa-times"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="7" style="text-align:center;padding:40px;color:var(--text-muted);">No hay devoluciones</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nueva -->
    <div class="modal-overlay" :class="{active:showNueva}" @click.self="showNueva=false">
      <div class="modal" style="max-width:min(90vw,800px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('nueva_devolucion') }}</h3><button class="modal-close" @click="showNueva=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('buscar_venta') }}</label><input v-model="buscarVenta" class="form-control" placeholder="Número de factura..." @input="buscarVentas"></div>
          <div v-if="ventaResults.length && !ventaSeleccionada" class="mb-md" style="max-height:200px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="v in ventaResults" :key="v.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);" @click="seleccionarVenta(v)">
              <strong>{{ v.numero_factura }}</strong> - {{ v.cliente_nombre||'Público General' }} - {{ formatMoney(v.total) }}
            </div>
          </div>
          <div v-if="ventaSeleccionada" class="mb-md">
            <div class="flex items-center justify-between mb-sm">
              <span><strong>Venta:</strong> {{ ventaSeleccionada.numero_factura }}</span>
              <button class="btn btn-sm btn-ghost" @click="ventaSeleccionada=null;formItems=[]"><i class="fas fa-times"></i> {{ i18n.t('cancelar') }}</button>
            </div>
            <table class="data-table">
              <thead><tr><th><input type="checkbox" @change="toggleAll($event)"></th><th>Producto</th><th>Cant. Orig.</th><th>Cant. Devolver</th><th>Estado</th></tr></thead>
              <tbody>
                <tr v-for="(item,i) in formItems" :key="i">
                  <td><input type="checkbox" v-model="item.selected"></td>
                  <td>{{ item.producto_nombre }}</td>
                  <td>{{ item.cantidad_original }}</td>
                  <td><input v-model.number="item.cantidad" type="number" :max="item.cantidad_original" min="1" class="form-control table-num-input" :disabled="!item.selected" @input="clampCantidad(item)"></td>
                  <td><select v-model="item.estado_producto" class="form-control table-select-input"><option value="bueno">{{ i18n.t('bueno') }}</option><option value="danado">{{ i18n.t('danado') }}</option></select></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="form-group"><label>{{ i18n.t('motivo_label') }}</label><textarea v-model="formMotivo" class="form-control" rows="2" placeholder="Razón de la devolución"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="!ventaSeleccionada || !formItems.some(i=>i.selected) || isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('creando_devolucion') }}</span><span v-else>{{ i18n.t('crear_devolucion') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDetalle}" @click.self="showDetalle=false">
      <div class="modal" style="max-width:min(90vw,700px);">
        <div class="modal-header"><h3 class="modal-title">{{ detalle?.numero_devolucion }}</h3><button class="modal-close" @click="showDetalle=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="detalle">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('factura_label') }}:</strong> {{ detalle.numero_factura }}</div>
            <div><strong>Estado:</strong> <span :class="['badge',badgeEstado(detalle.estado)]">{{ detalle.estado }}</span></div>
            <div><strong>{{ i18n.t('cliente') }}:</strong> {{ detalle.cliente_nombre || 'N/A' }}</div>
            <div><strong>{{ i18n.t('motivo_label') }}:</strong> {{ detalle.motivo || 'N/A' }}</div>
          </div>
          <table class="data-table"><thead><tr><th>Producto</th><th>Cant.</th><th>Precio</th><th>Subtotal</th><th>Estado</th></tr></thead>
            <tbody><tr v-for="item in detalle.items" :key="item.id"><td>{{ item.producto_nombre }}</td><td>{{ item.cantidad }}</td><td>{{ formatMoney(item.precio_unitario) }}</td><td>{{ formatMoney(item.subtotal) }}</td><td>{{ item.estado_producto }}</td></tr></tbody>
          </table>
          <div class="mt-md text-right" style="font-size:18px;"><strong>Total: {{ formatMoney(detalle.monto_total) }}</strong></div>
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

const { fm: formatMoney } = useCurrency();

const i18n = useI18nStore();
const toast = useToastStore();
const confirm = useConfirmStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('creando_devolucion') });

const items = ref([]); const filtro = ref(''); const estado = ref('');
const showNueva = ref(false); const showDetalle = ref(false); const detalle = ref(null);
const buscarVenta = ref(''); const ventaResults = ref([]); const ventaSeleccionada = ref(null);
const formItems = ref([]); const formMotivo = ref('');

onMounted(() => cargar());

async function cargar() { try { const {data}=await api.get('/devoluciones',{params:{q:filtro.value,estado:estado.value}}); items.value=data.data||[]; } catch(e){} }
async function buscarVentas() { if(buscarVenta.value.length<2){ventaResults.value=[];return;} try { const {data}=await api.get('/devoluciones/buscar-venta',{params:{q:buscarVenta.value}}); ventaResults.value=data.ventas||[]; } catch(e){} }
function seleccionarVenta(v) { ventaSeleccionada.value=v; formItems.value=(v.items||[]).map(i=>({...i,selected:false,cantidad:i.cantidad,cantidad_original:i.cantidad,estado_producto:'bueno'})); ventaResults.value=[]; }
function toggleAll(e) { formItems.value.forEach(i=>i.selected=e.target.checked); }
function clampCantidad(item) {
  if (item.cantidad > item.cantidad_original) item.cantidad = item.cantidad_original;
  if (item.cantidad < 1 || isNaN(item.cantidad)) item.cantidad = 1;
}
async function guardar() {
  const selected = formItems.value.filter(i=>i.selected);
  try {
    await execute(async () => {
      await api.post('/devoluciones', { venta_id:ventaSeleccionada.value.id, motivo:formMotivo.value, items:selected.map(i=>({producto_id:i.producto_id,cantidad:i.cantidad,precio_unitario:i.precio_unitario,estado_producto:i.estado_producto})) });
      showNueva.value=false; ventaSeleccionada.value=null; formItems.value=[]; formMotivo.value=''; cargar();
    });
  } catch(e){
    if (e.response?.status === 429) { toast.warning('La solicitud ya está siendo procesada. Por favor espere.'); }
    else { toast.error(e.response?.data?.error||i18n.t('error')); }
  }
}
async function verDetalle(id) { try { const {data}=await api.get(`/devoluciones/${id}`); detalle.value=data.devolucion; showDetalle.value=true; } catch(e){} }
async function aprobar(id) { if(!await confirm.ask({ message: i18n.t('aprobar_devolucion'), confirmText: i18n.t('aprobar'), type: 'success' })) return; try { await api.post(`/devoluciones/${id}/aprobar`); cargar(); } catch(e){} }
async function rechazar(id) { if(!await confirm.ask({ message: i18n.t('rechazar_devolucion'), confirmText: i18n.t('rechazar'), type: 'danger' })) return; try { await api.post(`/devoluciones/${id}/rechazar`); cargar(); } catch(e){} }
function badgeEstado(e) { return {pendiente:'badge-warning',completada:'badge-success',rechazada:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
.filter-input { width: 100%; max-width: 250px; min-width: 0; }
.filter-select { width: 100%; max-width: 150px; min-width: 0; }
.table-num-input { width: 100%; max-width: 70px; min-width: 0; }
.table-select-input { width: 100%; max-width: 120px; min-width: 0; }

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
  .table-select-input { max-width: 100%; min-width: 0; }
  .table-num-input { max-width: 80px; min-width: 0; }
  .grid-2 { grid-template-columns: 1fr; }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 500px; }
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
  .btn { min-height: 44px; width: 100%; font-size: 15px; }
  .page-header .btn { flex: 1 1 100%; }
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
