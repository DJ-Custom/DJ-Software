<template>
  <div>
    <div class="flex justify-between items-center mb-lg">
      <h2 class="page-title" style="margin:0;">{{ i18n.t('roles_y_permisos') }}</h2>
      <button class="btn btn-primary" @click="abrirModal()"><i class="fas fa-plus"></i> {{ i18n.t('nuevo_rol') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr><th>{{ i18n.t('rol_nombre') }}</th><th>{{ i18n.t('rol_descripcion') }}</th><th>Usuarios</th><th>{{ i18n.t('rol_estado') }}</th><th>{{ i18n.t('rol_modulos') }}</th><th>{{ i18n.t('acciones') }}</th></tr>
          </thead>
          <tbody>
            <tr v-for="r in roles" :key="r.id">
              <td><strong>{{ r.nombre }}</strong></td>
              <td>{{ r.descripcion || '-' }}</td>
              <td>{{ r.usuarios_count }}</td>
              <td><span :class="['badge', r.activo ? 'badge-success' : 'badge-danger']">{{ r.activo ? i18n.t('activo') : i18n.t('inactivo') }}</span></td>
              <td>
                <div class="permiso-chips">
                  <span v-for="p in (r.permisos || []).slice(0, 4)" :key="p" class="chip">{{ nombreModulo(p) }}</span>
                  <span v-if="(r.permisos || []).length > 4" class="chip muted">+{{ (r.permisos || []).length - 4 }}</span>
                  <span v-if="!(r.permisos || []).length" class="chip muted">{{ i18n.t('sin_restricciones') }}</span>
                </div>
              </td>
              <td>
                <button class="btn btn-sm btn-ghost" @click="abrirModal(r)"><i class="fas fa-edit"></i></button>
                <button v-if="!r.usuarios_count" class="btn btn-sm btn-danger" @click="eliminarRol(r.id)"><i class="fas fa-trash"></i></button>
              </td>
            </tr>
          </tbody>
        </table>
        </div>
        <div v-if="!roles.length" style="text-align:center;color:var(--text-muted);padding:30px;">{{ i18n.t('sin_roles') }}</div>
      </div>
    </div>

    <!-- Modal Rol -->
    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal" style="max-width: min(90vw, 720px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingId ? i18n.t('editar_rol') : i18n.t('nuevo_rol') }}</h3>
          <button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body" style="max-height:70vh;overflow:auto;">
          <div class="grid-2 gap-md mb-md">
            <div class="form-group">
              <label>{{ i18n.t('rol_nombre') }} *</label>
              <input v-model="form.nombre" class="form-control" placeholder="Ej: Vendedor">
            </div>
            <div class="form-group">
              <label>{{ i18n.t('rol_descripcion') }}</label>
              <input v-model="form.descripcion" class="form-control" placeholder="Opcional">
            </div>
          </div>
          <div class="form-group mb-md">
            <label><input v-model="form.activo" type="checkbox" style="margin-right:6px;"> {{ i18n.t('activo') }}</label>
          </div>

          <h4 style="margin-bottom:12px;font-size:15px;color:var(--text-secondary);"><i class="fas fa-shield-alt"></i> {{ i18n.t('permisos_por_modulo') }}</h4>
          <div v-for="sec in modulosDisponibles" :key="sec.seccion" class="permiso-section">
            <div class="permiso-section-title">{{ sec.seccion }}</div>
            <div class="permiso-grid">
              <label v-for="item in sec.items" :key="item.slug" class="permiso-item" :class="{ 'sub-permiso': item.nombre.startsWith('—') }">
                <input v-model="form.permisos" type="checkbox" :value="item.slug">
                <i :class="item.icono"></i>
                <span>{{ item.nombre }}</span>
              </label>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showModal=false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('guardando_rol') }}</span><span v-else>{{ editingId ? i18n.t('guardar') : i18n.t('crear') }}</span></button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const confirm = useConfirmStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando_rol') });

const roles = ref([]);
const modulosDisponibles = ref([]);
const showModal = ref(false);
const editingId = ref(null);
const form = ref({ nombre: '', descripcion: '', activo: true, permisos: [] });

const slugToNombre = ref({});

async function cargar() {
  try {
    const [{ data: r }, { data: m }] = await Promise.all([
      api.get('/roles'),
      api.get('/roles/permisos')
    ]);
    roles.value = r.roles || [];
    modulosDisponibles.value = m.modulos || [];
    // Build lookup map
    const map = {};
    (m.modulos || []).forEach(sec => {
      sec.items.forEach(it => { map[it.slug] = it.nombre; });
    });
    slugToNombre.value = map;
  } catch (e) { toast.error(i18n.t('error_cargar_roles')); }
}

function nombreModulo(slug) {
  return slugToNombre.value[slug] || slug;
}

function abrirModal(r = null) {
  editingId.value = r ? r.id : null;
  form.value = r
    ? { nombre: r.nombre, descripcion: r.descripcion || '', activo: r.activo, permisos: Array.isArray(r.permisos) ? [...r.permisos] : (JSON.parse(r.permisos || '[]')) }
    : { nombre: '', descripcion: '', activo: true, permisos: [] };
  showModal.value = true;
}

async function guardar() {
  try {
    await execute(async () => {
      if (editingId.value) { await api.put(`/roles/${editingId.value}`, form.value); }
      else { await api.post('/roles', form.value); }
      showModal.value = false;
      cargar();
    });
  } catch (e) {
    if (e.response?.status === 429) { toast.warning('La solicitud ya está siendo procesada. Por favor espere.'); }
    else { toast.error(e.response?.data?.error || 'Error al guardar'); }
  }
}

async function eliminarRol(id) {
  if (!await confirm.ask({ message: i18n.t('confirmar_eliminar_rol'), confirmText: i18n.t('eliminar'), type: 'danger' })) return;
  try {
    await api.delete(`/roles/${id}`);
    cargar();
  } catch (e) {
    toast.error(e.response?.data?.error || i18n.t('error'));
  }
}

onMounted(cargar);
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.permiso-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
.chip {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 11px;
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border: 1px solid var(--bg-hover);
}
.chip.muted {
  opacity: 0.6;
}
.permiso-section {
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--bg-hover);
}
.permiso-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}
.permiso-section-title {
  font-weight: 700;
  font-size: 13px;
  color: var(--text-secondary);
  text-transform: uppercase;
  margin-bottom: 10px;
  letter-spacing: 0.3px;
}
.permiso-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 8px;
}
.permiso-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 8px;
  background: var(--bg-tertiary);
  border: 1px solid var(--bg-hover);
  cursor: pointer;
  font-size: 13px;
  transition: background 0.15s, border-color 0.15s;
}
.permiso-item:hover {
  background: var(--bg-hover);
  border-color: var(--primary);
}
.permiso-item input {
  cursor: pointer;
}
.permiso-item i {
  width: 18px;
  text-align: center;
  color: var(--primary);
}
.permiso-item.sub-permiso {
  margin-left: 20px;
  background: rgba(42,157,244,0.06);
  border-color: rgba(42,157,244,0.15);
  font-size: 12px;
}
.permiso-item.sub-permiso i {
  font-size: 11px;
  color: var(--info);
}
.permiso-item.sub-permiso:hover {
  background: rgba(42,157,244,0.12);
  border-color: rgba(42,157,244,0.3);
}

@media (max-width: 768px) {
  .modal {
    max-width: min(90vw, 500px);
  }
  
  .permiso-grid {
    grid-template-columns: 1fr;
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
}

@media (max-width: 480px) {
  .flex.justify-between.items-center.mb-lg {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .permiso-item.sub-permiso {
    margin-left: 0;
    padding-left: 20px;
  }
  
  .permiso-section-title {
    font-size: clamp(11px, 2.5vw, 13px);
  }
  
  .permiso-item {
    font-size: clamp(12px, 2.5vw, 13px);
  }
}
</style>
