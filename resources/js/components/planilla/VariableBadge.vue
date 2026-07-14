<template>
  <span :class="['var-badge', tipo]" :title="`${nombre} (${clave})`">
    <i :class="icon"></i> {{ nombre }}
  </span>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  clave: { type: String, required: true },
  nombre: { type: String, default: '' },
  tipo: { type: String, default: 'custom' },
});

const icon = computed(() => {
  const icons = {
    ingreso: 'fas fa-arrow-up',
    deduccion: 'fas fa-arrow-down',
    operacion: 'fas fa-calculator',
    custom: 'fas fa-cog',
  };
  return icons[props.tipo] || icons.custom;
});
</script>

<style scoped>
.var-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: clamp(10px, 1.5vw, 12px);
  font-weight: 500;
  word-break: break-word;
}
.var-badge.ingreso { background: rgba(34,197,94,0.1); color: #22c55e; }
.var-badge.deduccion { background: rgba(239,68,68,0.1); color: #ef4444; }
.var-badge.operacion { background: rgba(59,130,246,0.1); color: #3b82f6; }
.var-badge.custom { background: rgba(245,158,11,0.1); color: #f59e0b; }

@media (max-width: 768px) {
  .var-badge { padding: 3px 6px; min-height: 32px; }
}

@media (max-width: 480px) {
  .var-badge { padding: 4px 8px; font-size: 11px; min-height: 36px; }
}
</style>
