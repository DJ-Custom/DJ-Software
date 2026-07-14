import { defineStore } from 'pinia';
import api from '../services/api';

const DIVISAS = {
    CRC: { codigo: 'CRC', nombre: 'Colón Costarricense', simbolo: '₡', locale: 'es-CR' },
    USD: { codigo: 'USD', nombre: 'Dólar Estadounidense', simbolo: '$', locale: 'en-US' },
    EUR: { codigo: 'EUR', nombre: 'Euro', simbolo: '€', locale: 'de-DE' },
};

export const useCurrencyStore = defineStore('currency', {
    state: () => ({
        divisa: localStorage.getItem('divisa') || 'CRC',
        tasas: { CRC: 1, USD: 0.00192, EUR: 0.00176 },
        loaded: false,
    }),

    getters: {
        divisaActual: (state) => DIVISAS[state.divisa] || DIVISAS.CRC,
        simbolo: (state) => (DIVISAS[state.divisa] || DIVISAS.CRC).simbolo,
        divisasDisponibles: () => Object.values(DIVISAS),
    },

    actions: {
        async setDivisa(codigo) {
            if (DIVISAS[codigo]) {
                this.divisa = codigo;
                localStorage.setItem('divisa', codigo);
                try { await api.post('/configuracion/divisa', { divisa: codigo }); } catch(e) {}
            }
        },

        async cargarTasas() {
            try {
                const { data } = await api.get('/configuracion/tasas-cambio');
                if (data.tasas) {
                    this.tasas = { CRC: 1, ...data.tasas };
                }
                this.loaded = true;
            } catch (e) {
                this.loaded = true;
            }
        },

        loadFromServer(divisa, tasas) {
            if (divisa && DIVISAS[divisa]) {
                this.divisa = divisa;
                localStorage.setItem('divisa', divisa);
            }
            if (tasas) {
                this.tasas = { CRC: 1, USD: 1 / (tasas.USD || 520), EUR: 1 / (tasas.EUR || 570) };
            }
            this.loaded = true;
        },

        convertir(monto, desdeDivisa = 'CRC') {
            if (!monto || desdeDivisa === this.divisa) return Number(monto);
            const enBase = Number(monto) / (this.tasas[desdeDivisa] || 1);
            return enBase * (this.tasas[this.divisa] || 1);
        },

        formatMoney(val, forceDivisa = null) {
            const divisa = forceDivisa || this.divisa;
            const info = DIVISAS[divisa] || DIVISAS.CRC;
            const num = Number(val || 0);
            return info.simbolo + num.toLocaleString(info.locale, { minimumFractionDigits: 0, maximumFractionDigits: 2 });
        },
    },
});
