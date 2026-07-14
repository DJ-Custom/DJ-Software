<template>
  <div class="formula-editor">
    <div class="formula-editor-header">
      <h4>{{ i18n.t('planilla_editor_formula') }}</h4>
      <div class="formula-actions">
        <button class="btn btn-sm btn-ghost" @click="$emit('clear')" :title="i18n.t('limpiar')">
          <i class="fas fa-eraser"></i>
        </button>
      </div>
    </div>

    <div class="formula-editor-body">
      <div class="formula-input-area">
        <div class="formula-display" @click="focusInput" ref="formulaDisplay">
          <span v-for="(part, idx) in displayParts" :key="idx"
            :class="['formula-part', part.type]"
            :style="{ color: part.color }"
            @click="removePart(idx)"
            :title="part.type === 'variable' ? 'Click para quitar' : ''">
            {{ formatPartValue(part) }}
          </span>
          <span v-if="displayParts.length === 0" class="formula-placeholder">
            {{ i18n.t('planilla_arrastre_variables') }}
          </span>
        </div>
        <input ref="hiddenInput" v-model="rawFormula" @input="onInput" class="formula-hidden-input"
          :placeholder="i18n.t('planilla_escriba_formula')" />
      </div>

      <div class="formula-validation" v-if="validationState !== null">
        <span v-if="validationState" class="validation-success">
          <i class="fas fa-check-circle"></i> {{ i18n.t('planilla_formula_valida') }}
        </span>
        <div v-else class="validation-errors">
          <span v-for="(err, i) in validationErrors" :key="i" class="validation-error">
            <i class="fas fa-exclamation-circle"></i> {{ err }}
          </span>
        </div>
      </div>
    </div>

    <div class="variables-panel">
      <div class="variables-section" v-for="tipo in tiposVariables" :key="tipo.key">
        <h5 :class="['section-title', tipo.key]">
          <i :class="tipo.icon"></i> {{ tipo.label }}
        </h5>
        <div class="variables-grid">
          <div v-for="v in variablesPorTipo(tipo.key)" :key="v.clave"
            class="variable-chip"
            :class="tipo.key"
            draggable="true"
            @dragstart="onDragStart($event, v)"
            @click="insertVariable(v)">
            <span class="var-name">{{ v.nombre }}</span>
            <span class="var-key">{{ v.clave }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import api from '../../services/api';

const i18n = useI18nStore();

const props = defineProps({
  modelValue: { type: String, default: '' },
});

const emit = defineEmits(['update:modelValue', 'validate', 'clear']);

const rawFormula = ref(props.modelValue);
const variables = ref([]);
const hiddenInput = ref(null);
const formulaDisplay = ref(null);
const validationState = ref(null);
const validationErrors = ref([]);

const tiposVariables = [
  { key: 'ingreso', label: 'Ingresos', icon: 'fas fa-arrow-up' },
  { key: 'deduccion', label: 'Deducciones', icon: 'fas fa-arrow-down' },
  { key: 'operacion', label: 'Operaciones', icon: 'fas fa-calculator' },
  { key: 'custom', label: 'Personalizadas', icon: 'fas fa-cog' },
];

const displayParts = computed(() => {
  if (!rawFormula.value) return [];
  const parts = [];
  const regex = /([a-zA-Z_][a-zA-Z0-9_]*)|([+\-*/()])|(\d+\.?\d*)/g;
  let match;
  while ((match = regex.exec(rawFormula.value)) !== null) {
    if (match[1]) {
      const v = variables.value.find(x => x.clave === match[1]);
      parts.push({
        type: 'variable',
        value: match[1],
        color: getVarColor(v),
        name: v?.nombre || match[1],
      });
    } else if (match[2]) {
      parts.push({
        type: 'operator',
        value: match[2],
        color: ['+', '-'].includes(match[2]) ? '#ef4444' : '#8b5cf6',
      });
    } else if (match[3]) {
      parts.push({ type: 'number', value: match[3], color: '#3b82f6' });
    }
  }
  return parts;
});

function getVarColor(v) {
  if (!v) return '#6b7280';
  const colors = { ingreso: '#22c55e', deduccion: '#ef4444', operacion: '#3b82f6', custom: '#f59e0b' };
  return colors[v.tipo] || '#6b7280';
}

function formatPartValue(part) {
  if (part.type === 'variable') return part.name;
  return part.value;
}

function variablesPorTipo(tipo) {
  return variables.value.filter(v => v.tipo === tipo);
}

function insertVariable(v) {
  const cursorPos = hiddenInput.value?.selectionStart || rawFormula.value.length;
  const before = rawFormula.value.substring(0, cursorPos);
  const after = rawFormula.value.substring(cursorPos);
  const space = before.length > 0 && !before.endsWith(' ') && !before.endsWith('(') ? ' ' : '';
  rawFormula.value = before + space + v.clave + ' ' + after;
  emit('update:modelValue', rawFormula.value);
  validate();
}

function removePart(idx) {
  const parts = displayParts.value;
  if (parts[idx].type === 'variable') {
    rawFormula.value = rawFormula.value.replace(parts[idx].value, '').replace(/\s+/g, ' ').trim();
    emit('update:modelValue', rawFormula.value);
    validate();
  }
}

function onDragStart(event, v) {
  event.dataTransfer.setData('text/plain', v.clave);
  event.dataTransfer.effectAllowed = 'copy';
}

function onInput() {
  emit('update:modelValue', rawFormula.value);
  validate();
}

function focusInput() {
  hiddenInput.value?.focus();
}

async function validate() {
  if (!rawFormula.value.trim()) {
    validationState.value = null;
    return;
  }
  try {
    const res = await api.post('/planilla/validar-formula', { formula: rawFormula.value });
    validationState.value = res.data.valid;
    validationErrors.value = res.data.errors || [];
    emit('validate', { valid: res.data.valid, errors: res.data.errors, tokens: res.data.tokens });
  } catch (e) {
    validationState.value = false;
    validationErrors.value = ['Error al validar la fórmula.'];
  }
}

onMounted(async () => {
  try {
    const res = await api.get('/planilla/variables');
    variables.value = res.data.variables || [];
  } catch (e) { /* silent */ }
});

watch(() => props.modelValue, (val) => {
  if (val !== rawFormula.value) rawFormula.value = val;
});
</script>

<style scoped>
.formula-editor { border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
.formula-editor-header { display: flex; align-items: center; justify-content: space-between; padding: 8px 12px; background: var(--bg-secondary); border-bottom: 1px solid var(--border); }
.formula-editor-header h4 { margin: 0; font-size: clamp(13px, 1.5vw, 14px); }
.formula-editor-body { padding: 12px; }
.formula-input-area { position: relative; }
.formula-display { min-height: 48px; padding: 8px 12px; border: 1px solid var(--border); border-radius: 6px; cursor: text; display: flex; flex-wrap: wrap; align-items: center; gap: 4px; background: var(--bg-primary); font-family: 'Fira Code', monospace; font-size: clamp(12px, 1.5vw, 14px); }
.formula-hidden-input { position: absolute; opacity: 0; pointer-events: none; }
.formula-placeholder { color: var(--text-tertiary); font-style: italic; }
.formula-part { padding: 2px 4px; border-radius: 3px; cursor: default; transition: background 0.15s; }
.formula-part.variable { cursor: pointer; font-weight: 600; }
.formula-part.variable:hover { background: rgba(239,68,68,0.15); }
.formula-part.operator { font-weight: 700; }
.formula-part.number { font-family: 'Fira Code', monospace; }
.formula-validation { margin-top: 8px; font-size: 13px; }
.validation-success { color: #22c55e; }
.validation-error { color: #ef4444; display: block; }
.variables-panel { padding: 8px 12px; border-top: 1px solid var(--border); max-height: 200px; overflow-y: auto; }
.section-title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; margin: 8px 0 4px; display: flex; align-items: center; gap: 6px; }
.section-title.ingreso { color: #22c55e; }
.section-title.deduccion { color: #ef4444; }
.section-title.operacion { color: #3b82f6; }
.section-title.custom { color: #f59e0b; }
.variables-grid { display: flex; flex-wrap: wrap; gap: 4px; }
.variable-chip { padding: 3px 8px; border-radius: 4px; font-size: 12px; cursor: grab; user-select: none; transition: all 0.15s; border: 1px solid transparent; }
.variable-chip:active { cursor: grabbing; }
.variable-chip.ingreso { background: rgba(34,197,94,0.1); color: #22c55e; border-color: rgba(34,197,94,0.3); }
.variable-chip.deduccion { background: rgba(239,68,68,0.1); color: #ef4444; border-color: rgba(239,68,68,0.3); }
.variable-chip.operacion { background: rgba(59,130,246,0.1); color: #3b82f6; border-color: rgba(59,130,246,0.3); }
.variable-chip.custom { background: rgba(245,158,11,0.1); color: #f59e0b; border-color: rgba(245,158,11,0.3); }
.variable-chip:hover { transform: translateY(-1px); box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.var-key { opacity: 0.6; font-size: 10px; margin-left: 4px; }

@media (max-width: 1023px) {
  .variables-panel { max-height: 180px; }
}

@media (max-width: 768px) {
  .formula-editor-header { padding: 6px 10px; }
  .formula-editor-body { padding: 10px; }
  .formula-display { min-height: 44px; padding: 6px 10px; overflow-x: auto; flex-wrap: nowrap; }
  .formula-display::-webkit-scrollbar { height: 4px; }
  .variables-panel { padding: 6px 10px; max-height: 160px; }
  .variables-grid { gap: 6px; }
  .variable-chip { padding: 6px 10px; font-size: 13px; min-height: 36px; touch-action: manipulation; }
  .variable-chip:active { transform: scale(0.97); }
}

@media (max-width: 480px) {
  .formula-editor-header h4 { font-size: 13px; }
  .formula-display { font-size: 12px; min-height: 40px; }
  .section-title { font-size: 11px; }
  .variable-chip { padding: 8px 12px; min-height: 44px; }
  .var-key { display: none; }
}
</style>
