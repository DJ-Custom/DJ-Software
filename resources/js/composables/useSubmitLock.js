import { ref } from 'vue';

/**
 * Composable global para prevenir envíos duplicados (multi-click/spam).
 * @param {object} options
 * @param {string} options.loadingText - Texto mostrado mientras carga
 * @param {number} options.minDuration - Duración mínima del bloqueo en ms (evita parpadeos)
 * @returns {{ isSubmitting: Ref<boolean>, submitLocked: Ref<boolean>, submitText: Ref<string>, execute: Function }}
 */
export function useSubmitLock(options = {}) {
    const { loadingText = 'Procesando...', minDuration = 400 } = options;

    const isSubmitting = ref(false);
    const submitLocked = ref(false);
    const submitText = ref('');

    /**
     * Ejecuta una función async bloqueando el botón hasta que termine.
     * @param {Function} fn - Función async a ejecutar
     * @param {object} opts
     * @param {string} opts.successText - Texto de éxito temporal
     * @param {string} opts.errorText - Texto de error temporal
     * @returns {Promise<any>}
     */
    async function execute(fn, opts = {}) {
        if (isSubmitting.value || submitLocked.value) {
            return Promise.reject(new Error('Submission already in progress'));
        }

        const startTime = Date.now();
        isSubmitting.value = true;
        submitLocked.value = true;
        submitText.value = loadingText;

        try {
            const result = await fn();

            // Asegurar duración mínima para evitar parpadeos
            const elapsed = Date.now() - startTime;
            if (elapsed < minDuration) {
                await new Promise(r => setTimeout(r, minDuration - elapsed));
            }

            return result;
        } catch (error) {
            throw error;
        } finally {
            isSubmitting.value = false;
            submitLocked.value = false;
            submitText.value = '';
        }
    }

    return {
        isSubmitting,
        submitLocked,
        submitText,
        execute,
    };
}
