<template>
  <div>
    <div class="flex items-center gap-sm mb-lg flex-wrap">
      <input v-model="filtros.busqueda" class="form-control busqueda-input" :placeholder="i18n.t('registro_ventas_buscar')" @input="cargar">
      <input v-model="filtros.desde" type="date" class="form-control date-input" @change="cargar">
      <input v-model="filtros.hasta" type="date" class="form-control date-input" @change="cargar">
      <select v-model="filtros.usuario_id" class="form-control usuario-select" @change="cargar">
        <option value="">{{ i18n.t('registro_ventas_todos_usuarios') }}</option>
        <option v-for="u in usuarios" :key="u.id" :value="u.id">{{ u.nombre }}</option>
      </select>
    </div>
    <div class="card"><div class="card-body table-responsive">
      <table class="data-table"><thead><tr><th>#</th><th>{{ i18n.t('registro_ventas_fecha') }}</th><th>{{ i18n.t('registro_ventas_cliente') }}</th><th>{{ i18n.t('registro_ventas_vendedor') }}</th><th>{{ i18n.t('registro_ventas_total') }}</th><th>{{ i18n.t('registro_ventas_metodo') }}</th><th>{{ i18n.t('registro_ventas_estado') }}</th><th></th></tr></thead>
        <tbody><tr v-for="v in ventas" :key="v.id">
          <td><strong>{{ v.numero_factura||v.id }}</strong></td>
          <td>{{ fdate(v.created_at) }}</td>
          <td>{{ v.cliente_nombre||i18n.t('registro_ventas_publico_general') }}</td>
          <td>{{ v.usuario_nombre||'-' }}</td>
          <td class="total-cell">{{ fm(v.total) }}</td>
          <td><span class="badge badge-info">{{ v.metodo_pago }}</span></td>
          <td><span :class="['badge', estadoBadgeClass(v)]">{{ estadoDisplay(v) }}</span></td>
          <td><button class="btn btn-sm btn-ghost" @click="verDetalle(v)"><i class="fas fa-eye"></i></button></td>
        </tr></tbody>
      </table>
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
import { useI18nStore } from '../stores/i18n';
import { useCurrency } from '../composables/useCurrency';

const { fm } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();

const ventas = ref([]); const usuarios = ref([]); const page = ref(1); const pages = ref(1);
const filtros = ref({ busqueda:'', desde:'', hasta:'', usuario_id:'' });
async function cargar() { try { const {data} = await api.get('/ventas', {params:{...filtros.value, page:page.value}}); ventas.value=data.ventas||[]; page.value=data.page||1; pages.value=data.pages||1; } catch(e){} }
async function cargarUsuarios() { try { const {data} = await api.get('/usuarios'); usuarios.value=data.usuarios||[]; } catch(e){} }
function verDetalle(v) { toast.info(`${i18n.t('registro_ventas_numero')} #${v.id} - ${i18n.t('registro_ventas_cliente')}: ${v.cliente_nombre||i18n.t('registro_ventas_n_a')} - ${i18n.t('registro_ventas_total')}: ${fm(v.total)}`); }
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleString('es-CR',{day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }
function estadoBadgeClass(v) {
    if (v.has_devolucion) return 'badge-warning';
    if (v.estado === 'completada') return 'badge-success';
    if (v.estado === 'cancelada') return 'badge-danger';
    if (v.estado === 'parcialmente_anulada') return 'badge-warning';
    return 'badge-secondary';
}
function estadoDisplay(v) {
    if (v.has_devolucion) return i18n.t('registro_ventas_con_devolucion');
    return v.estado;
}
onMounted(() => { cargar(); cargarUsuarios(); });
</script>

<style scoped>
.busqueda-input {
    max-width: 280px;
    min-height: 44px;
}

.date-input {
    width: 150px;
    min-height: 44px;
}

.usuario-select {
    width: 160px;
    min-height: 44px;
}

.table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    padding: 0;
}

.total-cell {
    font-weight: 700;
}

@media (max-width: 1023px) {
    .busqueda-input {
        max-width: 240px;
    }

    .data-table {
        min-width: 750px;
    }
}

@media (max-width: 768px) {
    .busqueda-input,
    .date-input,
    .usuario-select {
        width: 100%;
        max-width: 100%;
    }

    .data-table {
        min-width: 700px;
    }
}

@media (max-width: 480px) {
    .busqueda-input,
    .date-input,
    .usuario-select {
        width: 100%;
        max-width: 100%;
        min-height: 44px;
    }

    .data-table th,
    .data-table td {
        padding: 8px 10px;
        font-size: 12px;
    }
}
</style>
