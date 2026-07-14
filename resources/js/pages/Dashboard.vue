<template class="dashboard">
  <div>
    <!-- KPI Cards -->
    <div class="grid-4 mb-lg">
      <div class="stat-card animate-fade-in stagger-1" >
        <div class="stat-icon" style="background: rgba(16,185,129,0.15); color: var(--success);"><i class="fas fa-dollar-sign"></i></div>
        <div class="stat-value">{{ fm(stats.ventas_hoy?.total) }}</div>
        <div class="stat-label">{{ $t('ventas_hoy') }}</div>
        <div class="stat-change positive"><i class="fas fa-receipt"></i> {{ stats.ventas_hoy?.cantidad || 0 }} {{ i18n.t('ventas_label') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-2">
        <div class="stat-icon" style="background: rgba(59,130,246,0.15); color: var(--info);"><i class="fas fa-chart-line"></i></div>
        <div class="stat-value">{{ fm(stats.ventas_mes?.total) }}</div>
        <div class="stat-label">{{ $t('ventas_mes') }}</div>
        <div class="stat-change positive"><i class="fas fa-arrow-up"></i> {{ stats.ventas_mes?.cantidad || 0 }} {{ i18n.t('ventas_label') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-3" >
        <div class="stat-icon" style="background: rgba(245,158,11,0.15); color: var(--warning);"><i class="fas fa-boxes-stacked"></i></div>
        <div class="stat-value">{{ stats.productos_stock || 0 }}</div>
        <div class="stat-label">{{ i18n.t('productos_en_stock') }}</div>
        <div v-if="stats.bajos_stock > 0" class="stat-change negative"><i class="fas fa-exclamation-triangle"></i> {{ stats.bajos_stock }} {{ i18n.t('bajo_stock') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-4">
        <div class="stat-icon" style="background: rgba(0,107,179,0.15); color: var(--primary-gold);"><i class="fas fa-users"></i></div>
        <div class="stat-value">{{ stats.total_clientes || 0 }}</div>
        <div class="stat-label">{{ i18n.t('clientes_activos') }}</div>
        <div class="stat-change positive" v-if="stats.clientes_nuevos"><i class="fas fa-user-plus"></i> +{{ stats.clientes_nuevos }} nuevos</div>
      </div>
    </div>

    <!-- Segunda fila de KPIs -->
    <div class="grid-4 mb-lg">
      <div class="stat-card animate-fade-in stagger-1">
        <div class="stat-icon" style="background: rgba(100,204,204,0.15); color: #64cccc;"><i class="fas fa-receipt"></i></div>
        <div class="stat-value">{{ fm(stats.ticket_promedio_hoy) }}</div>
        <div class="stat-label">{{ $t('ticket_promedio') }}</div>
        <div class="stat-change positive" v-if="stats.ticket_promedio_mes"><i class="fas fa-chart-bar"></i> {{ fm(stats.ticket_promedio_mes) }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-2">
        <div class="stat-icon" style="background: rgba(76,175,80,0.15); color: #4caf50;"><i class="fas fa-coins"></i></div>
        <div class="stat-value">{{ fm(stats.margen_bruto) }}</div>
        <div class="stat-label">{{ i18n.t('margen_bruto') }}</div>
        <div class="stat-change positive" v-if="stats.ventas_mes?.total"><i class="fas fa-percentage"></i> {{ stats.ventas_mes.total > 0 ? Math.round((stats.margen_bruto / stats.ventas_mes.total) * 100) : 0 }}% {{ i18n.t('rentabilidad_pct_label') }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-3">
        <div class="stat-icon" style="background: rgba(156,39,176,0.15); color: #9c27b0;"><i class="fas fa-percentage"></i></div>
        <div class="stat-value" :class="stats.crecimiento_semanal >= 0 ? 'positive' : 'negative'">{{ stats.crecimiento_semanal >= 0 ? '+' : '' }}{{ stats.crecimiento_semanal }}%</div>
        <div class="stat-label">{{ i18n.t('crecimiento_semanal') }}</div>
        <div class="stat-change positive"><i class="fas fa-calendar-week"></i> {{ fm(stats.ventas_semana) }}</div>
      </div>
      <div class="stat-card animate-fade-in stagger-4">
        <div class="stat-icon" style="background: rgba(239,68,68,0.15); color: var(--danger);"><i class="fas fa-hand-holding-usd"></i></div>
        <div class="stat-value">{{ fm(stats.cuentas_por_cobrar) }}</div>
        <div class="stat-label">{{ $t('cuentas_cobrar') }}</div>
        <div class="stat-change negative" v-if="stats.cuentas_por_cobrar > 0"><i class="fas fa-exclamation-circle"></i> {{ i18n.t('pendiente') }}</div>
      </div>
    </div>

    <!-- Quick Access Modules -->
    <div v-for="section in moduleSections" :key="section.title" class="mb-lg animate-fade-in">
      <h3 style="margin-bottom:12px;font-size:14px;text-transform:uppercase;letter-spacing:1px;color:var(--text-secondary);font-weight:600;">{{ section.title }}</h3>
      <div class="dash-modules-grid">
        <router-link v-for="m in section.items" :key="m.route" :to="m.route" class="dash-module-card">
          <div class="dash-module-icon" :style="{background: m.bg, color: m.color}"><i :class="m.icon"></i></div>
          <div class="dash-module-info">
            <div class="dash-module-name">{{ m.name }}</div>
            <div class="dash-module-desc">{{ m.desc }}</div>
          </div>
        </router-link>
      </div>
    </div>

    <!-- KPIs de Inventario y Clientes -->
    <div class="grid-3 gap-lg mb-lg">
      <div class="card animate-fade-in">
        <div class="card-header flex justify-between items-center">
          <h3 class="card-title"><i class="fas fa-crown" style="margin-right:8px;color:var(--warning);"></i>{{ i18n.t('top_vendedor_mes') }}</h3>
        </div>
        <div class="card-body" style="text-align:center;padding:28px;">
          <div v-if="stats.top_vendedor" class="animate-fade-in">
            <div style="width:60px;height:60px;border-radius:50%;background:var(--gradient-main);display:flex;align-items:center;justify-content:center;margin:0 auto 12px;"><i class="fas fa-user-tie" style="font-size:24px;color:white;"></i></div>
            <div style="font-size:18px;font-weight:700;">{{ stats.top_vendedor.nombre }}</div>
            <div style="font-size:14px;color:var(--text-muted);margin-top:4px;">{{ stats.top_vendedor.ventas }} {{ i18n.t('ventas_label') }}</div>
            <div style="font-size:20px;font-weight:700;color:var(--success);margin-top:8px;">{{ fm(stats.top_vendedor.total) }}</div>
          </div>
          <div v-else style="color:var(--text-muted);padding:20px;">{{ i18n.t('sin_datos') }}</div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header flex justify-between items-center">
          <h3 class="card-title"><i class="fas fa-fire" style="margin-right:8px;color:var(--danger);"></i>{{ i18n.t('mas_vendidos_hoy') }}</h3>
        </div>
        <div class="card-body" style="padding:0;max-height:200px;overflow:auto;">
          <div class="table-responsive">
          <table class="data-table" style="font-size:13px;">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th style="text-align:right;">{{ i18n.t('uds') }}</th><th style="text-align:right;">{{ i18n.t('ingresos') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in stats.top_hoy" :key="p.nombre"><td>{{ p.nombre }}</td><td style="text-align:right;">{{ p.unidades }}</td><td style="text-align:right;">{{ fm(p.ingresos) }}</td></tr>
              <tr v-if="!stats.top_hoy?.length"><td colspan="3" style="text-align:center;color:var(--text-muted);padding:24px;">{{ i18n.t('sin_ventas_hoy') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header flex justify-between items-center">
          <h3 class="card-title"><i class="fas fa-box" style="margin-right:8px;color:var(--info);"></i>{{ i18n.t('resumen_inventario') }}</h3>
        </div>
        <div class="card-body" style="padding:20px;">
          <div class="flex justify-between mb-sm" style="padding:8px 0;border-bottom:1px solid var(--bg-hover);"><span style="color:var(--text-muted);">{{ i18n.t('valor_total') }}</span><strong>{{ fm(stats.valor_inventario) }}</strong></div>
          <div class="flex justify-between mb-sm" style="padding:8px 0;border-bottom:1px solid var(--bg-hover);"><span style="color:var(--text-muted);">{{ i18n.t('sin_movimiento_30d') }}</span><strong :style="{color: stats.sin_movimiento > 0 ? 'var(--warning)' : 'var(--success)'}">{{ stats.sin_movimiento }}</strong></div>
          <div class="flex justify-between mb-sm" style="padding:8px 0;border-bottom:1px solid var(--bg-hover);"><span style="color:var(--text-muted);">{{ i18n.t('clientes_recurrentes_label') }}</span><strong>{{ stats.clientes_recurrentes }}</strong></div>
          <div class="flex justify-between" style="padding:8px 0;"><span style="color:var(--text-muted);">{{ $t('compras') }}</span><strong>{{ fm(stats.compras_mes) }}</strong></div>
        </div>
      </div>
    </div>

    <!-- Recent Data -->
    <div class="grid-2 gap-lg">
      <div class="card animate-fade-in">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-clock" style="margin-right:8px;"></i>{{ i18n.t('ventas_recientes') }}</h3>
          <router-link to="/ventas" class="btn btn-sm btn-ghost">{{ i18n.t('ver_todas') }}</router-link>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('factura') }}</th><th>{{ i18n.t('total') }}</th><th>{{ i18n.t('metodo') }}</th><th>{{ i18n.t('fecha') }}</th></tr></thead>
            <tbody>
              <tr v-for="v in stats.ventas_recientes" :key="v.id">
                <td><strong>{{ v.numero_factura }}</strong></td>
                <td>{{ fm(v.total) }}</td>
                <td><span class="badge badge-info">{{ v.metodo_pago }}</span></td>
                <td>{{ formatDate(v.created_at) }}</td>
              </tr>
              <tr v-if="!stats.ventas_recientes?.length"><td colspan="4" style="text-align:center;color:var(--text-muted);padding:40px;">{{ i18n.t('no_hay_ventas') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
      <div class="card animate-fade-in">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-exclamation-triangle" style="margin-right:8px;color:var(--warning);"></i>{{ i18n.t('bajo_stock_label') }}</h3>
          <router-link to="/productos" class="btn btn-sm btn-ghost">{{ i18n.t('ver_todos') }}</router-link>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('stock') }}</th><th>{{ i18n.t('min') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in stats.productos_bajo_stock" :key="p.id">
                <td><strong>{{ p.nombre }}</strong><div style="font-size:11px;color:var(--text-muted);">{{ p.codigo }}</div></td>
                <td><span class="badge badge-danger">{{ p.stock }}</span></td>
                <td>{{ p.stock_minimo }}</td>
              </tr>
              <tr v-if="!stats.productos_bajo_stock?.length"><td colspan="3" style="text-align:center;color:var(--text-muted);padding:40px;">{{ i18n.t('sin_alertas') }}</td></tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import api from '../services/api';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';
import { useAuthStore } from '../stores/auth';

const { fm } = useCurrency();
const i18n = useI18nStore();
const authStore = useAuthStore();
const stats = ref({});

const moduleSections = computed(() => {
  const allSections = [
    { title: i18n.t('punto_de_venta'), items: [
      { name: i18n.t('caja_rapida'), desc: i18n.t('desc_caja'), route: '/caja', icon: 'fas fa-cash-register', bg: 'rgba(255, 255, 255, 0.8)', color: 'var(--success)', slug: 'caja' },
      { name: i18n.t('historial_ventas'), desc: i18n.t('desc_ventas'), route: '/ventas', icon: 'fas fa-receipt', bg: 'rgba(255, 255, 255, 0.6)', color: 'var(--info)', slug: 'ventas' },
      { name: i18n.t('devoluciones'), desc: i18n.t('desc_devoluciones'), route: '/devoluciones', icon: 'fas fa-undo', bg: 'rgba(255, 255, 255, 0.6)', color: 'var(--warning)', slug: 'devoluciones' },
      { name: i18n.t('notas_credito'), desc: i18n.t('desc_notas_credito'), route: '/notas-credito', icon: 'fas fa-file-invoice', bg: 'rgba(255, 255, 255, 0.6)', color: '#1a73e8', slug: 'notas_credito' },
      { name: i18n.t('enviar_cotizacion'), desc: i18n.t('desc_enviar_cotizacion'), route: '/enviar-cotizacion', icon: 'fas fa-paper-plane', bg: 'rgba(255, 255, 255, 0.6)', color: '#0288d1', slug: 'enviar_cotizacion' },
    ]},
    { title: i18n.t('gestion_comercial'), items: [
      { name: i18n.t('cotizaciones'), desc: i18n.t('desc_cotizaciones'), route: '/cotizaciones', icon: 'fas fa-file-alt', bg: 'rgba(255, 255, 255, 0.6)', color: '#e67e22', slug: 'cotizaciones' },
      { name: i18n.t('cotizacion_designer'), desc: i18n.t('desc_cotizacion_designer'), route: '/cotizacion-designer', icon: 'fas fa-file-invoice', bg: 'rgba(255, 255, 255, 0.6)', color: '#ff7043', slug: 'cotizacion_designer' },
      { name: i18n.t('pedidos'), desc: i18n.t('desc_pedidos'), route: '/pedidos', icon: 'fas fa-clipboard-list', bg: 'rgba(255, 255, 255, 0.6)', color: '#43a047', slug: 'pedidos' },
      { name: i18n.t('combos'), desc: i18n.t('desc_combos'), route: '/combos', icon: 'fas fa-tags', bg: 'rgba(255, 255, 255, 0.6)', color: '#e91e63', slug: 'combos' },
      { name: i18n.t('clientes'), desc: i18n.t('desc_clientes'), route: '/clientes', icon: 'fas fa-users', bg: 'rgba(255, 255, 255, 0.6)', color: 'var(--primary-gold)', slug: 'clientes' },
      { name: i18n.t('chat_interno'), desc: i18n.t('desc_chat'), route: '/chats', icon: 'fas fa-comments', bg: 'rgba(255, 255, 255, 0.6)', color: '#7c4dff', slug: 'chats' },
      { name: i18n.t('notificaciones'), desc: i18n.t('desc_notificaciones'), route: '/notificaciones', icon: 'fas fa-bell', bg: 'rgba(255, 255, 255, 0.6)', color: '#ef5350', slug: 'notificaciones' },
    ]},
    { title: i18n.t('inventario_compras'), items: [
      { name: i18n.t('productos'), desc: i18n.t('desc_productos'), route: '/productos', icon: 'fas fa-boxes-stacked', bg: '#ede7f6', color: '#7c4dff', slug: 'productos' },
      { name: i18n.t('catalogo'), desc: i18n.t('desc_catalogo'), route: '/catalogo', icon: 'fas fa-book-open', bg: '#e8f5e9', color: '#43a047', slug: 'catalogo' },
      { name: i18n.t('inventario_ubicacion'), desc: i18n.t('desc_inventario_ubicacion'), route: '/inventario-ubicacion', icon: 'fas fa-warehouse', bg: '#e0f7fa', color: '#00bcd4', slug: 'inventario_ubicacion' },
      { name: i18n.t('traspasos'), desc: i18n.t('desc_traspasos'), route: '/traspasos', icon: 'fas fa-exchange-alt', bg: '#e0f7fa', color: '#00bcd4', slug: 'traspasos' },
      { name: i18n.t('ajustes_inventario'), desc: i18n.t('desc_ajustes'), route: '/ajustes-inventario', icon: 'fas fa-sliders-h', bg: '#fff3e0', color: '#ff9800', slug: 'ajustes_inventario' },
      { name: i18n.t('compras'), desc: i18n.t('desc_compras'), route: '/compras', icon: 'fas fa-shopping-cart', bg: '#e3f2fd', color: '#1e88e5', slug: 'compras' },
      { name: i18n.t('proveedores'), desc: i18n.t('desc_proveedores'), route: '/proveedores', icon: 'fas fa-truck', bg: '#e8eaf6', color: '#3f51b5', slug: 'proveedores' },
      { name: i18n.t('etiquetas'), desc: i18n.t('desc_etiquetas'), route: '/etiquetas', icon: 'fas fa-tag', bg: '#f3e5f5', color: '#9c27b0', slug: 'etiquetas' },
    ]},
    { title: i18n.t('inteligencia_reportes'), items: [
      { name: i18n.t('business_intelligence'), desc: i18n.t('desc_bi'), route: '/business-intelligence', icon: 'fas fa-brain', bg: '#e8f5e9', color: '#2e7d32', slug: 'business_intelligence' },
      { name: i18n.t('reportes'), desc: i18n.t('desc_reportes'), route: '/reportes', icon: 'fas fa-chart-bar', bg: '#fff8e1', color: '#f9a825', slug: 'reportes' },
      { name: i18n.t('geo_business'), desc: i18n.t('desc_geo'), route: '/geo-business', icon: 'fas fa-map-marked-alt', bg: '#e3f2fd', color: '#1565c0', slug: 'geo_business' },
      { name: i18n.t('rentabilidad'), desc: i18n.t('desc_rentabilidad'), route: '/rentabilidad', icon: 'fas fa-coins', bg: 'rgba(255, 255, 255, 0.6)', color: 'var(--primary-gold)', slug: 'rentabilidad' },
      { name: i18n.t('productividad'), desc: i18n.t('desc_productividad'), route: '/productividad', icon: 'fas fa-user-clock', bg: '#fce4ec', color: '#c62828', slug: 'productividad' },
    ]},
    { title: i18n.t('finanzas_contabilidad'), items: [
      { name: i18n.t('cuentas_cobrar'), desc: i18n.t('desc_cuentas_cobrar'), route: '/cuentas-cobrar', icon: 'fas fa-hand-holding-usd', bg: '#e8f5e9', color: '#388e3c', slug: 'cuentas_cobrar' },
      { name: i18n.t('listas_precios'), desc: i18n.t('desc_listas_precios'), route: '/listas-precios', icon: 'fas fa-list-ol', bg: '#e0f7fa', color: '#0097a7', slug: 'listas_precios' },
      { name: i18n.t('contabilidad'), desc: i18n.t('desc_contabilidad'), route: '/contabilidad', icon: 'fas fa-calculator', bg: '#e8eaf6', color: '#303f9f', slug: 'contabilidad' },
      { name: i18n.t('tesoreria'), desc: i18n.t('desc_tesoreria'), route: '/tesoreria', icon: 'fas fa-vault', bg: '#fbe9e7', color: '#d84315', slug: 'tesoreria' },
      { name: i18n.t('presupuestos'), desc: i18n.t('desc_presupuestos'), route: '/presupuestos', icon: 'fas fa-file-invoice-dollar', bg: '#fff3e0', color: '#ef6c00', slug: 'presupuestos' },
      { name: i18n.t('facturacion_electronica'), desc: i18n.t('desc_facturacion'), route: '/facturacion-electronica', icon: 'fas fa-file-signature', bg: '#f1f8e9', color: '#558b2f', slug: 'facturacion_electronica' },
    ]},
    { title: i18n.t('marketing_crm_label'), items: [
      { name: i18n.t('crm'), desc: i18n.t('desc_crm'), route: '/crm', icon: 'fas fa-handshake', bg: '#e8f5e9', color: '#43a047', slug: 'crm' },
      { name: i18n.t('email_builder'), desc: i18n.t('desc_email_builder'), route: '/email-builder', icon: 'fas fa-envelope-open-text', bg: '#e3f2fd', color: '#1e88e5', slug: 'email_builder' },
      { name: i18n.t('formularios'), desc: i18n.t('desc_formularios'), route: '/formularios', icon: 'fas fa-wpforms', bg: '#fff8e1', color: '#fbc02d', slug: 'formularios' },
    ]},
    { title: i18n.t('admin_sistema'), items: [
      { name: i18n.t('usuarios'), desc: i18n.t('desc_usuarios'), route: '/usuarios', icon: 'fas fa-user-shield', bg: '#fce4ec', color: '#c62828', slug: 'usuarios' },
      { name: i18n.t('planilla'), desc: i18n.t('desc_planilla'), route: '/planilla', icon: 'fas fa-money-check-alt', bg: '#e8f5e9', color: '#2e7d32', slug: 'planilla' },
      { name: i18n.t('auditoria'), desc: i18n.t('desc_auditoria'), route: '/auditoria', icon: 'fas fa-shield-alt', bg: '#efebe9', color: '#5d4037', slug: 'auditoria' },
      { name: i18n.t('ticket_designer'), desc: i18n.t('desc_ticket'), route: '/ticket-designer', icon: 'fas fa-print', bg: '#e0f7fa', color: '#00838f', slug: 'ticket_designer' },
      { name: i18n.t('configuracion'), desc: i18n.t('desc_configuracion'), route: '/configuracion', icon: 'fas fa-cog', bg: '#eceff1', color: '#546e7a', slug: 'configuracion' },
    ]},
  ];

  return allSections
    .map(section => ({
      ...section,
      items: section.items.filter(m => authStore.hasModule(m.slug)),
    }))
    .filter(section => section.items.length > 0);
});

onMounted(async () => {
    try { const { data } = await api.get('/dashboard/stats'); stats.value = data; } catch (e) { console.error(e); }
});

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString(i18n.locale === 'en' ? 'en-US' : 'es-CR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.dash-modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 12px;
}
.dash-module-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px;
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
  border-radius: 12px;
  text-decoration: none;
  color: inherit;
  transition: all 0.2s ease;
}
.dash-module-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  border: 1.3px solid var(--primary-gold);
  background-color: rgba(1, 35, 78, 0.1);
}
.dash-module-icon {
  width: 44px; height: 44px; border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; flex-shrink: 0;
}
.dash-module-name { font-weight: 600; font-size: 14px; }
.dash-module-desc { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

[data-theme="dark"] .dash-module-card {
  .dash-module-name {
    color: var(--text-primary);
  }
}
[data-theme="dark"] .dashboard {
  background: var(--bg-primary);
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

/* =============================================
   TABLETS / SMALL DESKTOPS (max-width: 1023px)
   ============================================= */
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
  .dash-modules-grid {
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)) !important;
  }
}

/* =============================================
   MOBILE (max-width: 768px)
   App-like dashboard experience
   ============================================= */
@media (max-width: 768px) {
  /* === GRIDS: Proper mobile collapse === */
  .grid-4 {
    grid-template-columns: repeat(2, 1fr) !important;
    gap: 10px !important;
  }
  .grid-3 {
    grid-template-columns: 1fr !important;
    gap: 12px !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
    gap: 12px !important;
  }
  .dash-modules-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)) !important;
    gap: 8px !important;
  }

  /* === STAT CARDS: Compact and clean === */
  .stat-value {
    font-size: 20px !important;
    letter-spacing: -0.5px;
  }
  .stat-card {
    padding: 12px !important;
    border-radius: 12px !important;
  }
  .stat-card:hover {
    transform: none !important;
  }
  .stat-card .stat-icon {
    width: 36px !important;
    height: 36px !important;
    font-size: 15px !important;
    margin-bottom: 6px !important;
    border-radius: 10px !important;
  }
  .stat-card .stat-label {
    font-size: 11px !important;
    margin-top: 2px !important;
  }
  .stat-card .stat-change {
    font-size: 10px !important;
    padding: 2px 6px !important;
    margin-top: 4px !important;
  }

  /* === MODULE CARDS: Touch-friendly === */
  .dash-module-card {
    padding: 12px !important;
    gap: 10px !important;
    border-radius: 12px !important;
    -webkit-tap-highlight-color: transparent;
  }
  .dash-module-card:active {
    transform: scale(0.98) !important;
    transition: transform 0.1s !important;
  }
  .dash-module-icon {
    width: 38px !important;
    height: 38px !important;
    font-size: 16px !important;
    border-radius: 10px !important;
  }
  .dash-module-name {
    font-size: 13px !important;
  }
  .dash-module-desc {
    font-size: 11px !important;
    margin-top: 1px !important;
  }

  /* === SECTION TITLES: Better hierarchy === */
  h3[style*="text-transform:uppercase"] {
    font-size: 11px !important;
    letter-spacing: 0.8px !important;
    margin-bottom: 10px !important;
  }

  /* === CARDS: Proper padding === */
  .card-header {
    padding: 12px 14px !important;
  }
  .card-title {
    font-size: 13px !important;
  }
  .card-body {
    padding: 12px 14px !important;
  }

  /* === TABLES: Card-style on mobile === */
  .table-responsive table {
    min-width: auto !important;
  }
  .table-responsive table thead {
    display: none !important;
  }
  .table-responsive table tbody tr {
    display: flex !important;
    flex-direction: column !important;
    padding: 10px 12px !important;
    margin-bottom: 8px !important;
    background: var(--bg-card);
    border-radius: 10px !important;
    border: 1px solid rgba(0,0,0,0.04);
  }
  .table-responsive table tbody td {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    padding: 4px 0 !important;
    font-size: 12px !important;
    border-bottom: 1px solid rgba(0,0,0,0.03) !important;
  }
  .table-responsive table tbody td:last-child {
    border-bottom: none !important;
  }
  .table-responsive table tbody td::before {
    content: attr(data-label);
    font-weight: 600;
    color: var(--text-secondary);
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  /* === TOP VENDOR / INVENTORY CARDS === */
  .card-body[style*="text-align:center"] {
    padding: 16px !important;
  }
  .card-body[style*="padding:0"] {
    padding: 0 !important;
  }
}

/* =============================================
   SMALL PHONES (max-width: 480px)
   Ultra-compact dashboard
   ============================================= */
@media (max-width: 480px) {
  .grid-4 {
    grid-template-columns: 1fr !important;
    gap: 8px !important;
  }
  .grid-3 {
    grid-template-columns: 1fr !important;
    gap: 8px !important;
  }
  .grid-2 {
    grid-template-columns: 1fr !important;
    gap: 10px !important;
  }
  .dash-modules-grid {
    grid-template-columns: 1fr !important;
    gap: 6px !important;
  }

  .dash-module-card {
    padding: 10px !important;
    gap: 8px !important;
  }
  .dash-module-icon {
    width: 34px !important;
    height: 34px !important;
    font-size: 14px !important;
  }
  .dash-module-name {
    font-size: 12px !important;
  }
  .stat-value {
    font-size: 18px !important;
  }
  .stat-card {
    padding: 10px !important;
  }
  .stat-card .stat-icon {
    width: 32px !important;
    height: 32px !important;
    font-size: 13px !important;
  }
}
</style>
