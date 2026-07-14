<template>
  <div class="payroll-processing">
    <div class="pp-header">
      <h4><i class="fas fa-cogs"></i> {{ i18n.t('planilla_procesar_nomina') }}</h4>
    </div>

    <div class="pp-form">
      <div class="pp-form-grid">
        <div class="form-group">
          <label>{{ i18n.t('planilla_periodo') }} *</label>
          <input v-model="form.periodo" type="date" class="form-control" />
        </div>
        <div class="form-group">
          <label>{{ i18n.t('planilla_fecha_pago') }}</label>
          <input v-model="form.fecha_pago" type="date" class="form-control" />
        </div>
      </div>

      <div class="form-group">
        <label>{{ i18n.t('planilla_empleados') }}</label>
        <div class="emp-select-list">
          <label class="emp-select-all">
            <input type="checkbox" :checked="allSelected" @change="toggleAll" />
            {{ i18n.t('planilla_todos_activos') }} ({{ empleados.length }})
          </label>
          <div class="emp-select-items">
            <label v-for="e in empleados" :key="e.id" class="emp-select-item">
              <input type="checkbox" :value="e.id" v-model="form.empleado_ids" />
              <span>{{ e.nombre }}</span>
              <span class="emp-salary">{{ fm(e.salario_base) }}</span>
            </label>
          </div>
        </div>
      </div>

      <div class="pp-actions">
        <button class="btn btn-primary btn-lg" @click="procesar" :disabled="processing || !form.periodo">
          <i v-if="processing" class="fas fa-spinner fa-spin"></i>
          <i v-else class="fas fa-cogs"></i>
          {{ processing ? i18n.t('planilla_procesando') : i18n.t('planilla_procesar_nomina') }}
        </button>
      </div>
    </div>

    <div v-if="resultado" class="pp-result" :class="resultado.success ? 'success' : 'error'">
      <div v-if="resultado.success" class="result-success">
        <i class="fas fa-check-circle"></i>
        <span>{{ i18n.t('planilla_nomina_procesada') }}: {{ resultado.pagos_creados }}/{{ resultado.total_empleados }}</span>
      </div>
      <div v-else class="result-error">
        <i class="fas fa-exclamation-circle"></i>
        <span>{{ resultado.message }}</span>
      </div>
      <div v-if="resultado.errores?.length" class="result-errors">
        <div v-for="(err, i) in resultado.errores" :key="i" class="error-item">{{ err }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import { useToastStore } from '../../stores/toast';
import { useCurrency } from '../../composables/useCurrency';
import api from '../../services/api';

const i18n = useI18nStore();
const toast = useToastStore();
const { fm } = useCurrency();

const empleados = ref([]);
const processing = ref(false);
const resultado = ref(null);

const form = ref({
  periodo: new Date().toISOString().split('T')[0],
  fecha_pago: new Date().toISOString().split('T')[0],
  empleado_ids: [],
});

const allSelected = computed(() =>
  empleados.value.length > 0 && form.value.empleado_ids.length === empleados.value.length
);

function toggleAll(e) {
  form.value.empleado_ids = e.target.checked ? empleados.value.map(x => x.id) : [];
}

async function loadEmpleados() {
  try {
    const res = await api.get('/planilla/empleados?activo=1');
    empleados.value = res.data.empleados || [];
  } catch (e) { /* silent */ }
}

async function procesar() {
  if (!form.value.periodo) return;
  processing.value = true;
  resultado.value = null;
  try {
    const payload = { ...form.value };
    if (payload.empleado_ids.length === 0) delete payload.empleado_ids;
    const res = await api.post('/planilla/procesar', payload);
    resultado.value = res.data;
    toast.success(i18n.t('planilla_nomina_procesada'));
  } catch (e) {
    resultado.value = { success: false, message: e.response?.data?.message || i18n.t('error') };
    toast.error(i18n.t('error'));
  } finally {
    processing.value = false;
  }
}

onMounted(loadEmpleados);
</script>

<style scoped>
.payroll-processing { }
.pp-header { margin-bottom: 12px; }
.pp-header h4 { margin: 0; display: flex; align-items: center; gap: 6px; }
.pp-form { border: 1px solid var(--border); border-radius: 8px; padding: 16px; background: var(--bg-secondary); }
.pp-form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; }
.form-group { margin-bottom: 12px; }
.form-group label { display: block; font-size: 12px; font-weight: 600; margin-bottom: 4px; }
.emp-select-list { border: 1px solid var(--border); border-radius: 6px; overflow: hidden; }
.emp-select-all { display: flex; align-items: center; gap: 8px; padding: 8px 12px; background: var(--bg-tertiary); font-weight: 600; font-size: 13px; cursor: pointer; }
.emp-select-items { max-height: 200px; overflow-y: auto; }
.emp-select-item { display: flex; align-items: center; gap: 8px; padding: 6px 12px; border-bottom: 1px solid var(--border); font-size: 13px; cursor: pointer; }
.emp-salary { margin-left: auto; color: var(--text-tertiary); font-size: 12px; }
.pp-actions { text-align: center; margin-top: 12px; }
.pp-actions .btn { min-height: 44px; }
.pp-result { margin-top: 12px; padding: 12px; border-radius: 8px; }
.pp-result.success { background: rgba(34,197,94,0.1); border: 1px solid rgba(34,197,94,0.3); }
.pp-result.error { background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3); }
.result-success, .result-error { display: flex; align-items: center; gap: 8px; font-weight: 600; }
.result-success { color: #22c55e; }
.result-error { color: #ef4444; }
.result-errors { margin-top: 8px; }
.error-item { font-size: 12px; color: var(--text-secondary); padding: 2px 0; }

@media (max-width: 1023px) {
  .pp-form { padding: 14px; }
  .pp-form-grid { gap: 10px; }
}

@media (max-width: 768px) {
  .pp-form { padding: 12px; }
  .pp-form-grid { grid-template-columns: 1fr; }
  .emp-select-all { padding: 8px 10px; font-size: 12px; }
  .emp-select-item { padding: 6px 10px; font-size: 12px; }
  .pp-actions .btn { width: 100%; min-height: 44px; }
}

@media (max-width: 480px) {
  .pp-header h4 { font-size: clamp(14px, 2vw, 16px); }
  .pp-form { padding: 10px; }
  .emp-select-items { max-height: 160px; }
  .emp-select-item { padding: 8px 10px; min-height: 44px; }
}
</style>
