import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useConfirmStore = defineStore('confirm', () => {
    const visible = ref(false);
    const title = ref('Confirmar');
    const message = ref('');
    const confirmText = ref('Sí');
    const cancelText = ref('Cancelar');
    const type = ref('warning');
    let resolveFn = null;

    function ask(opts = {}) {
        title.value = opts.title || 'Confirmar';
        message.value = opts.message || '';
        confirmText.value = opts.confirmText || 'Sí';
        cancelText.value = opts.cancelText || 'Cancelar';
        type.value = opts.type || 'warning';
        visible.value = true;
        return new Promise((resolve) => { resolveFn = resolve; });
    }

    function confirm() {
        visible.value = false;
        if (resolveFn) resolveFn(true);
        resolveFn = null;
    }

    function cancel() {
        visible.value = false;
        if (resolveFn) resolveFn(false);
        resolveFn = null;
    }

    return { visible, title, message, confirmText, cancelText, type, ask, confirm, cancel };
});
