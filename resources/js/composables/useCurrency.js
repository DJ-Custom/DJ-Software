import { useCurrencyStore } from '../stores/currency';

/**
 * Composable that provides currency-aware money formatting.
 * Uses the global currency store to respect the user's selected currency and exchange rates.
 *
 * Usage in components:
 *   import { useCurrency } from '../composables/useCurrency';
 *   const { fm, simbolo } = useCurrency();
 *   // In template: {{ fm(1500) }} -> outputs "$2.88" or "₡1,500" depending on selected currency
 */
export function useCurrency() {
    const store = useCurrencyStore();

    /**
     * Format a money value using the active currency settings.
     * Amounts are assumed to be in CRC (base currency) unless `fromCurrency` is specified.
     */
    function fm(val, fromCurrency = 'CRC') {
        if (val === null || val === undefined) return store.simbolo + '0';
        const converted = store.convertir(Number(val || 0), fromCurrency);
        return store.formatMoney(converted);
    }

    /**
     * Format a raw number (no conversion), just locale formatting with the active symbol.
     */
    function fmRaw(val) {
        return store.formatMoney(val);
    }

    return {
        fm,
        fmRaw,
        get simbolo() { return store.simbolo; },
        get divisa() { return store.divisa; },
        store,
    };
}
