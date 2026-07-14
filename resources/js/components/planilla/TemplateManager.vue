<template>
  <div class="template-manager">
    <div class="tm-header">
      <h4><i class="fas fa-copy"></i> {{ i18n.t('planilla_plantillas') }}</h4>
      <button class="btn btn-sm btn-primary" @click="showCreate = true">
        <i class="fas fa-plus"></i> {{ i18n.t('planilla_nueva_plantilla') }}
      </button>
    </div>

    <div class="tm-list" v-if="!showCreate && !editing">
      <div v-for="p in plantillas" :key="p.id" class="template-card" :class="{ inactive: !p.activo }">
        <div class="tc-header">
          <strong>{{ p.nombre }}</strong>
          <span v-if="p.es_sistema" class="badge badge-info">Sistema</span>
        </div>
        <p v-if="p.descripcion" class="tc-desc">{{ p.descripcion }}</p>
        <div class="tc-formula">
          <code>{{ p.formula_texto }}</code>
        </div>
        <div class="tc-footer">
          <span class="tc-emp-count">{{ p.empleados?.length || 0 }} empleados</span>
          <div class="tc-actions">
            <button class="btn btn-sm btn-ghost" @click="editTemplate(p)" :disabled="p.es_sistema">
              <i class="fas fa-edit"></i>
            </button>
            <button class="btn btn-sm btn-ghost" @click="assignTemplate(p)">
              <i class="fas fa-user-plus"></i>
            </button>
            <button class="btn btn-sm btn-ghost text-danger" @click="deleteTemplate(p)" :disabled="p.es_sistema">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </div>
      </div>
      <div v-if="plantillas.length === 0" class="empty-state">
        <i class="fas fa-copy"></i>
        <p>{{ i18n.t('planilla_sin_plantillas') }}</p>
      </div>
    </div>

    <div v-if="showCreate || editing" class="tm-form">
      <h4>{{ editing ? i18n.t('planilla_editar_plantilla') : i18n.t('planilla_nueva_plantilla') }}</h4>
      <div class="form-group">
        <label>{{ i18n.t('planilla_nombre_plantilla') }} *</label>
        <input v-model="form.nombre" class="form-control" />
      </div>
      <div class="form-group">
        <label>{{ i18n.t('planilla_descripcion') }}</label>
        <textarea v-model="form.descripcion" class="form-control" rows="2"></textarea>
      </div>
      <div class="form-group">
        <label>{{ i18n.t('planilla_formula') }} *</label>
        <FormulaEditor v-model="form.formula_texto" />
      </div>
      <div class="form-actions">
        <button class="btn btn-ghost" @click="cancelForm">{{ i18n.t('cancelar') }}</button>
        <button class="btn btn-primary" @click="saveTemplate" :disabled="saving">
          <i v-if="saving" class="fas fa-spinner fa-spin"></i> {{ i18n.t('guardar') }}
        </button>
      </div>
    </div>

    <div v-if="showAssign" class="tm-assign">
      <h4>{{ i18n.t('planilla_asignar_plantilla') }}: {{ assignTarget?.nombre }}</h4>
      <div class="assign-list">
        <label v-for="e in empleados" :key="e.id" class="assign-item">
          <input type="checkbox" :value="e.id" v-model="assignEmpIds" />
          <span>{{ e.nombre }}</span>
          <span class="assign-meta">{{ e.cedula }}</span>
        </label>
      </div>
      <div class="form-actions">
        <button class="btn btn-ghost" @click="showAssign = false">{{ i18n.t('cancelar') }}</button>
        <button class="btn btn-primary" @click="saveAssignment" :disabled="saving">
          <i v-if="saving" class="fas fa-spinner fa-spin"></i> {{ i18n.t('planilla_asignar') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useI18nStore } from '../../stores/i18n';
import { useToastStore } from '../../stores/toast';
import api from '../../services/api';
import FormulaEditor from './FormulaEditor.vue';

const i18n = useI18nStore();
const toast = useToastStore();

const plantillas = ref([]);
const empleados = ref([]);
const showCreate = ref(false);
const editing = ref(null);
const saving = ref(false);
const showAssign = ref(false);
const assignTarget = ref(null);
const assignEmpIds = ref([]);

const form = ref({ nombre: '', descripcion: '', formula_texto: '' });

async function loadData() {
  try {
    const [pRes, eRes] = await Promise.all([
      api.get('/planilla/plantillas'),
      api.get('/planilla/empleados'),
    ]);
    plantillas.value = pRes.data.plantillas || [];
    empleados.value = eRes.data.empleados || [];
  } catch (e) { /* silent */ }
}

function editTemplate(p) {
  editing.value = p;
  form.value = { nombre: p.nombre, descripcion: p.descripcion || '', formula_texto: p.formula_texto };
  showCreate.value = false;
}

function cancelForm() {
  showCreate.value = false;
  editing.value = null;
  form.value = { nombre: '', descripcion: '', formula_texto: '' };
}

async function saveTemplate() {
  if (!form.value.nombre || !form.value.formula_texto) {
    toast.warning(i18n.t('planilla_campos_requeridos'));
    return;
  }
  saving.value = true;
  try {
    if (editing.value) {
      await api.put(`/planilla/plantillas/${editing.value.id}`, form.value);
    } else {
      await api.post('/planilla/plantillas', form.value);
    }
    toast.success(i18n.t('guardado'));
    cancelForm();
    loadData();
  } catch (e) {
    toast.error(e.response?.data?.message || i18n.t('error'));
  } finally {
    saving.value = false;
  }
}

async function deleteTemplate(p) {
  if (!confirm(i18n.t('planilla_confirmar_eliminar'))) return;
  try {
    await api.delete(`/planilla/plantillas/${p.id}`);
    toast.success(i18n.t('eliminado'));
    loadData();
  } catch (e) {
    toast.error(e.response?.data?.message || i18n.t('error'));
  }
}

function assignTemplate(p) {
  assignTarget.value = p;
  assignEmpIds.value = p.empleados?.map(e => e.id) || [];
  showAssign.value = true;
}

async function saveAssignment() {
  saving.value = true;
  try {
    await api.post(`/planilla/plantillas/${assignTarget.value.id}/asignar`, { empleado_ids: assignEmpIds.value });
    toast.success(i18n.t('planilla_plantilla_asignada'));
    showAssign.value = false;
    loadData();
  } catch (e) {
    toast.error(e.response?.data?.message || i18n.t('error'));
  } finally {
    saving.value = false;
  }
}

onMounted(loadData);
</script>

<style scoped>
.template-manager { }
.tm-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.tm-header h4 { margin: 0; display: flex; align-items: center; gap: 6px; }
.tm-header .btn { min-height: 44px; }
.template-card { border: 1px solid var(--border); border-radius: 8px; padding: 12px; margin-bottom: 8px; background: var(--bg-primary); }
.template-card.inactive { opacity: 0.6; }
.tc-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.tc-desc { font-size: 13px; color: var(--text-secondary); margin: 4px 0; }
.tc-formula { font-family: 'Fira Code', monospace; font-size: 12px; padding: 6px 8px; background: var(--bg-secondary); border-radius: 4px; overflow-x: auto; margin: 6px 0; }
.tc-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 6px; }
.tc-emp-count { font-size: 12px; color: var(--text-tertiary); }
.tc-actions { display: flex; gap: 2px; }
.tc-actions .btn { min-height: 44px; }
.tm-form, .tm-assign { border: 1px solid var(--border); border-radius: 8px; padding: 16px; background: var(--bg-secondary); }
.tm-form h4, .tm-assign h4 { margin: 0 0 12px; }
.form-group { margin-bottom: 10px; }
.form-group label { display: block; font-size: 12px; font-weight: 600; margin-bottom: 3px; }
.form-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 12px; }
.form-actions .btn { min-height: 44px; }
.empty-state { text-align: center; padding: 30px; color: var(--text-tertiary); }
.empty-state i { font-size: 32px; margin-bottom: 8px; display: block; }
.assign-list { max-height: 300px; overflow-y: auto; }
.assign-item { display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid var(--border); cursor: pointer; font-size: 13px; }
.assign-meta { color: var(--text-tertiary); font-size: 12px; margin-left: auto; }

@media (max-width: 1023px) {
  .template-card { padding: 10px; }
  .tc-formula { font-size: 11px; }
}

@media (max-width: 768px) {
  .tm-header { flex-wrap: wrap; gap: 8px; }
  .tm-header .btn { width: 100%; min-height: 44px; }
  .tc-header { flex-wrap: wrap; }
  .tc-formula { font-size: 11px; padding: 6px; }
  .tc-footer { flex-direction: column; align-items: flex-start; gap: 6px; }
  .tc-actions { width: 100%; justify-content: flex-end; }
  .tc-actions .btn { flex: 1; }
  .tm-form, .tm-assign { padding: 12px; }
  .form-actions { flex-direction: column-reverse; }
  .form-actions .btn { width: 100%; min-height: 44px; }
  .assign-item { padding: 8px 0; min-height: 44px; }
}

@media (max-width: 480px) {
  .tm-header h4 { font-size: clamp(14px, 2vw, 16px); }
  .template-card { padding: 8px; }
  .tc-desc { font-size: 12px; }
  .tc-formula { font-size: 10px; padding: 4px 6px; }
  .assign-list { max-height: 240px; }
  .assign-item { font-size: 12px; }
}
</style>
