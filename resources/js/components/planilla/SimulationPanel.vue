<template>
  <div class="simulation-panel">
    <div class="sim-header">
      <h4><i class="fas fa-play-circle"></i> {{ i18n.t('planilla_simulacion') }}</h4>
      <button class="btn btn-sm btn-primary" @click="ejecutarSimulacion" :disabled="loading || !formula">
        <i v-if="loading" class="fas fa-spinner fa-spin"></i>
        <i v-else class="fas fa-play"></i> {{ i18n.t('planilla_ejecutar') }}
      </button>
    </div>

    <div class="sim-variables" v-if="!resultado">
      <div class="sim-row" v-for="v in variablesInputs" :key="v.clave">
        <label>{{ v.nombre }}</label>
        <input type="number" v-model.number="v.valor" class="form-control form-control-sm" step="0.01" min="0" />
      </div>
    </div>

    <div class="sim-result" v-if="resultado">
      <div class="sim-summary">
        <div class="summary-card ingresos">
          <span class="summary-label">{{ i18n.t('planilla_total_ingresos') }}</span>
          <span class="summary-value">{{ fm(resultado.total_ingresos) }}</span>
        </div>
        <div class="summary-card deducciones">
          <span class="summary-label">{{ i18n.t('planilla_total_deducciones') }}</span>
          <span class="summary-value">{{ fm(resultado.total_deducciones) }}</span>
        </div>
        <div class="summary-card neto">
          <span class="summary-label">{{ i18n.t('planilla_salario_neto') }}</span>
          <span class="summary-value">{{ fm(resultado.resultado) }}</span>
        </div>
      </div>

      <div class="sim-steps">
        <h5>{{ i18n.t('planilla_pasos') }}</h5>
        <div v-for="step in resultado.pasos" :key="step.step" class="step-item">
          <span class="step-num">{{ step.step }}</span>
          <div class="step-content">
            <span class="step-desc">{{ step.description }}</span>
            <span v-if="step.operation" class="step-op">{{ step.operation }}</span>
            <span v-if="step.expression" class="step-expr">{{ step.expression }}</span>
            <span v-if="step.result !== undefined" class="step-result">{{ fm(step.result) }}</span>
          </div>
        </div>
      </div>

      <div class="sim-variables-used">
        <h5>{{ i18n.t('planilla_variables_utilizadas') }}</h5>
        <div v-for="uv in resultado.variables_utilizadas" :key="uv.clave" class="used-var">
          <span class="used-name">{{ uv.nombre }}</span>
          <span class="used-value">{{ fm(uv.valor) }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import { useCurrency } from '../../composables/useCurrency';
import api from '../../services/api';

const i18n = useI18nStore();
const { fm } = useCurrency();

const props = defineProps({
  formula: { type: String, default: '' },
  empleado: { type: Object, default: null },
});

const loading = ref(false);
const resultado = ref(null);

const variablesInputs = ref([
  { clave: 'salario_base', nombre: 'Salario Base', valor: 0 },
  { clave: 'horas_extra', nombre: 'Horas Extra', valor: 0 },
  { clave: 'horas_dobles', nombre: 'Horas Dobles', valor: 0 },
  { clave: 'horas_nocturnas', nombre: 'Horas Nocturnas', valor: 0 },
  { clave: 'bonificaciones', nombre: 'Bonificaciones', valor: 0 },
  { clave: 'comisiones', nombre: 'Comisiones', valor: 0 },
  { clave: 'incentivos', nombre: 'Incentivos', valor: 0 },
  { clave: 'rebajos', nombre: 'Rebajos', valor: 0 },
  { clave: 'embargos', nombre: 'Embargos', valor: 0 },
  { clave: 'vacaciones', nombre: 'Vacaciones', valor: 0 },
  { clave: 'aguinaldo', nombre: 'Aguinaldo', valor: 0 },
  { clave: 'otros_ingresos', nombre: 'Otros Ingresos', valor: 0 },
  { clave: 'otras_deducciones', nombre: 'Otras Deducciones', valor: 0 },
]);

watch(() => props.empleado, (e) => {
  if (e) {
    variablesInputs.value.find(v => v.clave === 'salario_base').valor = parseFloat(e.salario_base) || 0;
  }
}, { immediate: true });

async function ejecutarSimulacion() {
  loading.value = true;
  resultado.value = null;
  try {
    const vars = {};
    variablesInputs.value.forEach(v => { vars[v.clave] = v.valor; });
    const res = await api.post('/planilla/simular', { formula: props.formula, variables: vars });
    resultado.value = res.data.simulacion;
  } catch (e) {
    resultado.value = null;
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.simulation-panel { border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
.sim-header { display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: var(--bg-secondary); border-bottom: 1px solid var(--border); }
.sim-header h4 { margin: 0; font-size: clamp(13px, 1.5vw, 14px); display: flex; align-items: center; gap: 6px; }
.sim-variables { padding: 12px; display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 8px; }
.sim-row label { font-size: 12px; color: var(--text-secondary); display: block; margin-bottom: 2px; }
.sim-result { padding: 12px; overflow-x: auto; }
.sim-summary { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 16px; }
.summary-card { padding: 12px; border-radius: 8px; text-align: center; }
.summary-card.ingresos { background: rgba(34,197,94,0.1); }
.summary-card.deducciones { background: rgba(239,68,68,0.1); }
.summary-card.neto { background: rgba(59,130,246,0.1); }
.summary-label { display: block; font-size: 11px; text-transform: uppercase; color: var(--text-tertiary); margin-bottom: 4px; }
.summary-value { font-size: clamp(16px, 2vw, 20px); font-weight: 700; }
.summary-card.ingresos .summary-value { color: #22c55e; }
.summary-card.deducciones .summary-value { color: #ef4444; }
.summary-card.neto .summary-value { color: #3b82f6; }
.sim-steps h5, .sim-variables-used h5 { font-size: 13px; margin: 12px 0 6px; color: var(--text-secondary); }
.step-item { display: flex; align-items: flex-start; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--border); font-size: 13px; }
.step-num { background: var(--bg-tertiary); color: var(--text-secondary); width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 11px; flex-shrink: 0; }
.step-content { display: flex; flex-direction: column; gap: 2px; }
.step-desc { color: var(--text-secondary); }
.step-op { color: #22c55e; font-weight: 500; font-family: 'Fira Code', monospace; }
.step-expr { color: #3b82f6; font-family: 'Fira Code', monospace; word-break: break-all; }
.step-result { color: #8b5cf6; font-weight: 700; font-size: 15px; }
.used-var { display: flex; justify-content: space-between; padding: 3px 0; font-size: 13px; }
.used-name { color: var(--text-secondary); }
.used-value { font-weight: 600; }

@media (max-width: 1023px) {
  .sim-variables { grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); }
  .sim-summary { gap: 8px; }
  .summary-card { padding: 10px; }
}

@media (max-width: 768px) {
  .sim-header { flex-wrap: wrap; gap: 8px; }
  .sim-header .btn { min-height: 44px; }
  .sim-variables { grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); padding: 10px; gap: 6px; }
  .sim-summary { grid-template-columns: 1fr; }
  .summary-card { padding: 12px; }
  .step-item { font-size: 12px; }
  .step-result { font-size: 14px; }
  .used-var { font-size: 12px; }
}

@media (max-width: 480px) {
  .sim-header h4 { font-size: 13px; }
  .sim-variables { grid-template-columns: 1fr; }
  .sim-row input { min-height: 44px; }
  .summary-value { font-size: 16px; }
  .sim-steps h5, .sim-variables-used h5 { font-size: 12px; }
  .step-item { padding: 8px 0; }
}
</style>
