import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useChatDrawerStore = defineStore('chatDrawer', () => {
  const isOpen = ref(false);
  const totalUnread = ref(0);
  const activeChatId = ref(null);

  function open(chatId = null) {
    isOpen.value = true;
    if (chatId) activeChatId.value = chatId;
  }

  function close() {
    isOpen.value = false;
  }

  function toggle() {
    isOpen.value = !isOpen.value;
  }

  function setActiveChat(chatId) {
    activeChatId.value = chatId;
  }

  function setUnread(count) {
    totalUnread.value = count;
  }

  const hasUnread = computed(() => totalUnread.value > 0);

  return {
    isOpen,
    totalUnread,
    activeChatId,
    hasUnread,
    open,
    close,
    toggle,
    setActiveChat,
    setUnread,
  };
});
