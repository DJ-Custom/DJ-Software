<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ i18n.t('contabilidad') }}</h3>
      <button class="btn btn-primary" @click="showModal=true;form={fecha:'',tipo:'debito',cuenta_id:'',monto:0,descripcion:'',referencia:''}"><i class="fas fa-plus"></i> {{ i18n.t('contabilidad_nuevo_asiento') }}</button>
    </div>
    <div class="grid-3 mb-lg">
      <div class="stat-card"><div class="stat-value">{{ fm(activos) }}</div><div class="stat-label">{{ i18n.t('contabilidad_activos') }}</div></div>
      <div class="stat-card"><div class="stat-value">{{ fm(pasivos) }}</div><div class="stat-label">{{ i18n.t('contabilidad_pasivos') }}</div></div>
      <div class="stat-card"><div class="stat-value">{{ fm(patrimonio) }}</div><div class="stat-label">{{ i18n.t('contabilidad_patrimonio') }}</div></div>
    </div>
    <div class="card"><div class="card-body" style="padding:0;">
      <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('contabilidad_cuenta') }}</th><th>{{ i18n.t('contabilidad_tipo') }}</th><th>{{ i18n.t('contabilidad_descripcion') }}</th><th>{{ i18n.t('contabilidad_debe') }}</th><th>{{ i18n.t('contabilidad_haber') }}</th><th>{{ i18n.t('contabilidad_referencia') }}</th></tr></thead>
          <tbody><tr v-for="a in asientos" :key="a.id">
            <td>{{ a.fecha }}</td><td><strong>{{ a.cuenta_nombre || a.cuenta_id }}</strong></td>
            <td><span :class="['badge', a.tipo==='debito'?'badge-success':'badge-info']">{{ a.tipo }}</span></td>
            <td>{{ a.descripcion }}</td>
            <td style="color:var(--success);font-weight:700;">{{ a.tipo==='debito'?fm(a.monto):'-' }}</td>
            <td style="color:var(--info);font-weight:700;">{{ a.tipo==='credito'?fm(a.monto):'-' }}</td>
            <td class="text-xs">{{ a.referencia||'-' }}</td>
          </tr></tbody>
        </table>
      </div>
    </div></div>
    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('contabilidad_nuevo_asiento') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('fecha') }} *</label><input v-model="form.fecha" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('contabilidad_tipo') }} *</label><select v-model="form.tipo" class="form-control"><option value="debito">{{ i18n.t('contabilidad_debito') }}</option><option value="credito">{{ i18n.t('contabilidad_credito') }}</option></select></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('contabilidad_cuenta_contable') }}</label><input v-model="form.cuenta_id" class="form-control" :placeholder="i18n.t('contabilidad_cuenta')"></div>
          <div class="form-group"><label>{{ i18n.t('contabilidad_monto') }} *</label><input v-model.number="form.monto" type="number" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('contabilidad_descripcion') }}</label><input v-model="form.descripcion" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('contabilidad_referencia') }}</label><input v-model="form.referencia" class="form-control"></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('guardando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('guardar') }}</span></button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';
import { useSubmitLock } from '../composables/useSubmitLock';

const { fm } = useCurrency();
const i18n = useI18nStore();

const toast = useToastStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando') });

const asientos = ref([]); 
const showModal = ref(false); 
const form = ref({});
const activos = ref(0); 
const pasivos = ref(0); 
const patrimonio = ref(0);

async function cargar() { try { const {data} = await api.get('/contabilidad'); asientos.value=data.asientos||[]; activos.value=data.activos||0; pasivos.value=data.pasivos||0; patrimonio.value=data.patrimonio||0; } catch(e){} }
async function guardar() {
  try {
    await execute(async () => { await api.post('/contabilidad', form.value); showModal.value=false; cargar(); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message||i18n.t('error')); }
  }
}
onMounted(cargar);
</script>

<style scoped>
.modal-responsive {
  max-width: min(90vw, 500px);
}

.form-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.text-xs {
  font-size: 12px;
}

@media (max-width: 1023px) {
  .grid-3 {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .grid-3 {
    grid-template-columns: 1fr;
  }

  .stat-card .stat-value {
    font-size: clamp(1rem, 3vw, 1.5rem);
  }

  .form-grid-2 {
    grid-template-columns: 1fr;
  }

  .modal-responsive {
    max-width: min(95vw, 500px);
  }

  .btn {
    min-height: 44px;
  }

  .stat-card {
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

  .stat-value {
    font-size: clamp(0.9rem, 4vw, 1.2rem);
  }
}
</style>
