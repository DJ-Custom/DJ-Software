<template>
  <div>
    <div class="flex items-center gap-sm mb-lg flex-wrap filter-row">
      <select v-model="filtro.estado" class="form-control filter-input" @change="cargar"><option value="">{{ i18n.t('todos') }}</option><option value="pendiente">{{ i18n.t('facturacion_electronica_pendiente') }}</option><option value="aceptada">{{ i18n.t('facturacion_electronica_aceptada') }}</option><option value="rechazada">{{ i18n.t('facturacion_electronica_rechazada') }}</option></select>
      <input v-model="filtro.desde" type="date" class="form-control filter-input" @change="cargar">
      <input v-model="filtro.hasta" type="date" class="form-control filter-input" @change="cargar">
      <span class="badge badge-info">{{ total }} {{ i18n.t('facturacion_electronica_facturas') }}</span>
    </div>
    <div class="card"><div class="card-body" style="padding:0;">
      <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('facturacion_electronica_consecutivo') }}</th><th>{{ i18n.t('factura') }}</th><th>{{ i18n.t('facturacion_electronica_tipo') }}</th><th>{{ i18n.t('facturacion_electronica_estado_hacienda') }}</th><th>{{ i18n.t('facturacion_electronica_total_venta') }}</th><th>{{ i18n.t('facturacion_electronica_emision') }}</th><th></th></tr></thead>
          <tbody><tr v-for="f in facturas" :key="f.id">
            <td><strong>{{ f.numero_consecutivo }}</strong></td><td>{{ f.numero_factura||'-' }}</td>
            <td><span class="badge badge-info">{{ f.tipo_documento }}</span></td>
            <td><span :class="['badge', f.estado_hacienda==='aceptada'?'badge-success':f.estado_hacienda==='rechazada'?'badge-danger':'badge-warning']">{{ f.estado_hacienda }}</span></td>
            <td>{{ fm(f.venta_total) }}</td><td>{{ fdate(f.fecha_emision) }}</td>
            <td><button v-if="f.estado_hacienda!=='aceptada'" class="btn btn-sm btn-info" @click="reenviar(f.id)"><i class="fas fa-redo"></i></button></td>
          </tr></tbody>
        </table>
      </div>
    </div></div>
    <div class="flex items-center justify-center gap-sm mt-md" v-if="pages > 1">
      <button class="btn btn-sm btn-ghost" :disabled="page<=1" @click="page--;cargar()"><i class="fas fa-chevron-left"></i></button>
      <span>{{ page }} / {{ pages }}</span>
      <button class="btn btn-sm btn-ghost" :disabled="page>=pages" @click="page++;cargar()"><i class="fas fa-chevron-right"></i></button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const { fm } = useCurrency();

const toast = useToastStore();

const facturas = ref([]); const total = ref(0); const pages = ref(1); const page = ref(1);
const filtro = ref({estado:'',desde:'',hasta:''});
async function cargar() { try { const {data} = await api.get('/facturacion-electronica', {params:{...filtro.value,page:page.value}}); facturas.value=data.facturas||[]; total.value=data.total; pages.value=data.pages; } catch(e){} }
async function reenviar(id) { try { await api.post(`/facturacion-electronica/${id}/reenviar`); toast.success(i18n.t('facturacion_electronica_enviada')); cargar(); } catch(e){} }
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
onMounted(cargar);
</script>

<style scoped>
.filter-row {
  flex-wrap: wrap;
}

.filter-input {
  width: auto;
  min-width: 130px;
  flex: 1 1 auto;
}

@media (max-width: 1023px) {
  .filter-input {
    min-width: 110px;
  }
}

@media (max-width: 768px) {
  .filter-input {
    min-width: 100%;
    width: 100%;
  }

  .btn {
    min-height: 44px;
  }

  .badge-info {
    width: 100%;
    text-align: center;
  }
}

@media (max-width: 480px) {
  .data-table {
    font-size: 13px;
  }

  .data-table th,
  .data-table td {
    padding: 6px 8px;
    white-space: nowrap;
  }

  .pagination {
    font-size: 14px;
  }
}
</style>
