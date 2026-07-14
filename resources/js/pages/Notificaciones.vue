<template>
  <div>
    <div class="flex justify-between items-center mb-lg">
      <h2 class="page-title" style="margin:0;"><i class="fas fa-bell" style="margin-right:8px;"></i>{{ i18n.t('notificaciones') }}</h2>
      <button class="btn btn-primary" @click="showCrear = true"><i class="fas fa-plus"></i> {{ i18n.t('notificaciones_nueva') }}</button>
    </div>

    <div class="tabs mb-md">
      <button class="tab-btn" :class="{ active: vista === 'mis' }" @click="vista = 'mis'">{{ i18n.t('notificaciones_tab_recibidas') }}</button>
      <button v-if="esAdmin" class="tab-btn" :class="{ active: vista === 'admin' }" @click="vista = 'admin'">{{ i18n.t('notificaciones_tab_enviadas') }}</button>
    </div>

    <!-- Filtros -->
    <div class="card mb-md">
      <div class="card-body" style="display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end;">
        <div class="form-group" style="flex:1;min-width:160px;">
          <label class="form-label">{{ i18n.t('buscar') }}</label>
          <input v-model="filtros.busqueda" class="form-control" :placeholder="i18n.t('notificaciones_buscar')">
        </div>
        <div class="form-group" style="min-width:140px;">
          <label class="form-label">{{ i18n.t('notificaciones_tipo') }}</label>
          <select v-model="filtros.tipo" class="form-control">
            <option value="">{{ i18n.t('todos') }}</option>
            <option v-for="t in tipos" :key="t.slug" :value="t.slug">{{ t.nombre }}</option>
          </select>
        </div>
        <div class="form-group" style="min-width:140px;">
          <label class="form-label">{{ i18n.t('notificaciones_prioridad') }}</label>
          <select v-model="filtros.prioridad" class="form-control">
            <option value="">{{ i18n.t('notificaciones_filtro_todas') }}</option>
            <option value="baja">{{ i18n.t('notificaciones_baja') }}</option>
            <option value="normal">{{ i18n.t('notificaciones_normal') }}</option>
            <option value="alta">{{ i18n.t('notificaciones_alta') }}</option>
            <option value="urgente">{{ i18n.t('notificaciones_urgente') }}</option>
          </select>
        </div>
        <div class="form-group" style="min-width:120px;">
          <label class="form-label">{{ i18n.t('estado') }}</label>
          <select v-model="filtros.estado" class="form-control">
            <option value="">{{ i18n.t('todos') }}</option>
            <option value="noleida">{{ i18n.t('notificaciones_filtro_no_leidas') }}</option>
            <option value="leida">{{ i18n.t('notificaciones_leidas') }}</option>
          </select>
        </div>
        <button class="btn btn-ghost" @click="resetFiltros"><i class="fas fa-undo"></i></button>
      </div>
    </div>

    <!-- Vista Mis Notificaciones -->
    <div v-if="vista === 'mis'">
      <div v-if="!notificacionesFiltradas.length" class="card">
        <div class="card-body" style="text-align:center;color:var(--text-muted);padding:40px;">
          <i class="fas fa-inbox" style="font-size:36px;margin-bottom:10px;"></i>
          <p>{{ i18n.t('notificaciones_sin_datos') }}</p>
        </div>
      </div>
      <div v-else class="notif-grid">
        <div v-for="n in notificacionesFiltradas" :key="n.id" class="notif-card" :class="{ unread: !n.leido }">
          <div class="notif-card-header">
            <div class="notif-card-icon" :style="{ background: n.color + '22', color: n.color }">
              <i :class="n.icono || 'fas fa-bell'"></i>
            </div>
            <div style="flex:1;min-width:0;">
              <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;">
                <strong style="font-size:14px;">{{ n.titulo }}</strong>
                <span v-if="n.prioridad === 'urgente'" class="badge badge-danger">{{ i18n.t('notificaciones_urgente') }}</span>
                <span v-else-if="n.prioridad === 'alta'" class="badge badge-warning">{{ i18n.t('notificaciones_alta') }}</span>
              </div>
              <div style="font-size:12px;color:var(--text-muted);margin-top:2px;">{{ formatoFecha(n.enviada_en) }}</div>
            </div>
          </div>
          <p style="margin:10px 0 0;font-size:13px;color:var(--text-secondary);line-height:1.5;">{{ n.mensaje }}</p>
          <div class="notif-card-footer">
            <span class="badge" :style="{ background: n.color + '22', color: n.color }">{{ tipoLabel(n.tipo) }}</span>
            <div style="display:flex;gap:8px;align-items:center;">
              <button v-if="!n.leido" class="btn btn-xs btn-primary" @click="marcarLeida(n)">{{ i18n.t('notificaciones_marcar_leido') }}</button>
              <span v-else class="text-muted" style="font-size:12px;"><i class="fas fa-check"></i> {{ i18n.t('notificaciones_leidas') }}</span>
              <button class="btn btn-xs btn-danger" @click="descartarNotif(n)" :title="i18n.t('notificaciones_eliminar')"><i class="fas fa-trash"></i></button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Vista Admin -->
    <div v-if="vista === 'admin' && esAdmin">
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('notificaciones_titulo_label') }}</th>
                <th>{{ i18n.t('notificaciones_tipo') }}</th>
                <th>{{ i18n.t('notificaciones_prioridad') }}</th>
                <th>{{ i18n.t('creado') }}</th>
                <th>{{ i18n.t('fecha') }}</th>
                <th>{{ i18n.t('notificaciones_total') }}</th>
                <th>{{ i18n.t('notificaciones_leidas') }}</th>
                <th>{{ i18n.t('notificaciones_pendientes') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="n in notificacionesAdminFiltradas" :key="n.id">
                <td><strong>{{ n.titulo }}</strong></td>
                <td><span class="badge" :style="{ background: n.color + '22', color: n.color }">{{ tipoLabel(n.tipo) }}</span></td>
                <td>
                  <span v-if="n.prioridad === 'urgente'" class="badge badge-danger">{{ i18n.t('notificaciones_urgente') }}</span>
                  <span v-else-if="n.prioridad === 'alta'" class="badge badge-warning">{{ i18n.t('notificaciones_alta') }}</span>
                  <span v-else-if="n.prioridad === 'baja'" class="badge badge-info">{{ i18n.t('notificaciones_baja') }}</span>
                  <span v-else class="badge badge-ghost">{{ i18n.t('notificaciones_normal') }}</span>
                </td>
                <td>{{ n.creador?.nombre || '-' }}</td>
                <td>{{ formatoFecha(n.enviada_en) }}</td>
                <td>{{ n.total_enviados }}</td>
                <td>{{ n.total_leidos }}</td>
                <td>{{ n.total_enviados - n.total_leidos }}</td>
                <td>
                  <button class="btn btn-sm btn-danger" @click="eliminarNotif(n.id)"><i class="fas fa-trash"></i></button>
                </td>
              </tr>
            </tbody>
          </table>
          </div>
          <div v-if="!notificacionesAdminFiltradas.length" style="text-align:center;color:var(--text-muted);padding:40px;">
            <i class="fas fa-inbox" style="font-size:36px;margin-bottom:10px;"></i>
            <p>{{ i18n.t('notificaciones_sin_datos') }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear Notificación -->
    <div class="modal-overlay" :class="{ active: showCrear }" @click.self="showCrear = false">
      <div class="modal" style="max-width: min(90vw, 560px); max-height: 85vh; overflow-y: auto;">
        <div class="modal-header">
          <h3 class="modal-title">{{ i18n.t('notificaciones_nueva') }}</h3>
          <button class="modal-close" @click="showCrear = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">{{ i18n.t('notificaciones_titulo_label') }} <span class="text-danger">*</span></label>
            <input v-model="form.titulo" class="form-control" placeholder="Ej: Mantenimiento programado">
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('notificaciones_mensaje') }} <span class="text-danger">*</span></label>
            <textarea v-model="form.mensaje" class="form-control" rows="3" placeholder="Describe la notificación..."></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('notificaciones_tipo') }} <span class="text-danger">*</span></label>
            <div class="tipo-grid">
              <div v-for="t in tipos" :key="t.slug" class="tipo-card" :class="{ active: form.tipo === t.slug }" @click="form.tipo = t.slug; form.color = t.color; form.icono = t.icono">
                <i :class="t.icono" :style="{ color: t.color }"></i>
                <span>{{ t.nombre }}</span>
              </div>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('notificaciones_prioridad') }} <span class="text-danger">*</span></label>
            <select v-model="form.prioridad" class="form-control">
              <option value="baja">{{ i18n.t('notificaciones_baja') }}</option>
              <option value="normal">{{ i18n.t('notificaciones_normal') }}</option>
              <option value="alta">{{ i18n.t('notificaciones_alta') }}</option>
              <option value="urgente">{{ i18n.t('notificaciones_urgente') }}</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Color del badge</label>
            <div style="display:flex;gap:10px;align-items:center;">
              <input v-model="form.color" type="color" style="width:48px;height:36px;border:none;border-radius:6px;cursor:pointer;">
              <span style="font-size:13px;color:var(--text-muted);">{{ form.color }}</span>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Icono</label>
            <select v-model="form.icono" class="form-control">
              <option value="fas fa-bell">Campana</option>
              <option value="fas fa-info-circle">Info</option>
              <option value="fas fa-exclamation-triangle">Advertencia</option>
              <option value="fas fa-check-circle">{{ i18n.t('exito') }}</option>
              <option value="fas fa-times-circle">{{ i18n.t('error') }}</option>
              <option value="fas fa-cog">{{ i18n.t('notificaciones_sistema') }}</option>
              <option value="fas fa-clock">Recordatorio</option>
              <option value="fas fa-bolt">{{ i18n.t('notificaciones_urgente') }}</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('notificaciones_destinatarios') }}</label>
            <div style="display:flex;gap:8px;margin-bottom:8px;">
              <label style="display:flex;align-items:center;gap:4px;font-size:13px;cursor:pointer;">
                <input v-model="form.global" type="checkbox"> Enviar a todos los usuarios
              </label>
            </div>
            <div v-if="!form.global">
              <label class="form-label" style="font-size:12px;">Por roles</label>
              <div class="chips-row">
                <span v-for="r in roles" :key="r.id" class="chip" :class="{ active: form.roles.includes(r.id) }" @click="toggleRole(r.id)">
                  {{ r.nombre }}
                </span>
              </div>
              <label class="form-label" style="font-size:12px;margin-top:10px;">Usuarios específicos</label>
              <div class="chips-row">
                <span v-for="u in usuariosDisponibles" :key="u.id" class="chip" :class="{ active: form.destinatarios.includes(u.id) }" @click="toggleUsuario(u.id)">
                  {{ u.nombre }}
                </span>
              </div>
            </div>
          </div>
          <div class="preview-box">
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:8px;">Vista previa</div>
            <div class="notif-preview-item">
              <div class="notif-preview-icon" :style="{ background: form.color + '22', color: form.color }">
                <i :class="form.icono"></i>
              </div>
              <div>
                <div style="font-weight:600;font-size:13px;">{{ form.titulo || 'Título de la notificación' }}</div>
                <div style="font-size:12px;color:var(--text-secondary);margin-top:2px;">{{ form.mensaje || 'Contenido del mensaje...' }}</div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showCrear = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="enviarNotificacion" :disabled="!form.titulo || !form.mensaje || !form.tipo">{{ i18n.t('notificaciones_enviar') }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const confirm = useConfirmStore();
const i18n = useI18nStore();

const authStore = useAuthStore();
const esAdmin = computed(() => authStore.user?.rol_nombre === 'admin');

const vista = ref('mis');
const showCrear = ref(false);
const notificaciones = ref([]);
const notificacionesAdmin = ref([]);
const tipos = ref([]);
const roles = ref([]);
const usuariosDisponibles = ref([]);

const filtros = ref({ busqueda: '', tipo: '', prioridad: '', estado: '' });

const form = ref({
  titulo: '', mensaje: '', tipo: 'informativa', prioridad: 'normal',
  color: '#3b82f6', icono: 'fas fa-bell',
  global: false, destinatarios: [], roles: []
});

const notificacionesFiltradas = computed(() => {
  return notificaciones.value.filter(n => {
    const q = filtros.value.busqueda.toLowerCase();
    const matchQ = !q || (n.titulo || '').toLowerCase().includes(q) || (n.mensaje || '').toLowerCase().includes(q);
    const matchTipo = !filtros.value.tipo || n.tipo === filtros.value.tipo;
    const matchPrioridad = !filtros.value.prioridad || n.prioridad === filtros.value.prioridad;
    const matchEstado = !filtros.value.estado ||
      (filtros.value.estado === 'noleida' && !n.leido) ||
      (filtros.value.estado === 'leida' && n.leido);
    return matchQ && matchTipo && matchPrioridad && matchEstado;
  });
});

const notificacionesAdminFiltradas = computed(() => {
  return notificacionesAdmin.value.filter(n => {
    const q = filtros.value.busqueda.toLowerCase();
    const matchQ = !q || (n.titulo || '').toLowerCase().includes(q) || (n.mensaje || '').toLowerCase().includes(q);
    const matchTipo = !filtros.value.tipo || n.tipo === filtros.value.tipo;
    const matchPrioridad = !filtros.value.prioridad || n.prioridad === filtros.value.prioridad;
    return matchQ && matchTipo && matchPrioridad;
  });
});

async function cargarNotificaciones() {
  try {
    const { data } = await api.get('/notificaciones');
    notificaciones.value = data.notificaciones || [];
  } catch (e) {}
}

async function cargarNotificacionesAdmin() {
  if (!esAdmin.value) return;
  try {
    const { data } = await api.get('/notificaciones?panel=admin');
    notificacionesAdmin.value = data.notificaciones?.data || [];
  } catch (e) {}
}

async function cargarTipos() {
  try {
    const { data } = await api.get('/notificaciones/tipos');
    tipos.value = data.tipos || [];
  } catch (e) {}
}

async function cargarUsuarios() {
  try {
    const { data } = await api.get('/usuarios');
    usuariosDisponibles.value = (data.usuarios || []).filter(u => u.id !== authStore.user?.id);
  } catch (e) {}
}

async function cargarRoles() {
  try {
    const { data } = await api.get('/roles');
    roles.value = data.roles || [];
  } catch (e) {}
}

async function enviarNotificacion() {
  try {
    await api.post('/notificaciones', {
      titulo: form.value.titulo,
      mensaje: form.value.mensaje,
      tipo: form.value.tipo,
      prioridad: form.value.prioridad,
      color: form.value.color,
      icono: form.value.icono,
      global: form.value.global,
      destinatarios: form.value.destinatarios,
      roles: form.value.roles,
    });
    showCrear.value = false;
    resetForm();
    await cargarNotificaciones();
    await cargarNotificacionesAdmin();
  } catch (e) {
    toast.error(e.response?.data?.error || i18n.t('notificaciones_error_enviar_notificacion'));
  }
}

async function marcarLeida(n) {
  try {
    await api.post(`/notificaciones/${n.id}/leida`);
    n.leido = true;
    n.leido_at = new Date().toISOString();
  } catch (e) {}
}

async function eliminarNotif(id) {
  if (!await confirm.ask({ message: i18n.t('notificaciones_confirmar_eliminar'), confirmText: i18n.t('eliminar'), type: 'danger' })) return;
  try {
    await api.delete(`/notificaciones/${id}`);
    await cargarNotificacionesAdmin();
  } catch (e) {}
}

async function descartarNotif(n) {
  if (!await confirm.ask({ message: i18n.t('notificaciones_confirmar_eliminar'), confirmText: i18n.t('eliminar'), type: 'warning' })) return;
  try {
    await api.delete(`/notificaciones/${n.id}/descartar`);
    const idx = notificaciones.value.findIndex(x => x.id === n.id);
    if (idx >= 0) notificaciones.value.splice(idx, 1);
  } catch (e) {}
}

function toggleRole(id) {
  const i = form.value.roles.indexOf(id);
  if (i >= 0) form.value.roles.splice(i, 1);
  else form.value.roles.push(id);
}

function toggleUsuario(id) {
  const i = form.value.destinatarios.indexOf(id);
  if (i >= 0) form.value.destinatarios.splice(i, 1);
  else form.value.destinatarios.push(id);
}

function resetForm() {
  form.value = { titulo: '', mensaje: '', tipo: 'informativa', prioridad: 'normal', color: '#3b82f6', icono: 'fas fa-bell', global: false, destinatarios: [], roles: [] };
}

function resetFiltros() {
  filtros.value = { busqueda: '', tipo: '', prioridad: '', estado: '' };
}

function tipoLabel(slug) {
  const t = tipos.value.find(x => x.slug === slug);
  return t ? t.nombre : slug;
}

function formatoFecha(fecha) {
  if (!fecha) return '-';
  const d = new Date(fecha);
  const now = new Date();
  const diff = Math.floor((now - d) / 1000);
  if (diff < 60) return i18n.t('hace_momento');
  if (diff < 3600) return i18n.tp('hace_min', { n: Math.floor(diff / 60) });
  if (diff < 86400) return i18n.tp('hace_h', { n: Math.floor(diff / 3600) });
  return d.toLocaleDateString('es-CR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}

onMounted(() => {
  cargarNotificaciones();
  cargarNotificacionesAdmin();
  cargarTipos();
  cargarUsuarios();
  cargarRoles();
});
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.tabs {
  display: flex;
  gap: 4px;
  border-bottom: 1px solid var(--bg-hover);
}

.tab-btn {
  padding: 10px 18px;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  font-size: 14px;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.15s;
}

.tab-btn.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
  font-weight: 600;
}

.notif-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
}

.notif-card {
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
  border-radius: 12px;
  padding: 16px;
  transition: box-shadow 0.15s, border-color 0.15s;
}

.notif-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.notif-card.unread {
  border-left: 3px solid #3b82f6;
}

.notif-card-header {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.notif-card-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  flex-shrink: 0;
}

.notif-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
  padding-top: 10px;
  border-top: 1px solid var(--bg-hover);
}

.tipo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 8px;
}

.tipo-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 10px;
  border: 1px solid var(--bg-hover);
  border-radius: 10px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.15s;
}

.tipo-card.active {
  border-color: var(--primary);
  background: rgba(59,130,246,0.08);
}

.chips-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  max-height: 120px;
  overflow-y: auto;
}

.preview-box {
  background: var(--bg-hover);
  border-radius: 10px;
  padding: 14px;
  margin-top: 10px;
}

.notif-preview-item {
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--bg-card);
  border: 1px solid var(--bg-hover);
  border-radius: 10px;
  padding: 10px;
}

.notif-preview-icon {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  flex-shrink: 0;
}

.badge-ghost {
  background: var(--bg-hover);
  color: var(--text-muted);
}

.badge-info {
  background: rgba(59,130,246,0.15);
  color: #3b82f6;
}

.badge-warning {
  background: rgba(245,158,11,0.15);
  color: #d97706;
}

.text-muted {
  color: var(--text-muted);
}

@media (max-width: 768px) {
  .modal {
    max-width: min(90vw, 500px);
  }
  
  .notif-grid {
    grid-template-columns: 1fr;
  }
  
  .tipo-grid {
    grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  }
  
  .grid-2 {
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
  
  .tab-btn {
    padding: 12px 14px;
    font-size: clamp(12px, 2.5vw, 14px);
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
  
  .notif-card {
    padding: 12px;
  }
  
  .notif-card-header {
    flex-direction: column;
    gap: 8px;
  }
  
  .notif-card-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  
  .notif-card-footer > div {
    justify-content: space-between;
  }
  
  .tipo-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .chips-row {
    max-height: 100px;
  }
  
  .preview-box {
    padding: 10px;
  }
  
  .notif-preview-item {
    flex-direction: column;
    text-align: center;
    gap: 8px;
  }
}
</style>
