<template>
  <div>
    <!-- Header -->
    <div class="flex items-center justify-between mb-lg flex-wrap gap-sm geo-header">
      <h2 class="text-2xl font-bold" style="color:var(--text-primary);"><i class="fas fa-globe-americas" style="color:var(--primary);"></i> {{ i18n.t('geo_business_titulo') }}</h2>
      <div class="flex gap-sm geo-header-actions">
        <button class="btn btn-ghost btn-sm btn-mobile-min" @click="exportCSV('dashboard')"><i class="fas fa-file-csv"></i> {{ i18n.t('geo_business_csv') }}</button>
        <button class="btn btn-ghost btn-sm btn-mobile-min" @click="exportPrint"><i class="fas fa-print"></i> {{ i18n.t('geo_business_imprimir') }}</button>
        <button class="btn btn-primary btn-sm btn-mobile-min" @click="cargarTodo"><i class="fas fa-sync-alt"></i> {{ i18n.t('geo_business_actualizar') }}</button>
      </div>
    </div>

    <!-- Advanced Filters -->
    <div class="card mb-lg geo-filters-card">
      <div class="flex items-center gap-sm flex-wrap geo-filters">
        <div class="form-group geo-filter-item">
          <label class="geo-filter-label">{{ i18n.t('geo_business_desde') }}</label>
          <input v-model="filtros.desde" type="date" class="form-control" @change="cargarTodo">
        </div>
        <div class="form-group geo-filter-item">
          <label class="geo-filter-label">{{ i18n.t('geo_business_hasta') }}</label>
          <input v-model="filtros.hasta" type="date" class="form-control" @change="cargarTodo">
        </div>
        <div class="form-group geo-filter-item geo-filter-ubicacion">
          <label class="geo-filter-label">{{ i18n.t('geo_business_ubicacion') }}</label>
          <select v-model="filtros.ubicacion_id" class="form-control" @change="cargarTodo">
            <option value="">{{ i18n.t('geo_business_todas_ubicaciones') }}</option>
            <option v-for="u in ubicacionesOpts" :key="u.id" :value="u.id">{{ u.nombre }}</option>
          </select>
        </div>
        <div class="form-group geo-filter-item geo-filter-producto">
          <label class="geo-filter-label">{{ i18n.t('geo_business_producto') }}</label>
          <input v-model="productoBuscar" class="form-control" :placeholder="i18n.t('geo_business_buscar_producto')" @input="filtrarProductos">
          <div v-if="productosFiltrados.length && productoBuscar" class="geo-producto-dropdown">
            <div v-for="p in productosFiltrados" :key="p.id" class="p-sm geo-producto-item" @click="seleccionarProducto(p)">{{ p.nombre }}</div>
          </div>
        </div>
        <div class="form-group geo-filter-item geo-filter-categoria">
          <label class="geo-filter-label">{{ i18n.t('geo_business_categoria') }}</label>
          <select v-model="filtros.categoria_id" class="form-control" @change="cargarTodo">
            <option value="">{{ i18n.t('todos') }}</option>
            <option v-for="c in categoriasOpts" :key="c.id" :value="c.id">{{ c.nombre }}</option>
          </select>
        </div>
        <div class="form-group geo-filter-item">
          <label class="geo-filter-label">Periodo</label>
          <select v-model="periodoPreset" class="form-control" @change="aplicarPreset">
            <option value="custom">{{ i18n.t('geo_business_personalizado') }}</option>
            <option value="7">{{ i18n.t('bi_ultimos_7_dias') }}</option>
            <option value="30">{{ i18n.t('bi_ultimos_30_dias') }}</option>
            <option value="90">{{ i18n.t('bi_ultimos_90_dias') }}</option>
            <option value="365">{{ i18n.t('bi_ultimo_anio') }}</option>
          </select>
        </div>
        <div v-if="filtros.producto_id" class="flex items-center gap-xs geo-producto-badge">
          <span class="badge badge-info">{{ productoSel?.nombre }}</span>
          <button class="btn btn-xs btn-primary" @click="cargarProductoAnalisis" :title="i18n.t('geo_business_analizar_producto')"><i class="fas fa-search"></i></button>
          <button class="btn btn-xs btn-danger" @click="limpiarProducto"><i class="fas fa-times"></i></button>
        </div>
      </div>
    </div>

    <!-- Errores visibles -->
    <div v-if="errores.length" class="card mb-lg geo-error-card">
      <div v-for="(err, i) in errores" :key="i" class="geo-error-item">
        <i class="fas fa-exclamation-circle"></i> {{ err }}
      </div>
      <button class="btn btn-xs btn-ghost" @click="errores=[]" style="margin-top:4px;">{{ i18n.t('geo_business_limpiar_errores') }}</button>
    </div>

    <!-- Debug panel -->
    <div class="card mb-lg geo-debug-card">
      <div class="geo-debug-text">
        <strong style="color:var(--primary);">Debug:</strong>
        Cargando={{ cargando }} |
        KPIs: ventas={{ kpis.total_ventas ?? 0 }}, ingresos={{ kpis.total_ingresos ?? 0 }} |
        Ubicaciones={{ locSummary.length }} |
        TopProductos={{ topProductos.length }} |
        Tendencias={{ trend.length }} |
        Categorias={{ categoriasData.length }} |
        Comparativa={{ comparativa.ubicaciones?.length ?? 0 }} |
        Movimientos={{ movimientos.data?.length ?? 0 }}
      </div>
    </div>

    <!-- Loading -->
    <div v-if="cargando" class="flex justify-center items-center p-lg" style="min-height:200px;">
      <div style="text-align:center;color:var(--text-muted);">
        <i class="fas fa-circle-notch fa-spin" style="font-size:32px;margin-bottom:12px;display:block;"></i>
        <span>{{ i18n.t('geo_business_cargando_datos') }}</span>
      </div>
    </div>

    <!-- Tabs -->
    <div class="tabs-bar mb-lg geo-tabs-bar">
      <button v-for="t in tabs" :key="t.id" :class="['tab-btn', activeTab===t.id?'active':'']" @click="activeTab=t.id">
        <i :class="t.icon"></i> {{ t.label }}
      </button>
    </div>

    <!-- TAB 1: GeoAnalytics -->
    <div v-if="activeTab==='geo'" class="tab-panel">
      <!-- Compact Stats Bar -->
      <div class="card mb-lg geo-compact-stats">
        <div class="flex items-center justify-between geo-compact-inner">
          <div class="flex gap-md items-center geo-compact-items">
            <div class="flex items-center gap-sm geo-stat-pill"><i class="fas fa-shopping-cart" style="color:var(--primary);font-size:14px;"></i><span class="geo-stat-num">{{ kpis.total_ventas ?? 0 }}</span><span class="geo-stat-label">{{ i18n.t('geo_business_ventas') }}</span></div>
            <div class="flex items-center gap-sm geo-stat-pill"><i class="fas fa-coins" style="color:var(--success);font-size:14px;"></i><span class="geo-stat-num">{{ fm(kpis.total_ingresos) }}</span><span class="geo-stat-label">{{ i18n.t('ingresos') }}</span></div>
            <div class="flex items-center gap-sm geo-stat-pill"><i class="fas fa-boxes" style="color:var(--warning);font-size:14px;"></i><span class="geo-stat-num">{{ kpis.total_productos_vendidos ?? 0 }}</span><span class="geo-stat-label">{{ i18n.t('uds') }}</span></div>
            <div class="flex items-center gap-sm geo-stat-pill"><i class="fas fa-ticket-alt" style="color:var(--info);font-size:14px;"></i><span class="geo-stat-num">{{ fm(kpis.ticket_promedio) }}</span><span class="geo-stat-label">{{ i18n.t('geo_business_ticket') }}</span></div>
          </div>
          <button class="btn btn-ghost btn-sm btn-mobile-min" @click="statsExpanded=!statsExpanded">
            <i :class="statsExpanded?'fas fa-chevron-up':'fas fa-chevron-down'"></i> {{ statsExpanded ? i18n.t('geo_business_compactar') : i18n.t('geo_business_expandir') }}
          </button>
        </div>
      </div>

      <!-- Expanded Stats -->
      <div v-if="statsExpanded" class="grid-4 mb-lg geo-expanded-grid">
        <div class="stat-card">
          <div class="flex items-center justify-between mb-sm">
            <span class="stat-label">{{ i18n.t('geo_business_total_ventas_label') }}</span>
            <i class="fas fa-shopping-cart" style="color:var(--primary);font-size:20px;"></i>
          </div>
          <div class="stat-value">{{ kpis.total_ventas ?? 0 }}</div>
          <div class="stat-change positive"><i class="fas fa-receipt"></i> {{ i18n.t('geo_business_facturas_generadas') }}</div>
        </div>
        <div class="stat-card">
          <div class="flex items-center justify-between mb-sm">
            <span class="stat-label">{{ i18n.t('geo_business_ingresos_totales') }}</span>
            <i class="fas fa-coins" style="color:var(--success);font-size:20px;"></i>
          </div>
          <div class="stat-value">{{ fm(kpis.total_ingresos) }}</div>
          <div class="stat-change positive"><i class="fas fa-arrow-up"></i> {{ i18n.t('geo_business_ventas_completadas') }}</div>
        </div>
        <div class="stat-card">
          <div class="flex items-center justify-between mb-sm">
            <span class="stat-label">{{ i18n.t('geo_business_productos_vendidos') }}</span>
            <i class="fas fa-boxes" style="color:var(--warning);font-size:20px;"></i>
          </div>
          <div class="stat-value">{{ kpis.total_productos_vendidos ?? 0 }}</div>
          <div class="stat-change positive"><i class="fas fa-box"></i> {{ i18n.t('geo_business_unidades_totales') }}</div>
        </div>
        <div class="stat-card">
          <div class="flex items-center justify-between mb-sm">
            <span class="stat-label">{{ i18n.t('ticket_promedio') }}</span>
            <i class="fas fa-ticket-alt" style="color:var(--info);font-size:20px;"></i>
          </div>
          <div class="stat-value">{{ fm(kpis.ticket_promedio) }}</div>
          <div class="stat-change positive"><i class="fas fa-chart-line"></i> {{ i18n.t('geo_business_promedio_venta') }}</div>
        </div>
      </div>

      <!-- Map -->
      <div class="card mb-lg">
        <div class="card-header geo-map-header">
          <h3 class="card-title geo-map-title">
            <i class="fas fa-map-marked-alt"></i>
            {{ filtros.producto_id ? i18n.tp('geo_business_movimiento_producto', { n: productoSel?.nombre || i18n.t('geo_business_producto') }) : i18n.t('geo_business_mapa_ventas_label') }}
          </h3>
          <div class="flex gap-sm items-center geo-map-legend">
            <div v-if="filtros.producto_id" class="flex gap-xs items-center geo-legend">
              <span class="flex items-center gap-xs geo-legend-item geo-legend-alto"><span class="geo-legend-dot geo-legend-dot-alto"></span>{{ i18n.t('geo_business_alto') }}</span>
              <span class="flex items-center gap-xs geo-legend-item geo-legend-medio"><span class="geo-legend-dot geo-legend-dot-medio"></span>{{ i18n.t('geo_business_medio') }}</span>
              <span class="flex items-center gap-xs geo-legend-item geo-legend-bajo"><span class="geo-legend-dot geo-legend-dot-bajo"></span>{{ i18n.t('geo_business_bajo') }}</span>
            </div>
            <div v-else class="flex gap-xs items-center geo-legend">
              <span class="flex items-center gap-xs geo-legend-item geo-legend-default"><span class="geo-legend-dot geo-legend-dot-alto"></span>{{ i18n.t('geo_business_alto') }}</span>
              <span class="flex items-center gap-xs geo-legend-item geo-legend-default"><span class="geo-legend-dot geo-legend-dot-medio"></span>{{ i18n.t('geo_business_medio') }}</span>
              <span class="flex items-center gap-xs geo-legend-item geo-legend-default"><span class="geo-legend-dot geo-legend-dot-bajo"></span>{{ i18n.t('geo_business_bajo') }}</span>
            </div>
            <button :class="['btn btn-sm', capa==='markers'?'btn-primary':'btn-ghost']" @click="capa='markers'"><i class="fas fa-map-marker-alt"></i></button>
            <button :class="['btn btn-sm', capa==='heatmap'?'btn-primary':'btn-ghost']" @click="capa='heatmap'"><i class="fas fa-fire"></i></button>
            <button :class="['btn btn-sm', capa==='both'?'btn-primary':'btn-ghost']" @click="capa='both'"><i class="fas fa-layer-group"></i></button>
          </div>
        </div>
        <div class="card-body" style="padding:0;">
          <div ref="mapRef" id="geo-map"></div>
        </div>
      </div>

      <div class="grid-2 mb-lg geo-charts-grid">
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-line"></i> {{ i18n.t('bi_tendencia_ventas') }}</h3></div>
          <div class="card-body"><canvas ref="chartTrendRef"></canvas></div>
        </div>
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-pie"></i> {{ i18n.t('bi_ventas_categoria') }}</h3></div>
          <div class="card-body"><canvas ref="chartPieRef"></canvas></div>
        </div>
      </div>

      <div class="grid-2 geo-tables-grid">
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-crown"></i> {{ i18n.t('geo_business_productos_top') }}</h3></div>
          <div class="card-body" style="padding:0;">
            <div class="table-responsive">
              <table class="data-table">
                <thead><tr><th>{{ i18n.t('geo_business_producto_col') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('ingresos') }}</th></tr></thead>
                <tbody>
                  <tr v-for="p in topProductos" :key="p.id">
                    <td><strong>{{ p.nombre }}</strong><div class="text-xs-muted">{{ p.codigo||'' }}</div></td>
                    <td>{{ p.total_vendido }}</td>
                    <td style="font-weight:700;">{{ fm(p.total_monto) }}</td>
                  </tr>
                  <tr v-if="!topProductos.length"><td colspan="3" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-store"></i> {{ i18n.t('geo_business_rendimiento_ubicacion') }}</h3></div>
          <div class="card-body" style="padding:0;">
            <div class="table-responsive">
              <table class="data-table">
                <thead><tr><th>{{ i18n.t('geo_business_ubicacion') }}</th><th>{{ i18n.t('geo_business_ventas') }}</th><th>{{ i18n.t('ingresos') }}</th><th>{{ i18n.t('geo_business_rend') }}</th></tr></thead>
                <tbody>
                  <tr v-for="u in locSummary" :key="u.id">
                    <td><strong>{{ u.nombre }}</strong></td>
                    <td>{{ u.cantidad_ventas }}</td>
                    <td style="font-weight:700;">{{ fm(u.total_ventas) }}</td>
                    <td><span :class="['badge', badgeRendimiento(u.rendimiento)]">{{ u.rendimiento }}</span></td>
                  </tr>
                  <tr v-if="!locSummary.length"><td colspan="4" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- TAB 2: Análisis de Ventas -->
    <div v-if="activeTab==='ventas'" class="tab-panel">
      <div class="grid-2 mb-lg geo-charts-grid">
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-bar"></i> {{ i18n.t('geo_business_comparativo_ingresos') }}</h3></div>
          <div class="card-body"><canvas ref="chartBarRef"></canvas></div>
        </div>
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-chart-area"></i> {{ i18n.t('geo_business_evolucion_ticket') }}</h3></div>
          <div class="card-body"><canvas ref="chartTicketRef"></canvas></div>
        </div>
      </div>
      <div class="card mb-lg">
        <div class="card-header flex justify-between">
          <h3 class="card-title"><i class="fas fa-list"></i> {{ i18n.t('geo_business_detalle_ventas_ubicacion') }}</h3>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('geo_business_ubicacion') }}</th><th>{{ i18n.t('geo_business_ventas') }}</th><th>{{ i18n.t('ingresos') }}</th><th>{{ i18n.t('ticket_promedio') }}</th><th>{{ i18n.t('geo_business_vendedores') }}</th><th>{{ i18n.t('geo_business_porcentaje_total') }}</th></tr></thead>
              <tbody>
                <tr v-for="u in locSummary" :key="u.id">
                  <td><strong>{{ u.nombre }}</strong><div class="text-xs-muted">{{ u.direccion||'' }}</div></td>
                  <td>{{ u.cantidad_ventas }}</td>
                  <td style="font-weight:700;">{{ fm(u.total_ventas) }}</td>
                  <td>{{ fm(u.ticket_promedio || (u.cantidad_ventas > 0 ? u.total_ventas / u.cantidad_ventas : 0)) }}</td>
                  <td>{{ u.vendedores || 0 }}</td>
                  <td><div class="geo-pct-bar"><div class="geo-pct-track"><div :style="{width:u.porcentaje+'%'}" class="geo-pct-fill"></div></div><span class="text-xs">{{ u.porcentaje }}%</span></div></td>
                </tr>
                <tr v-if="!locSummary.length"><td colspan="6" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- TAB 3: Movimientos -->
    <div v-if="activeTab==='movimientos'" class="tab-panel">
      <div class="flex items-center gap-sm mb-md">
        <select v-model="filtroMovTipo" class="form-control geo-mov-select" @change="cargarMovimientos">
          <option value="">{{ i18n.t('geo_business_todos_tipos') }}</option>
          <option value="entrada">{{ i18n.t('geo_business_entrada') }}</option>
          <option value="salida">{{ i18n.t('geo_business_salida') }}</option>
        </select>
        <button class="btn btn-ghost btn-sm btn-mobile-min" @click="cargarMovimientos"><i class="fas fa-sync-alt"></i></button>
      </div>
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-exchange-alt"></i> {{ i18n.t('geo_business_movimientos_inventario') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('geo_business_fecha') }}</th><th>{{ i18n.t('geo_business_producto_col') }}</th><th>{{ i18n.t('geo_business_tipo_col') }}</th><th>{{ i18n.t('geo_business_cantidad') }}</th><th>{{ i18n.t('geo_business_stock_anterior') }}</th><th>{{ i18n.t('geo_business_stock_nuevo') }}</th><th>{{ i18n.t('geo_business_referencia') }}</th><th>{{ i18n.t('geo_business_usuario_col') }}</th></tr></thead>
              <tbody>
                <tr v-for="m in movimientos.data" :key="m.id">
                  <td>{{ formatDate(m.fecha) }}</td>
                  <td><strong>{{ m.producto }}</strong><div class="text-xs-muted">{{ m.codigo||'' }}</div></td>
                  <td><span :class="['badge', m.tipo==='entrada'?'badge-success':'badge-danger']">{{ m.tipo }}</span></td>
                  <td>{{ m.cantidad }}</td>
                  <td>{{ m.stock_anterior }}</td>
                  <td>{{ m.stock_nuevo }}</td>
                  <td><span class="badge badge-secondary">{{ m.referencia_tipo||'-' }}</span></td>
                  <td>{{ m.usuario||'-' }}</td>
                </tr>
                <tr v-if="!movimientos.data?.length"><td colspan="8" class="empty-state-cell">{{ i18n.t('geo_business_no_movimientos') }}</td></tr>
              </tbody>
            </table>
          </div>
          <div v-if="movimientos.last_page > 1" class="flex justify-center gap-sm p-md">
            <button class="btn btn-sm btn-ghost btn-mobile-min" :disabled="movimientos.current_page===1" @click="cambiarPagina(movimientos.current_page-1)">{{ i18n.t('anterior') }}</button>
            <span class="text-sm-muted" style="padding:6px 0;">{{ i18n.tp('pagina_de', { n: movimientos.current_page, total: movimientos.last_page }) }}</span>
            <button class="btn btn-sm btn-ghost btn-mobile-min" :disabled="movimientos.current_page===movimientos.last_page" @click="cambiarPagina(movimientos.current_page+1)">{{ i18n.t('siguiente') }}</button>
          </div>
        </div>
      </div>
    </div>

    <!-- TAB 4: Rendimiento -->
    <div v-if="activeTab==='rendimiento'" class="tab-panel">
      <div class="grid-2 mb-lg geo-charts-grid">
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-trophy"></i> {{ i18n.t('geo_business_comparativa_ubicaciones') }}</h3></div>
          <div class="card-body"><canvas ref="chartCompareRef"></canvas></div>
        </div>
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-percentage"></i> {{ i18n.t('geo_business_distribucion_ingresos') }}</h3></div>
          <div class="card-body"><canvas ref="chartDoughnutRef"></canvas></div>
        </div>
      </div>
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-balance-scale"></i> {{ i18n.t('geo_business_metricas_detalladas') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('geo_business_ubicacion') }}</th><th>{{ i18n.t('geo_business_ventas') }}</th><th>{{ i18n.t('ingresos') }}</th><th>{{ i18n.t('geo_business_productos') }}</th><th>{{ i18n.t('geo_business_clientes') }}</th><th>{{ i18n.t('geo_business_vendedores') }}</th><th>{{ i18n.t('ticket_promedio') }}</th><th>% Ing.</th><th>% Vtas</th></tr></thead>
              <tbody>
                <tr v-for="u in comparativa.ubicaciones" :key="u.id">
                  <td><strong>{{ u.nombre }}</strong></td>
                  <td>{{ u.ventas }}</td>
                  <td style="font-weight:700;">{{ fm(u.ingresos) }}</td>
                  <td>{{ u.productos_vendidos }}</td>
                  <td>{{ u.clientes }}</td>
                  <td>{{ u.vendedores }}</td>
                  <td>{{ fm(u.ticket_promedio) }}</td>
                  <td>{{ u.porcentaje_ingresos }}%</td>
                  <td>{{ u.porcentaje_ventas }}%</td>
                </tr>
                <tr v-if="!comparativa.ubicaciones?.length"><td colspan="9" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <div class="card mt-lg">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-box"></i> {{ i18n.t('geo_business_productos_por_ubicacion') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('geo_business_producto_col') }}</th><th>{{ i18n.t('geo_business_ubicacion') }}</th><th>{{ i18n.t('geo_business_cantidad') }}</th><th>{{ i18n.t('geo_business_monto') }}</th></tr></thead>
              <tbody>
                <tr v-for="p in comparativa.productos_por_ubicacion" :key="p.producto_id+'-'+p.ubicacion_id">
                  <td><strong>{{ p.producto }}</strong></td>
                  <td>{{ p.ubicacion }}</td>
                  <td>{{ p.cantidad }}</td>
                  <td style="font-weight:700;">{{ fm(p.monto) }}</td>
                </tr>
                <tr v-if="!comparativa.productos_por_ubicacion?.length"><td colspan="4" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue';
import api from '../services/api';
import { useAuthStore } from '../stores/auth';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';
import Chart from 'chart.js/auto';

import {
  map as createLeafletMap,
  tileLayer as createTileLayer,
  layerGroup as createLayerGroup,
  circle as createCircle,
  circleMarker as createCircleMarker,
  divIcon as createDivIcon,
  marker as createMarker,
  control as leafletControl
} from 'leaflet';

import 'leaflet/dist/leaflet.css';

const i18n = useI18nStore();
const { fm, store: currencyStore } = useCurrency();
const authStore = useAuthStore();

const tabs = [
  { id: 'geo', label: 'GeoAnalytics', icon: 'fas fa-globe' },
  { id: 'ventas', label: i18n.t('geo_business_analisis_ventas'), icon: 'fas fa-chart-line' },
  { id: 'movimientos', label: i18n.t('movimientos') || 'Movimientos', icon: 'fas fa-exchange-alt' },
  { id: 'rendimiento', label: 'Rendimiento', icon: 'fas fa-trophy' }
];

const activeTab = ref('geo');
const statsExpanded = ref(false);

const periodoPreset = ref('30');

const filtros = ref({
  desde: '',
  hasta: '',
  ubicacion_id: '',
  producto_id: '',
  categoria_id: ''
});

const productoBuscar = ref('');
const productosOpts = ref([]);
const productosFiltrados = ref([]);
const productoSel = ref(null);
const filtroMovTipo = ref('');

const ubicacionesOpts = ref([]);
const categoriasOpts = ref([]);

const kpis = ref({});
const trend = ref([]);
const topProductos = ref([]);
const locSummary = ref([]);
const categoriasData = ref([]);
const tendencias = ref([]);
const comparativa = ref({
  ubicaciones: [],
  productos_por_ubicacion: []
});

const movimientos = ref({
  data: [],
  current_page: 1,
  last_page: 1
});

const productoAnalisis = ref({});
const showProductoModal = ref(false);
const cargando = ref(false);
const errores = ref([]);

const capa = ref('both');
const mapRef = ref(null);

let map = null;
let tileLayer = null;
let markersLayer = null;
let heatLayer = null;

const chartTrendRef = ref(null);
const chartPieRef = ref(null);
const chartBarRef = ref(null);
const chartTicketRef = ref(null);
const chartCompareRef = ref(null);
const chartDoughnutRef = ref(null);

let charts = {};

function aplicarPreset() {
  if (periodoPreset.value === 'custom') return;

  const d = new Date();
  d.setDate(d.getDate() - parseInt(periodoPreset.value));

  filtros.value.desde = d.toISOString().split('T')[0];
  filtros.value.hasta = new Date().toISOString().split('T')[0];

  cargarTodo();
}

async function cargarOpciones() {
  try {
    const [u, c, p] = await Promise.all([
      api.get('/configuracion/ubicaciones'),
      api.get('/configuracion/categorias'),
      api.get('/productos?limit=500')
    ]);

    ubicacionesOpts.value = u.data.ubicaciones || [];
    categoriasOpts.value = c.data.categorias || [];
    productosOpts.value = p.data.productos || [];
  } catch (e) {
    errores.value.push(
      'Opciones: ' +
        (e?.response?.data?.message || e.message || 'Error desconocido')
    );
    console.error(e);
  }
}

function filtrarProductos() {
  const q = productoBuscar.value.toLowerCase();

  productosFiltrados.value = (productosOpts.value || [])
    .filter((p) => (p.nombre || '').toLowerCase().includes(q))
    .slice(0, 10);
}

function seleccionarProducto(p) {
  filtros.value.producto_id = p.id;
  productoSel.value = p;
  productoBuscar.value = '';
  productosFiltrados.value = [];

  cargarTodo();
}

function limpiarProducto() {
  filtros.value.producto_id = '';
  productoSel.value = null;

  cargarTodo();
}

async function cargarDashboard() {
  try {
    const params = { ...filtros.value };

    console.log('[GeoBusiness] cargarDashboard params', params);

    const { data } = await api.get('/reportes/geo-dashboard', { params });

    console.log('[GeoBusiness] cargarDashboard OK', data);

    kpis.value = data.kpis || {};
    topProductos.value = data.top_productos || [];

    locSummary.value = (data.ubicaciones || []).map((u) => {
      u.ticket_promedio =
        u.cantidad_ventas > 0
          ? u.total_ventas / u.cantidad_ventas
          : 0;

      return u;
    });

    categoriasData.value = data.categorias || [];

    const totalGen = locSummary.value.reduce(
      (s, u) => s + Number(u.total_ventas || 0),
      0
    );

    locSummary.value.forEach((u) => {
      u.porcentaje =
        totalGen > 0
          ? Math.round((Number(u.total_ventas || 0) / totalGen) * 100)
          : 0;
    });

    nextTick(() => renderCharts());
  } catch (e) {
    const msg = e?.response?.data?.message || e.message || 'Error desconocido';

    console.error('[GeoBusiness] cargarDashboard ERROR', e);
    errores.value.push('Dashboard: ' + msg);
  }
}

async function cargarTendencias() {
  try {
    const params = { ...filtros.value };

    console.log('[GeoBusiness] cargarTendencias params', params);

    const { data } = await api.get('/reportes/geo-tendencias', { params });

    console.log('[GeoBusiness] cargarTendencias OK', data);

    tendencias.value = data.tendencias || [];
    trend.value = data.tendencias || [];

    nextTick(() => renderCharts());
  } catch (e) {
    const msg = e?.response?.data?.message || e.message || 'Error desconocido';

    console.error('[GeoBusiness] cargarTendencias ERROR', e);
    errores.value.push('Tendencias: ' + msg);
  }
}

async function cargarComparativa() {
  try {
    const params = { ...filtros.value };

    console.log('[GeoBusiness] cargarComparativa params', params);

    const { data } = await api.get('/reportes/geo-comparativa', { params });

    console.log('[GeoBusiness] cargarComparativa OK', data);

    comparativa.value = data || {
      ubicaciones: [],
      productos_por_ubicacion: []
    };

    nextTick(() => renderCharts());
  } catch (e) {
    const msg = e?.response?.data?.message || e.message || 'Error desconocido';

    console.error('[GeoBusiness] cargarComparativa ERROR', e);
    errores.value.push('Comparativa: ' + msg);
  }
}

async function cargarMovimientos(page = 1) {
  try {
    const params = { ...filtros.value, page };

    if (filtroMovTipo.value) {
      params.tipo = filtroMovTipo.value;
    }

    console.log('[GeoBusiness] cargarMovimientos params', params);

    const { data } = await api.get('/reportes/geo-movimientos', { params });

    console.log('[GeoBusiness] cargarMovimientos OK', data);

    movimientos.value =
      data.movimientos || {
        data: [],
        current_page: 1,
        last_page: 1
      };
  } catch (e) {
    const msg = e?.response?.data?.message || e.message || 'Error desconocido';

    console.error('[GeoBusiness] cargarMovimientos ERROR', e);
    errores.value.push('Movimientos: ' + msg);
  }
}

async function cargarMapa() {
  try {
    const params = {
      desde: filtros.value.desde,
      hasta: filtros.value.hasta
    };

    if (filtros.value.producto_id) {
      params.producto_id = filtros.value.producto_id;
    }

    console.log('[GeoBusiness] cargarMapa params', params);

    const { data } = await api.get('/reportes/ventas-geo', { params });

    console.log('[GeoBusiness] cargarMapa OK', data);

    renderMap(data.ubicaciones || [], data.heatmap || []);
  } catch (e) {
    const msg = e?.response?.data?.message || e.message || 'Error desconocido';

    console.error('[GeoBusiness] cargarMapa ERROR', e);
    errores.value.push('Mapa: ' + msg);
  }
}

async function cargarProductoAnalisis() {
  if (!filtros.value.producto_id) return;

  try {
    const params = { ...filtros.value };

    const { data } = await api.get('/reportes/geo-producto', { params });

    productoAnalisis.value = data || {};
    showProductoModal.value = true;
  } catch (e) {
    errores.value.push(
      'Producto: ' +
        (e?.response?.data?.message || e.message || 'Error desconocido')
    );
    console.error(e);
  }
}

async function cargarTodo() {
  cargando.value = true;

  console.log('[GeoBusiness] cargarTodo iniciado');

  try {
    await Promise.all([
      cargarDashboard(),
      cargarTendencias(),
      cargarComparativa(),
      cargarMovimientos(1),
      cargarMapa()
    ]);

    console.log('[GeoBusiness] cargarTodo completado');
  } catch (e) {
    errores.value.push('General: ' + (e?.message || 'Error desconocido'));
    console.error('[GeoBusiness] cargarTodo ERROR', e);
  } finally {
    cargando.value = false;
    console.log('[GeoBusiness] cargando = false');
  }
}

function cambiarPagina(page) {
  cargarMovimientos(page);
}

function renderMap(ubs, heatData) {
  if (!mapRef.value) return;

  if (!map) {
    map = createLeafletMap(mapRef.value, {
      zoomControl: false
    }).setView([9.7, -84.0], 8);

    leafletControl.zoom({
      position: 'bottomright'
    }).addTo(map);

    updateTileLayer();
  }

  limpiarCapasMapa();

  const isProductoMode =
    filtros.value.producto_id &&
    ubs.length &&
    ubs[0].cantidad_producto !== undefined;

  const markerGroup = [];

  if (capa.value === 'markers' || capa.value === 'both') {
    markersLayer = createLayerGroup().addTo(map);

    if (isProductoMode) {
      renderProductoMarkers(ubs, markerGroup);
    } else {
      renderVentasMarkers(ubs, markerGroup);
    }
  }

  if ((capa.value === 'heatmap' || capa.value === 'both') && heatData.length) {
    renderHeatmapSinPlugin(heatData, isProductoMode);
  }

  if (markerGroup.length) {
    map.fitBounds(markerGroup, {
      padding: [40, 40],
      maxZoom: 14
    });
  } else {
    map.setView([9.7, -84.0], 8);
  }
}

function limpiarCapasMapa() {
  if (markersLayer) {
    map.removeLayer(markersLayer);
    markersLayer = null;
  }

  if (heatLayer) {
    map.removeLayer(heatLayer);
    heatLayer = null;
  }
}

function renderProductoMarkers(ubs, markerGroup) {
  const maxCantidad = Math.max(
    ...ubs.map((u) => u.cantidad_producto || 0),
    1
  );

  const productoNombre =
    productoSel.value?.nombre || i18n.t('geo_business_producto');

  ubs.forEach((u) => {
    if (!u.lat || !u.lng) return;

    const cantidad = u.cantidad_producto || 0;
    const monto = u.monto_producto || 0;

    if (cantidad <= 0) return;

    const pct = cantidad / maxCantidad;

    let color = '#ef4444';
    let fillOpacity = 0.35;

    if (pct >= 0.7) {
      color = '#10b981';
      fillOpacity = 0.55;
    } else if (pct >= 0.3) {
      color = '#f59e0b';
      fillOpacity = 0.45;
    }

    const radiusMeters = 1500 + pct * 6500;
    const pulseClass = pct >= 0.7 ? 'pulse-circle' : '';

    const circle = createCircle([Number(u.lat), Number(u.lng)], {
      radius: radiusMeters,
      color,
      weight: 2,
      fillColor: color,
      fillOpacity,
      className: pulseClass
    }).addTo(markersLayer);

    circle.bindPopup(`
      <div style="min-width:200px;">
        <strong style="color:${color};">${u.nombre}</strong><br/>
        <span style="font-size:12px;color:#666;">${u.direccion || ''}</span><br/>
        <hr style="margin:6px 0;border:0;border-top:1px solid #eee;"/>
        <b>${i18n.t('geo_business_producto')}:</b> ${productoNombre}<br/>
        <b>${i18n.t('cantidad')}:</b> ${cantidad} uds<br/>
        <b>${i18n.t('geo_business_monto')}:</b> ${fm(monto)}<br/>
        <b>%:</b> ${Math.round(pct * 100)}%
      </div>
    `);

    markerGroup.push([Number(u.lat), Number(u.lng)]);
  });

  const topUb = ubs.reduce(
    (a, b) =>
      (a.cantidad_producto || 0) > (b.cantidad_producto || 0)
        ? a
        : b,
    ubs[0]
  );

  if (topUb && topUb.cantidad_producto > 0 && topUb.lat && topUb.lng) {
    const starIcon = createDivIcon({
      className: 'geo-marker-star',
      html: `
        <div style="
          width:28px;
          height:28px;
          background:#ffd700;
          border:3px solid #fff;
          border-radius:50%;
          display:flex;
          align-items:center;
          justify-content:center;
          box-shadow:0 0 10px rgba(255,215,0,0.6);
          animation:pulse-star 1.5s infinite;
        ">
          <i class="fas fa-star" style="color:#fff;font-size:12px;"></i>
        </div>
      `,
      iconSize: [28, 28],
      iconAnchor: [14, 14]
    });

    const starMarker = createMarker([Number(topUb.lat), Number(topUb.lng)], {
      icon: starIcon,
      zIndexOffset: 1000
    }).addTo(markersLayer);

    starMarker.bindPopup(`
      <div style="min-width:200px;">
        <strong style="color:#ffd700;">${topUb.nombre}</strong><br/>
        <b>${productoNombre}:</b> ${topUb.cantidad_producto} uds<br/>
        <b>${i18n.t('geo_business_monto')}:</b> ${fm(topUb.monto_producto)}
      </div>
    `);

    markerGroup.push([Number(topUb.lat), Number(topUb.lng)]);
  }
}

function renderVentasMarkers(ubs, markerGroup) {
  const maxVentas = Math.max(
    ...ubs.map((u) => u.total_ventas || 0),
    1
  );

  ubs.forEach((u) => {
    if (!u.lat || !u.lng) return;

    const pct = (u.total_ventas || 0) / maxVentas;

    let color = '#ef4444';

    if (pct >= 0.7) {
      color = '#10b981';
    } else if (pct >= 0.3) {
      color = '#f59e0b';
    }

    const iconHtml = `
      <div style="
        width:18px;
        height:18px;
        background:${color};
        border:2px solid #fff;
        border-radius:50%;
        box-shadow:0 0 0 2px ${color}80;
        transform:translate(-50%,-50%);
      "></div>
    `;

    const customIcon = createDivIcon({
      className: 'geo-marker',
      html: iconHtml,
      iconSize: [18, 18],
      iconAnchor: [9, 9]
    });

    const marker = createMarker([Number(u.lat), Number(u.lng)], {
      icon: customIcon
    }).addTo(markersLayer);

    marker.bindPopup(`
      <div style="min-width:180px;">
        <strong>${u.nombre}</strong><br/>
        <span style="font-size:12px;color:#666;">${u.direccion || ''}</span><br/>
        <hr style="margin:6px 0;border:0;border-top:1px solid #eee;"/>
        <b>${i18n.t('geo_business_ventas')}:</b> ${u.cantidad_ventas || 0}<br/>
        <b>${i18n.t('total')}:</b> ${fm(u.total_ventas)}<br/>
        <b>${i18n.t('ticket_promedio')}:</b> ${fm(u.ticket_promedio || 0)}
      </div>
    `);

    markerGroup.push([Number(u.lat), Number(u.lng)]);
  });
}

function renderHeatmapSinPlugin(heatData, isProductoMode) {
  heatLayer = createLayerGroup().addTo(map);

  const divisor = isProductoMode ? 50 : 50000;

  heatData.forEach((p) => {
    const lat = Number(p[0]);
    const lng = Number(p[1]);
    const valor = Number(p[2] || 0);

    if (!lat || !lng) return;

    const intensidad = Math.min(valor / divisor, 1);

    let color = '#ef4444';

    if (intensidad >= 0.7) {
      color = '#10b981';
    } else if (intensidad >= 0.3) {
      color = '#f59e0b';
    }

    createCircleMarker([lat, lng], {
      radius: 12 + intensidad * 28,
      color,
      weight: 1,
      fillColor: color,
      fillOpacity: 0.2 + intensidad * 0.45
    }).addTo(heatLayer);
  });
}

function isDark() {
  return (
    authStore.theme === 'dark' ||
    document.documentElement.dataset.theme === 'dark'
  );
}

function updateTileLayer() {
  if (!map) return;

  if (tileLayer) {
    map.removeLayer(tileLayer);
    tileLayer = null;
  }

  const dark = isDark();

  tileLayer = createTileLayer(
    dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    {
      attribution: dark
        ? '&copy; OpenStreetMap &copy; CARTO'
        : '&copy; OpenStreetMap contributors',
      subdomains: dark ? 'abcd' : 'abc',
      maxZoom: dark ? 19 : 18
    }
  ).addTo(map);
}

function destroyCharts() {
  Object.values(charts).forEach((c) => {
    if (c) c.destroy();
  });

  charts = {};
}

function renderCharts() {
  try {
    destroyCharts();

    const dark = isDark();
    const textColor = dark ? '#e2e8f0' : '#475569';
    const gridColor = dark
      ? 'rgba(255,255,255,0.08)'
      : 'rgba(0,0,0,0.06)';

    if (chartTrendRef.value && trend.value.length) {
      charts.trend = new Chart(chartTrendRef.value, {
        type: 'line',
        data: {
          labels: trend.value.map((t) => t.fecha_label),
          datasets: [
            {
              label: i18n.t('geo_business_ventas'),
              data: trend.value.map((t) => t.ventas),
              borderColor: '#2a9df4',
              backgroundColor: 'rgba(42,157,244,0.15)',
              fill: true,
              tension: 0.4,
              pointRadius: 3
            },
            {
              label: i18n.t('ingresos'),
              data: trend.value.map((t) => t.ingresos / 1000),
              borderColor: '#ffd700',
              backgroundColor: 'rgba(255,215,0,0.15)',
              fill: true,
              tension: 0.4,
              pointRadius: 3,
              yAxisID: 'y1'
            }
          ]
        },
        options: {
          responsive: true,
          interaction: {
            mode: 'index',
            intersect: false
          },
          plugins: {
            legend: {
              labels: {
                color: textColor
              }
            }
          },
          scales: {
            x: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            },
            y: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            },
            y1: {
              position: 'right',
              ticks: {
                color: textColor
              },
              grid: {
                display: false
              }
            }
          }
        }
      });
    }

    if (chartPieRef.value && categoriasData.value.length) {
      charts.pie = new Chart(chartPieRef.value, {
        type: 'doughnut',
        data: {
          labels: categoriasData.value.map((c) => c.categoria),
          datasets: [
            {
              data: categoriasData.value.map((c) => c.monto),
              backgroundColor: [
                '#2a9df4',
                '#ffd700',
                '#10b981',
                '#ef4444',
                '#f59e0b',
                '#8b5cf6',
                '#ec4899'
              ],
              borderWidth: 0
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              position: 'right',
              labels: {
                color: textColor
              }
            }
          }
        }
      });
    }

    if (chartBarRef.value && locSummary.value.length) {
      charts.bar = new Chart(chartBarRef.value, {
        type: 'bar',
        data: {
          labels: locSummary.value.map((u) => u.nombre),
          datasets: [
            {
              label: `${i18n.t('ingresos')} (${currencyStore.simbolo})`,
              data: locSummary.value.map((u) => u.total_ventas),
              backgroundColor: '#2a9df4',
              borderRadius: 6
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              labels: {
                color: textColor
              }
            }
          },
          scales: {
            x: {
              ticks: {
                color: textColor
              },
              grid: {
                display: false
              }
            },
            y: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            }
          }
        }
      });
    }

    if (chartTicketRef.value && tendencias.value.length) {
      charts.ticket = new Chart(chartTicketRef.value, {
        type: 'line',
        data: {
          labels: tendencias.value.map((t) => t.fecha_label),
          datasets: [
            {
              label: i18n.t('ticket_promedio'),
              data: tendencias.value.map((t) => t.ticket_promedio),
              borderColor: '#10b981',
              backgroundColor: 'rgba(16,185,129,0.15)',
              fill: true,
              tension: 0.4,
              pointRadius: 3
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              labels: {
                color: textColor
              }
            }
          },
          scales: {
            x: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            },
            y: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            }
          }
        }
      });
    }

    if (chartCompareRef.value && comparativa.value.ubicaciones?.length) {
      charts.compare = new Chart(chartCompareRef.value, {
        type: 'bar',
        data: {
          labels: comparativa.value.ubicaciones.map((u) => u.nombre),
          datasets: [
            {
              label: i18n.t('geo_business_ventas'),
              data: comparativa.value.ubicaciones.map((u) => u.ventas),
              backgroundColor: '#2a9df4',
              borderRadius: 6
            },
            {
              label: `${i18n.t('ingresos')} (${currencyStore.simbolo}/1000)`,
              data: comparativa.value.ubicaciones.map((u) => u.ingresos / 1000),
              backgroundColor: '#ffd700',
              borderRadius: 6
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              labels: {
                color: textColor
              }
            }
          },
          scales: {
            x: {
              ticks: {
                color: textColor
              },
              grid: {
                display: false
              }
            },
            y: {
              ticks: {
                color: textColor
              },
              grid: {
                color: gridColor
              }
            }
          }
        }
      });
    }

    if (chartDoughnutRef.value && comparativa.value.ubicaciones?.length) {
      charts.doughnut = new Chart(chartDoughnutRef.value, {
        type: 'doughnut',
        data: {
          labels: comparativa.value.ubicaciones.map((u) => u.nombre),
          datasets: [
            {
              data: comparativa.value.ubicaciones.map((u) => u.ingresos),
              backgroundColor: [
                '#2a9df4',
                '#ffd700',
                '#10b981',
                '#ef4444',
                '#f59e0b',
                '#8b5cf6'
              ],
              borderWidth: 0
            }
          ]
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              position: 'right',
              labels: {
                color: textColor
              }
            }
          }
        }
      });
    }
  } catch (e) {
    errores.value.push('Charts: ' + (e?.message || 'Error desconocido'));
    console.error(e);
  }
}

function badgeRendimiento(r) {
  const val = String(r || '').toLowerCase();

  if (val === 'alto') return 'badge-success';
  if (val === 'medio') return 'badge-warning';

  return 'badge-danger';
}

function formatDate(d) {
  if (!d) return '-';

  return new Date(d).toLocaleDateString('es-CR');
}

function exportCSV(type) {
  let csv = '';

  if (type === 'dashboard') {
    csv = `${i18n.t('geo_business_ubicacion')},${i18n.t('geo_business_ventas')},${i18n.t('ingresos')},${i18n.t('ticket_promedio')}\n`;

    locSummary.value.forEach((u) => {
      csv += `"${u.nombre}",${u.cantidad_ventas},${u.total_ventas},${u.ticket_promedio}\n`;
    });
  }

  const blob = new Blob([csv], {
    type: 'text/csv'
  });

  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');

  a.href = url;
  a.download = `geobusiness-${type}-${new Date().toISOString().split('T')[0]}.csv`;
  a.click();

  URL.revokeObjectURL(url);
}

function exportPrint() {
  window.print();
}

watch(activeTab, (tab) => {
  if (tab === 'geo' && map) {
    nextTick(() => {
      map.invalidateSize();
    });
  }

  setTimeout(() => {
    renderCharts();
  }, 50);

  if (tab === 'movimientos') {
    cargarMovimientos(1);
  }
});

watch(
  () => authStore.theme,
  () => {
    if (map) {
      updateTileLayer();
      cargarMapa();
    }

    nextTick(() => renderCharts());
  }
);

watch(capa, () => {
  cargarMapa();
});

onMounted(() => {
  aplicarPreset();
  cargarOpciones();
});

onUnmounted(() => {
  destroyCharts();

  if (map) {
    limpiarCapasMapa();

    if (tileLayer) {
      map.removeLayer(tileLayer);
      tileLayer = null;
    }

    map.remove();
    map = null;
  }
});
</script>

<style scoped>
#geo-map { width: 100%; height: 520px; border-radius: 0 0 var(--radius-xl) var(--radius-xl); }
:deep(.leaflet-popup-content-wrapper) { border-radius: 8px; background: var(--bg-card); color: var(--text-primary); }
:deep(.leaflet-popup-tip) { background: var(--bg-card); }
:deep(.leaflet-container) { background: var(--bg-hover); font-family: var(--font-main); }
:deep(.leaflet-control-zoom a) { background: var(--bg-card) !important; color: var(--text-primary) !important; border-color: var(--bg-hover) !important; }
:deep(.leaflet-control-attribution) { background: var(--bg-card) !important; color: var(--text-muted) !important; }
:deep(.leaflet-control-attribution a) { color: var(--text-secondary) !important; }
:deep(.geo-marker) { background: transparent !important; border: none !important; }
:deep(.geo-marker-star) { background: transparent !important; border: none !important; }
:deep(.pulse-circle) { animation: pulse-ring 2s infinite; }
@keyframes pulse-ring {
  0% { stroke-width: 2; stroke-opacity: 1; }
  50% { stroke-width: 6; stroke-opacity: 0.4; }
  100% { stroke-width: 2; stroke-opacity: 1; }
}
@keyframes pulse-star {
  0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255,215,0,0.6); }
  50% { transform: scale(1.15); box-shadow: 0 0 0 8px rgba(255,215,0,0); }
  100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(255,215,0,0); }
}

.tabs-bar { display:flex; gap:8px; border-bottom:1px solid var(--bg-hover); padding-bottom:8px; margin-bottom:16px; overflow-x: auto; -webkit-overflow-scrolling: touch; }
.tab-btn { background:transparent; border:none; padding:8px 16px; border-radius:var(--radius-md); color:var(--text-muted); cursor:pointer; font-size:14px; font-weight:500; display:flex; align-items:center; gap:6px; transition:all .2s; white-space: nowrap; min-height: 44px; }
.tab-btn:hover { color:var(--text-primary); background:var(--bg-hover); }
.tab-btn.active { color:var(--primary); background:var(--bg-hover); }

.tab-panel { display: block; }
.tab-panel canvas { min-height: 180px; max-height: 220px; }

/* Responsive helper classes */
.table-responsive { overflow-x: auto; -webkit-overflow-scrolling: touch; }
.text-xs { font-size: 12px; }
.text-xs-muted { font-size: 11px; color: var(--text-muted); }
.text-sm-muted { font-size: 13px; color: var(--text-muted); }
.empty-state-cell { text-align: center; color: var(--text-muted); padding: 30px; }
.btn-mobile-min { min-height: 44px; }

/* GeoBusiness-specific responsive styles */
.geo-filters-card { padding: 16px; }
.geo-filter-item { margin: 0; min-width: 140px; }
.geo-filter-label { font-size: 11px; color: var(--text-muted); margin-bottom: 4px; display: block; }
.geo-filter-ubicacion { min-width: 180px; }
.geo-filter-producto { min-width: 200px; position: relative; }
.geo-filter-categoria { min-width: 160px; }
.geo-producto-dropdown { position: absolute; z-index: 100; background: var(--bg-card); border: 1px solid var(--bg-hover); border-radius: 8px; max-height: 150px; overflow: auto; margin-top: 2px; min-width: 200px; }
.geo-producto-item { cursor: pointer; font-size: 13px; }
.geo-producto-badge { background: var(--bg-hover); padding: 6px 12px; border-radius: var(--radius-full); font-size: 13px; }
.geo-error-card { padding: 12px 16px; background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.3); }
.geo-error-item { color: #ef4444; font-size: 13px; margin-bottom: 4px; }
.geo-debug-card { padding: 8px 12px; background: rgba(42,157,244,0.08); border: 1px solid rgba(42,157,244,0.2); }
.geo-debug-text { font-size: 12px; color: var(--text-muted); }
.geo-compact-stats { padding: 12px 16px; }
.geo-compact-inner { }
.geo-compact-items { flex-wrap: wrap; }
.geo-stat-pill { background: var(--bg-hover); padding: 6px 12px; border-radius: var(--radius-full); }
.geo-stat-num { font-size: 13px; font-weight: 600; }
.geo-stat-label { font-size: 11px; color: var(--text-muted); }
.geo-expanded-grid { grid-template-columns: repeat(4, 1fr); }
.geo-map-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; }
.geo-map-title { margin: 0; }
.geo-map-legend { flex-wrap: wrap; }
.geo-legend { font-size: 12px; }
.geo-legend-item { padding: 3px 8px; border-radius: var(--radius-full); }
.geo-legend-alto { background: rgba(16,185,129,0.15); color: #10b981; }
.geo-legend-medio { background: rgba(245,158,11,0.15); color: #f59e0b; }
.geo-legend-bajo { background: rgba(239,68,68,0.15); color: #ef4444; }
.geo-legend-default { background: var(--bg-hover); color: var(--text-muted); }
.geo-legend-dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.geo-legend-dot-alto { background: #10b981; }
.geo-legend-dot-medio { background: #f59e0b; }
.geo-legend-dot-bajo { background: #ef4444; }
.geo-charts-grid { grid-template-columns: 1fr 1fr; }
.geo-tables-grid { grid-template-columns: 1fr 1fr; }
.geo-pct-bar { display: flex; align-items: center; gap: 8px; }
.geo-pct-track { flex: 1; background: var(--bg-hover); border-radius: 4px; height: 8px; }
.geo-pct-fill { height: 100%; background: var(--primary-gold); border-radius: 4px; }
.geo-mov-select { width: 160px; }

@media (max-width: 1023px) {
  .geo-charts-grid, .geo-tables-grid { grid-template-columns: 1fr; }
  .geo-expanded-grid { grid-template-columns: repeat(2, 1fr); }
  .geo-filter-item { min-width: 130px; }
  .geo-filter-ubicacion { min-width: 160px; }
  .geo-filter-producto { min-width: 180px; }
  .geo-filter-categoria { min-width: 140px; }
  .flex.geo-filters { flex-wrap: wrap; gap: 8px; }
}

@media (max-width: 768px) {
  .geo-header { flex-direction: column; align-items: stretch; }
  .geo-header-actions { justify-content: flex-end; flex-wrap: wrap; gap: 6px; }
  .geo-filters { flex-direction: column; gap: 8px; }
  .geo-filter-item {
    min-width: 100%;
    flex: 1 1 100%;
  }
  .geo-filter-ubicacion,
  .geo-filter-producto,
  .geo-filter-categoria { min-width: 100%; }
  .geo-filter-producto { position: static; }
  .geo-producto-dropdown {
    position: static;
    min-width: 100%;
    width: 100%;
  }
  .tabs-bar {
    overflow-x: auto;
    flex-wrap: nowrap;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
    padding: 0 4px;
  }
  .tabs-bar::-webkit-scrollbar { display: none; }
  #geo-map { height: 300px; }
  .geo-expanded-grid { grid-template-columns: repeat(2, 1fr); }
  .geo-compact-items { flex-direction: column; align-items: stretch; gap: 6px; }
  .geo-stat-pill { display: flex; justify-content: space-between; }
  .geo-map-header { flex-direction: column; align-items: flex-start; gap: 8px; }
  .geo-map-legend { flex-wrap: wrap; gap: 4px; }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 12px 16px;
  }
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  .btn-mobile-min { min-height: 44px; }
}

@media (max-width: 480px) {
  .geo-expanded-grid { grid-template-columns: 1fr; }
  .stat-value { font-size: clamp(16px, 4vw, 24px); }
  #geo-map { height: 250px; }
  .geo-tabs-bar { gap: 4px; }
  .tab-btn { padding: 8px 10px; font-size: 12px; min-height: 40px; }
  .geo-mov-select { width: 100%; }
  .geo-header-actions { flex-direction: column; gap: 6px; }
  .geo-header-actions .btn { width: 100%; }
  .geo-legend { font-size: 11px; flex-wrap: wrap; gap: 4px; }
  .geo-legend-item { font-size: 10px; padding: 2px 6px; }
}
</style>
