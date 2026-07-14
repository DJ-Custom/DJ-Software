<template>
  <div>
    <!-- Dashboard Stats -->
    <div class="grid-4 gap-md mb-lg">
      <div class="card stat-card" style="animation-delay:0.05s">
        <div class="stat-icon" style="background: rgba(59,130,246,0.12); color: #3b82f6;"><i class="fas fa-cubes"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.total_productos }}</div>
          <div class="stat-label">{{ i18n.t('catalogo_total_productos') }}</div>
        </div>
      </div>
      <div class="card stat-card" style="animation-delay:0.1s">
        <div class="stat-icon" style="background: rgba(16,185,129,0.12); color: #10b981;"><i class="fas fa-warehouse"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.stock_total }}</div>
          <div class="stat-label">{{ i18n.t('catalogo_stock_total') }}</div>
        </div>
      </div>
      <div class="card stat-card" style="animation-delay:0.15s">
        <div class="stat-icon" style="background: rgba(239,68,68,0.12); color: #ef4444;"><i class="fas fa-times-circle"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.productos_agotados }}</div>
          <div class="stat-label">{{ i18n.t('catalogo_productos_agotados') }}</div>
        </div>
      </div>
      <div class="card stat-card" style="animation-delay:0.2s">
        <div class="stat-icon" style="background: rgba(245,158,11,0.12); color: #f59e0b;"><i class="fas fa-exclamation-triangle"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.productos_bajo_stock }}</div>
          <div class="stat-label">{{ i18n.t('catalogo_stock_bajo') }}</div>
        </div>
      </div>
      <div class="card stat-card" style="animation-delay:0.25s">
        <div class="stat-icon" style="background: rgba(139,92,246,0.12); color: #8b5cf6;"><i class="fas fa-coins"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ formatMoney(stats.valor_inventario_venta) }}</div>
          <div class="stat-label">{{ i18n.t('sec_inventario') }} ({{ i18n.t('precio_venta') }})</div>
        </div>
      </div>
      <div class="card stat-card" style="animation-delay:0.3s">
        <div class="stat-icon" style="background: rgba(6,182,212,0.12); color: #06b6d4;"><i class="fas fa-chart-line"></i></div>
        <div class="stat-info">
          <div class="stat-value">{{ formatMoney(stats.valor_inventario_costo) }}</div>
          <div class="stat-label">{{ i18n.t('sec_inventario') }} ({{ i18n.t('costo') }})</div>
        </div>
      </div>
    </div>

    <!-- Top más vendidos -->
    <div v-if="masVendidos.length" class="card mb-lg">
      <div class="card-body" style="padding:16px 20px;">
        <div style="font-weight:700; font-size:14px; margin-bottom:12px;"><i class="fas fa-trophy" style="margin-right:6px; color:#f59e0b;"></i>{{ i18n.t('mas_vendidos_hoy') }} ({{ i18n.t('bi_ultimos_30_dias') }})</div>
        <div class="flex flex-wrap gap-md">
          <div v-for="(p, idx) in masVendidos" :key="p.id" class="top-seller-item">
            <div class="top-seller-rank">#{{ idx + 1 }}</div>
            <div class="top-seller-info">
              <div class="top-seller-name" :title="p.nombre">{{ p.nombre }}</div>
              <div class="top-seller-meta">{{ p.codigo || 'Sin código' }} — {{ p.total_vendido }} {{ i18n.t('ventas_label') }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Search & Filters Toolbar -->
    <div class="card mb-lg">
      <div class="card-body">
        <div class="flex flex-wrap gap-md items-end">
          <div class="form-group" style="min-width:200px; flex:1; max-width:100%;">
            <label class="form-label">{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label>
            <div class="input-icon-wrapper">
              <i class="fas fa-search"></i>
              <input v-model="filtros.q" type="text" class="form-control" :placeholder="i18n.t('buscar_productos')" @input="debounceCargar" style="padding-left:44px; width:100%; min-width:0;" />
            </div>
          </div>
          <div class="form-group" style="width:100%; max-width:160px; min-width:0;">
            <label class="form-label">{{ i18n.t('categoria') }}</label>
            <select v-model="filtros.categoria_id" class="form-control" @change="page=1; cargar()">
              <option value="">{{ i18n.t('todas_categorias') }}</option>
              <option v-for="c in opciones.categorias" :key="c.id" :value="c.id">{{ c.nombre }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:160px; min-width:0;">
            <label class="form-label">{{ i18n.t('proveedor') }}</label>
            <select v-model="filtros.proveedor_id" class="form-control" @change="page=1; cargar()">
              <option value="">{{ i18n.t('todos') }}</option>
              <option v-for="p in opciones.proveedores" :key="p.id" :value="p.id">{{ p.nombre }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:160px; min-width:0;">
            <label class="form-label">{{ i18n.t('ubicacion') }}</label>
            <select v-model="filtros.ubicacion_id" class="form-control" @change="page=1; cargar(); cargarStats()">
              <option value="">{{ i18n.t('todas_categorias') }}</option>
              <option v-for="u in opciones.ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:160px; min-width:0;">
            <label class="form-label">{{ i18n.t('inventario_ubicacion_disponible') }}</label>
            <select v-model="filtros.disponibilidad" class="form-control" @change="page=1; cargar()">
              <option value="">{{ i18n.t('todas_categorias') }}</option>
              <option value="disponible">{{ i18n.t('inventario_ubicacion_disponible') }}</option>
              <option value="stock_bajo">{{ i18n.t('bajo_stock') }}</option>
              <option value="agotados">{{ i18n.t('sin_stock') }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:120px; min-width:0;">
            <label class="form-label">{{ i18n.t('precio') }} {{ i18n.t('min') }}</label>
            <input v-model.number="filtros.precio_min" type="number" class="form-control" placeholder="0" @change="page=1; cargar()" />
          </div>
          <div class="form-group" style="width:100%; max-width:120px; min-width:0;">
            <label class="form-label">{{ i18n.t('precio') }} {{ i18n.t('max') }}</label>
            <input v-model.number="filtros.precio_max" type="number" class="form-control" placeholder="0" @change="page=1; cargar()" />
          </div>
        </div>
        <div class="flex flex-wrap gap-md items-end mt-md">
          <div class="form-group" style="width:100%; max-width:120px; min-width:0;">
            <label class="form-label">{{ i18n.t('margen_ganancia') }} {{ i18n.t('min') }} %</label>
            <input v-model.number="filtros.margen_min" type="number" class="form-control" placeholder="0" @change="page=1; cargar()" />
          </div>
          <div class="form-group" style="width:100%; max-width:120px; min-width:0;">
            <label class="form-label">{{ i18n.t('margen_ganancia') }} {{ i18n.t('max') }} %</label>
            <input v-model.number="filtros.margen_max" type="number" class="form-control" placeholder="0" @change="page=1; cargar()" />
          </div>
          <div class="form-group" style="width:100%; max-width:160px; min-width:0;">
            <label class="form-label">{{ i18n.t('filtrar') }}</label>
            <select v-model="filtros.order_by" class="form-control" @change="page=1; cargar()">
              <option value="nombre">{{ i18n.t('nombre') }}</option>
              <option value="codigo">{{ i18n.t('codigo') }}</option>
              <option value="precio_venta">{{ i18n.t('precio_venta') }}</option>
              <option value="precio_compra">{{ i18n.t('precio_compra') }}</option>
              <option value="stock">{{ i18n.t('stock') }}</option>
              <option value="categoria_nombre">{{ i18n.t('categoria') }}</option>
            </select>
          </div>
          <div class="form-group" style="width:100%; max-width:100px; min-width:0;">
            <label class="form-label">{{ i18n.t('direccion') }}</label>
            <select v-model="filtros.order_dir" class="form-control" @change="page=1; cargar()">
              <option value="asc">Asc</option>
              <option value="desc">Desc</option>
            </select>
          </div>
          <div class="flex gap-sm items-center" style="margin-bottom:20px;">
            <button class="btn btn-sm btn-ghost" :class="{ active: vista === 'tabla' }" @click="vista = 'tabla'" :title="i18n.t('ver')"><i class="fas fa-list"></i></button>
            <button class="btn btn-sm btn-ghost" :class="{ active: vista === 'cards' }" @click="vista = 'cards'" :title="i18n.t('ver')"><i class="fas fa-th-large"></i></button>
          </div>
          <button class="btn btn-secondary btn-sm" style="margin-bottom:20px;" @click="limpiarFiltros"><i class="fas fa-eraser"></i> {{ i18n.t('limpiar') }}</button>
        </div>
      </div>
    </div>

    <!-- Vista Tabla -->
    <div v-if="vista === 'tabla'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-boxes-stacked" style="margin-right:8px;"></i>{{ i18n.t('catalogo') }}</h3>
        <span class="badge badge-info">{{ total }} {{ i18n.t('productos') }}</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th style="width:50px;">Img</th>
                <th>{{ i18n.t('producto') }}</th>
                <th>{{ i18n.t('categoria') }}</th>
                <th>{{ i18n.t('proveedor') }}</th>
                <th>{{ i18n.t('precio_venta') }}</th>
                <th>{{ i18n.t('precio_compra') }}</th>
                <th>{{ i18n.t('margen_ganancia') }} %</th>
                <th>{{ i18n.t('inventario_ubicacion_disponible') }}</th>
                <th>{{ i18n.t('inventario_ubicacion_reservado') }}</th>
                <th>{{ i18n.t('estado') }}</th>
                <th style="width:60px;">{{ i18n.t('ver') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in productos" :key="p.id" class="animate-fade-in" style="cursor:pointer;" @click="verDetalle(p)">
                <td>
                  <div class="catalog-img-thumb">
                    <img v-if="p.imagen_principal" :src="p.imagen_principal" />
                    <i v-else class="fas fa-box" style="color:var(--text-muted);"></i>
                  </div>
                </td>
                <td>
                  <div style="font-weight:600;">{{ p.nombre }}</div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ p.codigo || 'Sin código' }}</div>
                </td>
                <td>{{ p.categoria_nombre || '-' }}</td>
                <td>{{ p.proveedor_nombre || '-' }}</td>
                <td style="font-weight:700;">{{ formatMoney(p.precio_venta) }}</td>
                <td>{{ formatMoney(p.precio_compra) }}</td>
                <td>
                  <span :style="{ color: colorMargen(p.margen_ganancia) }">{{ p.margen_ganancia ? p.margen_ganancia + '%' : '-' }}</span>
                </td>
                <td style="font-weight:700;">{{ p.stock_disponible }}</td>
                <td>{{ p.stock_reservado }}</td>
                <td>
                  <span :class="['badge', badgeEstado(p.estado_stock)]">
                    {{ textoEstado(p.estado_stock) }}
                  </span>
                </td>
                <td>
                  <button class="btn btn-sm btn-ghost" :title="i18n.t('ver_detalles')" @click.stop="verDetalle(p)"><i class="fas fa-eye"></i></button>
                </td>
              </tr>
              <tr v-if="!productos.length && !loading">
                <td colspan="11" style="text-align:center; padding:40px; color: var(--text-muted);">{{ i18n.t('catalogo_sin_datos') }}</td>
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

    <!-- Vista Cards -->
    <div v-else class="grid-4 gap-md">
      <div v-for="p in productos" :key="p.id" class="card catalog-card animate-fade-in" @click="verDetalle(p)">
        <div class="catalog-card-img">
          <img v-if="p.imagen_principal" :src="p.imagen_principal" />
          <div v-else class="catalog-card-placeholder"><i class="fas fa-box"></i></div>
          <span :class="['badge catalog-card-badge', badgeEstado(p.estado_stock)]">{{ textoEstado(p.estado_stock) }}</span>
        </div>
        <div class="catalog-card-body">
          <div class="catalog-card-title" :title="p.nombre">{{ p.nombre }}</div>
          <div class="catalog-card-meta">{{ p.codigo || i18n.t('sin_codigo') }} — {{ p.categoria_nombre || '-' }}</div>
          <div class="catalog-card-footer">
            <div class="catalog-card-price">{{ formatMoney(p.precio_venta) }}</div>
            <div class="catalog-card-stock" :style="{ color: colorStock(p.estado_stock) }">
              <i class="fas fa-cubes"></i> {{ p.stock_disponible }} {{ i18n.t('inventario_ubicacion_disponible') }}
            </div>
          </div>
        </div>
      </div>
      <div v-if="!productos.length && !loading" class="card" style="grid-column: 1 / -1; text-align:center; padding:60px; color:var(--text-muted);">
        <i class="fas fa-search" style="font-size:40px; margin-bottom:16px; opacity:0.4;"></i>
        <div>{{ i18n.t('catalogo_sin_datos') }}</div>
      </div>
    </div>

    <!-- Pagination for cards -->
    <div v-if="vista === 'cards' && pages > 1" class="flex justify-between items-center mt-lg">
      <span style="font-size:13px; color: var(--text-secondary);">{{ i18n.tp('pagina_de', { n: page, total: pages }) }}</span>
      <div class="flex gap-sm">
        <button class="btn btn-sm btn-secondary" :disabled="page <= 1" @click="page--; cargar()">{{ i18n.t('anterior') }}</button>
        <button class="btn btn-sm btn-secondary" :disabled="page >= pages" @click="page++; cargar()">{{ i18n.t('siguiente') }}</button>
      </div>
    </div>

    <!-- Modal Detalle Producto -->
    <div class="modal-overlay" :class="{ active: showDetalle }" @click.self="showDetalle = false">
      <div class="modal" style="max-width: min(90vw, 900px);">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-eye" style="margin-right:8px;"></i>{{ i18n.t('ver_detalles') }}</h3>
          <button class="modal-close" @click="showDetalle = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" v-if="detalle">
          <div class="grid-2 gap-md mb-md">
            <div>
              <div class="catalog-detail-img-wrapper">
                <img v-if="detalle.imagen_principal" :src="detalle.imagen_principal" />
                <div v-else class="catalog-detail-placeholder"><i class="fas fa-box"></i></div>
              </div>
            </div>
            <div>
              <div class="catalog-detail-name">{{ detalle.nombre }}</div>
              <div class="flex gap-sm mb-sm flex-wrap">
                <span class="badge badge-secondary">{{ detalle.codigo || 'Sin código' }}</span>
                <span v-if="detalle.codigo_barras" class="badge badge-info"><i class="fas fa-barcode"></i> {{ detalle.codigo_barras }}</span>
                <span :class="['badge', badgeEstado(detalle.estado_stock)]">{{ textoEstado(detalle.estado_stock) }}</span>
              </div>
              <div class="catalog-detail-row"><strong>{{ i18n.t('categoria') }}:</strong> {{ detalle.categoria?.nombre || '-' }}</div>
              <div class="catalog-detail-row"><strong>{{ i18n.t('proveedor') }}:</strong> {{ detalle.proveedor?.nombre || '-' }}</div>
              <div class="catalog-detail-row"><strong>{{ i18n.t('producto') }}:</strong> {{ detalle.unidad || '-' }}</div>
              <div class="catalog-detail-row"><strong>{{ i18n.t('ver') }}:</strong> {{ detalle.visible_web ? i18n.t('si') : i18n.t('no') }}</div>
              <div class="catalog-detail-row"><strong>{{ i18n.t('descripcion') }}:</strong> {{ detalle.descripcion || i18n.t('sin_descripcion') }}</div>
            </div>
          </div>

          <!-- Financiera -->
          <div class="card mb-md" style="background: var(--gradient-subtle);">
            <div class="card-body" style="padding:16px 20px;">
              <div style="font-weight:700; font-size:14px; margin-bottom:12px;"><i class="fas fa-chart-pie" style="margin-right:6px;"></i>{{ i18n.t('finanzas_contabilidad') }}</div>
              <div class="grid-4 gap-md">
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('precio_compra') }}</div>
                  <div style="font-size:18px; font-weight:700;">{{ formatMoney(detalle.precio_compra) }}</div>
                </div>
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('precio_venta') }}</div>
                  <div style="font-size:18px; font-weight:700;">{{ formatMoney(detalle.precio_venta) }}</div>
                </div>
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('margen_ganancia') }}</div>
                  <div style="font-size:18px; font-weight:700;" :style="{ color: colorMargen(detalle.margen_ganancia) }">{{ detalle.margen_ganancia ? detalle.margen_ganancia + '%' : '-' }}</div>
                </div>
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('utilidad') }}</div>
                  <div style="font-size:18px; font-weight:700;">{{ formatMoney(detalle.ganancia_estimada) }}</div>
                </div>
              </div>
              <div class="grid-3 gap-md mt-sm">
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('impuesto') }}</div>
                  <div style="font-weight:600;">{{ detalle.impuesto || 0 }}%</div>
                </div>
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('producto') }}</div>
                  <div style="font-weight:600;">{{ detalle.peso ? detalle.peso + ' kg' : '-' }}</div>
                </div>
                <div>
                  <div style="font-size:12px; color:var(--text-muted);">{{ i18n.t('stock_minimo') }}</div>
                  <div style="font-weight:600;">{{ detalle.stock_minimo ?? '-' }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Inventario por Ubicación -->
          <div class="card mb-md">
            <div class="card-body" style="padding:16px 20px;">
              <div style="font-weight:700; font-size:14px; margin-bottom:12px;"><i class="fas fa-warehouse" style="margin-right:6px;"></i>{{ i18n.t('inventario_ubicacion') }}</div>
              <div class="table-container">
                <table class="data-table" style="font-size:13px;">
                  <thead>
                    <tr><th>{{ i18n.t('inventario_ubicacion_ubicacion') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('inventario_ubicacion_reservado') }}</th><th>{{ i18n.t('inventario_ubicacion_disponible') }}</th><th>{{ i18n.t('inventario_ubicacion_minimo') }}</th><th>{{ i18n.t('inventario_ubicacion_maximo') }}</th><th>{{ i18n.t('estado') }}</th></tr>
                  </thead>
                  <tbody>
                    <tr v-for="iu in detalle.inventario_ubicaciones" :key="iu.id">
                      <td><strong>{{ iu.ubicacion?.nombre || iu.ubicacion_nombre }}</strong></td>
                      <td>{{ iu.cantidad }}</td>
                      <td>{{ iu.cantidad_reservada }}</td>
                      <td style="font-weight:700;">{{ iu.cantidad - iu.cantidad_reservada }}</td>
                      <td>{{ iu.stock_minimo ?? '-' }}</td>
                      <td>{{ iu.stock_maximo ?? '-' }}</td>
                      <td><span :class="['badge', badgeEstado(iu.estado_stock)]">{{ textoEstado(iu.estado_stock) }}</span></td>
                    </tr>
                    <tr v-if="!detalle.inventario_ubicaciones?.length">
                      <td colspan="7" style="text-align:center; padding:16px; color:var(--text-muted);">{{ i18n.t('sin_datos') }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div class="mt-sm" style="display:flex; gap:16px; flex-wrap:wrap; font-size:13px;">
                <span><strong>{{ i18n.t('total') }}:</strong> {{ detalle.stock_total }} {{ i18n.t('productos') }}</span>
                <span><strong>{{ i18n.t('inventario_ubicacion_reservado') }}:</strong> {{ detalle.stock_reservado }}</span>
                <span><strong>{{ i18n.t('inventario_ubicacion_disponible') }}:</strong> {{ detalle.stock_disponible }}</span>
              </div>
            </div>
          </div>

          <!-- Movimientos recientes -->
          <div class="card">
            <div class="card-body" style="padding:16px 20px;">
              <div style="font-weight:700; font-size:14px; margin-bottom:12px;"><i class="fas fa-history" style="margin-right:6px;"></i>{{ i18n.t('modificado') }}</div>
              <div class="table-container" style="max-height:300px;">
                <table class="data-table" style="font-size:13px;">
                  <thead>
                    <tr><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('contabilidad_tipo') }}</th><th>{{ i18n.t('ubicacion') }}</th><th>{{ i18n.t('cantidad') }}</th><th>{{ i18n.t('ajustes_stock_anterior') }}</th><th>{{ i18n.t('ajustes_stock_nuevo') }}</th><th>{{ i18n.t('referencia') }}</th></tr>
                  </thead>
                  <tbody>
                    <tr v-for="m in detalleMovimientos" :key="m.id">
                      <td style="white-space:nowrap;">{{ formatDateTime(m.created_at) }}</td>
                      <td><span :class="['badge', badgeTipoMovimiento(m.tipo)]">{{ m.tipo }}</span></td>
                      <td>
                        <span v-if="m.ubicacion_nombre">{{ m.ubicacion_nombre }}</span>
                        <span v-if="m.ubicacion_destino_nombre" style="color:var(--text-muted);">→ {{ m.ubicacion_destino_nombre }}</span>
                      </td>
                      <td style="font-weight:700;">{{ m.cantidad }}</td>
                      <td>{{ m.stock_anterior }}</td>
                      <td>{{ m.stock_nuevo }}</td>
                      <td style="color:var(--text-muted);">{{ m.referencia_tipo || '-' }}</td>
                    </tr>
                    <tr v-if="!detalleMovimientos.length">
                      <td colspan="7" style="text-align:center; padding:16px; color:var(--text-muted);">{{ i18n.t('sin_datos') }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, reactive } from 'vue';
import api from '../services/api';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm: formatMoney } = useCurrency();
const i18n = useI18nStore();

const productos = ref([]);
const total = ref(0);
const page = ref(1);
const pages = ref(1);
const loading = ref(false);
const vista = ref('tabla');

const filtros = reactive({
  q: '',
  categoria_id: '',
  proveedor_id: '',
  ubicacion_id: '',
  disponibilidad: '',
  precio_min: '',
  precio_max: '',
  margen_min: '',
  margen_max: '',
  order_by: 'nombre',
  order_dir: 'asc',
});

const opciones = reactive({
  categorias: [],
  ubicaciones: [],
  proveedores: [],
});

const stats = reactive({
  total_productos: 0,
  stock_total: 0,
  stock_reservado: 0,
  productos_agotados: 0,
  productos_bajo_stock: 0,
  valor_inventario_costo: 0,
  valor_inventario_venta: 0,
});

const showDetalle = ref(false);
const detalle = ref(null);
const detalleMovimientos = ref([]);
const masVendidos = ref([]);

let searchTimeout = null;
let pollInterval = null;

onMounted(() => {
  cargarOpciones();
  cargar();
  cargarStats();
  pollInterval = setInterval(() => { cargar(); cargarStats(); }, 30000);
});

onBeforeUnmount(() => {
  if (pollInterval) clearInterval(pollInterval);
});

async function cargar() {
  loading.value = true;
  try {
    const params = { page: page.value };
    Object.entries(filtros).forEach(([k, v]) => {
      if (v !== '' && v !== null && v !== undefined) params[k] = v;
    });
    const { data } = await api.get('/catalogo', { params });
    productos.value = data.productos;
    total.value = data.total;
    pages.value = data.pages;
  } catch (e) { console.error(e); }
  loading.value = false;
}

async function cargarStats() {
  try {
    const params = {};
    if (filtros.ubicacion_id) params.ubicacion_id = filtros.ubicacion_id;
    const { data } = await api.get('/catalogo/dashboard', { params });
    stats.total_productos = data.total_productos;
    stats.stock_total = data.stock_total;
    stats.stock_reservado = data.stock_reservado;
    stats.productos_agotados = data.productos_agotados;
    stats.productos_bajo_stock = data.productos_bajo_stock;
    stats.valor_inventario_costo = data.valor_inventario_costo;
    stats.valor_inventario_venta = data.valor_inventario_venta;
    masVendidos.value = data.productos_mas_vendidos || [];
  } catch (e) { console.error(e); }
}

async function cargarOpciones() {
  try {
    const { data } = await api.get('/catalogo/filtros');
    opciones.categorias = data.categorias || [];
    opciones.ubicaciones = data.ubicaciones || [];
    opciones.proveedores = data.proveedores || [];
  } catch (e) { console.error(e); }
}

function debounceCargar() {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => { page.value = 1; cargar(); }, 400);
}

function limpiarFiltros() {
  filtros.q = '';
  filtros.categoria_id = '';
  filtros.proveedor_id = '';
  filtros.ubicacion_id = '';
  filtros.disponibilidad = '';
  filtros.precio_min = '';
  filtros.precio_max = '';
  filtros.margen_min = '';
  filtros.margen_max = '';
  filtros.order_by = 'nombre';
  filtros.order_dir = 'asc';
  page.value = 1;
  cargar();
  cargarStats();
}

async function verDetalle(p) {
  showDetalle.value = true;
  detalle.value = null;
  detalleMovimientos.value = [];
  try {
    const params = {};
    if (filtros.ubicacion_id) params.ubicacion_id = filtros.ubicacion_id;
    const { data } = await api.get(`/catalogo/${p.id}`, { params });
    detalle.value = data.producto;
    detalleMovimientos.value = data.movimientos || [];
    if (detalle.value?.inventario_ubicaciones) {
      detalle.value.inventario_ubicaciones.forEach(iu => {
        const disp = Math.max(0, iu.cantidad - iu.cantidad_reservada);
        if (disp <= 0) iu.estado_stock = 'agotado';
        else if (iu.stock_minimo !== null && disp <= iu.stock_minimo) iu.estado_stock = 'bajo';
        else if (iu.stock_maximo !== null && disp >= iu.stock_maximo) iu.estado_stock = 'alto';
        else iu.estado_stock = 'medio';
      });
    }
  } catch (e) { console.error(e); }
}

function badgeEstado(estado) {
  return { agotado: 'badge-danger', bajo: 'badge-warning', medio: 'badge-info', alto: 'badge-success' }[estado] || 'badge-secondary';
}

function textoEstado(estado) {
  return { agotado: i18n.t('sin_stock'), bajo: i18n.t('bajo_stock'), medio: i18n.t('suficiente'), alto: i18n.t('activo') }[estado] || estado;
}

function colorStock(estado) {
  if (estado === 'agotado') return '#ef4444';
  if (estado === 'bajo') return '#f59e0b';
  return '#10b981';
}

function colorMargen(val) {
  if (!val) return 'var(--text-muted)';
  if (val < 10) return '#ef4444';
  if (val < 25) return '#f59e0b';
  return '#10b981';
}

function badgeTipoMovimiento(tipo) {
  return { entrada: 'badge-success', salida: 'badge-danger', transferencia: 'badge-info', ajuste: 'badge-warning' }[tipo] || 'badge-secondary';
}


function formatDateTime(d) {
  if (!d) return '-';
  return new Date(d).toLocaleString('es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.input-icon-wrapper { position: relative; }
.input-icon-wrapper i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 14px; }

.catalog-img-thumb { width: 40px; height: 40px; border-radius: 8px; background: var(--bg-hover); display: flex; align-items: center; justify-content: center; overflow: hidden; }
.catalog-img-thumb img { width: 100%; height: 100%; object-fit: cover; }

.catalog-card { cursor: pointer; transition: transform 0.25s ease, box-shadow 0.25s ease; overflow: hidden; }
.catalog-card:hover { transform: translateY(-6px); box-shadow: var(--shadow-lg); }
.catalog-card-img { height: 180px; background: var(--bg-hover); position: relative; overflow: hidden; display: flex; align-items: center; justify-content: center; }
.catalog-card-img img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease; }
.catalog-card:hover .catalog-card-img img { transform: scale(1.05); }
.catalog-card-placeholder { font-size: 48px; color: var(--text-muted); opacity: 0.5; }
.catalog-card-badge { position: absolute; top: 10px; right: 10px; font-size: 11px; }
.catalog-card-body { padding: 16px; }
.catalog-card-title { font-weight: 700; font-size: 15px; color: var(--text-primary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 4px; }
.catalog-card-meta { font-size: 12px; color: var(--text-muted); margin-bottom: 12px; }
.catalog-card-footer { display: flex; align-items: center; justify-content: space-between; }
.catalog-card-price { font-size: 16px; font-weight: 800; color: var(--text-primary); }
.catalog-card-stock { font-size: 12px; font-weight: 600; display: flex; align-items: center; gap: 4px; }

.catalog-detail-img-wrapper { width: 100%; height: 220px; border-radius: 12px; background: var(--bg-hover); display: flex; align-items: center; justify-content: center; overflow: hidden; }
.catalog-detail-img-wrapper img { width: 100%; height: 100%; object-fit: cover; }
.catalog-detail-placeholder { font-size: 64px; color: var(--text-muted); opacity: 0.4; }
.catalog-detail-name { font-size: 22px; font-weight: 800; margin-bottom: 10px; line-height: 1.2; }
.catalog-detail-row { font-size: 13px; color: var(--text-secondary); margin-bottom: 6px; }
.catalog-detail-row strong { color: var(--text-primary); }

.btn-ghost.active { background: var(--gradient-main); color: white; }

.top-seller-item { display: flex; align-items: center; gap: 10px; padding: 8px 12px; background: var(--bg-hover); border-radius: var(--radius-md); min-width: 200px; flex: 1; }
.top-seller-rank { width: 28px; height: 28px; border-radius: 50%; background: var(--gradient-main); color: white; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700; flex-shrink: 0; }
.top-seller-info { min-width: 0; }
.top-seller-name { font-weight: 600; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.top-seller-meta { font-size: 11px; color: var(--text-muted); }

@media (max-width: 1023px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .top-seller-item { min-width: 180px; }
  .flex.flex-wrap.gap-md.items-end {
    flex-wrap: wrap;
    gap: 8px;
  }
  .flex.flex-wrap.gap-md.items-end > .form-group {
    flex: 1 1 calc(50% - 8px);
    min-width: 0;
    max-width: 100% !important;
  }
}

@media (max-width: 768px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .catalog-card-img { height: 140px; }
  .top-seller-item { min-width: 160px; }
  .flex.flex-wrap.gap-md.items-end {
    flex-direction: column;
    gap: 8px;
  }
  .flex.flex-wrap.gap-md.items-end > .form-group {
    flex: 1 1 100%;
    min-width: 100%;
    max-width: 100% !important;
  }
  .flex.flex-wrap.gap-md.items-end > .form-group[style*="max-width"] {
    max-width: 100% !important;
  }
  /* Override ALL inline max-width styles for mobile */
  .form-group[style*="max-width: 160px"],
  .form-group[style*="max-width: 120px"],
  .form-group[style*="max-width: 100px"] {
    max-width: 100% !important;
    flex: 1 1 100%;
    min-width: 0;
  }
  .flex.flex-wrap.gap-md.items-end > .flex.gap-sm.items-center {
    flex: 1 1 100%;
    justify-content: flex-start;
  }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 700px; }
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
}

@media (max-width: 480px) {
  .grid-4 { grid-template-columns: 1fr; }
  .btn { min-height: 44px; width: 100%; font-size: 15px; }
  .catalog-card-img { height: 120px; }
  .top-seller-item { min-width: 140px; }
  .flex.flex-wrap.gap-md.items-end > .flex.gap-sm.items-center {
    flex-direction: column;
    gap: 8px;
  }
  .flex.flex-wrap.gap-md.items-end > .flex.gap-sm.items-center > .btn {
    width: 100%;
  }
  /* Stack filters vertically on small phones */
  .form-group[style*="max-width: 160px"],
  .form-group[style*="max-width: 120px"],
  .form-group[style*="max-width: 100px"] {
    flex: 1 1 100%;
  }
  .data-table thead { display: none; }
  .data-table tbody tr {
    display: flex; flex-direction: column; padding: 12px; margin: 8px;
    border: 1px solid var(--border); border-radius: 8px;
    background: var(--bg-card); gap: 4px;
  }
  .data-table tbody td {
    display: flex; justify-content: space-between; align-items: center;
    padding: 4px 0; font-size: 14px; white-space: normal; border: none;
  }
  .data-table tbody td::before {
    content: attr(data-label); font-weight: 600; color: var(--text-secondary); min-width: 40%;
  }
  .data-table { min-width: 100%; }
  .modal-body { overflow-y: auto; }
}
</style>
