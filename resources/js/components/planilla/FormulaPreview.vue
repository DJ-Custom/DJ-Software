<template>
  <div class="formula-preview">
    <div class="preview-label">{{ i18n.t('planilla_vista_previa') }}</div>
    <div class="preview-formula">
      <span v-for="(part, idx) in parts" :key="idx"
        :class="['preview-part', part.type]"
        :style="{ color: part.color }">
        {{ formatValue(part) }}
      </span>
      <span v-if="parts.length === 0" class="preview-empty">
        {{ i18n.t('planilla_sin_formula') }}
      </span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useI18nStore } from '../../stores/i18n';

const i18n = useI18nStore();

const props = defineProps({
  formula: { type: String, default: '' },
  variables: { type: Array, default: () => [] },
});

const parts = computed(() => {
  if (!props.formula) return [];
  const result = [];
  const regex = /([a-zA-Z_][a-zA-Z0-9_]*)|([+\-*/()])|(\d+\.?\d*)/g;
  let match;
  while ((match = regex.exec(props.formula)) !== null) {
    if (match[1]) {
      const v = props.variables.find(x => x.clave === match[1]);
      result.push({ type: 'variable', value: match[1], color: getColor(v), name: v?.nombre || match[1] });
    } else if (match[2]) {
      result.push({ type: 'operator', value: match[2], color: ['+', '-'].includes(match[2]) ? '#ef4444' : '#8b5cf6' });
    } else if (match[3]) {
      result.push({ type: 'number', value: match[3], color: '#3b82f6' });
    }
  }
  return result;
});

function getColor(v) {
  if (!v) return '#6b7280';
  return { ingreso: '#22c55e', deduccion: '#ef4444', operacion: '#3b82f6', custom: '#f59e0b' }[v.tipo] || '#6b7280';
}

function formatValue(part) {
  return part.type === 'variable' ? part.name : ` ${part.value} `;
}
</script>

<style scoped>
.formula-preview { padding: 8px 12px; border: 1px solid var(--border); border-radius: 6px; background: var(--bg-secondary); margin-top: 8px; }
.preview-label { font-size: 11px; text-transform: uppercase; color: var(--text-tertiary); margin-bottom: 4px; letter-spacing: 0.5px; }
.preview-formula { font-family: 'Fira Code', monospace; font-size: clamp(12px, 1.5vw, 14px); display: flex; flex-wrap: wrap; align-items: center; overflow-x: auto; }
.preview-part.variable { font-weight: 600; }
.preview-part.operator { font-weight: 700; }
.preview-empty { color: var(--text-tertiary); font-style: italic; font-family: inherit; }

@media (max-width: 1023px) {
  .formula-preview { padding: 8px 10px; }
}

@media (max-width: 768px) {
  .formula-preview { padding: 6px 8px; }
  .preview-formula { white-space: nowrap; }
}

@media (max-width: 480px) {
  .preview-label { font-size: 10px; }
  .preview-formula { font-size: 12px; }
}
</style>
