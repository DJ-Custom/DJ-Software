<template>
  <div>
    <router-view />
    <ToastContainer />
    <ConfirmModal />
    <ChatDrawer />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, watch } from 'vue';
import { useAuthStore } from './stores/auth';
import { getToken } from './services/authToken';
import ToastContainer from './components/ToastContainer.vue';
import ConfirmModal from './components/ConfirmModal.vue';
import ChatDrawer from './components/ChatDrawer.vue';

const authStore = useAuthStore();

function destroySession() {
  authStore.forceLogout();
}

onMounted(() => {
  window.addEventListener('auth:logout', destroySession);

  window.addEventListener('beforeunload', () => {
    if (getToken()) {
      try {
        const data = new Blob([JSON.stringify({ token: getToken() })], { type: 'application/json' });
        navigator.sendBeacon('/api/auth/invalidate-token', data);
      } catch (e) {}
    }
    destroySession();
  });

  window.addEventListener('offline', () => {
    destroySession();
  });

  window.addEventListener('popstate', () => {
    if (!authStore.isAuthenticated) {
      window.location.href = '/login';
    }
  });

  history.pushState(null, '', location.href);
  window.addEventListener('popstate', () => {
    history.pushState(null, '', location.href);
    if (!authStore.isAuthenticated) {
      window.location.href = '/login';
    }
  });
});

onUnmounted(() => {
  window.removeEventListener('auth:logout', destroySession);
});

watch(() => authStore.theme, (theme) => {
  document.documentElement.dataset.theme = theme;
}, { immediate: true });
</script>
