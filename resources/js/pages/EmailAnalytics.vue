<template>
  <div>
    <div class="flex justify-between items-center mb-lg ea-topbar">
      <div>
        <button class="btn btn-ghost btn-sm mb-sm" @click="router.push('/email-builder')"><i class="fas fa-arrow-left"></i> {{ i18n.t('email_builder_volver') }}</button>
        <h2 class="page-title" style="margin:0;"><i class="fas fa-chart-bar" style="margin-right:8px;"></i>{{ i18n.t('email_analytics_detalle') }}: {{ campaign?.nombre || i18n.t('email_marketing_campana') }}</h2>
      </div>
    </div>

    <div v-if="loading" style="text-align:center;padding:60px;color:var(--text-muted);">
      <i class="fas fa-spinner fa-spin" style="font-size:32px;margin-bottom:12px;"></i>
      <p>{{ i18n.t('email_analytics_cargando') }}</p>
    </div>

    <div v-else-if="!stats" style="text-align:center;padding:60px;color:var(--text-muted);">
      <i class="fas fa-exclamation-circle" style="font-size:32px;margin-bottom:12px;"></i>
      <p>{{ i18n.t('email_analytics_sin_datos') }}</p>
    </div>

    <template v-else>
      <!-- KPI Cards -->
      <div class="grid-4 gap-md mb-lg ea-kpi-grid">
        <div class="card stat-card">
          <div class="stat-icon" style="background:rgba(59,130,246,0.12);color:#3b82f6;"><i class="fas fa-paper-plane"></i></div>
          <div class="stat-value">{{ stats.total_enviados }}</div>
          <div class="stat-label">{{ i18n.t('email_analytics_enviados') }}</div>
        </div>
        <div class="card stat-card">
          <div class="stat-icon" style="background:rgba(16,185,129,0.12);color:#10b981;"><i class="fas fa-envelope-open"></i></div>
          <div class="stat-value">{{ stats.total_abiertos }}</div>
          <div class="stat-label">{{ i18n.t('email_analytics_aperturas') }}</div>
          <div class="ea-rate">{{ tasaApertura }}% {{ i18n.t('email_analytics_tasa') }}</div>
        </div>
        <div class="card stat-card">
          <div class="stat-icon" style="background:rgba(139,92,246,0.12);color:#8b5cf6;"><i class="fas fa-mouse-pointer"></i></div>
          <div class="stat-value">{{ stats.total_clicks }}</div>
          <div class="stat-label">{{ i18n.t('email_analytics_clics') }}</div>
          <div class="ea-rate">{{ tasaClic }}% CTR</div>
        </div>
        <div class="card stat-card">
          <div class="stat-icon" style="background:rgba(239,68,68,0.12);color:#ef4444;"><i class="fas fa-times-circle"></i></div>
          <div class="stat-value">{{ stats.total_rebotes }}</div>
          <div class="stat-label">{{ i18n.t('email_analytics_rebotes') }}</div>
          <div class="ea-rate">{{ tasaRebote }}% {{ i18n.t('email_analytics_tasa') }}</div>
        </div>
      </div>

      <!-- Charts Row -->
      <div class="grid-2 gap-md mb-lg ea-charts-grid">
        <div class="card">
          <div class="card-header"><h4 class="ea-card-title">{{ i18n.t('email_analytics_dispositivos') }}</h4></div>
          <div class="card-body">
            <div v-if="!Object.keys(deviceBreakdown).length" style="text-align:center;color:var(--text-muted);padding:30px;">{{ i18n.t('sin_datos') }}</div>
            <div v-else class="device-bars">
              <div v-for="(count, device) in deviceBreakdown" :key="device" class="device-bar">
                <div class="device-label-text">
                  <i :class="deviceIcon(device)"></i>
                  <span>{{ device || i18n.t('email_analytics_desconocido') }}</span>
                </div>
                <div class="device-progress">
                  <div class="device-progress-fill" :style="{ width: devicePct(count) + '%' }"></div>
                </div>
                <div class="device-count">{{ count }}</div>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-header"><h4 class="ea-card-title">{{ i18n.t('email_analytics_rendimiento') }}</h4></div>
          <div class="card-body">
            <div class="metric-row">
              <span class="metric-label">{{ i18n.t('email_analytics_tasa_apertura') }}</span>
              <span class="metric-value" :class="{ good: tasaApertura >= 20, bad: tasaApertura < 10 }">{{ tasaApertura }}%</span>
            </div>
            <div class="metric-row">
              <span class="metric-label">{{ i18n.t('email_analytics_click_through_rate') }}</span>
              <span class="metric-value" :class="{ good: tasaClic >= 2, bad: tasaClic < 1 }">{{ tasaClic }}%</span>
            </div>
            <div class="metric-row">
              <span class="metric-label">{{ i18n.t('email_analytics_tasa_rebote') }}</span>
              <span class="metric-value" :class="{ good: tasaRebote < 2, bad: tasaRebote >= 5 }">{{ tasaRebote }}%</span>
            </div>
            <div class="metric-row">
              <span class="metric-label">{{ i18n.t('email_analytics_total_destinatarios') }}</span>
              <span class="metric-value">{{ stats.total_recipients }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Recipients Table -->
      <div class="card">
        <div class="card-header ea-table-header">
          <h4 class="ea-card-title">{{ i18n.t('email_analytics_detalle_destinatarios') }}</h4>
          <div class="ea-filter-chips">
            <span v-for="s in estados" :key="s" class="filter-chip" :class="{ active: filtroEstado === s }" @click="filtroEstado = filtroEstado === s ? '' : s">{{ s }}</span>
          </div>
        </div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead>
                <tr><th>{{ i18n.t('email') }}</th><th>{{ i18n.t('nombre') }}</th><th>{{ i18n.t('email_analytics_estado') }}</th><th>{{ i18n.t('email_analytics_enviados') }}</th><th>{{ i18n.t('email_analytics_abierto') }}</th><th>{{ i18n.t('email_analytics_clic') }}</th><th>{{ i18n.t('email_analytics_dispositivo') }}</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in filteredRecipients" :key="r.id">
                  <td>{{ r.email }}</td>
                  <td>{{ r.nombre || '-' }}</td>
                  <td><span class="badge" :class="badgeClass(r.estado)">{{ r.estado }}</span></td>
                  <td>{{ r.enviado_at ? formatDate(r.enviado_at) : '-' }}</td>
                  <td>{{ r.abierto_at ? formatDate(r.abierto_at) : '-' }}</td>
                  <td>{{ r.click_at ? formatDate(r.click_at) : '-' }}</td>
                  <td>{{ r.device || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="!filteredRecipients.length" style="text-align:center;color:var(--text-muted);padding:30px;">{{ i18n.t('email_analytics_no_destinatarios') }}</div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '../services/api';
import { useI18nStore } from '../stores/i18n';

const route = useRoute();
const router = useRouter();
const i18n = useI18nStore();
const campaignId = ref(route.params.id);

const campaign = ref(null);
const stats = ref(null);
const recipients = ref([]);
const deviceBreakdown = ref({});
const loading = ref(true);
const filtroEstado = ref('');
const estados = ['pendiente', 'enviado', 'abierto', 'click', 'rebote', 'error'];

const filteredRecipients = computed(() => {
  if (!filtroEstado.value) return recipients.value;
  return recipients.value.filter(r => r.estado === filtroEstado.value);
});

const tasaApertura = computed(() => {
  const s = stats.value;
  if (!s || s.total_enviados === 0) return 0;
  return ((s.total_abiertos / s.total_enviados) * 100).toFixed(1);
});

const tasaClic = computed(() => {
  const s = stats.value;
  if (!s || s.total_enviados === 0) return 0;
  return ((s.total_clicks / s.total_enviados) * 100).toFixed(1);
});

const tasaRebote = computed(() => {
  const s = stats.value;
  if (!s || s.total_enviados === 0) return 0;
  return ((s.total_rebotes / s.total_enviados) * 100).toFixed(1);
});

function devicePct(count) {
  const total = Object.values(deviceBreakdown.value).reduce((a, b) => a + b, 0);
  return total > 0 ? (count / total) * 100 : 0;
}

function deviceIcon(dev) {
  if (dev === 'mobile') return 'fas fa-mobile-alt';
  if (dev === 'tablet') return 'fas fa-tablet-alt';
  return 'fas fa-desktop';
}

function badgeClass(estado) {
  return {
    pendiente: 'badge-warning',
    enviado: 'badge-info',
    abierto: 'badge-success',
    click: 'badge-primary',
    rebote: 'badge-danger',
    error: 'badge-danger',
  }[estado] || 'badge-ghost';
}

function formatDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}

async function cargar() {
  loading.value = true;
  try {
    const { data } = await api.get(`/email-builder/campaigns/${campaignId.value}`);
    campaign.value = data.campaign;
    recipients.value = data.campaign?.recipients || [];
  } catch (e) {}
  try {
    const { data } = await api.get(`/email-builder/campaigns/${campaignId.value}/analytics`);
    stats.value = data.stats;
    deviceBreakdown.value = data.stats?.device_breakdown || {};
  } catch (e) {}
  loading.value = false;
}

onMounted(cargar);
</script>

<style scoped>
.stat-card {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  padding: 20px;
  gap: 8px;
}

.stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--text-primary);
}

.stat-label {
  font-size: 13px;
  color: var(--text-muted);
}

.ea-rate {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 4px;
}

.ea-card-title {
  margin: 0;
  font-size: 15px;
}

.ea-table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ea-filter-chips {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.device-bars {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.device-bar {
  display: flex;
  align-items: center;
  gap: 12px;
}

.device-label-text {
  width: 90px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text-secondary);
}

.device-progress {
  flex: 1;
  height: 8px;
  background: var(--bg-hover);
  border-radius: 4px;
  overflow: hidden;
}

.device-progress-fill {
  height: 100%;
  background: var(--primary);
  border-radius: 4px;
  transition: width 0.5s ease;
}

.device-count {
  width: 40px;
  text-align: right;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
}

.metric-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid var(--bg-hover);
}

.metric-row:last-child {
  border-bottom: none;
}

.metric-label {
  font-size: 14px;
  color: var(--text-muted);
}

.metric-value {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}

.metric-value.good { color: #10b981; }
.metric-value.bad { color: #ef4444; }

.filter-chip {
  padding: 3px 10px;
  border-radius: 10px;
  font-size: 11px;
  cursor: pointer;
  background: var(--bg-hover);
  color: var(--text-muted);
  transition: all 0.15s;
  text-transform: capitalize;
}

.filter-chip.active {
  background: var(--primary);
  color: #fff;
}

.badge-primary {
  background: rgba(59,130,246,0.15);
  color: #3b82f6;
}

@media (max-width: 1023px) {
  .ea-table-header { flex-direction: column; align-items: flex-start; gap: 10px; }
  .ea-filter-chips { overflow-x: auto; flex-wrap: nowrap; padding-bottom: 4px; }
}

@media (max-width: 768px) {
  .ea-topbar { flex-direction: column; align-items: stretch; gap: 8px; }
  .ea-kpi-grid { grid-template-columns: repeat(2, 1fr); }
  .ea-charts-grid { grid-template-columns: 1fr; }
  .device-label-text { width: 70px; font-size: 12px; }
}

@media (max-width: 480px) {
  .ea-kpi-grid { grid-template-columns: 1fr; }
  .stat-value { font-size: clamp(18px, 5vw, 24px); }
  .metric-row { flex-direction: column; align-items: flex-start; gap: 4px; }
  .ea-filter-chips { gap: 4px; }
}
</style>
