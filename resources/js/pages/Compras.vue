<template>
  <div>
    <div class="page-header">
      <div class="filters-row">
        <input v-model="filtro" class="form-control filter-input" :placeholder="i18n.t('buscar_compra')" @input="cargar">
        <select v-model="estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="pendiente">{{ i18n.t('pendiente') }}</option>
          <option value="recibida">{{ i18n.t('recibida') }}</option>
          <option value="cancelada">{{ i18n.t('cancelada') }}</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="showNueva=true"><i class="fas fa-plus"></i> {{ i18n.t('nueva_compra') }}</button>
    </div>

    <div class="card">
      <div class="card-body table-card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('numero_label') }}</th><th>{{ i18n.t('proveedor_col') }}</th><th>{{ i18n.t('total') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="c in items" :key="c.id">
                <td><strong>{{ c.numero_compra }}</strong></td>
                <td>{{ c.proveedor_nombre }}</td>
                <td>{{ formatMoney(c.total) }}</td>
                <td><span :class="['badge', badgeEstado(c.estado)]">{{ c.estado }}</span></td>
                <td>{{ formatDate(c.created_at) }}</td>
                <td>
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(c.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="c.estado==='pendiente'" class="btn btn-sm btn-success" @click="recibir(c.id)" :title="i18n.t('recibir')"><i class="fas fa-check"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="6" class="empty-state">{{ i18n.t('no_hay_compras') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nueva -->
    <div class="modal-overlay" :class="{active:showNueva}" @click.self="showNueva=false">
      <div class="modal modal-lg">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('nueva_orden') }}</h3><button class="modal-close" @click="showNueva=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-grid-2 mb-md">
            <div class="form-group"><label>{{ i18n.t('proveedor_col') }}</label>
              <select v-model="form.proveedor_id" class="form-control"><option value="">{{ i18n.t('seleccionar') }}</option><option v-for="p in proveedores" :key="p.id" :value="p.id">{{ p.nombre }}</option></select>
            </div>
            <div class="form-group"><label>{{ i18n.t('fecha_compra') }}</label><input v-model="form.fecha_compra" type="date" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('buscar_producto') }}</label><input v-model="buscarProd" class="form-control" :placeholder="i18n.t('nombre_o_codigo')" @input="buscarProductos"></div>
          <div v-if="prodResults.length" class="mb-md product-results">
            <div v-for="p in prodResults" :key="p.id" class="p-sm product-result-item" @click="agregarItem(p)">{{ p.nombre }} - {{ i18n.t('costo') }}: {{ formatMoney(p.precio_compra) }}</div>
          </div>
          <div class="table-responsive mb-md" v-if="form.items.length">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('costo_unitario') }}</th><th>{{ i18n.t('subtotal') }}</th><th></th></tr></thead>
              <tbody><tr v-for="(item,i) in form.items" :key="i"><td>{{ item.nombre }}</td><td><input v-model.number="item.cantidad" type="number" min="1" class="form-control input-sm"></td><td><input v-model.number="item.precio_unitario" type="number" class="form-control input-md"></td><td>{{ formatMoney(item.cantidad*item.precio_unitario) }}</td><td><button class="btn btn-sm btn-danger" @click="form.items.splice(i,1)"><i class="fas fa-trash"></i></button></td></tr></tbody>
            </table>
          </div>
          <div class="text-right"><strong>{{ i18n.t('total') }}: {{ formatMoney(totalForm) }}</strong></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-save" @click="guardar" :disabled="!form.proveedor_id||!form.items.length || isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('creando_compra') }}</span><span v-else>{{ i18n.t('crear_compra') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDetalle}" @click.self="showDetalle=false">
      <div class="modal modal-md">
        <div class="modal-header"><h3 class="modal-title">{{ detalle?.numero_compra }}</h3><button class="modal-close" @click="showDetalle=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="detalle">
          <div class="info-grid mb-md">
            <div><strong>{{ i18n.t('proveedor_col') }}:</strong> {{ detalle.proveedor_nombre }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge',badgeEstado(detalle.estado)]">{{ detalle.estado }}</span></div>
          </div>
          <div class="table-responsive">
            <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('costo') }}</th><th>{{ i18n.t('subtotal') }}</th></tr></thead>
              <tbody><tr v-for="item in detalle.items" :key="item.id"><td>{{ item.producto_nombre }}</td><td>{{ item.cantidad }}</td><td>{{ formatMoney(item.precio_unitario) }}</td><td>{{ formatMoney(item.subtotal) }}</td></tr></tbody>
            </table>
          </div>
          <div class="mt-md text-right total-text"><strong>{{ i18n.t('total') }}: {{ formatMoney(detalle.total) }}</strong></div>
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

const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const confirm = useConfirmStore();
const i18n = useI18nStore();

const items = ref([]); const filtro = ref(''); const estado = ref('');
const showNueva = ref(false); const showDetalle = ref(false); const detalle = ref(null);
const proveedores = ref([]);
const form = ref({ proveedor_id:'', fecha_compra:'', items:[], notas:'' });
const buscarProd = ref(''); const prodResults = ref([]);
const totalForm = computed(() => form.value.items.reduce((s,i) => s+i.cantidad*i.precio_unitario, 0));

onMounted(async () => { cargar(); try { const {data}=await api.get('/proveedores',{params:{activo:1}}); proveedores.value=data.data||[]; } catch(e){} });

import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('creando_compra') });

async function cargar() { try { const {data}=await api.get('/compras',{params:{q:filtro.value,estado:estado.value}}); items.value=data.data||[]; } catch(e){} }
async function buscarProductos() { if(buscarProd.value.length<2){prodResults.value=[];return;} try { const {data}=await api.get('/productos/buscar',{params:{q:buscarProd.value}}); prodResults.value=data.productos||[]; } catch(e){} }
function agregarItem(p) { form.value.items.push({producto_id:p.id,nombre:p.nombre,cantidad:1,precio_unitario:p.precio_compra||0}); buscarProd.value=''; prodResults.value=[]; }
async function guardar() {
  try {
    await execute(async () => {
      await api.post('/compras',form.value);
      showNueva.value=false;
      form.value={proveedor_id:'',fecha_compra:'',items:[],notas:''};
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
async function verDetalle(id) { try { const {data}=await api.get(`/compras/${id}`); detalle.value=data.compra; showDetalle.value=true; } catch(e){} }
async function recibir(id) { if(!await confirm.ask({ message: i18n.t('recibir_compra'), confirmText: i18n.t('recibir'), type: 'success' })) return; try { await api.post(`/compras/${id}/recibir`); cargar(); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); } }
function badgeEstado(e) { return {pendiente:'badge-warning',recibida:'badge-success',cancelada:'badge-danger'}[e]||'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.filters-row {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-input {
  width: 250px;
  min-width: 0;
}

.filter-select {
  width: 150px;
  min-width: 0;
}

.table-card-body {
  padding: 0;
}

.product-results {
  max-height: 150px;
  overflow: auto;
  border: 1px solid var(--bg-hover);
  border-radius: 8px;
}

.product-result-item {
  cursor: pointer;
  border-bottom: 1px solid var(--bg-hover);
}

.input-sm {
  width: 70px;
  min-width: 50px;
}

.input-md {
  width: 100px;
  min-width: 60px;
}

.btn-save {
  min-height: 44px;
}

.modal-lg {
  max-width: min(90vw, 800px);
}

.modal-md {
  max-width: min(90vw, 700px);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.form-grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.total-text {
  font-size: clamp(16px, 2vw, 18px);
}

/* Tablet */
@media (max-width: 1023px) {
  .filter-input {
    width: 200px;
  }

  .filter-select {
    width: 130px;
  }
}

/* Mobile */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .page-header .btn {
    min-height: 44px;
  }

  .filters-row {
    flex-direction: column;
  }

  .filter-input,
  .filter-select {
    width: 100%;
  }

  .form-grid-2 {
    grid-template-columns: 1fr;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .modal-lg,
  .modal-md {
    max-width: 95vw;
    margin: 16px;
  }
}

/* Small mobile */
@media (max-width: 480px) {
  .page-header .btn {
    width: 100%;
    min-height: 48px;
  }

  .btn-save {
    width: 100%;
    min-height: 48px;
  }
}
</style>
