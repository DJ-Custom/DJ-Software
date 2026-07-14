<template>
  <div class="chat-page-wrapper">
    <div class="chat-page-center">
      <div class="chat-page-icon">
        <i class="fas fa-comments"></i>
      </div>
      <h2>{{ i18n.t('chats_interno') }}</h2>
      <p>{{ i18n.t('chats_abrir_panel') }}</p>
      <button class="chat-page-btn" @click="chatDrawer.open()">
        <i class="fas fa-arrow-right"></i> {{ i18n.t('chats_abrir_chat') }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useChatDrawerStore } from '../stores/chatDrawer';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const chatDrawer = useChatDrawerStore();

onMounted(() => {
  chatDrawer.open();
});
</script>

<style scoped>
.chat-page-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 200px);
  padding: 20px;
}

.chat-page-center {
  text-align: center;
  max-width: 400px;
}

.chat-page-icon {
  width: 80px;
  height: 80px;
  border-radius: 24px;
  background: var(--gradient-main, linear-gradient(135deg, #0e3b58, #006bb3));
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  margin: 0 auto 20px;
  box-shadow: 0 8px 24px rgba(14,59,88,0.25);
}

.chat-page-center h2 {
  font-size: 22px;
  font-weight: 700;
  color: var(--text-primary, #1a2332);
  margin-bottom: 8px;
}

.chat-page-center p {
  color: var(--text-muted, #6b7280);
  font-size: 15px;
  margin-bottom: 24px;
  line-height: 1.5;
}

.chat-page-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border-radius: 12px;
  border: none;
  background: var(--gradient-main, linear-gradient(135deg, #0e3b58, #006bb3));
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  font-family: inherit;
}

.chat-page-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(14,59,88,0.3);
}

@media (max-width: 768px) {
  .chat-page-wrapper {
    min-height: calc(100vh - 150px);
    padding: 16px;
  }
  
  .chat-page-center {
    max-width: 100%;
  }
  
  .chat-page-icon {
    width: 60px;
    height: 60px;
    font-size: 24px;
  }
  
  .chat-page-center h2 {
    font-size: clamp(18px, 4vw, 22px);
  }
  
  .chat-page-center p {
    font-size: clamp(13px, 3vw, 15px);
  }
  
  .chat-page-btn {
    width: 100%;
    justify-content: center;
    padding: 14px 24px;
    min-height: 48px;
  }
}

@media (max-width: 480px) {
  .chat-page-wrapper {
    padding: 12px;
  }
  
  .chat-page-center h2 {
    font-size: 20px;
  }
  
  .chat-page-center p {
    font-size: 14px;
  }
}
</style>
