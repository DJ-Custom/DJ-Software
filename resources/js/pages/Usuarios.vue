<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h2 style="font-size:18px; font-weight:700;">{{ i18n.t('gestion_usuarios') }}</h2>
      <button class="btn btn-primary" @click="showModal = true; resetForm()">
        <i class="fas fa-plus"></i> {{ i18n.t('nuevo_usuario') }}
      </button>
    </div>

    <!-- Search & Filters -->
    <div class="card mb-md" style="padding:12px 16px;">
      <div class="flex items-center gap-sm flex-wrap">
        <div style="flex:1;min-width:200px;position:relative;">
          <i class="fas fa-search" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:13px;"></i>
          <input v-model="filtro.q" class="form-control" :placeholder="i18n.t('buscar_usuario')" style="padding-left:32px;">
        </div>
        <select v-model="filtro.rol_id" class="form-control">
          <option value="">{{ i18n.t('todos_los_roles') }}</option>
          <option v-for="r in roles" :key="r.id" :value="r.id">{{ r.nombre }}</option>
        </select>
        <select v-model="filtro.estado" class="form-control">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="activo">{{ i18n.t('activos') }}</option>
          <option value="inactivo">{{ i18n.t('inactivos') }}</option>
        </select>
        <span class="badge badge-info">{{ usuariosFiltrados.length }} de {{ usuarios.length }}</span>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-user-shield" style="margin-right:8px;"></i>{{ i18n.t('usuarios') }}</h3>
        <span class="badge badge-info">{{ usuarios.length }} {{ i18n.t('todos') }}</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('usuario_nombre') }}</th>
                <th>{{ i18n.t('usuario_email') }}</th>
                <th>{{ i18n.t('usuario_rol') }}</th>
                <th>{{ i18n.t('usuario_estado') }}</th>
                <th>{{ i18n.t('usuario_ultimo_login') }}</th>
                <th>{{ i18n.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="u in usuariosFiltrados" :key="u.id" class="animate-fade-in">
                <td><strong>{{ u.nombre }}</strong></td>
                <td>{{ u.email }}</td>
                <td><span class="badge badge-info">{{ u.rol_nombre }}</span></td>
                <td>
                  <span :class="['badge', u.activo ? 'badge-success' : 'badge-danger']">
                    {{ u.activo ? i18n.t('activo') : i18n.t('inactivo') }}
                  </span>
                </td>
                <td>{{ u.ultimo_login ? formatDate(u.ultimo_login) : i18n.t('nunca') }}</td>
                <td>
                  <div class="flex gap-sm">
                    <button class="btn btn-sm btn-ghost" @click="editar(u)"><i class="fas fa-edit"></i></button>
                    <button class="btn btn-sm btn-ghost" @click="toggleEstado(u)" :title="u.activo ? i18n.t('desactivar') : i18n.t('activar')">
                      <i :class="u.activo ? 'fas fa-ban' : 'fas fa-check'" :style="{ color: u.activo ? 'var(--danger)' : 'var(--success)' }"></i>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!usuarios.length">
                <td colspan="6" style="text-align:center; padding:40px; color: var(--text-muted);">{{ i18n.t('no_hay_usuarios') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingId ? i18n.t('editar_usuario') : i18n.t('nuevo_usuario') }}</h3>
          <button class="modal-close" @click="showModal = false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="form-label">{{ i18n.t('usuario_nombre') }} *</label>
            <input v-model="form.nombre" class="form-control" placeholder="Nombre completo" required />
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('usuario_email') }} *</label>
            <input v-model="form.email" type="email" class="form-control" placeholder="correo@email.com" required />
          </div>
          <div class="form-group">
            <label class="form-label">{{ editingId ? 'Nueva contraseña (dejar vacío para no cambiar)' : 'Contraseña *' }}</label>
            <input v-model="form.password" type="password" class="form-control" placeholder="••••••••" :required="!editingId" />
          </div>
          <div class="form-group">
            <label class="form-label">{{ i18n.t('usuario_rol') }}</label>
            <select v-model="form.rol_id" class="form-control">
              <option v-for="r in roles" :key="r.id" :value="r.id">{{ r.nombre }}</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showModal = false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardar" :disabled="isSubmitting">
            <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
            <span v-if="isSubmitting">{{ i18n.t('guardando_usuario') }}</span>
            <span v-else>{{ editingId ? i18n.t('actualizar') : i18n.t('crear') }}</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useSubmitLock } from '../composables/useSubmitLock';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const toast = useToastStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: 'Guardando usuario...' });
const usuarios = ref([]);
const roles = ref([]);
const showModal = ref(false);
const editingId = ref(null);
const form = ref({});
const filtro = ref({ q: '', rol_id: '', estado: '' });

const usuariosFiltrados = computed(() => {
  let list = usuarios.value;
  const q = filtro.value.q.toLowerCase().trim();
  if (q) list = list.filter(u => (u.nombre||'').toLowerCase().includes(q) || (u.email||'').toLowerCase().includes(q));
  if (filtro.value.rol_id) list = list.filter(u => u.rol_id == filtro.value.rol_id);
  if (filtro.value.estado === 'activo') list = list.filter(u => u.activo);
  if (filtro.value.estado === 'inactivo') list = list.filter(u => !u.activo);
  return list;
});

onMounted(() => { cargar(); cargarRoles(); });

async function cargar() {
    try {
        const { data } = await api.get('/usuarios');
        usuarios.value = data.usuarios;
    } catch (e) { console.error(e); }
}

async function cargarRoles() {
    try {
        const { data } = await api.get('/usuarios/roles');
        roles.value = data.roles;
    } catch (e) { console.error(e); }
}

function resetForm() {
    editingId.value = null;
    form.value = { nombre: '', email: '', password: '', rol_id: 2 };
}

function editar(u) {
    editingId.value = u.id;
    form.value = { nombre: u.nombre, email: u.email, password: '', rol_id: u.rol_id };
    showModal.value = true;
}

async function guardar() {
    if (!form.value.nombre || !form.value.email) { toast.error('Nombre y email son requeridos'); return; }
    if (!editingId.value && !form.value.password) { toast.error('La contraseña es requerida'); return; }
    try {
        await execute(async () => {
            const payload = { ...form.value };
            if (!payload.password) delete payload.password;
            if (editingId.value) {
                await api.put(`/usuarios/${editingId.value}`, payload);
                toast.success(i18n.t('usuario_actualizado'));
            } else {
                await api.post('/usuarios', payload);
                toast.success(i18n.t('usuario_creado'));
            }
            showModal.value = false;
            cargar();
        });
    } catch (e) {
        if (e.response?.status === 429) {
            toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
        } else {
            toast.error(e.response?.data?.error || e.response?.data?.message || i18n.t('error'));
        }
    }
}

async function toggleEstado(u) {
    try {
        await api.post(`/usuarios/${u.id}/toggle`);
        toast.success(u.activo ? 'Usuario desactivado' : 'Usuario activado');
        cargar();
    } catch (e) {
        toast.error('Error al cambiar estado');
    }
}

function formatDate(d) {
    if (!d) return '';
    return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

@media (max-width: 768px) {
  .modal {
    max-width: min(90vw, 500px);
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
}

@media (max-width: 480px) {
  .flex.items-center.justify-between.mb-lg {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .flex.items-center.gap-sm.flex-wrap {
    flex-direction: column;
  }
  
  .flex.items-center.gap-sm.flex-wrap > * {
    min-width: 100%;
  }
  
  .card-body {
    padding: 8px;
  }
}
</style>
