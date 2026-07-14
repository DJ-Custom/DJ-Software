<template>
  <div class="emp-config">
    <div class="config-header">
      <div class="emp-info">
        <h3>{{ empleado?.nombre }}</h3>
        <span class="emp-meta">{{ empleado?.cedula }} · {{ empleado?.puesto }}</span>
      </div>
      <div class="config-actions">
        <button class="btn btn-sm btn-ghost" @click="$emit('back')">
          <i class="fas fa-arrow-left"></i> {{ i18n.t('volver') }}
        </button>
      </div>
    </div>

    <div class="config-tabs">
      <button :class="['btn btn-sm', tab === 'general' ? 'btn-primary' : 'btn-ghost']" @click="tab = 'general'">
        <i class="fas fa-cog"></i> {{ i18n.t('planilla_general') }}
      </button>
      <button :class="['btn btn-sm', tab === 'formula' ? 'btn-primary' : 'btn-ghost']" @click="tab = 'formula'">
        <i class="fas fa-calculator"></i> {{ i18n.t('planilla_formula') }}
      </button>
      <button :class="['btn btn-sm', tab === 'simulacion' ? 'btn-primary' : 'btn-ghost']" @click="tab = 'simulacion'">
        <i class="fas fa-play-circle"></i> {{ i18n.t('planilla_simulacion') }}
      </button>
      <button :class="['btn btn-sm', tab === 'historial' ? 'btn-primary' : 'btn-ghost']" @click="tab = 'historial'">
        <i class="fas fa-history"></i> {{ i18n.t('planilla_historial') }}
      </button>
    </div>

    <div v-if="tab === 'general'" class="config-section">
      <div class="config-grid">
        <div class="form-group">
          <label>{{ i18n.t('planilla_tipo_salario') }}</label>
          <select v-model="config.tipo_salario" class="form-control">
            <option value="fijo">Fijo Mensual</option>
            <option value="por_hora">Por Hora</option>
            <option value="por_comision">Por Comisión</option>
            <option value="mixto">Mixto</option>
          </select>
        </div>
        <div class="form-group">
          <label>{{ i18n.t('planilla_jornada_laboral') }}</label>
          <input v-model.number="config.jornada_laboral" type="number" class="form-control" min="1" max="24" step="0.5" />
        </div>
        <div class="form-group">
          <label>{{ i18n.t('planilla_metodo_pago') }}</label>
          <select v-model="config.metodo_pago" class="form-control">
            <option value="diario">Diario</option>
            <option value="semanal">Semanal</option>
            <option value="quincenal">Quincenal</option>
            <option value="mensual">Mensual</option>
          </select>
        </div>
        <div class="form-group" v-if="config.tipo_salario === 'por_hora' || config.tipo_salario === 'mixto'">
          <label>{{ i18n.t('planilla_pago_hora') }}</label>
          <input v-model.number="config.pago_por_hora" type="number" class="form-control" min="0" step="0.01" />
        </div>
      </div>

      <div class="form-group template-group">
        <label>{{ i18n.t('planilla_plantilla_aplicada') }}</label>
        <select v-model="config.plantilla_id" class="form-control" @change="aplicarPlantilla">
          <option :value="null">— Sin plantilla —</option>
          <option v-for="p in plantillas" :key="p.id" :value="p.id">{{ p.nombre }}</option>
        </select>
      </div>
    </div>

    <div v-if="tab === 'formula'" class="config-section">
      <FormulaEditor v-model="config.formula_texto" @validate="onFormulaValidate" />
      <FormulaPreview :formula="config.formula_texto" :variables="variables" />
      <div class="formula-actions">
        <button class="btn btn-primary" @click="guardarConfig" :disabled="saving">
          <i v-if="saving" class="fas fa-spinner fa-spin"></i>
          <i v-else class="fas fa-save"></i> {{ i18n.t('guardar') }}
        </button>
      </div>
    </div>

    <div v-if="tab === 'simulacion'" class="config-section">
      <SimulationPanel :formula="config.formula_texto" :empleado="empleado" />
    </div>

    <div v-if="tab === 'historial'" class="config-section">
      <PayrollHistory :empleado-id="empleado?.id" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import { useToastStore } from '../../stores/toast';
import api from '../../services/api';
import FormulaEditor from './FormulaEditor.vue';
import FormulaPreview from './FormulaPreview.vue';
import SimulationPanel from './SimulationPanel.vue';
import PayrollHistory from './PayrollHistory.vue';

const i18n = useI18nStore();
const toast = useToastStore();

const props = defineProps({
  empleado: { type: Object, required: true },
});

const emit = defineEmits(['back', 'saved']);

const tab = ref('general');
const config = ref({});
const plantillas = ref([]);
const variables = ref([]);
const saving = ref(false);
const formulaValid = ref(false);

async function loadConfig() {
  try {
    const [configRes, plantRes, varRes] = await Promise.all([
      api.get(`/planilla/configuracion/${props.empleado.id}`),
      api.get('/planilla/plantillas'),
      api.get('/planilla/variables'),
    ]);
    config.value = configRes.data.configuracion || {};
    plantillas.value = (plantRes.data.plantillas || []).filter(p => p.activo);
    variables.value = varRes.data.variables || [];
  } catch (e) {
    toast.error(i18n.t('error'));
  }
}

async function guardarConfig() {
  saving.value = true;
  try {
    await api.put(`/planilla/configuracion/${props.empleado.id}`, config.value);
    toast.success(i18n.t('guardado'));
    emit('saved');
  } catch (e) {
    toast.error(e.response?.data?.message || i18n.t('error'));
  } finally {
    saving.value = false;
  }
}

function aplicarPlantilla() {
  const p = plantillas.value.find(x => x.id === config.value.plantilla_id);
  if (p) {
    config.value.formula_texto = p.formula_texto;
    config.value.formula_tokens = p.formula_tokens;
    config.value.configuracion_json = p.configuracion_base;
  }
}

function onFormulaValidate(result) {
  formulaValid.value = result.valid;
}

onMounted(loadConfig);
</script>

<style scoped>
.emp-config { padding: 0; }
.config-header { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--border); margin-bottom: 12px; }
.emp-info h3 { margin: 0; font-size: clamp(16px, 2vw, 18px); }
.emp-meta { font-size: 13px; color: var(--text-secondary); }
.config-tabs { display: flex; gap: 4px; margin-bottom: 16px; flex-wrap: wrap; }
.config-section { padding: 0; }
.config-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; }
.template-group { margin-top: 12px; }
.formula-actions { margin-top: 12px; text-align: right; }
.form-group { margin-bottom: 10px; }
.form-group label { display: block; font-size: 12px; font-weight: 600; color: var(--text-secondary); margin-bottom: 3px; }

@media (max-width: 1023px) {
  .config-grid { grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); }
}

@media (max-width: 768px) {
  .config-header { flex-direction: column; align-items: flex-start; gap: 8px; }
  .config-tabs { overflow-x: auto; flex-wrap: nowrap; padding-bottom: 4px; }
  .config-tabs .btn { white-space: nowrap; min-height: 44px; }
  .config-grid { grid-template-columns: 1fr; }
  .formula-actions .btn { min-height: 44px; width: 100%; }
}

@media (max-width: 480px) {
  .emp-info h3 { font-size: 16px; }
  .config-tabs .btn { font-size: 12px; padding: 6px 10px; min-height: 44px; }
}
</style>
