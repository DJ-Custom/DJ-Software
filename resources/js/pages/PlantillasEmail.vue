<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ i18n.t('plantillas_email_titulo') }}</h3>
      <button class="btn btn-primary" @click="showModal=true;editItem=null;form={nombre:'',asunto:'',contenido_html:''}"><i class="fas fa-plus"></i> {{ i18n.t('plantillas_email_nueva') }}</button>
    </div>
    <div class="grid-3 gap-md">
      <div v-for="p in plantillas" :key="p.id" class="card" style="padding:16px;">
        <div class="flex items-center justify-between mb-sm">
          <strong>{{ p.nombre }}</strong>
          <div class="flex gap-xs">
            <button class="btn btn-sm btn-ghost" @click="editar(p)"><i class="fas fa-edit"></i></button>
            <button class="btn btn-sm btn-ghost" @click="preview=p"><i class="fas fa-eye"></i></button>
          </div>
        </div>
        <div style="font-size:12px;color:var(--text-muted);">{{ p.asunto || i18n.t('plantillas_email_sin_asunto') }}</div>
        <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">{{ p.categoria || i18n.t('plantillas_email_general') }} · {{ fdate(p.created_at) }}</div>
      </div>
    </div>
    <div v-if="!plantillas.length" class="card" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('plantillas_email_sin_datos') }}</div>

    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-lg"><div class="modal-header"><h3 class="modal-title">{{ editItem ? i18n.t('plantillas_email_editar_titulo') : i18n.t('plantillas_email_nueva_titulo') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 gap-sm"><div class="form-group"><label>{{ i18n.t('plantillas_email_nombre') }}</label><input v-model="form.nombre" class="form-control"></div><div class="form-group"><label>{{ i18n.t('plantillas_email_asunto') }}</label><input v-model="form.asunto" class="form-control"></div></div>
          <div class="form-group"><label>{{ i18n.t('plantillas_email_categoria') }}</label><input v-model="form.categoria" class="form-control" :placeholder="i18n.t('plantillas_email_placeholder_categoria')"></div>
          <div class="form-group"><label>{{ i18n.t('plantillas_email_contenido_html') }}</label><textarea v-model="form.contenido_html" class="form-control" rows="12"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('plantillas_email_guardando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('guardar') }}</span></button></div>
      </div>
    </div>

    <div class="modal-overlay" :class="{active:!!preview}" @click.self="preview=null">
      <div class="modal modal-lg" v-if="preview"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('plantillas_email_vista_previa') }}: {{ preview.nombre }}</h3><button class="modal-close" @click="preview=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="flex items-center gap-sm mb-md"><button :class="['btn btn-sm', pvMode==='desktop'?'btn-primary':'btn-ghost']" @click="pvMode='desktop'"><i class="fas fa-laptop"></i></button><button :class="['btn btn-sm', pvMode==='mobile'?'btn-primary':'btn-ghost']" @click="pvMode='mobile'"><i class="fas fa-mobile-alt"></i></button></div>
          <div :style="{maxWidth:pvMode==='mobile'?'375px':'100%',margin:'0 auto',border:'1px solid var(--bg-hover)',borderRadius:'8px',padding:'16px',background:'#fff',color:'#333'}" v-html="preview.contenido_html"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('plantillas_email_guardando') });

const plantillas = ref([]); const showModal = ref(false); const editItem = ref(null); const preview = ref(null); const pvMode = ref('desktop');
const form = ref({nombre:'',asunto:'',contenido_html:'',categoria:''});
async function cargar() { try { const {data} = await api.get('/email-marketing/plantillas'); plantillas.value=data.plantillas||[]; } catch(e){} }
function editar(p) { editItem.value=p; form.value={nombre:p.nombre,asunto:p.asunto,contenido_html:p.contenido_html,categoria:p.categoria}; showModal.value=true; }
async function guardar() {
  try {
    await execute(async () => { if(editItem.value) await api.put(`/email-marketing/plantillas/${editItem.value.id}`, form.value); else await api.post('/email-marketing/plantillas', form.value); showModal.value=false; cargar(); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message||i18n.t('error')); }
  }
}
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
onMounted(cargar);
</script>

<style scoped>
.modal-lg {
    max-width: min(90vw, 700px);
}

@media (max-width: 1023px) {
    .modal-lg {
        max-width: min(90vw, 650px);
    }
}

@media (max-width: 768px) {
    .modal-lg {
        max-width: min(95vw, 560px);
    }
}

@media (max-width: 480px) {
    .modal-lg {
        max-width: 100%;
        margin: 8px;
    }
}
</style>
