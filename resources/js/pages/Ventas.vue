<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex items-center gap-md">
        <input v-model="filtros.busqueda" class="form-control filter-input" :placeholder="i18n.t('buscar_venta')" @input="cargar" />
        <input v-model="filtros.fecha_desde" type="date" class="form-control filter-date" @change="cargar" />
        <input v-model="filtros.fecha_hasta" type="date" class="form-control filter-date" @change="cargar" />
        <select v-model="filtros.estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="completada">{{ i18n.t('completada') }}</option>
          <option value="cancelada">{{ i18n.t('cancelada') }}</option>
          <option value="parcialmente_anulada">{{ i18n.t('parcialmente_anulada') }}</option>
        </select>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-receipt" style="margin-right:8px;"></i>{{ i18n.t('historial_ventas') }}</h3>
        <span class="badge badge-info">{{ total }} total</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('factura') }}</th>
                <th>{{ i18n.t('cliente') }}</th>
                <th>{{ i18n.t('cajero') }}</th>
                <th>{{ i18n.t('total') }}</th>
                <th>{{ i18n.t('metodo') }}</th>
                <th>{{ i18n.t('estado') }}</th>
                <th>{{ i18n.t('fecha') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="v in ventas" :key="v.id" class="animate-fade-in">
                <td :data-label="i18n.t('factura')"><strong>{{ v.numero_factura }}</strong></td>
                <td :data-label="i18n.t('cliente')">{{ v.cliente_nombre || i18n.t('publico_general') }}</td>
                <td :data-label="i18n.t('cajero')">{{ v.cajero }}</td>
                <td :data-label="i18n.t('total')">{{ fm(v.total) }}</td>
                <td :data-label="i18n.t('metodo')"><span class="badge badge-info">{{ v.metodo_pago }}</span></td>
                <td :data-label="i18n.t('estado')">
                  <span :class="['badge', estadoBadgeClass(v)]">
                    {{ estadoDisplay(v) }}
                  </span>
                </td>
                <td :data-label="i18n.t('fecha')">{{ formatDate(v.created_at) }}</td>
                <td :data-label="i18n.t('acciones')">
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(v.id)" :title="i18n.t('ver')">
                    <i class="fas fa-eye"></i>
                  </button>
                </td>
              </tr>
              <tr v-if="!ventas.length && !loading">
                <td colspan="8" style="text-align:center; padding:40px; color: var(--text-muted);">{{ i18n.t('no_hay_ventas') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer flex justify-between items-center" v-if="pages > 1">
        <span style="font-size:13px; color: var(--text-secondary);">{{ i18n.tp('pagina_de', { n: page, total: pages }) }}</span>
        <div class="flex gap-sm">
          <button class="btn btn-sm btn-secondary" :disabled="page <= 1" @click="page--; cargar()">{{ i18n.t('anterior') }}</button>
          <button class="btn btn-sm btn-secondary" :disabled="page >= pages" @click="page++; cargar()">{{ i18n.t('siguiente') }}</button>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{ active: showDetalle }" @click.self="showDetalle = false">
      <div class="modal" style="max-width:min(90vw,700px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ i18n.t('detalle_venta') }}</h3>
          <button class="modal-close" @click="showDetalle = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" v-if="detalle">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('factura') }}:</strong> {{ detalle.numero_factura }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge', estadoBadgeClass(detalle)]">{{ estadoDisplay(detalle) }}</span></div>
            <div><strong>{{ i18n.t('cliente') }}:</strong> {{ detalle.cliente_nombre || i18n.t('publico_general') }}</div>
            <div><strong>{{ i18n.t('cajero') }}:</strong> {{ detalle.cajero }}</div>
          </div>
          <div class="table-container">
            <table class="data-table">
              <thead>
                <tr>
                  <th>{{ i18n.t('producto') }}</th>
                  <th>{{ i18n.t('cant') }}</th>
                  <th>{{ i18n.t('precio') }}</th>
                  <th>{{ i18n.t('subtotal') }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in detalle.items" :key="item.id">
                  <td :data-label="i18n.t('producto')">{{ item.producto_nombre }}</td>
                  <td :data-label="i18n.t('cant')">{{ item.cantidad }}</td>
                  <td :data-label="i18n.t('precio')">{{ fm(item.precio_unitario) }}</td>
                  <td :data-label="i18n.t('subtotal')">{{ fm(item.subtotal) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="mt-md text-right">
            <div><strong>{{ i18n.t('subtotal') }}:</strong> {{ fm(detalle.subtotal) }}</div>
            <div><strong>{{ i18n.t('impuesto') }}:</strong> {{ fm(detalle.impuesto_total) }}</div>
            <div style="font-size:20px;"><strong>{{ i18n.t('total') }}:</strong> {{ fm(detalle.total) }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm } = useCurrency();
const i18n = useI18nStore();

const ventas = ref([]);
const total = ref(0);
const page = ref(1);
const pages = ref(1);
const loading = ref(false);
const filtros = ref({ busqueda: '', fecha_desde: '', fecha_hasta: '', estado: '' });
const showDetalle = ref(false);
const detalle = ref(null);

onMounted(() => cargar());

async function cargar() {
    loading.value = true;
    try {
        const params = { page: page.value, ...filtros.value };
        const { data } = await api.get('/ventas', { params });
        ventas.value = data.ventas;
        total.value = data.total;
        pages.value = data.pages;
        page.value = data.page;
    } catch (e) {
        console.error(e);
    }
    loading.value = false;
}

async function verDetalle(id) {
    try {
        const { data } = await api.get(`/ventas/${id}`);
        detalle.value = data.venta;
        showDetalle.value = true;
    } catch (e) {
        console.error(e);
    }
}

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString(i18n.locale === 'en' ? 'en-US' : 'es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function estadoBadgeClass(v) {
    if (v.has_devolucion) return 'badge-warning';
    if (v.estado === 'completada') return 'badge-success';
    if (v.estado === 'cancelada') return 'badge-danger';
    if (v.estado === 'parcialmente_anulada') return 'badge-warning';
    return 'badge-secondary';
}

function estadoDisplay(v) {
    if (v.has_devolucion) return i18n.t('con_devolucion');
    if (v.estado === 'completada') return i18n.t('completada');
    if (v.estado === 'cancelada') return i18n.t('cancelada');
    if (v.estado === 'parcialmente_anulada') return i18n.t('parcialmente_anulada');
    if (v.estado === 'pendiente') return i18n.t('pendiente');
    return v.estado;
}
</script>

<style scoped>
.filter-input { width: 100%; max-width: 260px; min-width: 0; }
.filter-date { width: 100%; max-width: 160px; min-width: 0; }
.filter-select { width: 100%; max-width: 160px; min-width: 0; }

@media (max-width: 1023px) {
  .filter-input { max-width: 200px; }
  .filter-date { max-width: 150px; }
  .filter-select { max-width: 150px; }
}

@media (max-width: 768px) {
  * { -webkit-tap-highlight-color: transparent; }
  .flex.items-center.gap-md {
    flex-wrap: wrap;
    gap: 8px;
  }
  .filter-input,
  .filter-date,
  .filter-select {
    max-width: 100% !important;
    min-width: 0 !important;
    min-height: 44px;
    font-size: 16px;
  }
  .grid-2 { grid-template-columns: 1fr; }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 600px; }
  .data-table th,
  .data-table td {
    padding: 8px 10px;
    font-size: 13px;
    white-space: nowrap;
  }
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 12px 16px;
  }
  .card-footer {
    flex-direction: column;
    gap: 10px;
    padding: 12px 16px;
  }
  .card-footer .flex.gap-sm {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .filter-input,
  .filter-date,
  .filter-select {
    max-width: 100% !important;
    min-height: 48px;
    font-size: 16px;
    border-radius: 8px;
  }
  .flex.items-center.gap-md {
    flex-direction: column;
  }
  .btn {
    min-height: 44px;
    width: 100%;
    font-size: 15px;
  }
  .card-header { padding: 10px 12px; }
  .card-body { padding: 0 !important; }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 600px; }
  .data-table thead { display: none; }
  .data-table tbody tr {
    display: flex;
    flex-direction: column;
    padding: 12px;
    margin: 8px;
    border: 1px solid var(--border);
    border-radius: 8px;
    background: var(--bg-card);
    gap: 4px;
  }
  .data-table tbody td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 4px 0;
    font-size: 14px;
    white-space: normal;
    border: none;
  }
  .data-table tbody td::before {
    content: attr(data-label);
    font-weight: 600;
    color: var(--text-secondary);
    min-width: 40%;
  }
  .grid-2 { grid-template-columns: 1fr; gap: 8px; }
  .modal-header { padding: 12px 16px; }
  .modal-body { padding: 12px 16px; overflow-y: auto; }
}
</style>
