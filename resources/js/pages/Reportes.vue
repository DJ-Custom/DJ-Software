<template>
  <div>
    <div class="flex items-center gap-md mb-lg flex-wrap">
      <input v-model="desde" type="date" class="form-control" @change="cargarReporte">
      <input v-model="hasta" type="date" class="form-control" @change="cargarReporte">
      <select v-model="reporte" class="form-control" @change="cargarReporte">
        <option value="ventas">{{ i18n.t('reportes_ventas_periodo') }}</option>
        <option value="productos">{{ i18n.t('reportes_productos_top') }}</option>
        <option value="clientes">{{ i18n.t('reportes_clientes_top') }}</option>
        <option value="vendedores">{{ i18n.t('reportes_ranking_vendedores') }}</option>
        <option value="metodos">{{ i18n.t('reportes_metodos_pago') }}</option>
        <option value="categorias">{{ i18n.t('reportes_ventas_categoria') }}</option>
        <option value="inventario">{{ i18n.t('reportes_valor_inventario') }}</option>
        <option value="flujo">{{ i18n.t('reportes_flujo_caja') }}</option>
      </select>
    </div>

    <!-- Ventas por Período -->
    <div v-if="reporte==='ventas'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-line"></i> {{ i18n.t('reportes_ventas_periodo') }}</h3></div>
      <div class="card-body">
        <div class="grid-3 mb-lg">
          <div class="stat-card"><div class="stat-value">{{ data.totales?.cantidad || 0 }}</div><div class="stat-label">{{ i18n.t('reportes_total_ventas') }}</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatMoney(data.totales?.monto) }}</div><div class="stat-label">{{ i18n.t('reportes_monto_total') }}</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatMoney(data.totales?.promedio) }}</div><div class="stat-label">{{ i18n.t('reportes_promedio') }}</div></div>
        </div>
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('reportes_fecha') }}</th><th>{{ i18n.t('ventas_label') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="v in data.ventas" :key="v.fecha"><td>{{ v.fecha }}</td><td>{{ v.cantidad }}</td><td>{{ formatMoney(v.monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Productos Top -->
    <div v-if="reporte==='productos'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-trophy"></i> {{ i18n.t('reportes_productos_top') }}</h3></div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>#</th><th>{{ i18n.t('reportes_productos') }}</th><th>{{ i18n.t('codigo') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="(p,i) in data.productos" :key="p.id"><td>{{ i+1 }}</td><td><strong>{{ p.nombre }}</strong></td><td>{{ p.codigo }}</td><td>{{ p.total_vendido }}</td><td>{{ formatMoney(p.total_monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Clientes Top -->
    <div v-if="reporte==='clientes'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-users"></i> {{ i18n.t('reportes_clientes_top') }}</h3></div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>#</th><th>{{ i18n.t('reportes_clientes') }}</th><th>{{ i18n.t('cliente_compras') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="(c,i) in data.clientes" :key="c.id"><td>{{ i+1 }}</td><td><strong>{{ c.nombre }}</strong></td><td>{{ c.total_compras }}</td><td>{{ formatMoney(c.total_monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Vendedores -->
    <div v-if="reporte==='vendedores'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-medal"></i> {{ i18n.t('reportes_ranking_vendedores') }}</h3></div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>#</th><th>{{ i18n.t('vendedor') }}</th><th>{{ i18n.t('ventas_label') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="(v,i) in data.vendedores" :key="v.id"><td>{{ i+1 }}</td><td><strong>{{ v.nombre }}</strong></td><td>{{ v.total_ventas }}</td><td>{{ formatMoney(v.total_monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Métodos Pago -->
    <div v-if="reporte==='metodos'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-credit-card"></i> {{ i18n.t('reportes_metodos_pago') }}</h3></div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('metodo_pago') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="m in data.metodos" :key="m.metodo_pago"><td><strong>{{ m.metodo_pago }}</strong></td><td>{{ m.cantidad }}</td><td>{{ formatMoney(m.monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Categorías -->
    <div v-if="reporte==='categorias'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-tags"></i> {{ i18n.t('reportes_ventas_categoria') }}</h3></div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('reportes_categoria') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="c in data.categorias" :key="c.categoria"><td><strong>{{ c.categoria }}</strong></td><td>{{ c.unidades }}</td><td>{{ formatMoney(c.monto) }}</td></tr></tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Inventario -->
    <div v-if="reporte==='inventario'">
      <div class="grid-4 mb-lg">
        <div class="stat-card"><div class="stat-value">{{ data.valor?.total_productos || 0 }}</div><div class="stat-label">{{ i18n.t('reportes_productos') }}</div></div>
        <div class="stat-card"><div class="stat-value">{{ data.valor?.total_unidades || 0 }}</div><div class="stat-label">{{ i18n.t('cantidad') }}</div></div>
        <div class="stat-card"><div class="stat-value">{{ formatMoney(data.valor?.valor_costo) }}</div><div class="stat-label">Valor Costo</div></div>
        <div class="stat-card"><div class="stat-value">{{ formatMoney(data.valor?.valor_venta) }}</div><div class="stat-label">Valor Venta</div></div>
      </div>
      <div class="card"><div class="card-header"><h3 class="card-title">{{ i18n.t('reportes_valor_inventario') }}</h3></div><div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('reportes_categoria') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
          <tbody><tr v-for="c in data.por_categoria" :key="c.categoria"><td>{{ c.categoria }}</td><td>{{ c.unidades }}</td><td>{{ formatMoney(c.valor) }}</td></tr></tbody>
        </table>
        </div>
      </div></div>
    </div>

    <!-- Flujo Caja -->
    <div v-if="reporte==='flujo'" class="card">
      <div class="card-header"><h3 class="card-title"><i class="fas fa-exchange-alt"></i> {{ i18n.t('reportes_flujo_caja') }}</h3></div>
      <div class="card-body">
        <div class="grid-2 gap-lg">
          <div><h4 class="mb-sm" style="color:var(--success);">{{ i18n.t('reportes_ingresos') }}</h4><div class="table-responsive"><table class="data-table"><thead><tr><th>{{ i18n.t('reportes_fecha') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
            <tbody><tr v-for="i in data.ingresos" :key="i.fecha"><td>{{ i.fecha }}</td><td>{{ formatMoney(i.monto) }}</td></tr></tbody></table></div></div>
          <div><h4 class="mb-sm" style="color:var(--danger);">{{ i18n.t('reportes_egresos') }}</h4><div class="table-responsive"><table class="data-table"><thead><tr><th>{{ i18n.t('reportes_fecha') }}</th><th>{{ i18n.t('reportes_monto') }}</th></tr></thead>
            <tbody><tr v-for="e in data.egresos" :key="e.fecha"><td>{{ e.fecha }}</td><td>{{ formatMoney(e.monto) }}</td></tr></tbody></table></div></div>
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

const i18n = useI18nStore();
const { fm: formatMoney } = useCurrency();

const reporte = ref('ventas');
const desde = ref(new Date(Date.now()-30*86400000).toISOString().split('T')[0]);
const hasta = ref(new Date().toISOString().split('T')[0]);
const data = ref({});

onMounted(() => cargarReporte());

async function cargarReporte() {
  const endpoints = {
    ventas: '/reportes/ventas-periodo', productos: '/reportes/productos-top',
    clientes: '/reportes/clientes-top', vendedores: '/reportes/vendedores',
    metodos: '/reportes/metodos-pago', categorias: '/reportes/categorias',
    inventario: '/reportes/inventario-valor', flujo: '/reportes/flujo-caja',
  };
  try { const r = await api.get(endpoints[reporte.value], { params: { desde: desde.value, hasta: hasta.value } }); data.value = r.data; } catch(e) { console.error(e); }
}

</script>
<style scoped>
input:focus {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}
select:focus {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}
table {
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

@media (max-width: 1023px) {
  .grid-4 {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  .grid-3 {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
  }
}

@media (max-width: 768px) {
  * {
    -webkit-tap-highlight-color: transparent;
  }
  .grid-4 {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  .grid-3 {
    grid-template-columns: 1fr !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
  }
  input, select {
    width: 100% !important;
    min-height: 44px !important;
    font-size: 16px !important;
  }
  .flex.items-center.gap-md {
    flex-direction: column !important;
    align-items: stretch !important;
    gap: 0.75rem !important;
  }
  .stat-value {
    font-size: clamp(1rem, 2vw, 1.5rem) !important;
  }
  .card-body {
    padding: 1rem !important;
  }
  table.data-table {
    font-size: 0.875rem;
  }
  table.data-table th,
  table.data-table td {
    padding: 0.5rem 0.625rem;
  }
}

@media (max-width: 480px) {
  .grid-4 {
    grid-template-columns: 1fr !important;
  }
  .grid-3 {
    grid-template-columns: 1fr !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
  }
  input, select {
    width: 100% !important;
    min-height: 48px !important;
    font-size: 16px !important;
    padding: 0.625rem 0.75rem !important;
  }
  .flex.items-center.gap-md {
    flex-direction: column !important;
    align-items: stretch !important;
    gap: 0.5rem !important;
  }
  .stat-value {
    font-size: clamp(0.9rem, 3vw, 1.2rem) !important;
  }
  .stat-card {
    padding: 0.75rem !important;
  }
  .card-body {
    padding: 0.75rem !important;
  }
  .card-header {
    padding: 0.75rem 1rem !important;
  }
  table.data-table {
    display: block;
    font-size: 0.8125rem;
  }
  table.data-table thead {
    display: none;
  }
  table.data-table tbody {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  table.data-table tr {
    display: flex;
    flex-direction: column;
    background: rgba(255, 255, 255, 0.03);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 8px;
    padding: 0.625rem 0.75rem;
    gap: 0.25rem;
  }
  table.data-table td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.25rem 0;
    border: none;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  }
  table.data-table td::before {
    content: attr(data-label);
    font-weight: 600;
    color: rgba(255, 255, 255, 0.5);
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.025em;
  }
  table.data-table td:last-child {
    border-bottom: none;
  }
}
</style>
