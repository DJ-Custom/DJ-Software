<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <select v-model="estado" class="form-control" style="width:100%; max-width:180px;" @change="cargar">
        <option value="">{{ i18n.t('traspasos_filtro_todos') }}</option>
        <option value="pendiente">{{ i18n.t('traspasos_filtro_pendiente') }}</option>
        <option value="en_transito">{{ i18n.t('traspasos_filtro_en_transito') }}</option>
        <option value="recibido">{{ i18n.t('traspasos_filtro_recibido') }}</option>
        <option value="cancelado">{{ i18n.t('traspasos_filtro_cancelado') }}</option>
      </select>
      <button class="btn btn-primary" @click="showNuevo=true"><i class="fas fa-plus"></i> {{ i18n.t('nuevo_traspaso') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('traspasos_numero') }}</th><th>{{ i18n.t('origen') }}</th><th>{{ i18n.t('destino') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="t in items" :key="t.id">
                <td><strong>{{ t.numero_traspaso }}</strong></td>
                <td>{{ t.origen_nombre }}</td>
                <td>{{ t.destino_nombre }}</td>
                <td><span :class="['badge', badgeEstado(t.estado)]">{{ t.estado }}</span></td>
                <td>{{ formatDate(t.created_at) }}</td>
                <td>
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(t.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="t.estado==='pendiente'" class="btn btn-sm btn-info" @click="enviar(t.id)" :title="i18n.t('enviar')"><i class="fas fa-truck"></i></button>
                  <button v-if="t.estado==='en_transito'" class="btn btn-sm btn-success" @click="abrirModalRecibir(t.id)" :title="i18n.t('recibir')"><i class="fas fa-check"></i></button>
                  <button v-if="t.estado==='pendiente'||t.estado==='en_transito'" class="btn btn-sm btn-danger" @click="cancelar(t.id)" :title="i18n.t('cancelar')"><i class="fas fa-times"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="6" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('sin_traspasos') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nuevo -->
    <div class="modal-overlay" :class="{active:showNuevo}" @click.self="showNuevo=false">
      <div class="modal" style="max-width: min(90vw, 800px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('nuevo_traspaso') }}</h3><button class="modal-close" @click="showNuevo=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 mb-md">
            <div class="form-group"><label>{{ i18n.t('origen') }}</label><select v-model="form.ubicacion_origen_id" class="form-control"><option value="">{{ i18n.t('seleccionar') }}...</option><option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('destino') }}</label><select v-model="form.ubicacion_destino_id" class="form-control"><option value="">{{ i18n.t('seleccionar') }}...</option><option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option></select></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label><input v-model="buscarProd" class="form-control" @input="buscarProductos" :placeholder="i18n.t('nombre_o_codigo')"></div>
          <div v-if="prodResults.length" class="mb-md" style="max-height:150px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="p in prodResults" :key="p.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);" @click="agregarItem(p)">{{ p.nombre }} ({{ i18n.t('stock') }}: {{ p.stock_ubicacion ?? p.stock }})</div>
          </div>
          <table class="data-table mb-md" v-if="form.items.length">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('disponible') }}</th><th></th></tr></thead>
            <tbody><tr v-for="(item,i) in form.items" :key="i"><td>{{ item.nombre }}</td><td><input v-model.number="item.cantidad" type="number" min="1" :max="item.stock_ubicacion" class="form-control" style="width:100%; max-width:80px;"></td><td>{{ item.stock_ubicacion }}</td><td><button class="btn btn-sm btn-danger" @click="form.items.splice(i,1)"><i class="fas fa-trash"></i></button></td></tr></tbody>
          </table>
          <div class="form-group"><label>{{ i18n.t('nota') }}</label><textarea v-model="form.notas" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="!form.ubicacion_origen_id||!form.ubicacion_destino_id||!form.items.length||form.items.some(i=>!i.cantidad||i.cantidad>i.stock_ubicacion) || isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('creando_traspaso') }}</span><span v-else>{{ i18n.t('crear') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDet}" @click.self="showDet=false">
      <div class="modal" style="max-width: min(90vw, 700px);">
        <div class="modal-header"><h3 class="modal-title">{{ det?.numero_traspaso }}</h3><button class="modal-close" @click="showDet=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="det">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('origen') }}:</strong> {{ det.origen_nombre }}</div>
            <div><strong>{{ i18n.t('destino') }}:</strong> {{ det.destino_nombre }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge',badgeEstado(det.estado)]">{{ det.estado }}</span></div>
          </div>
          <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('enviado') }}</th><th>{{ i18n.t('recibido') }}</th><th>{{ i18n.t('diferencia') }}</th></tr></thead>
            <tbody><tr v-for="it in det.items" :key="it.id"><td>{{ it.producto_nombre }}</td><td>{{ it.cantidad_enviada }}</td><td>{{ it.cantidad_recibida }}</td><td>{{ it.diferencia }}</td></tr></tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Recibir -->
    <div class="modal-overlay" :class="{active:showRecibir}" @click.self="showRecibir=false">
      <div class="modal" style="max-width: min(90vw, 700px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('recibir') }}</h3><button class="modal-close" @click="showRecibir=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="recibirData">
          <table class="data-table mb-md">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('enviado') }}</th><th>{{ i18n.t('recibido') }}</th><th>{{ i18n.t('nota') }}</th></tr></thead>
            <tbody><tr v-for="it in recibirData.items" :key="it.id">
              <td>{{ it.producto_nombre }}</td>
              <td>{{ it.cantidad_enviada }}</td>
              <td><input v-model.number="it.cantidad_recibida" type="number" min="0" :max="it.cantidad_enviada" class="form-control" style="width:100%; max-width:80px;"></td>
              <td><input v-model="it.notas_diferencia" class="form-control" style="width:100%; max-width:140px;" :placeholder="i18n.t('nota') + '...'"></td>
            </tr></tbody>
          </table>
          <div class="form-group"><label>{{ i18n.t('nota') }}</label><textarea v-model="recibirData.notas_recepcion" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-success" @click="confirmarRecibir" :disabled="recibirData?.items?.some(i=>i.cantidad_recibida===undefined||i.cantidad_recibida<0)">{{ i18n.t('confirmar') }}</button></div>
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
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: 'Creando traspaso...' });

const items = ref([]); const estado = ref('');
const showNuevo = ref(false); const showDet = ref(false); const showRecibir = ref(false);
const det = ref(null); const recibirData = ref(null);
const ubicaciones = ref([]);
const form = ref({ ubicacion_origen_id:'', ubicacion_destino_id:'', items:[], notas:'' });
const buscarProd = ref(''); const prodResults = ref([]);

onMounted(async () => { cargar(); try { const {data}=await api.get('/traspasos/ubicaciones'); ubicaciones.value=data.ubicaciones||[]; } catch(e){} });

async function cargar() { try { const {data}=await api.get('/traspasos',{params:{estado:estado.value}}); items.value=data.data||[]; } catch(e){} }
async function buscarProductos() { if(buscarProd.value.length<2){prodResults.value=[];return;} try { const {data}=await api.get('/productos/buscar',{params:{q:buscarProd.value,ubicacion_id:form.value.ubicacion_origen_id}}); prodResults.value=data.productos||[]; } catch(e){} }
function agregarItem(p) { form.value.items.push({producto_id:p.id,nombre:p.nombre,stock_ubicacion:p.stock_ubicacion??p.stock,cantidad:1}); buscarProd.value=''; prodResults.value=[]; }
async function guardar() {
  try {
    await execute(async () => { await api.post('/traspasos',form.value); showNuevo.value=false; form.value={ubicacion_origen_id:'',ubicacion_destino_id:'',items:[],notas:''}; cargar(); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.error||i18n.t('error')); }
  }
}
async function verDetalle(id) { try { const {data}=await api.get(`/traspasos/${id}`); det.value=data.traspaso; showDet.value=true; } catch(e){} }
async function enviar(id) { if(!await confirm.ask({ message: i18n.t('traspasos_detalle'), confirmText: i18n.t('enviar'), type: 'info' })) return; try { await api.post(`/traspasos/${id}/enviar`); cargar(); } catch(e){} }
async function abrirModalRecibir(id) {
  try { const {data}=await api.get(`/traspasos/${id}`); recibirData.value={id:data.traspaso.id,items:data.traspaso.items.map(i=>({...i,cantidad_recibida:i.cantidad_enviada,notas_diferencia:''})),notas_recepcion:''}; showRecibir.value=true; } catch(e){}
}
async function confirmarRecibir() {
  if(!recibirData.value) return;
  try {
    await api.post(`/traspasos/${recibirData.value.id}/recibir`,{items:recibirData.value.items,notas_recepcion:recibirData.value.notas_recepcion});
    showRecibir.value=false; recibirData.value=null; cargar();
  } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); }
}
async function cancelar(id) { if(!await confirm.ask({ message: i18n.t('confirmar_eliminar'), confirmText: i18n.t('cancelar'), type: 'danger' })) return; try { await api.post(`/traspasos/${id}/cancelar`); cargar(); } catch(e){} }
function badgeEstado(e) { return {pendiente:'badge-warning',en_transito:'badge-info',recibido:'badge-success',cancelado:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
@media (max-width: 1023px) {
  .flex {
    flex-wrap: wrap;
  }
}

@media (max-width: 768px) {
  .flex {
    flex-wrap: wrap;
  }
  .form-control {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .btn {
    min-height: 44px;
    width: 100%;
  }
  .modal-body {
    padding: 16px;
  }
}
</style>
