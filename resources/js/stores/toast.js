import { defineStore } from 'pinia';

export const useToastStore = defineStore('toast', {
    state: () => ({
        toasts: [],
    }),
    actions: {
        add(message, type = 'success', duration = 4000) {
            const id = Date.now();
            this.toasts.push({ id, message, type });
            setTimeout(() => this.remove(id), duration);
        },
        remove(id) {
            this.toasts = this.toasts.filter(t => t.id !== id);
        },
        success(msg) { this.add(msg, 'success'); },
        error(msg) { this.add(msg, 'danger', 6000); },
        warning(msg) { this.add(msg, 'warning'); },
        info(msg) { this.add(msg, 'info'); },
    },
});
