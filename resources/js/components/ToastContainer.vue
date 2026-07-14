<template>
  <div class="toast-container">
    <div v-for="toast in toasts" :key="toast.id" :class="['toast', `toast-${toast.type}`]">
      <i :class="iconClass(toast.type)" class="toast-icon"></i>
      <div class="toast-content">
        <div class="toast-message">{{ toast.message }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useToastStore } from '../stores/toast';

const store = useToastStore();
const toasts = computed(() => store.toasts);

function iconClass(type) {
    const map = { success: 'fas fa-check-circle', danger: 'fas fa-exclamation-circle', warning: 'fas fa-exclamation-triangle', info: 'fas fa-info-circle' };
    return map[type] || map.info;
}
</script>
