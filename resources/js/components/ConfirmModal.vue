<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="store.visible" class="confirm-overlay" @click.self="store.cancel">
        <Transition name="scale">
          <div v-if="store.visible" class="confirm-box">
            <div class="confirm-header">
              <i :class="iconClass" class="confirm-icon"></i>
              <h3 class="confirm-title">{{ store.title }}</h3>
            </div>
            <p class="confirm-body">{{ store.message }}</p>
            <div class="confirm-actions">
              <button class="btn btn-secondary" @click="store.cancel">{{ store.cancelText }}</button>
              <button :class="['btn', btnClass]" @click="store.confirm">{{ store.confirmText }}</button>
            </div>
          </div>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed } from 'vue';
import { useConfirmStore } from '../stores/confirm';

const store = useConfirmStore();

const iconClass = computed(() => {
  const map = { danger: 'fas fa-trash-alt', warning: 'fas fa-exclamation-triangle', info: 'fas fa-info-circle', success: 'fas fa-check-circle' };
  return map[store.type] || map.warning;
});

const btnClass = computed(() => {
  const map = { danger: 'btn-danger', warning: 'btn-warning', info: 'btn-info', success: 'btn-success' };
  return map[store.type] || 'btn-primary';
});
</script>

<style scoped>
.confirm-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(2px);
}
.confirm-box {
  background: var(--bg-card, #fff);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.25);
  padding: 24px;
  max-width: min(90vw, 400px);
  width: 90%;
  text-align: center;
}
.confirm-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}
.confirm-icon {
  font-size: 36px;
  color: var(--danger, #dc2626);
  opacity: 0.9;
}
.confirm-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary, #1f2937);
}
.confirm-body {
  margin: 0 0 20px;
  font-size: 14px;
  color: var(--text-secondary, #4b5563);
  line-height: 1.5;
}
.confirm-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}
.confirm-actions .btn {
  min-width: 90px;
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
.scale-enter-active, .scale-leave-active { transition: transform 0.2s ease, opacity 0.2s ease; }
.scale-enter-from, .scale-leave-to { transform: scale(0.92); opacity: 0; }
</style>
