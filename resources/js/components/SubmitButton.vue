<template>
  <button
    type="button"
    :disabled="disabled || loading"
    :class="[
      'btn',
      variantClass,
      { 'opacity-60 cursor-not-allowed': disabled || loading }
    ]"
    @click="$emit('click', $event)"
  >
    <i v-if="loading" class="fas fa-spinner fa-spin" style="margin-right:6px;"></i>
    <slot v-if="!loading" />
    <span v-else>{{ loadingLabel }}</span>
  </button>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  loading: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
  variant: { type: String, default: 'primary' },
  loadingLabel: { type: String, default: 'Procesando...' },
});

defineEmits(['click']);

const variantClass = computed(() => {
  const map = {
    primary: 'btn-primary',
    secondary: 'btn-secondary',
    danger: 'btn-danger',
    success: 'btn-success',
    ghost: 'btn-ghost',
  };
  return map[props.variant] || 'btn-primary';
});
</script>

<style scoped>
@media (max-width: 480px) {
  button {
    min-height: 44px;
    font-size: clamp(13px, 3vw, 15px);
    padding: 10px 16px;
  }
}
</style>
