<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ i18n.t('email_marketing_campana') }}</h3>
      <button class="btn btn-primary" @click="showModal=true;form={nombre:'',asunto:'',contenido_html:''}"><i class="fas fa-plus"></i> {{ i18n.t('email_marketing_nueva_campana') }}</button>
    </div>
    <div class="card"><div class="card-body" style="padding:0;">
      <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('email_marketing_campana') }}</th><th>{{ i18n.t('email_marketing_asunto') }}</th><th>{{ i18n.t('email_marketing_destinatarios') }}</th><th>{{ i18n.t('email_marketing_enviados') }}</th><th>{{ i18n.t('email_marketing_estado') }}</th><th>{{ i18n.t('email_marketing_fecha') }}</th><th></th></tr></thead>
          <tbody><tr v-for="c in campanas" :key="c.id">
            <td><strong>{{ c.nombre }}</strong></td><td>{{ c.asunto }}</td>
            <td>{{ c.destinatarios_count }}</td><td>{{ c.enviados_count }}</td>
            <td><span :class="['badge', c.estado==='enviada'?'badge-success':'badge-warning']">{{ c.estado }}</span></td>
            <td>{{ fdate(c.created_at) }}</td>
            <td class="flex gap-xs">
              <button v-if="c.estado==='borrador'" class="btn btn-sm btn-info" @click="showDest=c.id"><i class="fas fa-users"></i></button>
              <button v-if="c.estado==='borrador'" class="btn btn-sm btn-success" @click="enviar(c.id)"><i class="fas fa-paper-plane"></i></button>
            </td>
          </tr></tbody>
        </table>
      </div>
    </div></div>

    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal" style="max-width: min(90vw, 700px);"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('email_marketing_nueva_campana') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('email_marketing_nombre') }}</label><input v-model="form.nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('email_marketing_asunto') }}</label><input v-model="form.asunto" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('email_marketing_contenido') }}</label><textarea v-model="form.contenido_html" class="form-control" rows="10" placeholder="<h1>Mi Campaña</h1><p>Contenido...</p>"></textarea></div>
          <div class="form-group"><label>{{ i18n.t('cotizacion_designer_vista_previa') }}</label><div style="border:1px solid var(--bg-hover);border-radius:8px;padding:16px;background:#fff;color:#333;min-height:100px;" v-html="form.contenido_html"></div></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="crear"><i class="fas fa-save"></i> {{ i18n.t('crear') }}</button></div>
      </div>
    </div>

    <div class="modal-overlay" :class="{active:!!showDest}" @click.self="showDest=null">
      <div class="modal" style="max-width: min(90vw, 450px);"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('email_marketing_seleccionar_destinatarios') }}</h3><button class="modal-close" @click="showDest=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <button class="btn btn-sm btn-info mb-sm" @click="agregarTodos"><i class="fas fa-users"></i> {{ i18n.t('todos') }} clientes con email</button>
          <div class="form-group"><label>O emails individuales (uno por línea)</label><textarea v-model="emailsManual" class="form-control" rows="4" placeholder="email@ejemplo.com"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="agregarManuales">{{ i18n.t('aceptar') }}</button></div>
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

const campanas = ref([]); const showModal = ref(false); const showDest = ref(null);
const form = ref({nombre:'',asunto:'',contenido_html:''}); const emailsManual = ref('');
async function cargar() { try { const {data} = await api.get('/email-marketing/campanas'); campanas.value=data.campanas||[]; } catch(e){} }
async function crear() { try { await api.post('/email-marketing/campanas', form.value); showModal.value=false; cargar(); } catch(e){ toast.error(e.response?.data?.message||i18n.t('error')); } }
async function agregarTodos() { try { await api.post(`/email-marketing/campanas/${showDest.value}/destinatarios`, {todos_clientes:true}); toast.success(i18n.t('registro_guardado')); showDest.value=null; cargar(); } catch(e){} }
async function agregarManuales() { const emails = emailsManual.value.split('\n').filter(e=>e.trim()).map(e=>({email:e.trim()})); try { await api.post(`/email-marketing/campanas/${showDest.value}/destinatarios`, {emails}); showDest.value=null; cargar(); } catch(e){} }
async function enviar(id) { if(!await confirm.ask({ message: i18n.t('enviar_cotizacion_enviar_correo') + '?', confirmText: i18n.t('enviar'), type: 'info' })) return; try { const {data} = await api.post(`/email-marketing/campanas/${id}/enviar`); toast.success(`${i18n.t('enviado')}: ${data.enviados}`); cargar(); } catch(e){ toast.error(i18n.t('error')); } }
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
onMounted(cargar);
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
</style>
