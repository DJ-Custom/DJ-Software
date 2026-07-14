<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ i18n.t('presupuestos') }}</h3>
      <div class="flex items-center gap-sm">
        <DateRangeDownloader :fetch-data="fetchPresupuestosRange" filename="presupuestos" :columns="presupuestosColumns" />
        <button class="btn btn-primary" @click="showModal=true;form={nombre:'',fecha_inicio:'',fecha_fin:'',monto_total:0,periodo:'mensual',notas:'',detalle:[]}"><i class="fas fa-plus"></i> {{ i18n.t('presupuestos_nuevo') }}</button>
      </div>
    </div>
    <div class="grid-2 gap-lg">
      <div v-for="p in presupuestos" :key="p.id" class="card">
        <div class="card-header"><h3 class="card-title">{{ p.nombre }}</h3><span :class="['badge', p.estado==='activo'?'badge-success':'badge-secondary']">{{ p.estado }}</span></div>
        <div class="card-body">
          <div class="form-grid-2 gap-sm mb-md">
            <div><span class="text-xs text-muted">{{ i18n.t('presupuestos_periodo') }}</span><div style="font-weight:600;">{{ p.fecha_inicio }} - {{ p.fecha_fin }}</div></div>
            <div><span class="text-xs text-muted">{{ i18n.t('presupuestos_total_asignado') }}</span><div style="font-weight:600;">{{ fm(p.monto_total) }}</div></div>
          </div>
          <div class="mb-sm">
            <div class="flex items-center justify-between mb-xs"><span class="text-xs">{{ i18n.t('presupuestos_ejecutado') }}: {{ p.porcentaje_ejecutado }}%</span><span class="text-xs">{{ fm(p.monto_ejecutado) }}</span></div>
            <div class="progress-bar"><div :style="{width:Math.min(p.porcentaje_ejecutado,100)+'%',height:'100%',background:p.porcentaje_ejecutado>90?'var(--danger)':p.porcentaje_ejecutado>70?'var(--warning)':'var(--success)',borderRadius:'4px',transition:'width 0.3s'}"></div></div>
          </div>
          <div v-if="p.detalle?.length" style="margin-top:12px;">
            <div v-for="d in p.detalle" :key="d.id" class="flex items-center justify-between detail-row">
              <span>{{ d.categoria }}</span><span style="font-weight:600;">{{ fm(d.monto_asignado) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="!presupuestos.length" class="card empty-state">{{ i18n.t('presupuestos_sin_datos') }}</div>

    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('presupuestos_nuevo') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('presupuestos_nombre') }} *</label><input v-model="form.nombre" class="form-control"></div>
          <div class="form-grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('fecha') }} Inicio *</label><input v-model="form.fecha_inicio" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('fecha') }} Fin *</label><input v-model="form.fecha_fin" type="date" class="form-control"></div>
          </div>
          <div class="form-grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('presupuestos_monto') }} *</label><input v-model.number="form.monto_total" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('presupuestos_periodo') }}</label><select v-model="form.periodo" class="form-control"><option value="mensual">Mensual</option><option value="trimestral">Trimestral</option><option value="anual">Anual</option></select></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('presupuestos_notas') }}</label><textarea v-model="form.notas" class="form-control" rows="2"></textarea></div>
          <div class="form-group"><label>{{ i18n.t('presupuestos_categoria') }}</label>
            <div v-for="(d,i) in form.detalle" :key="i" class="flex items-center gap-sm mb-xs detail-row-edit">
              <input v-model="d.categoria" class="form-control flex-1" :placeholder="i18n.t('presupuestos_categoria')">
              <input v-model.number="d.monto_asignado" type="number" class="form-control monto-input" :placeholder="i18n.t('presupuestos_monto')">
              <button class="btn btn-sm btn-danger" @click="form.detalle.splice(i,1)"><i class="fas fa-times"></i></button>
            </div>
            <button class="btn btn-sm btn-ghost" @click="form.detalle.push({categoria:'',monto_asignado:0})"><i class="fas fa-plus"></i> Agregar categoría</button>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('procesando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('crear') }}</span></button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';
import { useCurrency } from '../composables/useCurrency';
import DateRangeDownloader from '../components/DateRangeDownloader.vue';

const { fm } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('procesando') });

const presupuestos = ref([]); const showModal = ref(false); const form = ref({});

const presupuestosColumns = [
  { key: 'nombre', label: 'Nombre' },
  { key: 'fecha_inicio', label: 'Fecha Inicio' },
  { key: 'fecha_fin', label: 'Fecha Fin' },
  { key: 'monto_total', label: 'Monto Total' },
  { key: 'monto_ejecutado', label: 'Ejecutado' },
  { key: 'porcentaje_ejecutado', label: '% Ejecutado' },
  { key: 'estado', label: 'Estado' },
];

async function fetchPresupuestosRange(desde, hasta) {
  const { data } = await api.get('/presupuestos');
  return (data.presupuestos || []).map(p => ({
    nombre: p.nombre, fecha_inicio: p.fecha_inicio, fecha_fin: p.fecha_fin,
    monto_total: p.monto_total, monto_ejecutado: p.monto_ejecutado,
    porcentaje_ejecutado: p.porcentaje_ejecutado, estado: p.estado,
  }));
}

async function cargar() { try { const {data} = await api.get('/presupuestos'); presupuestos.value=data.presupuestos||[]; } catch(e){} }
async function guardar() {
  try {
    await execute(async () => { await api.post('/presupuestos', form.value); showModal.value=false; cargar(); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message||i18n.t('error')); }
  }
}
onMounted(cargar);
</script>

<style scoped>
.modal-responsive {
  max-width: min(90vw, 550px);
}

.form-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.progress-bar {
  background: var(--bg-hover);
  border-radius: 4px;
  height: 8px;
  overflow: hidden;
}

.detail-row {
  padding: 4px 0;
  font-size: 13px;
  border-bottom: 1px solid var(--bg-hover);
}

.detail-row-edit {
  border-bottom: 1px solid var(--bg-hover);
}

.monto-input {
  width: 120px;
  min-width: 80px;
}

.text-xs {
  font-size: 12px;
}

.text-muted {
  color: var(--text-muted);
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

@media (max-width: 1023px) {
  .grid-2 {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .grid-2 {
    grid-template-columns: 1fr;
  }

  .form-grid-2 {
    grid-template-columns: 1fr;
  }

  .modal-responsive {
    max-width: min(95vw, 550px);
  }

  .btn {
    min-height: 44px;
  }

  .monto-input {
    width: 100px;
    min-width: 70px;
  }

  .card-header {
    flex-wrap: wrap;
  }
}

@media (max-width: 480px) {
  .detail-row {
    font-size: 12px;
  }

  .detail-row-edit {
    flex-wrap: wrap;
  }

  .monto-input {
    width: 100%;
    min-width: 0;
  }
}
</style>
