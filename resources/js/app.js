import { createApp } from 'vue';
import { createPinia } from 'pinia';
import router from './router';
import App from './App.vue';
import 'grapesjs/dist/css/grapes.min.css';
import './echo';

const pinia = createPinia();
const app = createApp(App);
app.use(pinia);
app.use(router);

// Global currency & i18n helpers available in all templates as $fm() and $t()
import { useCurrencyStore } from './stores/currency';
import { useI18nStore } from './stores/i18n';

const currencyStore = useCurrencyStore(pinia);
const i18nStore = useI18nStore(pinia);

app.config.globalProperties.$fm = function (val, fromCurrency = 'CRC') {
    if (val === null || val === undefined) return currencyStore.simbolo + '0';
    const converted = currencyStore.convertir(Number(val || 0), fromCurrency);
    return currencyStore.formatMoney(converted);
};
app.config.globalProperties.$t = function (key) {
    return i18nStore.t(key);
};
Object.defineProperty(app.config.globalProperties, '$simbolo', {
    get() { return currencyStore.simbolo; },
});

app.directive('no-negative', {
    mounted(el) {
        const input = el.tagName === 'INPUT' ? el : el.querySelector('input[type="number"]');
        if (!input) return;
        input._noNegHandler = () => {
            const val = parseFloat(input.value);
            if (val < 0) { input.value = 0; input.dispatchEvent(new Event('input', { bubbles: true })); }
        };
        input.addEventListener('input', input._noNegHandler);
        if (!input.min || parseFloat(input.min) < 0) input.min = '0';
    },
    unmounted(el) {
        const input = el.tagName === 'INPUT' ? el : el.querySelector('input[type="number"]');
        if (input && input._noNegHandler) input.removeEventListener('input', input._noNegHandler);
    }
});

app.mixin({
    mounted() {
        this.$nextTick(() => {
            const el = this.$el;
            if (el && el.querySelectorAll) {
                el.querySelectorAll('input[type="number"]').forEach(input => {
                    if (!input._globalNoNeg) {
                        input._globalNoNeg = true;
                        if (!input.min || parseFloat(input.min) < 0) input.min = '0';
                        input.addEventListener('change', () => {
                            const val = parseFloat(input.value);
                            if (val < 0) { input.value = 0; input.dispatchEvent(new Event('input', { bubbles: true })); }
                        });
                    }
                });
            }
        });
    }
});

app.mount('#app');
