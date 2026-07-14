<template>
  <div>
    <div class="grid-3 mb-lg">
      <div class="stat-card"><div class="stat-icon" style="background:var(--success-bg);color:var(--success);"><i class="fas fa-arrow-up"></i></div><div class="stat-value" style="color:var(--success);">{{ fm(resumen.ingresos) }}</div><div class="stat-label">{{ i18n.t('ingresos') }}</div></div>
      <div class="stat-card"><div class="stat-icon" style="background:var(--danger-bg);color:var(--danger);"><i class="fas fa-arrow-down"></i></div><div class="stat-value" style="color:var(--danger);">{{ fm(resumen.egresos) }}</div><div class="stat-label">{{ i18n.t('reportes_egresos') }}</div></div>
      <div class="stat-card"><div class="stat-icon" style="background:var(--info-bg);color:var(--info);"><i class="fas fa-balance-scale"></i></div><div class="stat-value">{{ fm(resumen.saldo) }}</div><div class="stat-label">{{ i18n.t('notas_saldo') }}</div></div>
    </div>
    <div class="flex items-center justify-between mb-lg flex-wrap gap-sm">
      <div class="flex items-center gap-sm flex-wrap filter-row">
        <select v-model="filtro.tipo" class="form-control filter-input" @change="cargar"><option value="">{{ i18n.t('todos') }}</option><option value="ingreso">{{ i18n.t('ingresos') }}</option><option value="egreso">{{ i18n.t('reportes_egresos') }}</option></select>
        <input v-model="filtro.desde" type="date" class="form-control filter-input" @change="cargar">
        <input v-model="filtro.hasta" type="date" class="form-control filter-input" @change="cargar">
      </div>
      <button class="btn btn-primary" @click="editingId=null;showModal=true;form={tipo:'ingreso',monto:0,fecha:new Date().toISOString().split('T')[0],categoria:'',descripcion:'',referencia:'',metodo_pago:'efectivo'}"><i class="fas fa-plus"></i> {{ i18n.t('tesoreria_nuevo_movimiento') }}</button>
    </div>
    <div class="card"><div class="card-body" style="padding:0;">
      <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('tesoreria_fecha') }}</th><th>{{ i18n.t('tesoreria_tipo') }}</th><th>{{ i18n.t('tesoreria_categoria') }}</th><th>{{ i18n.t('tesoreria_descripcion') }}</th><th>{{ i18n.t('metodo') }}</th><th>{{ i18n.t('tesoreria_referencia') }}</th><th>{{ i18n.t('tesoreria_monto') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
          <tbody><tr v-for="m in movimientos" :key="m.id">
            <td>{{ m.fecha }}</td>
            <td><span :class="['badge', m.tipo==='ingreso'?'badge-success':'badge-danger']">{{ m.tipo }}</span></td>
            <td>{{ m.categoria||'-' }}</td><td>{{ m.descripcion||'-' }}</td><td>{{ m.metodo_pago||'-' }}</td><td>{{ m.referencia||'-' }}</td>
            <td :style="{fontWeight:'700',color:m.tipo==='ingreso'?'var(--success)':'#c62828'}">{{ m.tipo==='ingreso'?'+':'-' }}{{ fm(m.monto) }}</td>
            <td>
              <button class="btn btn-sm btn-ghost" @click="editarMov(m)" :title="i18n.t('editar')"><i class="fas fa-edit"></i></button>
              <button class="btn btn-sm btn-ghost btn-danger-icon" @click="eliminarMov(m)" :title="i18n.t('eliminar')"><i class="fas fa-trash"></i></button>
            </td>
          </tr></tbody>
        </table>
      </div>
    </div></div>

    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive"><div class="modal-header"><h3 class="modal-title">{{ editingId ? i18n.t('editar') : i18n.t('tesoreria_nuevo_movimiento') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('tesoreria_tipo') }} *</label><select v-model="form.tipo" class="form-control"><option value="ingreso">{{ i18n.t('tesoreria_tipo_ingreso') }}</option><option value="egreso">{{ i18n.t('tesoreria_tipo_egreso') }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('tesoreria_monto') }} *</label><input v-model.number="form.monto" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('tesoreria_fecha') }} *</label><input v-model="form.fecha" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('metodo') }}</label><select v-model="form.metodo_pago" class="form-control"><option value="efectivo">{{ i18n.t('efectivo') }}</option><option value="transferencia">{{ i18n.t('tesoreria_tipo_transferencia') }}</option><option value="cheque">Cheque</option><option value="tarjeta">{{ i18n.t('tarjeta') }}</option></select></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('tesoreria_categoria') }}</label><input v-model="form.categoria" class="form-control" placeholder="Ventas, Alquiler, Servicios..."></div>
          <div class="form-group"><label>{{ i18n.t('tesoreria_descripcion') }}</label><input v-model="form.descripcion" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('tesoreria_referencia') }}</label><input v-model="form.referencia" class="form-control"></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('procesando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('guardar') }}</span></button></div>
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

const { fm } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('procesando') });

const movimientos = ref([]); const resumen = ref({ingresos:0,egresos:0,saldo:0}); const showModal = ref(false);
const filtro = ref({tipo:'',desde:'',hasta:''}); const form = ref({});
const editingId = ref(null);

async function cargar() { try { const {data} = await api.get('/tesoreria', {params:filtro.value}); movimientos.value=data.movimientos||[]; resumen.value=data.resumen||{}; } catch(e){} }

function editarMov(m) {
    editingId.value = m.id;
    form.value = {
        tipo: m.tipo, monto: m.monto, fecha: m.fecha, categoria: m.categoria || '',
        descripcion: m.descripcion || '', referencia: m.referencia || '', metodo_pago: m.metodo_pago || 'efectivo'
    };
    showModal.value = true;
}

async function eliminarMov(m) {
    if (!confirm('¿Eliminar este movimiento?')) return;
    try {
        await api.delete(`/tesoreria/${m.id}`);
        toast.success(i18n.t('eliminado'));
        cargar();
    } catch (e) { toast.error(e.response?.data?.error || i18n.t('error')); }
}

async function guardar() {
  try {
    await execute(async () => {
        if (editingId.value) {
            await api.put(`/tesoreria/${editingId.value}`, form.value);
        } else {
            await api.post('/tesoreria', form.value);
        }
        editingId.value = null;
        showModal.value = false;
        cargar();
    });
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

.filter-row {
  flex-wrap: wrap;
}

.filter-input {
  width: auto;
  min-width: 120px;
  flex: 1 1 auto;
}

.form-grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
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

  .filter-input {
    min-width: 100%;
    width: 100%;
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
