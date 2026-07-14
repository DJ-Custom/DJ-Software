<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <select v-model="estado" class="form-control" style="width:100%; max-width:180px;" @change="cargar">
        <option value="">{{ i18n.t('todos') }}</option>
        <option value="borrador">{{ i18n.t('ajustes_borrador') }}</option>
        <option value="aplicado">{{ i18n.t('ajustes_aplicado') }}</option>
        <option value="cancelado">{{ i18n.t('presupuestos_estado_cancelado') }}</option>
      </select>
      <button class="btn btn-primary" @click="showNuevo=true"><i class="fas fa-plus"></i> {{ i18n.t('ajustes_nuevo') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('ajustes_numero') }}</th><th>{{ i18n.t('ajustes_tipo') }}</th><th>{{ i18n.t('ajustes_motivo') }}</th><th>{{ i18n.t('ajustes_ubicacion') }}</th><th>{{ i18n.t('ajustes_usuario') }}</th><th>{{ i18n.t('ajustes_estado') }}</th><th>{{ i18n.t('ajustes_fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="a in items" :key="a.id">
                <td :data-label="i18n.t('ajustes_numero')"><strong>{{ a.numero_ajuste }}</strong></td>
                <td :data-label="i18n.t('ajustes_tipo')"><span class="badge badge-info">{{ a.tipo }}</span></td>
                <td :data-label="i18n.t('ajustes_motivo')">{{ a.motivo }}</td>
                <td :data-label="i18n.t('ajustes_ubicacion')"><span v-if="a.ubicacion_nombre" class="badge badge-info"><i class="fas fa-map-marker-alt"></i> {{ a.ubicacion_nombre }}</span><span v-else class="badge badge-secondary">{{ i18n.t('ajustes_sin_ubicacion') }}</span></td>
                <td :data-label="i18n.t('ajustes_usuario')">{{ a.usuario_nombre }}</td>
                <td :data-label="i18n.t('ajustes_estado')"><span :class="['badge', badgeEstado(a.estado)]">{{ a.estado }}</span></td>
                <td :data-label="i18n.t('ajustes_fecha')">{{ formatDate(a.created_at) }}</td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(a.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="a.estado==='borrador'" class="btn btn-sm btn-success" @click="aplicar(a.id)" :title="i18n.t('ajustes_aplicar')"><i class="fas fa-check"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="8" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('ajustes_sin_datos') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nuevo -->
    <div class="modal-overlay" :class="{active:showNuevo}" @click.self="showNuevo=false">
      <div class="modal" style="max-width: min(90vw, 700px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('ajustes_nuevo') }}</h3><button class="modal-close" @click="showNuevo=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 mb-md">
            <div class="form-group"><label>{{ i18n.t('ajustes_tipo') }}</label><select v-model="form.tipo" class="form-control"><option value="entrada">{{ i18n.t('ajustes_tipo_entrada') }}</option><option value="salida">{{ i18n.t('ajustes_tipo_salida') }}</option><option value="conteo">{{ i18n.t('ajustes_tipo_conteo') }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('ajustes_motivo') }}</label><select v-model="form.motivo" class="form-control"><option value="dano">{{ i18n.t('ajustes_tipo_dano') }}</option><option value="robo">Robo</option><option value="vencimiento">{{ i18n.t('ajustes_tipo_vencimiento') }}</option><option value="correccion">{{ i18n.t('ajustes_tipo_correccion') }}</option><option value="otro">{{ i18n.t('ajustes_tipo_otros') }}</option></select></div>
          </div>
          <div class="form-group">
            <label>{{ i18n.t('ajustes_ubicacion') }} <span style="color:var(--danger);">*</span></label>
            <div class="flex gap-sm">
              <select v-model="form.ubicacion_id" class="form-control" style="flex:1;" :class="{'border-danger':!form.ubicacion_id}">
                <option value="">— Seleccionar ubicación —</option>
                <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
              </select>
              <input v-model="ubicacionBuscar" class="form-control" placeholder="Buscar ubicación..." style="width:100%; max-width:200px;" @input="filtrarUbicaciones">
            </div>
            <div v-if="ubicacionesFiltradas.length && ubicacionBuscar" style="max-height:120px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;margin-top:4px;">
              <div v-for="u in ubicacionesFiltradas" :key="u.id" class="p-sm" style="cursor:pointer;" @click="form.ubicacion_id=u.id;ubicacionBuscar=''">{{ u.nombre }} <span style="color:var(--text-muted);font-size:12px;">{{ u.direccion||'' }}</span></div>
            </div>
          </div>
          <div class="form-group"><label>{{ i18n.t('ajustes_detalle') }}</label><input v-model="form.motivo_detalle" class="form-control" placeholder="Detalle del motivo"></div>
          <div class="form-group"><label>{{ i18n.t('presupuestos_notas') }}</label><textarea v-model="form.notas" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="crearAjuste">{{ i18n.t('crear') }} ({{ i18n.t('ajustes_borrador') }})</button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDet}" @click.self="showDet=false">
      <div class="modal" style="max-width: min(90vw, 800px);">
        <div class="modal-header"><h3 class="modal-title">{{ det?.numero_ajuste }}</h3><button class="modal-close" @click="showDet=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="det">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('ajustes_tipo') }}:</strong> {{ det.tipo }}</div>
            <div><strong>{{ i18n.t('ajustes_estado') }}:</strong> <span :class="['badge',badgeEstado(det.estado)]">{{ det.estado }}</span></div>
            <div><strong>{{ i18n.t('ajustes_motivo') }}:</strong> {{ det.motivo }}</div>
            <div><strong>{{ i18n.t('ajustes_ubicacion') }}:</strong> <span v-if="det.ubicacion_nombre" class="badge badge-info"><i class="fas fa-map-marker-alt"></i> {{ det.ubicacion_nombre }}</span><span v-else class="badge badge-secondary">{{ i18n.t('ajustes_sin_ubicacion') }}</span></div>
          </div>
          <div v-if="det.estado==='borrador'" class="mb-md">
            <h4 class="mb-sm">{{ i18n.t('cotizaciones_agregar_producto') }}</h4>
            <div class="flex gap-sm mb-sm">
              <input v-model="addBuscar" class="form-control" :placeholder="i18n.t('ajustes_buscar_producto')" @input="buscarProds" style="flex:1;">
              <input v-if="det.tipo==='conteo'" v-model.number="addStockFisico" type="number" class="form-control" placeholder="Stock físico" style="width:100%; max-width:120px;">
              <input v-else v-model.number="addCantidad" type="number" class="form-control" :placeholder="i18n.t('cantidad')" style="width:100%; max-width:100px;">
              <button class="btn btn-sm btn-primary" @click="agregarProd" :disabled="!addSelProd">{{ i18n.t('listas_precios_agregar') }}</button>
            </div>
            <div v-if="addProdResults.length" style="max-height:120px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
              <div v-for="p in addProdResults" :key="p.id" class="p-sm" style="cursor:pointer;" @click="addSelProd=p;addBuscar=p.nombre;addProdResults=[]">{{ p.nombre }} (Stock ubicación: {{ p.stock_ubicacion !== undefined ? p.stock_ubicacion : p.stock }})</div>
            </div>
          </div>
          <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>Stock Sistema</th><th v-if="det.tipo==='conteo'">Stock Físico</th><th>{{ i18n.t('cantidad') }} Ajuste</th></tr></thead>
            <tbody><tr v-for="it in det.items" :key="it.id"><td>{{ it.producto_nombre }}</td><td>{{ it.stock_sistema }}</td><td v-if="det.tipo==='conteo'">{{ it.stock_fisico }}</td><td>{{ it.cantidad_ajuste }}</td></tr></tbody>
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
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const confirm = useConfirmStore();
const i18n = useI18nStore();

const items = ref([]); const estado = ref('');
const showNuevo = ref(false); const showDet = ref(false); const det = ref(null);
const form = ref({ tipo:'entrada', motivo:'correccion', motivo_detalle:'', notas:'', ubicacion_id:'' });
const ubicaciones = ref([]);
const ubicacionBuscar = ref('');
const ubicacionesFiltradas = ref([]);
const addBuscar = ref(''); const addProdResults = ref([]); const addSelProd = ref(null); const addCantidad = ref(1); const addStockFisico = ref(null);

onMounted(async () => { cargar(); try { const {data}=await api.get('/configuracion/ubicaciones'); ubicaciones.value=data.ubicaciones||[]; } catch(e){} });
async function cargar() { try { const {data}=await api.get('/ajustes-inventario',{params:{estado:estado.value}}); items.value=data.data||[]; } catch(e){} }
async function crearAjuste() {
  if (!form.value.ubicacion_id) { toast.error('Debe seleccionar una ubicación'); return; }
  try { const {data}=await api.post('/ajustes-inventario',form.value); showNuevo.value=false; cargar(); verDetalle(data.id); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); }
}
async function verDetalle(id) { try { const {data}=await api.get(`/ajustes-inventario/${id}`); det.value=data.ajuste; showDet.value=true; } catch(e){} }
function filtrarUbicaciones() {
  const q = ubicacionBuscar.value.toLowerCase();
  ubicacionesFiltradas.value = q ? ubicaciones.value.filter(u => (u.nombre||'').toLowerCase().includes(q) || (u.direccion||'').toLowerCase().includes(q)) : [];
}
async function buscarProds() { if(addBuscar.value.length<2){addProdResults.value=[];return;} try { const {data}=await api.get('/productos/buscar',{params:{q:addBuscar.value,ubicacion_id:det.value?.ubicacion_id}}); addProdResults.value=data.productos||[]; } catch(e){} }
async function agregarProd() {
  if(!addSelProd.value||!det.value) return;
  try {
    const payload = { ajuste_id: det.value.id, producto_id: addSelProd.value.id };
    if (det.value.tipo === 'conteo') {
      payload.stock_fisico = addStockFisico.value;
    } else {
      payload.cantidad_ajuste = addCantidad.value;
    }
    await api.post('/ajustes-inventario/agregar-producto', payload);
    addSelProd.value=null; addBuscar.value=''; addCantidad.value=1; addStockFisico.value=null;
    verDetalle(det.value.id);
  } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); }
}
async function aplicar(id) { if(!await confirm.ask({ message: '¿Aplicar ajuste? Esta acción modificará el inventario.', confirmText: i18n.t('ajustes_aplicar'), type: 'warning' })) return; try { await api.post(`/ajustes-inventario/${id}/aplicar`); cargar(); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); } }
function badgeEstado(e) { return {borrador:'badge-warning',aplicado:'badge-success',cancelado:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
@media (max-width: 1023px) {
  .flex { flex-wrap: wrap; }
}

@media (max-width: 768px) {
  .flex { flex-wrap: wrap; gap: 8px; }
  .form-control {
    width: 100% !important;
    max-width: 100% !important;
    min-width: 0 !important;
  }
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  .page-header .form-control {
    max-width: 100% !important;
  }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 500px; }
}

@media (max-width: 480px) {
  .btn {
    min-height: 44px;
    width: 100%;
    font-size: 15px;
  }
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
  .modal-body { padding: 16px; overflow-y: auto; }
}
</style>
