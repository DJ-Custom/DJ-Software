<template>
  <div>
    <div class="flex justify-between items-center mb-lg ec-topbar">
      <div>
        <h2 class="page-title" style="margin:0;"><i class="fas fa-envelope-open-text" style="margin-right:8px;"></i>{{ i18n.t('email_builder') }}</h2>
        <p class="ec-subtitle">Crea, diseña y envía campañas de email profesionales</p>
      </div>
      <button class="btn btn-primary btn-mobile-min" @click="nuevaCampaña"><i class="fas fa-plus"></i> {{ i18n.t('email_campaigns_nueva') }}</button>
    </div>

    <!-- Stats Cards -->
    <div class="grid-4 gap-md mb-lg ec-stats-grid">
      <div class="card stat-card">
        <div class="stat-icon" style="background:rgba(59,130,246,0.12);color:#3b82f6;"><i class="fas fa-envelope"></i></div>
        <div class="stat-value">{{ stats.total }}</div>
        <div class="stat-label">{{ i18n.t('email_campaigns_total') }}</div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background:rgba(16,185,129,0.12);color:#10b981;"><i class="fas fa-paper-plane"></i></div>
        <div class="stat-value">{{ stats.enviadas }}</div>
        <div class="stat-label">{{ i18n.t('email_campaigns_enviadas') }}</div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background:rgba(245,158,11,0.12);color:#f59e0b;"><i class="fas fa-edit"></i></div>
        <div class="stat-value">{{ stats.borradores }}</div>
        <div class="stat-label">{{ i18n.t('email_campaigns_borradores') }}</div>
      </div>
      <div class="card stat-card">
        <div class="stat-icon" style="background:rgba(139,92,246,0.12);color:#8b5cf6;"><i class="fas fa-chart-line"></i></div>
        <div class="stat-value">{{ tasaApertura }}%</div>
        <div class="stat-label">{{ i18n.t('email_campaigns_tasa_apertura') }}</div>
      </div>
    </div>

    <!-- Filters & Tabs -->
    <div class="card mb-md">
      <div class="card-body ec-filters">
        <div class="ec-tabs">
          <button class="tab-btn" :class="{ active: filtroEstado === '' }" @click="filtroEstado = ''">{{ i18n.t('todos') }}</button>
          <button class="tab-btn" :class="{ active: filtroEstado === 'borrador' }" @click="filtroEstado = 'borrador'">{{ i18n.t('email_campaigns_borradores') }}</button>
          <button class="tab-btn" :class="{ active: filtroEstado === 'enviada' }" @click="filtroEstado = 'enviada'">{{ i18n.t('email_campaigns_enviadas') }}</button>
        </div>
        <div class="form-group ec-search">
          <input v-model="busqueda" class="form-control" :placeholder="i18n.t('email_campaigns_buscar')">
        </div>
      </div>
    </div>

    <!-- Campaigns Grid -->
    <div v-if="!filteredCampaigns.length" class="card ec-empty-state">
      <i class="fas fa-envelope-open ec-empty-icon"></i>
      <h3 class="ec-empty-title">{{ i18n.t('sin_campanas') }}</h3>
      <p class="ec-empty-desc">Crea tu primera campaña de email profesional</p>
      <button class="btn btn-primary btn-mobile-min" @click="nuevaCampaña"><i class="fas fa-plus"></i> {{ i18n.t('email_campaigns_nueva') }}</button>
    </div>

    <div v-else class="campaigns-grid">
      <div v-for="c in filteredCampaigns" :key="c.id" class="campaign-card">
        <div class="campaign-preview">
          <div v-if="c.thumbnail" class="campaign-thumb" :style="{ backgroundImage: `url(${c.thumbnail})` }"></div>
          <div v-else class="campaign-thumb-placeholder">
            <i class="fas fa-envelope" style="font-size:32px;opacity:0.3;"></i>
          </div>
          <span class="campaign-status" :class="c.estado">{{ c.estado }}</span>
        </div>
        <div class="campaign-body">
          <h4 class="campaign-name">{{ c.nombre }}</h4>
          <div class="campaign-subject">{{ c.asunto || i18n.t('plantillas_email_sin_asunto') }}</div>
          <div class="campaign-meta">
            <span><i class="fas fa-users"></i> {{ c.total_recipients }}</span>
            <span><i class="fas fa-paper-plane"></i> {{ c.total_enviados }}</span>
            <span><i class="fas fa-eye"></i> {{ c.total_abiertos }}</span>
          </div>
          <div class="campaign-date">
            {{ formatDate(c.created_at) }} · {{ c.creador?.nombre || '-' }}
          </div>
        </div>
        <div class="campaign-actions">
          <button class="btn btn-sm btn-ghost" @click="editar(c.id)" :title="i18n.t('editar')"><i class="fas fa-edit"></i></button>
          <button class="btn btn-sm btn-ghost" @click="duplicar(c)" :title="i18n.t('duplicar')"><i class="fas fa-copy"></i></button>
          <button v-if="c.estado === 'enviada'" class="btn btn-sm btn-ghost" @click="verAnalytics(c.id)" :title="i18n.t('email_campaigns_ver_analytics')"><i class="fas fa-chart-bar"></i></button>
          <button class="btn btn-sm btn-danger" @click="eliminar(c.id)" :title="i18n.t('eliminar')"><i class="fas fa-trash"></i></button>
        </div>
      </div>
    </div>

    <!-- Templates Section -->
    <div class="ec-templates-section">
      <div class="flex justify-between items-center mb-md">
        <h3 class="ec-templates-title"><i class="fas fa-layer-group" style="margin-right:8px;"></i>{{ i18n.t('email_builder_plantillas') }}</h3>
        <button class="btn btn-sm btn-ghost" @click="showTemplates = !showTemplates">{{ showTemplates ? i18n.t('ocultar') : i18n.t('ver') }}</button>
      </div>
      <div v-if="showTemplates" class="templates-grid">
        <div v-for="t in templates" :key="t.id" class="template-card" @click="usarPlantilla(t)">
          <div class="template-thumb">
            <div v-if="t.thumbnail" :style="{ backgroundImage: `url(${t.thumbnail})` }"></div>
            <div v-else class="template-placeholder"><i class="fas fa-file-code" style="font-size:24px;opacity:0.3;"></i></div>
          </div>
          <div class="template-info">
            <strong class="template-name">{{ t.nombre }}</strong>
            <div class="template-cat">{{ t.categoria || i18n.t('plantillas_email_general') }}</div>
          </div>
        </div>
        <div v-if="!templates.length" class="templates-empty">
          {{ i18n.t('plantillas_email_sin_datos') }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '../services/api';
import { useConfirmStore } from '../stores/confirm';
import { useI18nStore } from '../stores/i18n';

const confirm = useConfirmStore();
const i18n = useI18nStore();

const router = useRouter();
const campaigns = ref([]);
const templates = ref([]);
const stats = ref({ total: 0, enviadas: 0, borradores: 0 });
const busqueda = ref('');
const filtroEstado = ref('');
const showTemplates = ref(false);

const filteredCampaigns = computed(() => {
  return campaigns.value.filter(c => {
    const q = busqueda.value.toLowerCase();
    const matchQ = !q || (c.nombre || '').toLowerCase().includes(q) || (c.asunto || '').toLowerCase().includes(q);
    const matchEstado = !filtroEstado.value || c.estado === filtroEstado.value;
    return matchQ && matchEstado;
  });
});

const tasaApertura = computed(() => {
  const enviados = campaigns.value.filter(c => c.total_enviados > 0);
  if (!enviados.length) return 0;
  const totalEnviados = enviados.reduce((s, c) => s + c.total_enviados, 0);
  const totalAbiertos = enviados.reduce((s, c) => s + c.total_abiertos, 0);
  return totalEnviados > 0 ? ((totalAbiertos / totalEnviados) * 100).toFixed(1) : 0;
});

async function cargar() {
  try {
    const { data } = await api.get('/email-builder/dashboard');
    stats.value = { total: data.total, enviadas: data.enviadas, borradores: data.borradores };
  } catch (e) {}
  try {
    const { data } = await api.get('/email-builder/campaigns');
    campaigns.value = data.campaigns?.data || [];
  } catch (e) {}
  try {
    const { data } = await api.get('/email-builder/templates');
    templates.value = data.templates?.data || [];
  } catch (e) {}
}

function nuevaCampaña() {
  router.push('/email-builder/new');
}

function editar(id) {
  router.push(`/email-builder/edit/${id}`);
}

async function duplicar(c) {
  try {
    await api.post('/email-builder/campaigns', {
      nombre: c.nombre + ' (copia)',
      asunto: c.asunto,
      html_content: c.html_content,
      json_content: c.json_content,
    });
    await cargar();
  } catch (e) {}
}

function verAnalytics(id) {
  router.push(`/email-builder/analytics/${id}`);
}

async function eliminar(id) {
  if (!await confirm.ask({ message: i18n.t('email_campaigns_eliminar') + '?', confirmText: i18n.t('eliminar'), type: 'danger' })) return;
  try {
    await api.delete(`/email-builder/campaigns/${id}`);
    await cargar();
  } catch (e) {}
}

function usarPlantilla(t) {
  router.push(`/email-builder/new?template=${t.id}`);
}

function formatDate(d) {
  if (!d) return '-';
  return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short' });
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

.tab-btn {
  padding: 6px 14px;
  border-radius: 6px;
  border: none;
  background: transparent;
  font-size: 13px;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.15s;
  min-height: 44px;
}

.tab-btn.active {
  background: var(--primary);
  color: #fff;
}

.campaigns-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.campaign-card {
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
  border-radius: 12px;
  overflow: hidden;
  transition: box-shadow 0.15s;
}

.campaign-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
}

.campaign-preview {
  position: relative;
  height: 140px;
  background: var(--bg-hover);
  overflow: hidden;
}

.campaign-thumb {
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: top center;
}

.campaign-thumb-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
}

.campaign-status {
  position: absolute;
  top: 8px;
  right: 8px;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
}

.campaign-status.borrador {
  background: rgba(245,158,11,0.15);
  color: #d97706;
}

.campaign-status.enviada {
  background: rgba(16,185,129,0.15);
  color: #059669;
}

.campaign-body {
  padding: 14px 16px;
}

.campaign-name {
  margin: 0 0 6px;
  font-size: 15px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.campaign-subject {
  font-size: 12px;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.campaign-meta {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: var(--text-muted);
}

.campaign-meta span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.campaign-date {
  font-size: 11px;
  color: var(--text-muted);
  margin-top: 8px;
}

.campaign-actions {
  display: flex;
  gap: 6px;
  padding: 10px 16px 14px;
  border-top: 1px solid var(--bg-hover);
}

.templates-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 12px;
}

.template-card {
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: box-shadow 0.15s, border-color 0.15s;
}

.template-card:hover {
  border-color: var(--primary);
  box-shadow: 0 2px 8px rgba(59,130,246,0.12);
}

.template-thumb {
  height: 100px;
  background: var(--bg-hover);
}

.template-thumb > div {
  width: 100%;
  height: 100%;
  background-size: cover;
  background-position: top center;
}

.template-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
}

.template-info {
  padding: 10px 12px;
}

.template-name {
  font-size: 13px;
}

.template-cat {
  font-size: 11px;
  color: var(--text-muted);
}

.templates-empty {
  grid-column: 1/-1;
  text-align: center;
  color: var(--text-muted);
  padding: 30px;
}

.ec-subtitle {
  margin: 4px 0 0;
  color: var(--text-muted);
  font-size: 13px;
}

.ec-empty-state {
  text-align: center;
  padding: 60px;
  color: var(--text-muted);
}

.ec-empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.3;
  display: block;
}

.ec-empty-title {
  margin: 0 0 8px;
  font-size: 18px;
}

.ec-empty-desc {
  margin: 0 0 20px;
  font-size: 14px;
}

.ec-templates-section {
  margin-top: 40px;
}

.ec-templates-title {
  margin: 0;
  font-size: 18px;
}

.ec-filters {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: flex-end;
  padding: 14px 16px;
}

.ec-tabs {
  display: flex;
  gap: 4px;
}

.ec-search {
  flex: 1;
  min-width: 180px;
  margin: 0;
}

.btn-mobile-min {
  min-height: 44px;
}

@media (max-width: 1023px) {
  .campaigns-grid {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  }
}

@media (max-width: 768px) {
  .ec-topbar { flex-direction: column; align-items: stretch; gap: 12px; }
  .ec-stats-grid { grid-template-columns: repeat(2, 1fr); }
  .ec-filters { flex-direction: column; align-items: stretch; }
  .ec-tabs { overflow-x: auto; }
  .ec-search { min-width: 100%; }
  .campaigns-grid { grid-template-columns: 1fr; }
  .templates-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 480px) {
  .ec-stats-grid { grid-template-columns: 1fr; }
  .stat-value { font-size: clamp(18px, 5vw, 24px); }
  .templates-grid { grid-template-columns: 1fr 1fr; }
  .campaign-actions { flex-wrap: wrap; }
}
</style>
