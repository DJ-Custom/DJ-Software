<template>
  <div>
    <div class="flex items-center justify-between mb-lg form-topbar">
      <h3 style="margin:0;"><i class="fas fa-globe" style="color:var(--primary);"></i> {{ i18n.t('formularios_sitio_web') }}</h3>
      <div class="flex gap-sm form-tabs">
        <button :class="['btn', tab==='formularios'?'btn-primary':'btn-secondary']" @click="tab='formularios'">{{ i18n.t('formularios_formularios') }}</button>
        <button :class="['btn', tab==='respuestas'?'btn-primary':'btn-secondary']" @click="tab='respuestas';cargarRespuestas()">{{ i18n.t('formularios_leads') }}</button>
        <button :class="['btn', tab==='api'?'btn-primary':'btn-secondary']" @click="tab='api'">{{ i18n.t('formularios_api') }}</button>
      </div>
    </div>

    <!-- Tab Formularios -->
    <div v-if="tab==='formularios'">
      <div class="flex items-center justify-between mb-md">
        <span class="form-desc">{{ i18n.t('formularios_descripcion') }}</span>
        <button class="btn btn-primary btn-sm btn-mobile-min" @click="showModal=true;form={nombre:'',descripcion:'',campos_json:'[]'}"><i class="fas fa-plus"></i> {{ i18n.t('formularios_nuevo') }}</button>
      </div>
      <div class="grid-3 gap-md form-cards-grid">
        <div v-for="f in formularios" :key="f.id" class="card form-card">
          <div class="flex items-center justify-between mb-sm">
            <strong>{{ f.nombre }}</strong>
            <span :class="['badge', f.activo?'badge-success':'badge-secondary']">{{ f.activo?i18n.t('activo'):i18n.t('inactivo') }}</span>
          </div>
          <div class="form-card-desc">{{ f.descripcion || i18n.t('formularios_sin_descripcion') }}</div>
          <div class="flex items-center justify-between">
            <span class="form-card-count">{{ f.respuestas_count || 0 }} {{ i18n.t('formularios_respuestas') }}</span>
            <div class="flex gap-xs">
              <button class="btn btn-sm btn-ghost" @click="copiarLink(f)" :title="i18n.t('copiar')"><i class="fas fa-link"></i></button>
              <button class="btn btn-sm btn-ghost" @click="copiarEmbed(f)" :title="i18n.t('copiar')"><i class="fas fa-code"></i></button>
            </div>
          </div>
        </div>
      </div>
      <div v-if="!formularios.length" class="card form-empty-state"><i class="fas fa-globe form-empty-icon"></i><p>{{ i18n.t('formularios_sin_datos') }}</p></div>
    </div>

    <!-- Tab Leads/Respuestas -->
    <div v-if="tab==='respuestas'">
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-inbox"></i> {{ i18n.t('formularios_respuestas_recibidas') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
            <table class="data-table">
              <thead><tr><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('formularios_formularios') }}</th><th>{{ i18n.t('nombre') }}</th><th>{{ i18n.t('email') }}</th><th>{{ i18n.t('telefono') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
              <tbody>
                <tr v-for="r in respuestas" :key="r.id">
                  <td class="text-sm">{{ formatDate(r.created_at) }}</td>
                  <td>{{ r.formulario_nombre }}</td>
                  <td><strong>{{ r.datos?.nombre || r.datos?.name || '-' }}</strong></td>
                  <td>{{ r.datos?.email || '-' }}</td>
                  <td>{{ r.datos?.telefono || r.datos?.phone || '-' }}</td>
                  <td><span :class="['badge', r.atendido?'badge-success':'badge-warning']">{{ r.atendido?i18n.t('completado'):i18n.t('pendiente') }}</span></td>
                  <td>
                    <button v-if="!r.atendido" class="btn btn-sm btn-success btn-mobile-min" @click="atenderLead(r)" :title="i18n.t('completado')"><i class="fas fa-check"></i> {{ i18n.t('ver') }}</button>
                    <button class="btn btn-sm btn-ghost" @click="verLeadDetalle(r)" :title="i18n.t('ver_detalles')"><i class="fas fa-eye"></i></button>
                  </td>
                </tr>
                <tr v-if="!respuestas.length"><td colspan="7" class="empty-state-cell">{{ i18n.t('sin_datos') }}</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab API -->
    <div v-if="tab==='api'">
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-plug"></i> {{ i18n.t('formularios_api') }}</h3></div>
        <div class="card-body">
          <p class="form-api-desc">{{ i18n.t('formularios_descripcion') }}</p>
          <div class="form-api-block">
            <h4 class="form-api-subtitle">Endpoint</h4>
            <code class="form-api-code">POST {{ apiUrl }}/api/webhook/formulario/{id}</code>
          </div>
          <div class="form-api-block">
            <h4 class="form-api-subtitle">Ejemplo de Request</h4>
            <pre class="form-api-pre">{
  "nombre": "Juan Pérez",
  "email": "juan@ejemplo.com",
  "telefono": "+506 8888-0000",
  "mensaje": "Me interesa su producto..."
}</pre>
          </div>
          <div class="form-api-block">
            <h4 class="form-api-subtitle">Código de Ejemplo (HTML)</h4>
            <pre class="form-api-pre">&lt;form action="{{ apiUrl }}/api/webhook/formulario/1" method="POST"&gt;
  &lt;input name="nombre" required&gt;
  &lt;input name="email" type="email" required&gt;
  &lt;input name="telefono"&gt;
  &lt;textarea name="mensaje"&gt;&lt;/textarea&gt;
  &lt;button type="submit"&gt;{{ i18n.t('enviar') }}&lt;/button&gt;
&lt;/form&gt;</pre>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('formularios_nuevo') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('nombre') }}</label><input v-model="form.nombre" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('descripcion') }}</label><textarea v-model="form.descripcion" class="form-control" rows="2"></textarea></div>
          <div class="form-group"><label>{{ i18n.t('formularios_nombre_campo') }} (JSON)</label><textarea v-model="form.campos_json" class="form-control" rows="6" placeholder='[{"label":"Nombre","type":"text","required":true}]'></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-mobile-full" @click="crear"><i class="fas fa-save"></i> {{ i18n.t('crear') }}</button></div>
      </div>
    </div>

    <!-- Modal Lead Detalle -->
    <div class="modal-overlay" :class="{active:showLeadDetalle}" @click.self="showLeadDetalle=false">
      <div class="modal modal-responsive-sm">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('ver_detalles') }}</h3><button class="modal-close" @click="showLeadDetalle=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="leadDetalle">
          <div v-for="(val, key) in leadDetalle.datos" :key="key" class="flex items-center justify-between p-xs lead-detail-row">
            <strong class="lead-detail-key">{{ key }}</strong>
            <span class="lead-detail-val">{{ val }}</span>
          </div>
          <div class="mt-md text-sm-muted">{{ i18n.t('fecha') }}: {{ formatDate(leadDetalle.created_at) }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const i18n = useI18nStore();
const tab = ref('formularios');
const apiBase = computed(() => window.location.origin);
const webhookUrlConfig = ref('');
const apiUrl = computed(() => webhookUrlConfig.value || apiBase.value);

const formularios = ref([]); const showModal = ref(false);
const form = ref({nombre:'',descripcion:'',campos_json:'[]'});
const respuestas = ref([]);
const showLeadDetalle = ref(false); const leadDetalle = ref(null);

async function cargar() { try { const {data} = await api.get('/formularios'); formularios.value=data.formularios||[]; } catch(e){ formularios.value=[]; } }

async function cargarConfigApi() {
    try {
        const { data } = await api.get('/configuracion');
        const config = data.config || {};
        webhookUrlConfig.value = config['api_webhook_url'] || '';
    } catch (e) { console.error(e); }
}
async function crear() { try { await api.post('/formularios', form.value); showModal.value=false; cargar(); } catch(e){ toast.error(e.response?.data?.message||i18n.t('error')); } }

async function cargarRespuestas() {
  try { const {data} = await api.get('/formularios/respuestas'); respuestas.value = data.respuestas || []; } catch(e) { respuestas.value = []; }
}

async function atenderLead(r) {
  try {
    await api.post(`/formularios/respuestas/${r.id}/atender`);
    r.atendido = true;
    toast.success(i18n.t('registro_guardado'));
  } catch(e) { toast.error(i18n.t('error')); }
}

function verLeadDetalle(r) { leadDetalle.value = r; showLeadDetalle.value = true; }

function copiarLink(f) { navigator.clipboard.writeText(`${apiUrl.value}/api/webhook/formulario/${f.id}`); toast.success(i18n.t('copiar')); }
function copiarEmbed(f) {
  const code = `<form action="${apiUrl.value}/api/webhook/formulario/${f.id}" method="POST">\n  <input name="nombre" placeholder="Nombre" required>\n  <input name="email" type="email" placeholder="Email" required>\n  <input name="telefono" placeholder="Teléfono">\n  <textarea name="mensaje" placeholder="Mensaje"></textarea>\n  <button type="submit">${i18n.t('enviar')}</button>\n</form>`;
  navigator.clipboard.writeText(code);
  toast.success(i18n.t('copiar'));
}

function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }

onMounted(() => { cargar(); cargarConfigApi(); });
</script>

<style scoped>
.form-desc {
  font-size: 13px;
  color: var(--text-muted);
}

.form-card {
  padding: 16px;
}

.form-card-desc {
  font-size: 12px;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.form-card-count {
  font-size: 12px;
}

.form-empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.form-empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
  display: block;
}

.form-api-desc {
  margin-bottom: 16px;
  color: var(--text-muted);
  font-size: 14px;
}

.form-api-block {
  background: var(--bg-tertiary);
  padding: 16px;
  border-radius: 10px;
  margin-bottom: 16px;
}

.form-api-subtitle {
  margin: 0 0 8px;
  font-size: 14px;
}

.form-api-code {
  font-size: 13px;
  word-break: break-all;
  display: block;
  padding: 8px;
  background: var(--bg-card);
  border-radius: 6px;
}

.form-api-pre {
  font-size: 12px;
  overflow: auto;
  padding: 8px;
  background: var(--bg-card);
  border-radius: 6px;
  margin: 0;
}

.text-sm {
  font-size: 12px;
}

.text-sm-muted {
  font-size: 12px;
  color: var(--text-muted);
}

.empty-state-cell {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.modal-responsive {
  max-width: min(90vw, 600px);
}

.modal-responsive-sm {
  max-width: min(90vw, 500px);
}

.btn-mobile-min {
  min-height: 44px;
}

.btn-mobile-full {
  min-height: 44px;
  width: 100%;
}

.lead-detail-row {
  border-bottom: 1px solid var(--bg-hover);
}

.lead-detail-key {
  font-size: 13px;
  text-transform: capitalize;
}

.lead-detail-val {
  font-size: 13px;
}

.form-cards-grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

@media (max-width: 1023px) {
  .form-cards-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}

@media (max-width: 768px) {
  .form-topbar { flex-direction: column; align-items: stretch; gap: 12px; }
  .form-tabs { justify-content: center; }
  .form-cards-grid { grid-template-columns: 1fr; }
  .modal-footer { flex-direction: column; }
  .modal-footer .btn { width: 100%; }
}

@media (max-width: 480px) {
  .form-tabs { flex-direction: column; }
  .form-tabs .btn { width: 100%; min-height: 44px; }
}
</style>
