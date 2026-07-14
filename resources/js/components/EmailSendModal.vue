<template>
  <teleport to="body">
    <div class="preview-overlay" @click.self="$emit('close')">
      <div class="preview-box" style="max-height: 88vh;">
        <div class="pv-header">
          <div class="pv-title">
            <i class="fas fa-paper-plane"></i>
            <div>
              <h4>Enviar campaña</h4>
              <p>Selecciona los destinatarios</p>
            </div>
          </div>
          <button class="pv-close" @click="$emit('close')"><i class="fas fa-times"></i></button>
        </div>

        <div class="pv-body" style="padding:0; overflow:hidden; display:flex; flex-direction:column;">
          <!-- Tabs -->
          <div class="esm-tabs">
            <button :class="{ active: tab === 'manual' }" @click="tab = 'manual'"><i class="fas fa-keyboard"></i> Correos manuales</button>
            <button :class="{ active: tab === 'clientes' }" @click="tab = 'clientes'"><i class="fas fa-users"></i> Clientes</button>
            <button :class="{ active: tab === 'etiquetas' }" @click="tab = 'etiquetas'"><i class="fas fa-tags"></i> Por Etiquetas</button>
          </div>

          <!-- Tab: Manual -->
          <div v-if="tab === 'manual'" class="esm-tab-panel">
            <div class="esm-banner"><i class="fas fa-info-circle"></i> Puedes combinar correos manuales con clientes y etiquetas en las otras pestañas.</div>
            <label class="esm-label">Ingresa los correos (uno por línea)</label>
            <textarea v-model="manualEmails" class="esm-textarea" rows="8" placeholder="cliente1@email.com&#10;cliente2@email.com"></textarea>
            <div class="esm-helper">{{ manualParsed.length }} correo(s) válido(s) detectado(s)</div>
          </div>

          <!-- Tab: Clientes -->
          <div v-if="tab === 'clientes'" class="esm-tab-panel">
            <div class="esm-banner"><i class="fas fa-info-circle"></i> Se suma con correos manuales y etiquetas. El sistema evita duplicados automáticamente.</div>
            <div class="esm-filters">
              <input v-model="clienteFiltros.q" class="esm-input" placeholder="Buscar nombre, cédula, teléfono o email..." @input="debounceCargarClientes">
              <select v-model="clienteFiltros.clasificacion" class="esm-input esm-select-clasificacion" @change="cargarClientes">
                <option value="">Todas las clasificaciones</option>
                <option value="regular">Regular</option>
                <option value="vip">VIP</option>
                <option value="mayorista">Mayorista</option>
                <option value="nuevo">Nuevo</option>
              </select>
              <select v-model="clienteFiltros.activo" class="esm-input esm-select-activo" @change="cargarClientes">
                <option value="">Todos los estados</option>
                <option value="1">Activos</option>
                <option value="0">Inactivos</option>
              </select>
            </div>
            <div class="esm-etiqueta-filters">
              <span class="esm-filter-label">Filtrar por etiqueta:</span>
              <span
                v-for="e in etiquetasDisponibles"
                :key="e.id"
                class="esm-chip"
                :class="{ active: clienteFiltros.etiqueta_ids.includes(e.id) }"
                :style="chipStyle(e, clienteFiltros.etiqueta_ids.includes(e.id))"
                @click="toggleEtiquetaFilter(e.id)"
              >{{ e.nombre }}</span>
            </div>
            <div class="esm-table-wrap">
              <table class="esm-table">
                <thead>
                  <tr>
                    <th style="width:36px;"><input type="checkbox" :checked="allFilteredSelected" @change="toggleSelectAllFiltered"></th>
                    <th>Nombre</th>
                    <th>Email</th>
                    <th>Clasificación</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="c in clientesList" :key="c.id">
                    <td><input type="checkbox" :checked="selectedClienteIds.has(c.id)" @change="toggleCliente(c.id)"></td>
                    <td><strong>{{ c.nombre }}</strong></td>
                    <td>{{ c.email || '-' }}</td>
                    <td><span :class="['badge', classBadge(c.clasificacion)]">{{ c.clasificacion || 'regular' }}</span></td>
                  </tr>
                  <tr v-if="!clientesList.length">
                    <td colspan="4" style="text-align:center; padding:30px; color:var(--text-muted);">No hay clientes con email</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="esm-pagination" v-if="clientesPages > 1">
              <button class="esm-btn-sm" :disabled="clientesPage <= 1" @click="clientesPage--; cargarClientes()">Anterior</button>
              <span style="font-size:12px; color:var(--text-muted);">Página {{ clientesPage }} de {{ clientesPages }}</span>
              <button class="esm-btn-sm" :disabled="clientesPage >= clientesPages" @click="clientesPage++; cargarClientes()">Siguiente</button>
            </div>
            <div class="esm-helper">{{ selectedClienteIds.size }} cliente(s) seleccionado(s) de {{ clientesTotal }} filtrado(s)</div>
          </div>

          <!-- Tab: Etiquetas -->
          <div v-if="tab === 'etiquetas'" class="esm-tab-panel">
            <div class="esm-banner"><i class="fas fa-info-circle"></i> Se suma con correos manuales y clientes individuales. El backend evita duplicados por email.</div>
            <p class="esm-desc">Selecciona una o más etiquetas. Se enviará a <strong>todos</strong> los clientes con email que tengan la etiqueta seleccionada.</p>
            <div class="esm-etiqueta-grid">
              <div
                v-for="e in etiquetasConCount"
                :key="e.id"
                class="esm-etiqueta-card"
                :class="{ active: selectedEtiquetaIds.includes(e.id) }"
                @click="toggleEtiqueta(e.id)"
              >
                <div class="esm-etq-dot" :style="{ backgroundColor: e.color || '#3b82f6' }"></div>
                <div class="esm-etq-name">{{ e.nombre }}</div>
                <div class="esm-etq-count">{{ e.count }} clientes</div>
                <div v-if="selectedEtiquetaIds.includes(e.id)" class="esm-etq-check"><i class="fas fa-check-circle"></i></div>
              </div>
              <div v-if="!etiquetasConCount.length" style="grid-column:1/-1; text-align:center; color:var(--text-muted); padding:30px;">No hay etiquetas</div>
            </div>
            <div class="esm-helper">{{ selectedEtiquetaIds.length }} etiqueta(s) seleccionada(s) — {{ etiquetaTotalClients }} cliente(s) en total</div>
          </div>
        </div>

        <div class="pv-footer" style="justify-content:space-between; align-items:center;">
          <div class="esm-summary">
            <span v-if="totalSummary.manual" class="esm-sum-item"><i class="fas fa-envelope"></i> {{ totalSummary.manual }} manual</span>
            <span v-if="totalSummary.clientes" class="esm-sum-item"><i class="fas fa-users"></i> {{ totalSummary.clientes }} clientes</span>
            <span v-if="totalSummary.etiquetas" class="esm-sum-item"><i class="fas fa-tags"></i> {{ totalSummary.etiquetas }} por etiquetas</span>
            <span v-if="totalSummary.overlaps" class="esm-sum-item esm-overlap"><i class="fas fa-compress-alt"></i> {{ totalSummary.overlaps }} duplicado(s) omitido(s)</span>
            <span class="esm-sum-total"><i class="fas fa-paper-plane"></i> Total estimado: <strong>{{ totalSummary.total }}</strong> destinatario(s)</span>
          </div>
          <div style="display:flex; gap:10px;">
            <button class="sf-btn ghost" @click="$emit('close')">Cancelar</button>
            <button class="sf-btn send" :disabled="isSending || totalSummary.total === 0" @click="confirmarYEnviar">
              <i class="fas fa-paper-plane"></i> {{ isSending ? 'Enviando...' : 'Enviar campaña' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';

const props = defineProps({
  campaignId: { type: Number, required: true },
  asunto: { type: String, default: '' },
});

const emit = defineEmits(['close', 'sent']);

const toast = useToastStore();
const tab = ref('manual');
const isSending = ref(false);

// Manual
const manualEmails = ref('');
const manualParsed = computed(() => {
  return manualEmails.value.split('\n').map(e => e.trim()).filter(e => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e));
});

// Clientes
const clientesList = ref([]);
const clientesTotal = ref(0);
const clientesPage = ref(1);
const clientesPages = ref(1);
const selectedClienteIds = ref(new Set());
const selectedClienteEmails = ref(new Set()); // Track emails of selected clients for dedup
const clienteFiltros = ref({ q: '', clasificacion: '', activo: '', etiqueta_ids: [] });
let clienteTimeout = null;

// Map client id -> email for the currently visible page
const clienteEmailMap = computed(() => {
  const map = new Map();
  for (const c of clientesList.value) {
    if (c.email) map.set(c.id, c.email.toLowerCase().trim());
  }
  return map;
});

// Etiquetas
const etiquetasDisponibles = ref([]);
const selectedEtiquetaIds = ref([]);
const etiquetaCounts = ref({});

const allFilteredSelected = computed(() => {
  if (!clientesList.value.length) return false;
  return clientesList.value.every(c => selectedClienteIds.value.has(c.id));
});

const etiquetasConCount = computed(() => {
  return etiquetasDisponibles.value.map(e => ({
    ...e,
    count: etiquetaCounts.value[e.id] || 0,
  }));
});

const etiquetaTotalClients = computed(() => {
  let total = 0;
  const seen = new Set();
  // This is an approximation since we don't have exact deduplication without backend call
  // We'll show the sum of counts (client may be in multiple etiquetas)
  for (const id of selectedEtiquetaIds.value) {
    total += etiquetaCounts.value[id] || 0;
  }
  return total;
});

const totalSummary = computed(() => {
  const manualSet = new Set(manualParsed.value.map(e => e.toLowerCase()));
  const clienteEmailsSet = new Set(selectedClienteEmails.value);

  // Remove manual emails that also appear in selected individual clients
  const manualUnique = new Set(manualSet);
  for (const em of clienteEmailsSet) manualUnique.delete(em);

  // For etiquetas, we don't know exact emails without backend, but we can
  // subtract overlaps with manual and selected clients for a lower-bound estimate.
  // etiquetaCounts already counts unique clients per tag. The real dedup happens in backend.
  // We display a range / estimated total.
  const manualCount = manualSet.size;
  const manualUniqueCount = manualUnique.size;
  const clientesCount = selectedClienteIds.value.size;
  const etiquetasCount = etiquetaTotalClients.value;

  // Best estimate: manual + selected clients + etiquetas - obvious overlaps
  // Overlaps: manual emails that are also in selected clients
  const manualOverlap = manualCount - manualUniqueCount;
  const estimatedTotal = manualCount + clientesCount + etiquetasCount - manualOverlap;

  return {
    manual: manualCount,
    clientes: clientesCount,
    etiquetas: etiquetasCount,
    overlaps: manualOverlap,
    total: Math.max(estimatedTotal, 0),
  };
});

function debounceCargarClientes() {
  clearTimeout(clienteTimeout);
  clienteTimeout = setTimeout(() => { clientesPage.value = 1; cargarClientes(); }, 400);
}

async function cargarClientes() {
  try {
    const params = {
      page: clientesPage.value,
      q: clienteFiltros.value.q,
      con_email: 1,
      per_page: 50,
    };
    if (clienteFiltros.value.clasificacion) params.clasificacion = clienteFiltros.value.clasificacion;
    if (clienteFiltros.value.activo !== '') params.activo = clienteFiltros.value.activo;
    if (clienteFiltros.value.etiqueta_ids.length) params.etiqueta_ids = clienteFiltros.value.etiqueta_ids;

    const { data } = await api.get('/clientes', { params });
    clientesList.value = data.clientes || [];
    clientesTotal.value = data.total || 0;
    clientesPages.value = data.pages || 1;
  } catch (e) { console.error(e); }
}

function toggleCliente(id) {
  const s = new Set(selectedClienteIds.value);
  const e = new Set(selectedClienteEmails.value);
  if (s.has(id)) {
    s.delete(id);
    const email = clienteEmailMap.value.get(id);
    if (email) e.delete(email);
  } else {
    s.add(id);
    const email = clienteEmailMap.value.get(id);
    if (email) e.add(email);
  }
  selectedClienteIds.value = s;
  selectedClienteEmails.value = e;
}

function toggleSelectAllFiltered() {
  const allSelected = allFilteredSelected.value;
  const s = new Set(selectedClienteIds.value);
  const e = new Set(selectedClienteEmails.value);
  for (const c of clientesList.value) {
    if (allSelected) {
      s.delete(c.id);
      if (c.email) e.delete(c.email.toLowerCase().trim());
    } else {
      s.add(c.id);
      if (c.email) e.add(c.email.toLowerCase().trim());
    }
  }
  selectedClienteIds.value = s;
  selectedClienteEmails.value = e;
}

function toggleEtiquetaFilter(id) {
  const ids = clienteFiltros.value.etiqueta_ids;
  const idx = ids.indexOf(id);
  if (idx >= 0) ids.splice(idx, 1); else ids.push(id);
  clientesPage.value = 1;
  cargarClientes();
}

function toggleEtiqueta(id) {
  const idx = selectedEtiquetaIds.value.indexOf(id);
  if (idx >= 0) selectedEtiquetaIds.value.splice(idx, 1);
  else selectedEtiquetaIds.value.push(id);
}

async function cargarEtiquetas() {
  try {
    const { data } = await api.get('/etiquetas');
    etiquetasDisponibles.value = data.etiquetas || [];
    // Pre-calculate counts
    for (const e of etiquetasDisponibles.value) {
      try {
        const { data: d } = await api.get('/clientes', { params: { con_email: 1, etiqueta_ids: [e.id], per_page: 1 } });
        etiquetaCounts.value[e.id] = d.total || 0;
      } catch (err) { etiquetaCounts.value[e.id] = 0; }
    }
  } catch (e) { console.error(e); }
}

function chipStyle(e, active) {
  if (active) return { backgroundColor: e.color, color: '#fff', borderColor: e.color };
  return { borderColor: e.color, color: e.color };
}

function classBadge(clasificacion) {
  const map = { vip: 'badge-warning', mayorista: 'badge-info', nuevo: 'badge-success' };
  return map[clasificacion] || 'badge-info';
}

async function confirmarYEnviar() {
  if (!props.asunto) { toast.error('Ingresa un asunto en la campaña'); return; }
  if (totalSummary.value.total === 0) { toast.error('Selecciona al menos un destinatario'); return; }

  isSending.value = true;
  try {
    // 1. Update campaign subject
    await api.put(`/email-builder/campaigns/${props.campaignId}`, { asunto: props.asunto });

    // 2. Add manual emails
    if (manualParsed.value.length) {
      const emails = manualParsed.value.map(e => ({ email: e }));
      await api.post(`/email-builder/campaigns/${props.campaignId}/recipients`, { emails });
    }

    // 3. Add selected individual clients
    if (selectedClienteIds.value.size) {
      await api.post(`/email-builder/campaigns/${props.campaignId}/recipients`, {
        cliente_ids: Array.from(selectedClienteIds.value),
      });
    }

    // 4. Add by etiquetas
    if (selectedEtiquetaIds.value.length) {
      await api.post(`/email-builder/campaigns/${props.campaignId}/recipients`, {
        etiquetas: selectedEtiquetaIds.value,
      });
    }

    // 5. Send campaign
    const { data } = await api.post(`/email-builder/campaigns/${props.campaignId}/send`);
    toast.success(`Campaña enviada: ${data.enviados} correo(s)`);
    emit('sent', data);
    emit('close');
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(e.response?.data?.error || 'Error al enviar la campaña');
    }
  } finally {
    isSending.value = false;
  }
}

onMounted(() => {
  cargarClientes();
  cargarEtiquetas();
});
</script>

<style scoped>
.esm-tabs {
  display: flex;
  gap: 2px;
  padding: 6px;
  background: var(--bg-input);
  border-bottom: 1px solid rgba(0,0,0,0.05);
}
.esm-tabs button {
  flex: 1;
  padding: 10px 14px;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: var(--text-muted);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.esm-tabs button.active {
  background: var(--bg-card);
  color: var(--primary-dark);
  box-shadow: var(--shadow-sm);
}
[data-theme="dark"] .esm-tabs button.active {
  background: #1e293b;
  color: #e2e8f0;
}

.esm-tab-panel {
  padding: 18px 20px;
  overflow-y: auto;
  flex: 1;
}

.esm-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: 10px;
  background: rgba(59,130,246,0.08);
  color: var(--info);
  font-size: 12px;
  font-weight: 500;
  margin-bottom: 14px;
}
[data-theme="dark"] .esm-banner { background: rgba(59,130,246,0.12); }

.esm-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.4px;
  margin-bottom: 8px;
  display: block;
}

.esm-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 12px;
  background: var(--bg-input);
  color: var(--text-primary);
  font-size: 13px;
  font-family: var(--font-main);
  resize: vertical;
}
.esm-textarea:focus { outline: none; border-color: var(--primary-gold); }
[data-theme="dark"] .esm-textarea { background: #1e293b; border-color: rgba(255,255,255,0.08); color: #e2e8f0; }

.esm-helper {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 10px;
}

.esm-filters {
  display: flex;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.esm-input {
  padding: 8px 12px;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 10px;
  background: var(--bg-input);
  color: var(--text-primary);
  font-size: 13px;
  font-family: var(--font-main);
  flex: 1;
  min-width: 140px;
}
.esm-input:focus { outline: none; border-color: var(--primary-gold); }
[data-theme="dark"] .esm-input { background: #1e293b; border-color: rgba(255,255,255,0.08); color: #e2e8f0; }

.esm-etiqueta-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
  align-items: center;
}
.esm-filter-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted);
}

.esm-chip {
  padding: 4px 10px;
  border-radius: 10px;
  border: 2px solid;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.15s;
  user-select: none;
}
.esm-chip:hover { opacity: 0.85; transform: translateY(-1px); }
.esm-chip.active { box-shadow: 0 2px 8px rgba(0,0,0,0.15); }

.esm-table-wrap {
  border: 1px solid rgba(0,0,0,0.06);
  border-radius: 12px;
  overflow: hidden;
  max-height: 320px;
  overflow-y: auto;
}

.esm-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.esm-table th {
  background: var(--primary-dark);
  color: #ffffff;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.4px;
  padding: 10px 12px;
  text-align: left;
  border-bottom: 1px solid rgba(0,0,0,0.06);
}
.esm-table td {
  padding: 10px 12px;
  border-bottom: 1px solid rgba(0,0,0,0.04);
  color: var(--text-primary);
}
.esm-table tr:last-child td { border-bottom: none; }
.esm-table tbody tr:hover { background: rgba(59,130,246,0.04); }

.esm-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}

.esm-btn-sm {
  padding: 6px 12px;
  border: 1px solid rgba(0,0,0,0.06);
  border-radius: 8px;
  background: var(--bg-input);
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.esm-btn-sm:disabled { opacity: 0.5; cursor: not-allowed; }

.esm-desc {
  font-size: 13px;
  color: var(--text-muted);
  margin: 0 0 14px;
}

.esm-etiqueta-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 12px;
}

.esm-etiqueta-card {
  position: relative;
  padding: 14px;
  border-radius: 14px;
  border: 2px solid rgba(0,0,0,0.06);
  background: var(--bg-input);
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 6px;
}
.esm-etiqueta-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.esm-etiqueta-card.active { border-color: var(--primary-gold); background: rgba(31,95,124,0.08); }
[data-theme="dark"] .esm-etiqueta-card.active { background: rgba(31,95,124,0.2); }

.esm-etq-dot { width: 10px; height: 10px; border-radius: 50%; }
.esm-etq-name { font-size: 14px; font-weight: 700; color: var(--text-primary); }
.esm-etq-count { font-size: 12px; color: var(--text-muted); }
.esm-etq-check { position: absolute; top: 10px; right: 10px; color: var(--primary-gold); font-size: 16px; }

.esm-summary {
  display: flex;
  gap: 14px;
  align-items: center;
  flex-wrap: wrap;
}
.esm-sum-item {
  font-size: 12px;
  color: var(--text-muted);
  display: flex;
  align-items: center;
  gap: 5px;
}
.esm-sum-total {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-primary);
  padding-left: 10px;
  border-left: 1px solid rgba(0,0,0,0.08);
}
.esm-overlap {
  color: var(--warning);
}

/* Reuse existing modal styles */
.preview-overlay {
  position: fixed; inset: 0; z-index: 2000;
  background: rgba(0,0,0,0.45); backdrop-filter: blur(10px);
  display: flex; align-items: center; justify-content: center; padding: 20px;
}
.preview-box {
  background: var(--bg-card); border-radius: 20px; box-shadow: var(--shadow-xl);
  width: 100%; max-width: 960px; max-height: 90vh;
  display: flex; flex-direction: column; overflow: hidden;
  animation: popIn 0.3s cubic-bezier(0.34,1.56,0.64,1);
}
@keyframes popIn { from { transform: scale(0.92); opacity: 0; } to { transform: scale(1); opacity: 1; } }

.pv-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 14px 20px; border-bottom: 1px solid rgba(0,0,0,0.05); flex-shrink: 0;
}
.pv-title { display: flex; align-items: center; gap: 12px; }
.pv-title h4 { margin: 0; font-size: 15px; font-weight: 700; color: var(--text-primary); }
.pv-title p { margin: 2px 0 0; font-size: 12px; color: var(--text-muted); }
.pv-close { width: 32px; height: 32px; border: none; border-radius: 10px; background: transparent; color: var(--text-muted); font-size: 14px; cursor: pointer; transition: all 0.2s; }
.pv-close:hover { background: var(--danger-bg); color: var(--danger); }

.pv-body { flex: 1; overflow: auto; padding: 20px; display: flex; flex-direction: column; align-items: center; gap: 12px; background: #f1f5f9; }
[data-theme="dark"] .pv-body { background: #0b1120; }

.pv-footer { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 20px; border-top: 1px solid rgba(0,0,0,0.05); }

.sf-btn { padding: 10px 18px; border: none; border-radius: 10px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; }
.sf-btn.ghost { background: transparent; color: var(--text-secondary); }
.sf-btn.ghost:hover { background: var(--bg-hover); }
.sf-btn.send { background: linear-gradient(135deg,#10b981,#059669); color: #fff; box-shadow: 0 2px 8px rgba(16,185,129,0.25); }
.sf-btn.send:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(16,185,129,0.35); }
.sf-btn.send:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

.badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 9999px;
  font-size: 11px;
  font-weight: 600;
  text-transform: capitalize;
}
.badge-info { background: rgba(59,130,246,0.12); color: #3b82f6; }
.badge-warning { background: rgba(245,158,11,0.12); color: #d97706; }
.badge-success { background: rgba(16,185,129,0.12); color: #059669; }

.esm-select-clasificacion {
  width: 160px;
  flex: none;
}

.esm-select-activo {
  width: 140px;
  flex: none;
}

@media (max-width: 1023px) {
  .preview-box {
    max-width: min(90vw, 760px) !important;
  }
}

@media (max-width: 768px) {
  .preview-overlay {
    padding: 10px;
  }

  .preview-box {
    max-width: 100% !important;
    max-height: 95vh;
    border-radius: 14px;
  }

  .pv-header {
    padding: 10px 14px;
  }

  .pv-title h4 {
    font-size: 14px;
  }

  .pv-body {
    padding: 0;
  }

  .esm-tabs {
    flex-direction: column;
    gap: 4px;
    padding: 4px;
  }

  .esm-tabs button {
    font-size: 12px;
    padding: 8px 10px;
    min-height: 44px;
  }

  .esm-tab-panel {
    padding: 12px;
  }

  .esm-filters {
    flex-direction: column;
  }

  .esm-select-clasificacion,
  .esm-select-activo {
    width: 100%;
  }

  .esm-table-wrap {
    max-height: 240px;
  }

  .esm-table th:nth-child(4),
  .esm-table td:nth-child(4) {
    display: none;
  }

  .pv-footer {
    flex-direction: column;
    gap: 10px;
    padding: 10px 14px;
  }

  .esm-summary {
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
  }

  .pv-footer .sf-btn {
    width: 100%;
    justify-content: center;
    min-height: 44px;
  }

  .esm-etiqueta-grid {
    grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .pv-title h4 {
    font-size: clamp(13px, 3.5vw, 15px);
  }

  .esm-tab-panel {
    padding: 10px;
  }

  .esm-banner {
    font-size: 11px;
    padding: 8px 10px;
  }

  .esm-etiqueta-grid {
    grid-template-columns: 1fr 1fr;
    gap: 6px;
  }

  .esm-etiqueta-card {
    padding: 10px;
  }

  .esm-etq-name {
    font-size: 12px;
  }

  .esm-sum-total {
    font-size: 12px;
    padding-left: 0;
    border-left: none;
    border-top: 1px solid rgba(0,0,0,0.08);
    padding-top: 6px;
    width: 100%;
  }
}
</style>
