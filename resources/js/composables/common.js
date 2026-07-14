import api from '../services/api';
import { useConfirmStore } from '../stores/confirm';
import { useToastStore } from '../stores/toast';
import { useCurrencyStore } from '../stores/currency';

const confirm = useConfirmStore();
const toast = useToastStore();

function formatMoney(val, fromCurrency = 'CRC') {
    try {
        const store = useCurrencyStore();
        const converted = store.convertir(Number(val || 0), fromCurrency);
        return store.formatMoney(converted);
    } catch(e) {
        return '₡' + Number(val || 0).toLocaleString('es-CR', { minimumFractionDigits: 0 });
    }
}

async function deleteItem(p, url, callback) {
    if (!await confirm.ask({ message: `¿Eliminar registro? Esta acción no se puede deshacer.`, confirmText: 'Eliminar', type: 'danger' })) return;
    try {
        await api.delete(`${url}/${p.id}`);
        toast.success('Registro eliminado');
        if (callback && typeof callback === 'function') callback();
    } catch (e) {
        toast.error(e.response?.data?.error || 'Error al eliminar');
    }
}

function normalizarMinimo(obj, campo, minimo = 0) {
    const valor = Number(obj[campo]);
    if (isNaN(valor) || valor < minimo) {
        obj[campo] = minimo;
    }
}

function validarNoNegativo(event) {
    const input = event.target;
    const val = parseFloat(input.value);
    if (val < 0) {
        input.value = 0;
        input.dispatchEvent(new Event('input', { bubbles: true }));
    }
}

export default {
    formatMoney,
    deleteItem,
    normalizarMinimo,
    validarNoNegativo,
}