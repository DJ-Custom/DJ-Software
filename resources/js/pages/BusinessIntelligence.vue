<template>
  <div>
    <div class="flex items-center justify-between mb-lg flex-wrap gap-sm">
      <div class="flex items-center gap-sm">
        <select v-model="periodo" class="form-control" @change="cargar">
          <option value="7">{{ i18n.t('bi_ultimos_7_dias') }}</option><option value="30">{{ i18n.t('bi_ultimos_30_dias') }}</option>
          <option value="90">{{ i18n.t('bi_ultimos_90_dias') }}</option><option value="365">{{ i18n.t('bi_ultimo_anio') }}</option>
        </select>
      </div>
    </div>

    <div class="grid-4 mb-lg">
      <div class="stat-card animate-fade-in stagger-1">
        <div class="stat-icon" style="background:var(--success-bg);color:var(--success);"><i class="fas fa-dollar-sign"></i></div>
        <div class="stat-value">{{ fm(kpis.ventas_mes) }}</div>
        <div class="stat-label">{{ i18n.t('bi_ventas_mes') }}</div>
        <div :class="['stat-change', kpis.crecimiento >= 0 ? 'positive':'negative']"><i :class="kpis.crecimiento >= 0 ? 'fas fa-arrow-up':'fas fa-arrow-down'"></i> {{ kpis.crecimiento }}%</div>
      </div>
      <div class="stat-card animate-fade-in stagger-2">
        <div class="stat-icon" style="background:var(--warning-bg);color:var(--warning);"><i class="fas fa-undo"></i></div>
        <div class="stat-value">{{ kpis.tasa_devolucion }}%</div>
        <div class="stat-label">{{ i18n.t('bi_tasa_devolucion') }}</div>
        <div class="stat-change">{{ kpis.devoluciones_mes }} {{ i18n.t('bi_devoluciones') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-3">
        <div class="stat-icon" style="background:var(--info-bg);color:var(--info);"><i class="fas fa-warehouse"></i></div>
        <div class="stat-value">{{ fm(kpis.inventario_valor) }}</div>
        <div class="stat-label">{{ i18n.t('bi_valor_inventario') }}</div>
        <div class="stat-change negative" v-if="kpis.stock_bajo > 0"><i class="fas fa-exclamation-triangle"></i> {{ kpis.stock_bajo }} {{ i18n.t('bi_stock_bajo') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-4">
        <div class="stat-icon" style="background: rgba(100,204,204,0.15);color:#64cccc;"><i class="fas fa-receipt"></i></div>
        <div class="stat-value">{{ fm(kpis.ticket_promedio) }}</div>
        <div class="stat-label">{{ i18n.t('ticket_promedio') }}</div>
      </div>
    </div>

    <div class="grid-2 gap-lg mb-lg">
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-line"></i> {{ i18n.t('bi_tendencia_ventas') }}</h3></div>
        <div class="card-body">
          <div v-for="t in data.tendencia_ventas" :key="t.mes" class="flex items-center justify-between mb-xs" style="padding:6px 0;border-bottom:1px solid var(--bg-hover);">
            <span style="font-weight:600;">{{ t.mes }}</span>
            <div class="flex items-center gap-md"><span class="badge badge-info">{{ t.cantidad }} {{ i18n.t('geo_business_ventas') }}</span><span style="font-weight:700;">{{ fm(t.total) }}</span></div>
          </div>
          <div v-if="!data.tendencia_ventas?.length" style="text-align:center;color:var(--text-muted);padding:20px;">{{ i18n.t('sin_datos') }}</div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-clock"></i> {{ i18n.t('bi_ventas_por_hora') }}</h3></div>
        <div class="card-body">
          <div class="bi-hours-grid">
            <div v-for="h in data.ventas_por_hora" :key="h.hora" class="bi-hour-item">
              <div class="bi-hour-bar" :style="{height: barHeight(h.total, maxHora) + '%'}"></div>
              <div class="bi-hour-label">{{ h.hora }}h</div>
              <div class="bi-hour-val">{{ h.cantidad }}</div>
            </div>
          </div>
          <div v-if="!data.ventas_por_hora?.length" style="text-align:center;color:var(--text-muted);padding:20px;">{{ i18n.t('sin_datos') }}</div>
        </div>
      </div>
    </div>

    <div class="grid-2 gap-lg mb-lg">
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-trophy"></i> {{ i18n.t('bi_top_productos') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_producto') }}</th><th>{{ i18n.t('bi_unidades') }}</th><th>{{ i18n.t('ingresos') }}</th></tr></thead>
            <tbody><tr v-for="(p,i) in data.top_productos" :key="i"><td><strong>{{ p.nombre }}</strong></td><td>{{ p.unidades }}</td><td>{{ fm(p.ingresos) }}</td></tr></tbody>
          </table>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-users"></i> {{ i18n.t('bi_top_clientes') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_cliente') }}</th><th>{{ i18n.t('bi_compras') }}</th><th>{{ i18n.t('total') }}</th></tr></thead>
            <tbody><tr v-for="(c,i) in data.top_clientes" :key="i"><td><strong>{{ c.nombre }}</strong></td><td>{{ c.compras }}</td><td>{{ fm(c.total) }}</td></tr></tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <div class="grid-2 gap-lg mb-lg">
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-credit-card"></i> {{ i18n.t('bi_distribucion_metodos_pago') }}</h3></div>
        <div class="card-body">
          <div v-for="m in data.metodos_pago" :key="m.metodo_pago" class="flex items-center justify-between mb-sm" style="padding:8px 0;border-bottom:1px solid var(--bg-hover);">
            <div><span class="badge badge-info">{{ m.metodo_pago }}</span><span style="margin-left:8px;">{{ m.cantidad }} {{ i18n.t('bi_transacciones') }}</span></div>
            <strong>{{ fm(m.total) }}</strong>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-th-large"></i> {{ i18n.t('bi_ventas_categoria') }}</h3></div>
        <div class="card-body">
          <div v-for="c in data.ventas_por_categoria" :key="c.categoria" class="flex items-center justify-between mb-sm" style="padding:8px 0;border-bottom:1px solid var(--bg-hover);">
            <div><strong>{{ c.categoria }}</strong><span style="margin-left:8px;font-size:12px;color:var(--text-muted);">{{ c.unidades }} {{ i18n.t('uds') }}</span></div>
            <strong>{{ fm(c.total) }}</strong>
          </div>
        </div>
      </div>
    </div>

    <div class="grid-2 gap-lg mb-lg">
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-coins" style="color:var(--success);"></i> {{ i18n.t('rentabilidad_titulo') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_producto') }}</th><th style="text-align:right;">{{ i18n.t('bi_margen') }}</th><th style="text-align:right;">%</th></tr></thead>
            <tbody>
              <tr v-for="p in data.rentabilidad_productos" :key="p.nombre">
                <td><strong>{{ p.nombre }}</strong></td>
                <td style="text-align:right;color:var(--success);font-weight:600;">{{ fm(p.margen) }}</td>
                <td style="text-align:right;"><span class="badge" :class="p.porcentaje >= 30 ? 'badge-success' : p.porcentaje >= 15 ? 'badge-warning' : 'badge-danger'">{{ p.porcentaje }}%</span></td>
              </tr>
              <tr v-if="!data.rentabilidad_productos?.length"><td colspan="3" style="text-align:center;color:var(--text-muted);padding:24px;">{{ i18n.t('sin_datos') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-pie" style="color:var(--info);"></i> {{ i18n.t('bi_analisis_abc') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_producto') }}</th><th style="text-align:right;">{{ i18n.t('ingresos') }}</th><th style="text-align:right;">{{ i18n.t('bi_acum') }}</th><th style="text-align:center;">{{ i18n.t('bi_clase') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in data.abc_analysis" :key="p.nombre">
                <td><strong>{{ p.nombre }}</strong></td>
                <td style="text-align:right;">{{ fm(p.ingresos) }}</td>
                <td style="text-align:right;font-size:12px;color:var(--text-muted);">{{ p.pct_acumulado }}%</td>
                <td style="text-align:center;"><span class="badge" :class="p.clase==='A'?'badge-success':p.clase==='B'?'badge-warning':'badge-info'">{{ p.clase }}</span></td>
              </tr>
              <tr v-if="!data.abc_analysis?.length"><td colspan="4" style="text-align:center;color:var(--text-muted);padding:24px;">{{ i18n.t('sin_datos') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <div class="grid-2 gap-lg">
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-undo" style="color:var(--danger);"></i> {{ i18n.t('bi_productos_devoluciones') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_producto') }}</th><th style="text-align:right;">{{ i18n.t('bi_devoluciones_label') }}</th><th style="text-align:right;">{{ i18n.t('bi_uds_dev') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in data.productos_devoluciones" :key="p.nombre">
                <td><strong>{{ p.nombre }}</strong></td>
                <td style="text-align:right;"><span class="badge badge-danger">{{ p.devoluciones }}</span></td>
                <td style="text-align:right;">{{ p.unidades_devueltas }}</td>
              </tr>
              <tr v-if="!data.productos_devoluciones?.length"><td colspan="3" style="text-align:center;color:var(--text-muted);padding:24px;">{{ i18n.t('sin_datos') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-sync-alt" style="color:var(--warning);"></i> {{ i18n.t('bi_rotacion_inventario') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('bi_producto') }}</th><th style="text-align:right;">{{ i18n.t('stock') }}</th><th style="text-align:right;">{{ i18n.t('bi_vendido') }}</th><th style="text-align:right;">{{ i18n.t('bi_rotacion') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in data.rotacion_inventario" :key="p.nombre">
                <td><strong>{{ p.nombre }}</strong></td>
                <td style="text-align:right;">{{ p.stock }}</td>
                <td style="text-align:right;">{{ p.vendido }}</td>
                <td style="text-align:right;font-weight:700;color:var(--warning);">{{ p.rotacion }}x</td>
              </tr>
              <tr v-if="!data.rotacion_inventario?.length"><td colspan="4" style="text-align:center;color:var(--text-muted);padding:24px;">{{ i18n.t('sin_datos') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const { fm } = useCurrency();
const periodo = ref('30');
const data = ref({});
const kpis = computed(() => data.value.kpis || {});
const maxHora = computed(() => Math.max(...(data.value.ventas_por_hora || []).map(h => h.total), 1));
function barHeight(val, max) { return Math.round((val / max) * 100); }
async function cargar() { try { const {data: d} = await api.get('/bi/dashboard', {params:{periodo:periodo.value}}); data.value = d; } catch(e){} }
onMounted(cargar);
</script>

<style scoped>
.bi-hours-grid { display:flex; gap:4px; align-items:flex-end; height:120px; }
.bi-hour-item { flex:1; display:flex; flex-direction:column; align-items:center; }
.bi-hour-bar { width:100%; min-height:4px; background:var(--primary-gold); border-radius:4px 4px 0 0; transition:height 0.3s; }
.bi-hour-label { font-size:10px; color:var(--text-muted); margin-top:4px; }
.bi-hour-val { font-size:10px; font-weight:600; }

option {
  background: transparent;
  border: none;
  border-radius: 4px;
  color: #000000;
}
option:hover {
  background: var(--primary-gold);
  color: #ffffff;
}
option:focus {
  background: var(--primary-gold);
  color: #ffffff;
}
option:checked {
  background: var(--primary-gold);
  color: #ffffff;
}
select {
  background-color: rgba(255, 255, 255, 0.4);
  border: none;
  color: #283164;
  font-family: Verdana, Geneva, Tahoma, sans-serif;
  font-weight: 500;
}
select:focus {
  background: var(--primary-gold);
  color: #ffffff;
  box-shadow: 0 0 0 2px var(--primary-gold);
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
  .bi-hours-grid {
    height: 100px !important;
  }
}

@media (max-width: 768px) {
  .grid-4 {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  .grid-3 {
    grid-template-columns: 1fr !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
  }
  .bi-hours-grid {
    height: 80px !important;
  }
  .stat-value {
    font-size: clamp(1rem, 2vw, 1.5rem) !important;
  }
  .stat-card {
    padding: 12px !important;
  }
  select {
    width: 100% !important;
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
  .bi-hours-grid {
    height: 60px !important;
    gap: 2px !important;
  }
  .bi-hour-label {
    font-size: 8px !important;
  }
  .bi-hour-val {
    font-size: 8px !important;
  }
  .stat-value {
    font-size: clamp(0.9rem, 3vw, 1.2rem) !important;
  }
  .stat-card {
    padding: 10px !important;
  }
  select {
    width: 100% !important;
    min-height: 44px !important;
  }
}
</style>
