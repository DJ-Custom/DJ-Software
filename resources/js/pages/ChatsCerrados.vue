<template>
  <div class="chat-cerrados-page">
    <div class="flex justify-between items-center mb-lg">
      <h2 class="page-title" style="margin:0;">
        <i class="fas fa-lock" style="margin-right:8px;color:var(--danger);"></i>
        {{ i18n.t('chats_cerrados_titulo') }}
      </h2>
      <span class="badge badge-danger">{{ i18n.t('chats_cerrados_solo_lectura') }}</span>
    </div>

    <!-- Filtros -->
    <div class="card mb-lg">
      <div class="card-body" style="display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end;">
        <div class="form-group" style="flex:1;min-width:200px;">
          <label class="form-label">{{ i18n.t('buscar') }}</label>
          <input v-model="filtros.busqueda" class="form-control" :placeholder="i18n.t('chats_cerrados_buscar')">
        </div>
        <div class="form-group" style="min-width:160px;">
          <label class="form-label">{{ i18n.t('chats_cerrados_creador') }}</label>
          <select v-model="filtros.creador" class="form-control">
            <option value="">{{ i18n.t('todos') }}</option>
            <option v-for="u in creadoresUnicos" :key="u" :value="u">{{ u }}</option>
          </select>
        </div>
        <div class="form-group" style="min-width:160px;">
          <label class="form-label">{{ i18n.t('chats_cerrados_desde') }}</label>
          <input v-model="filtros.fechaDesde" type="date" class="form-control">
        </div>
        <div class="form-group" style="min-width:160px;">
          <label class="form-label">{{ i18n.t('chats_cerrados_hasta') }}</label>
          <input v-model="filtros.fechaHasta" type="date" class="form-control">
        </div>
        <button class="btn btn-ghost" @click="resetFiltros"><i class="fas fa-undo"></i></button>
      </div>
    </div>

    <!-- Lista -->
    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ i18n.t('estado') }}</th>
              <th>{{ i18n.t('chats_cerrados_titulo_col') }}</th>
              <th>{{ i18n.t('chats_cerrados_participantes') }}</th>
              <th>{{ i18n.t('chats_cerrados_creador') }}</th>
              <th>{{ i18n.t('chats_cerrados_cerrado_por') }}</th>
              <th>{{ i18n.t('chats_cerrados_fecha_cierre') }}</th>
              <th>{{ i18n.t('chats_cerrados_mensajes') }}</th>
              <th>{{ i18n.t('chats_cerrados_ultimo_mensaje') }}</th>
              <th>{{ i18n.t('acciones') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="chat in chatsFiltrados" :key="chat.id" class="chat-row" @click="verChat(chat)">
              <td><span class="badge badge-danger">{{ i18n.t('chats_cerrados_cerrado') }}</span></td>
              <td><strong>{{ chat.titulo }}</strong></td>
              <td>
                <div class="participantes-chips">
                  <span v-for="(n, i) in (chat.participantes_nombres || []).slice(0, 3)" :key="i" class="chip">{{ n }}</span>
                  <span v-if="(chat.participantes_nombres || []).length > 3" class="chip muted">+{{ (chat.participantes_nombres || []).length - 3 }}</span>
                </div>
              </td>
              <td>{{ chat.creador?.nombre || '-' }}</td>
              <td>{{ chat.cerrado_por?.nombre || '-' }}</td>
              <td>{{ formatoFecha(chat.cerrado_en) }}</td>
              <td>{{ chat.mensajes_count || 0 }}</td>
              <td class="cell-preview">{{ chat.ultimo_mensaje?.contenido || '-' }}</td>
              <td>
                <button v-if="esAdmin || chat.creador_id === authStore.user?.id" class="btn btn-sm btn-danger" @click.stop="eliminarChat(chat.id)">
                  <i class="fas fa-trash"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        </div>
        <div v-if="!chatsFiltrados.length" style="text-align:center;color:var(--text-muted);padding:40px;">
          <i class="fas fa-inbox" style="font-size:36px;margin-bottom:10px;"></i>
          <p>{{ i18n.t('chats_cerrados_sin_datos') }}</p>
        </div>
      </div>
    </div>

    <!-- Modal Vista Chat Cerrado -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal" style="max-width: min(90vw, 640px); max-height: 80vh; display: flex; flex-direction: column;">
        <div class="modal-header">
          <h3 class="modal-title">
            <span class="badge badge-danger" style="margin-right:8px;">{{ i18n.t('chats_cerrados_cerrado') }}</span>
            {{ chatSeleccionado?.titulo }}
          </h3>
          <button class="modal-close" @click="showModal = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" style="overflow-y:auto;flex:1;">
          <div class="chat-closed-banner">
            <i class="fas fa-lock"></i> {{ i18n.t('chats_cerrados_chat_fue_cerrado') }}
          </div>
          <div class="chat-meta-info">
            <div><strong>{{ i18n.t('chats_cerrados_creador') }}:</strong> {{ chatSeleccionado?.creador?.nombre }}</div>
            <div><strong>{{ i18n.t('chats_cerrados_cerrado_por') }}:</strong> {{ chatSeleccionado?.cerrado_por?.nombre || '-' }}</div>
            <div><strong>{{ i18n.t('chats_cerrados_fecha_cierre') }}:</strong> {{ formatoFecha(chatSeleccionado?.cerrado_en) }}</div>
            <div><strong>{{ i18n.t('chats_cerrados_participantes') }}:</strong> {{ (chatSeleccionado?.participantes_nombres || []).join(', ') }}</div>
          </div>
          <div class="chat-historial">
            <div v-for="msg in mensajes" :key="msg.id" class="chat-msg-readonly">
              <div class="chat-msg-readonly-header">
                <strong>{{ msg.usuario?.nombre || i18n.t('chats_cerrados_usuario') }}</strong>
                <span class="chat-msg-time">{{ formatoHora(msg.created_at) }}</span>
              </div>
              <div v-if="msg.contenido" class="chat-msg-readonly-body">{{ msg.contenido }}</div>
              <div v-if="msg.archivo_url" class="chat-msg-readonly-attachment">
                <a
                  v-if="msg.archivo_tipo?.startsWith('image/')"
                  href="#"
                  class="chat-attachment-image-link"
                  @click.prevent="verImagen(msg)"
                >
                  <img
                    :src="getArchivoUrl(msg)"
                    :alt="msg.archivo_nombre"
                    class="chat-attachment-image"
                    @error="cargarImagenBlob(msg)"
                  />
                </a>
                <a
                  v-else
                  href="#"
                  class="chat-attachment-file"
                  @click.prevent="descargarArchivo(msg)"
                >
                  <i class="fas fa-file"></i>
                  <div class="chat-attachment-info">
                    <span class="chat-attachment-name">{{ msg.archivo_nombre }}</span>
                    <span class="chat-attachment-size">{{ formatoSize(msg.archivo_size) }}</span>
                  </div>
                </a>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showModal = false">{{ i18n.t('cerrar') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import api from '../services/api';
import { getToken } from '../services/authToken';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const toast = useToastStore();
const confirm = useConfirmStore();

const authStore = useAuthStore();
const esAdmin = computed(() => authStore.user?.rol_nombre === 'admin');

const chats = ref([]);
const filtros = ref({ busqueda: '', creador: '', fechaDesde: '', fechaHasta: '' });
const showModal = ref(false);
const chatSeleccionado = ref(null);
const mensajes = ref([]);
const imagenBlobs = ref({});

const creadoresUnicos = computed(() => {
  const nombres = chats.value.map(c => c.creador?.nombre).filter(Boolean);
  return [...new Set(nombres)].sort();
});

const chatsFiltrados = computed(() => {
  return chats.value.filter(c => {
    const q = filtros.value.busqueda.toLowerCase();
    const matchQ = !q ||
      (c.titulo || '').toLowerCase().includes(q) ||
      (c.descripcion || '').toLowerCase().includes(q) ||
      (c.participantes_nombres || []).some(n => n.toLowerCase().includes(q));
    const matchCreador = !filtros.value.creador || c.creador?.nombre === filtros.value.creador;
    const matchDesde = !filtros.value.fechaDesde || new Date(c.cerrado_en) >= new Date(filtros.value.fechaDesde);
    const matchHasta = !filtros.value.fechaHasta || new Date(c.cerrado_en) <= new Date(filtros.value.fechaHasta + 'T23:59:59');
    return matchQ && matchCreador && matchDesde && matchHasta;
  });
});

async function cargarCerrados() {
  try {
    const { data } = await api.get('/chats-cerrados');
    chats.value = data.chats || [];
  } catch (e) {}
}

function limpiarBlobs() {
  for (const url of Object.values(imagenBlobs.value)) {
    URL.revokeObjectURL(url);
  }
  imagenBlobs.value = {};
}

async function verChat(chat) {
  limpiarBlobs();
  chatSeleccionado.value = chat;
  showModal.value = true;
  try {
    const { data } = await api.get(`/chats/${chat.id}/mensajes`);
    mensajes.value = data.mensajes?.data || [];
  } catch (e) {}
}

async function eliminarChat(id) {
  if (!await confirm.ask({ message: i18n.t('chats_cerrados_eliminar_permanente'), confirmText: i18n.t('eliminar'), type: 'danger' })) return;
  try {
    await api.delete(`/chats/${id}`);
    await cargarCerrados();
  } catch (e) {
    toast.error(e.response?.data?.error || i18n.t('chats_cerrados_error_eliminar'));
  }
}

function resetFiltros() {
  filtros.value = { busqueda: '', creador: '', fechaDesde: '', fechaHasta: '' };
}

function formatoFecha(fecha) {
  if (!fecha) return '-';
  return new Date(fecha).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function formatoHora(fecha) {
  if (!fecha) return '';
  return new Date(fecha).toLocaleString('es-CR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}

function formatoSize(bytes) {
  if (!bytes) return '';
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
}

function getArchivoUrl(msg) {
  if (imagenBlobs.value[msg.id]) return imagenBlobs.value[msg.id];
  if (msg.archivo_url_completa) return msg.archivo_url_completa;
  if (msg.archivo_url) return `/storage/${msg.archivo_url}`;
  return '';
}

async function cargarImagenBlob(msg) {
  if (imagenBlobs.value[msg.id] || !msg.archivo_url) return;
  try {
    const token = getToken();
    const url = msg.archivo_url_completa || `${window.location.origin}/storage/${msg.archivo_url}`;
    const res = await fetch(url, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
    if (res.ok) {
      const blob = await res.blob();
      imagenBlobs.value[msg.id] = URL.createObjectURL(blob);
    }
  } catch (e) {
    console.warn('Error cargando imagen:', e);
  }
}

async function descargarArchivo(msg) {
  try {
    const token = getToken();
    const res = await fetch(`/api/chats/${msg.chat_id}/mensajes/${msg.id}/adjunto`, {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const blob = await res.blob();
    const blobUrl = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = blobUrl;
    a.download = msg.archivo_nombre || 'archivo';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(blobUrl), 5000);
  } catch (e) {
    toast.error(i18n.t('chats_cerrados_error_descargar'));
    console.error(e);
  }
}

async function verImagen(msg) {
  try {
    const token = getToken();
    const url = msg.archivo_url_completa || `${window.location.origin}/storage/${msg.archivo_url}`;
    const res = await fetch(url, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const blob = await res.blob();
    const blobUrl = URL.createObjectURL(blob);
    window.open(blobUrl, '_blank');
    setTimeout(() => URL.revokeObjectURL(blobUrl), 60000);
  } catch (e) {
    toast.error(i18n.t('chats_cerrados_error_imagen'));
    console.error(e);
  }
}

onMounted(cargarCerrados);
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.participantes-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.cell-preview {
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chat-row {
  cursor: pointer;
  transition: background 0.15s;
}

.chat-row:hover {
  background: var(--bg-hover);
}

.chat-closed-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: var(--danger-bg, rgba(239,68,68,0.1));
  border: 1px solid var(--danger);
  border-radius: 8px;
  color: var(--danger);
  font-size: 13px;
  margin-bottom: 14px;
}

.chat-meta-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px 16px;
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--bg-hover);
}

.chat-historial {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.chat-msg-readonly {
  padding: 10px 12px;
  border-radius: 10px;
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
}

.chat-msg-readonly-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
  font-size: 12px;
}

.chat-msg-readonly-body {
  font-size: 13px;
  color: var(--text-primary);
  line-height: 1.4;
}

.chat-msg-time {
  color: var(--text-muted);
  font-size: 11px;
}

.chat-msg-readonly-attachment {
  margin-top: 6px;
}

.chat-attachment-image-link {
  display: block;
  max-width: 240px;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid var(--bg-hover);
}

.chat-attachment-image {
  width: 100%;
  height: auto;
  display: block;
  object-fit: cover;
}

.chat-attachment-file {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  border-radius: 10px;
  background: var(--bg-primary);
  border: 1px solid var(--bg-hover);
  color: var(--text-primary);
  font-size: 13px;
  text-decoration: none;
  transition: background 0.15s;
}

.chat-attachment-file:hover {
  background: var(--bg-hover);
}

.chat-attachment-file i {
  font-size: 20px;
  color: var(--primary);
}

.chat-attachment-info {
  display: flex;
  flex-direction: column;
  line-height: 1.3;
}

.chat-attachment-name {
  font-weight: 600;
  max-width: 180px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.chat-attachment-size {
  font-size: 11px;
  color: var(--text-muted);
}

@media (max-width: 768px) {
  .modal {
    max-width: min(90vw, 500px);
  }
  
  .grid-2 {
    grid-template-columns: 1fr;
  }
  
  .chat-meta-info {
    grid-template-columns: 1fr;
  }
  
  .form-group {
    margin-bottom: 12px;
  }
  
  .form-control {
    min-height: 44px;
  }
  
  .btn {
    min-height: 44px;
    min-width: 44px;
  }
  
  .table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  .cell-preview {
    max-width: 120px;
  }

  /* Override inline min-width styles for mobile */
  .form-group[style*="min-width: 200px"] {
    min-width: 0 !important;
    flex: 1 1 100%;
  }
  .form-group[style*="min-width: 160px"] {
    min-width: 0 !important;
    flex: 1 1 calc(50% - 12px);
  }
}

@media (max-width: 480px) {
  .flex.justify-between.items-center.mb-lg {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .card-body {
    padding: 8px;
  }
  
  .chat-attachment-image-link {
    max-width: 100%;
  }
  
  .chat-attachment-name {
    max-width: 140px;
  }
  
  .chat-closed-banner {
    font-size: clamp(11px, 2.5vw, 13px);
    padding: 8px 12px;
  }
  
  .chat-meta-info {
    font-size: clamp(11px, 2.5vw, 13px);
  }

  /* Stack all filters on small phones */
  .form-group[style*="min-width: 200px"],
  .form-group[style*="min-width: 160px"] {
    flex: 1 1 100%;
  }
}
</style>
