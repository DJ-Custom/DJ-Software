<template>
  <div class="payroll-history">
    <div class="ph-header">
      <h4><i class="fas fa-history"></i> {{ i18n.t('planilla_historial') }}</h4>
    </div>

    <div v-if="loading" class="loading-state">
      <i class="fas fa-spinner fa-spin"></i> {{ i18n.t('cargando') }}
    </div>

    <div v-else-if="historial.length === 0" class="empty-state">
      <i class="fas fa-history"></i>
      <p>{{ i18n.t('planilla_sin_historial') }}</p>
    </div>

    <div v-else class="ph-list">
      <div v-for="h in historial" :key="h.id" class="history-item">
        <div class="hi-header">
          <span :class="['hi-type', h.tipo_cambio]">{{ formatTipo(h.tipo_cambio) }}</span>
          <span class="hi-date">{{ formatDate(h.created_at) }}</span>
        </div>
        <div class="hi-user" v-if="h.usuario">
          <i class="fas fa-user"></i> {{ h.usuario.nombre }}
        </div>

        <div class="hi-diff" v-if="h.formula_anterior || h.formula_nueva">
          <div v-if="h.formula_anterior" class="diff-old">
            <span class="diff-label">{{ i18n.t('planilla_anterior') }}:</span>
            <code>{{ h.formula_anterior }}</code>
          </div>
          <div v-if="h.formula_nueva" class="diff-new">
            <span class="diff-label">{{ i18n.t('planilla_nueva') }}:</span>
            <code>{{ h.formula_nueva }}</code>
          </div>
        </div>

        <div class="hi-motivo" v-if="h.motivo">
          <i class="fas fa-comment"></i> {{ h.motivo }}
        </div>

        <div class="hi-actions" v-if="h.formula_anterior">
          <button class="btn btn-sm btn-ghost" @click="$emit('restore', h)">
            <i class="fas fa-undo"></i> {{ i18n.t('planilla_restaurar') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import api from '../../services/api';

const i18n = useI18nStore();

const props = defineProps({
  empleadoId: { type: [Number, String], required: true },
});

defineEmits(['restore']);

const historial = ref([]);
const loading = ref(false);

async function loadHistorial() {
  if (!props.empleadoId) return;
  loading.value = true;
  try {
    const res = await api.get(`/planilla/historial/${props.empleadoId}`);
    historial.value = res.data.historial || [];
  } catch (e) {
    historial.value = [];
  } finally {
    loading.value = false;
  }
}

function formatTipo(tipo) {
  const labels = {
    formula: 'Fórmula',
    configuracion: 'Configuración',
    plantilla: 'Plantilla',
  };
  return labels[tipo] || tipo;
}

function formatDate(d) {
  if (!d) return '';
  return new Date(d).toLocaleString('es-CR');
}

onMounted(loadHistorial);
watch(() => props.empleadoId, loadHistorial);
</script>

<style scoped>
.payroll-history { }
.ph-header { margin-bottom: 10px; }
.ph-header h4 { margin: 0; display: flex; align-items: center; gap: 6px; }
.loading-state, .empty-state { text-align: center; padding: 20px; color: var(--text-tertiary); }
.empty-state i { font-size: 24px; margin-bottom: 6px; display: block; }
.history-item { border: 1px solid var(--border); border-radius: 6px; padding: 10px 12px; margin-bottom: 8px; background: var(--bg-primary); }
.hi-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.hi-type { padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
.hi-type.formula { background: rgba(59,130,246,0.1); color: #3b82f6; }
.hi-type.configuracion { background: rgba(139,92,246,0.1); color: #8b5cf6; }
.hi-type.plantilla { background: rgba(34,197,94,0.1); color: #22c55e; }
.hi-date { font-size: 12px; color: var(--text-tertiary); }
.hi-user { font-size: 12px; color: var(--text-secondary); margin-bottom: 6px; }
.hi-diff { margin: 6px 0; overflow-x: auto; }
.diff-old, .diff-new { padding: 4px 8px; border-radius: 4px; margin-bottom: 4px; font-size: 12px; }
.diff-old { background: rgba(239,68,68,0.05); border-left: 3px solid #ef4444; }
.diff-new { background: rgba(34,197,94,0.05); border-left: 3px solid #22c55e; }
.diff-label { font-weight: 600; margin-right: 4px; font-size: 11px; text-transform: uppercase; }
.diff-old code, .diff-new code { font-family: 'Fira Code', monospace; word-break: break-all; }
.hi-motivo { font-size: 12px; color: var(--text-secondary); font-style: italic; margin-top: 4px; }
.hi-actions { margin-top: 6px; }
.hi-actions .btn { min-height: 44px; }

@media (max-width: 1023px) {
  .history-item { padding: 10px; }
}

@media (max-width: 768px) {
  .hi-header { flex-direction: column; align-items: flex-start; gap: 4px; }
  .hi-type { align-self: flex-start; }
  .hi-date { font-size: 11px; }
  .diff-old code, .diff-new code { font-size: 11px; }
  .hi-actions { text-align: center; }
  .hi-actions .btn { width: 100%; }
}

@media (max-width: 480px) {
  .ph-header h4 { font-size: clamp(14px, 2vw, 16px); }
  .history-item { padding: 8px; }
  .hi-type { font-size: 10px; padding: 2px 6px; }
  .diff-old, .diff-new { padding: 3px 6px; font-size: 11px; }
}
</style>
