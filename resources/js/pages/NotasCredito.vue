<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex gap-sm">
        <input v-model="filtro" class="form-control filter-input" :placeholder="i18n.t('notas_buscar')" @input="cargar">
        <select v-model="estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('notas_filtro_todas') }}</option>
          <option value="activa">{{ i18n.t('notas_filtro_activa') }}</option>
          <option value="usada">{{ i18n.t('notas_filtro_usada') }}</option>
          <option value="cancelada">{{ i18n.t('notas_filtro_cancelada') }}</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="showNueva=true"><i class="fas fa-plus"></i> {{ i18n.t('nueva_nota') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('numero') }}</th><th>{{ i18n.t('factura') }}</th><th>{{ i18n.t('cliente') }}</th><th>{{ i18n.t('monto') }}</th><th>{{ i18n.t('notas_saldo') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="n in items" :key="n.id">
                <td :data-label="i18n.t('numero')"><strong>{{ n.numero_nota }}</strong></td>
                <td :data-label="i18n.t('factura')">{{ n.numero_factura }}</td>
                <td :data-label="i18n.t('cliente')">{{ n.cliente_nombre || 'N/A' }}</td>
                <td :data-label="i18n.t('monto')">{{ formatMoney(n.monto_total) }}</td>
                <td :data-label="i18n.t('notas_saldo')">{{ formatMoney(n.saldo_restante) }}</td>
                <td :data-label="i18n.t('estado')"><span :class="['badge', badgeEstado(n.estado)]">{{ n.estado }}</span></td>
                <td :data-label="i18n.t('fecha')">{{ formatDate(n.created_at) }}</td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(n.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="n.estado==='activa'" class="btn btn-sm btn-danger" @click="cancelar(n.id)"><i class="fas fa-ban"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="8" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('sin_notas') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nueva -->
    <div class="modal-overlay" :class="{active:showNueva}" @click.self="showNueva=false">
      <div class="modal" style="max-width:min(90vw,800px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('nueva_nota') }}</h3><button class="modal-close" @click="showNueva=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('notas_seleccionar_factura') }}</label><input v-model="buscarVentaQ" class="form-control" :placeholder="i18n.t('notas_factura_label')" @input="buscarVentas"></div>
          <div v-if="ventaResults.length && !ventaSel" class="mb-md" style="max-height:200px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="v in ventaResults" :key="v.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);" @click="selVenta(v)">
              <strong>{{ v.numero_factura }}</strong> - {{ v.cliente_nombre||i18n.t('publico_general') }} - {{ formatMoney(v.total) }}
            </div>
          </div>
          <div v-if="ventaSel" class="mb-md">
            <div class="flex items-center justify-between mb-sm">
              <span><strong>{{ ventaSel.numero_factura }}</strong></span>
              <button class="btn btn-sm btn-ghost" @click="ventaSel=null;fItems=[]"><i class="fas fa-times"></i></button>
            </div>
            <div class="grid-2 mb-md">
              <div class="form-group"><label>{{ i18n.t('notas_estado') }}</label><select v-model="formTipo" class="form-control"><option value="parcial">Parcial</option><option value="total">Total</option></select></div>
              <div class="form-group"><label>{{ i18n.t('notas_estado_label') }}</label><select v-model="formTipoCredito" class="form-control"><option value="credito_tienda">{{ i18n.t('cliente_credito') }}</option><option value="devolucion_dinero">Devolución Dinero</option></select></div>
            </div>
            <table class="data-table">
              <thead><tr><th><input type="checkbox" @change="toggleAll($event)"></th><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('precio') }}</th><th>Devolver Inv.</th></tr></thead>
              <tbody><tr v-for="(it,i) in fItems" :key="i"><td><input type="checkbox" v-model="it.sel"></td><td>{{ it.producto_nombre }}</td><td><input v-model.number="it.cantidad" type="number" min="1" :max="it.max" class="form-control table-num-input" @input="clampCantidad(it)"></td><td>{{ formatMoney(it.precio_unitario) }}</td><td><input type="checkbox" v-model="it.devolver_inventario"></td></tr></tbody>
            </table>
          </div>
          <div class="form-group"><label>{{ i18n.t('motivo') }}</label><textarea v-model="formMotivo" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="!ventaSel||!fItems.some(i=>i.sel) || isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('creando_devolucion') }}</span><span v-else>{{ i18n.t('notas_crear') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDet}" @click.self="showDet=false">
      <div class="modal" style="max-width:min(90vw,700px);">
        <div class="modal-header"><h3 class="modal-title">{{ det?.numero_nota }}</h3><button class="modal-close" @click="showDet=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="det">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('factura') }}:</strong> {{ det.numero_factura }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge',badgeEstado(det.estado)]">{{ det.estado }}</span></div>
            <div><strong>{{ i18n.t('monto') }}:</strong> {{ formatMoney(det.monto_total) }}</div>
            <div><strong>{{ i18n.t('notas_saldo') }}:</strong> {{ formatMoney(det.saldo_restante) }}</div>
          </div>
          <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('subtotal') }}</th></tr></thead>
            <tbody><tr v-for="it in det.items" :key="it.id"><td>{{ it.producto_nombre }}</td><td>{{ it.cantidad }}</td><td>{{ formatMoney(it.subtotal) }}</td></tr></tbody>
          </table>
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
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const confirm = useConfirmStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('creando_devolucion') });

const items = ref([]); const filtro = ref(''); const estado = ref('');
const showNueva = ref(false); const showDet = ref(false); const det = ref(null);
const buscarVentaQ = ref(''); const ventaResults = ref([]); const ventaSel = ref(null);
const fItems = ref([]); const formMotivo = ref(''); const formTipo = ref('parcial'); const formTipoCredito = ref('credito_tienda');

onMounted(() => cargar());
async function cargar() { try { const {data}=await api.get('/notas-credito',{params:{q:filtro.value,estado:estado.value}}); items.value=data.data||[]; } catch(e){} }
async function buscarVentas() { if(buscarVentaQ.value.length<2){ventaResults.value=[];return;} try { const {data}=await api.get('/devoluciones/buscar-venta',{params:{q:buscarVentaQ.value}}); ventaResults.value=data.ventas||[]; } catch(e){} }
function selVenta(v) { ventaSel.value=v; fItems.value=(v.items||[]).map(i=>({...i,sel:false,cantidad:i.cantidad,max:i.cantidad,devolver_inventario:false})); ventaResults.value=[]; }
function toggleAll(e) { fItems.value.forEach(i=>i.sel=e.target.checked); }
function clampCantidad(it) {
  if (it.cantidad > it.max) it.cantidad = it.max;
  if (it.cantidad < 1 || isNaN(it.cantidad)) it.cantidad = 1;
}
async function guardar() {
  const sel = fItems.value.filter(i=>i.sel);
  try {
    await execute(async () => {
      await api.post('/notas-credito',{venta_id:ventaSel.value.id,tipo:formTipo.value,tipo_credito:formTipoCredito.value,motivo:formMotivo.value,items:sel.map(i=>({producto_id:i.producto_id,cantidad:i.cantidad,precio_unitario:i.precio_unitario,devolver_inventario:i.devolver_inventario}))});
      showNueva.value=false; ventaSel.value=null; cargar();
    });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.error||i18n.t('error')); }
  }
}
async function verDetalle(id) { try { const {data}=await api.get(`/notas-credito/${id}`); det.value=data.nota; showDet.value=true; } catch(e){} }
async function cancelar(id) { if(!await confirm.ask({ message: i18n.t('notas_filtro_cancelada') + '?', confirmText: i18n.t('cancelar'), type: 'danger' })) return; try { await api.post(`/notas-credito/${id}/cancelar`); cargar(); } catch(e){} }
function badgeEstado(e) { return {activa:'badge-success',usada:'badge-info',cancelada:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
.filter-input { width: 100%; max-width: 250px; min-width: 0; }
.filter-select { width: 100%; max-width: 150px; min-width: 0; }
.table-num-input { width: 100%; max-width: 70px; min-width: 0; }

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
