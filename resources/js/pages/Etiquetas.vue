<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ etiquetas.length }} {{ i18n.t('etiquetas') }}</h3>
      <button class="btn btn-primary" @click="showModal=true;editItem=null;form={nombre:'',color:'#3b82f6'}"><i class="fas fa-plus"></i> {{ i18n.t('nueva_etiqueta') }}</button>
    </div>
    <div class="grid-4 gap-md">
      <div v-for="e in etiquetas" :key="e.id" class="card" style="padding:16px;">
        <div class="flex items-center gap-sm mb-sm">
          <div style="width:24px;height:24px;border-radius:6px;" :style="{background:e.color}"></div>
          <strong style="flex:1;">{{ e.nombre }}</strong>
          <button class="btn btn-sm btn-ghost" @click="editar(e)"><i class="fas fa-edit"></i></button>
          <button class="btn btn-sm btn-danger" @click="eliminar(e.id)"><i class="fas fa-trash"></i></button>
        </div>
        <div style="font-size:12px;color:var(--text-muted);">{{ e.clientes_count || 0 }} {{ i18n.t('etiquetas_clientes') }} · {{ e.productos_count || 0 }} {{ i18n.t('etiquetas_productos') }}</div>
      </div>
    </div>
    <div v-if="!etiquetas.length" class="card" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('etiquetas_sin_creadas') }}</div>

    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal" style="max-width: min(90vw, 400px);"><div class="modal-header"><h3 class="modal-title">{{ editItem ? i18n.t('editar_etiqueta') : i18n.t('nueva_etiqueta') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('nombre') }}</label><input v-model="form.nombre" class="form-control" :placeholder="i18n.t('etiquetas_nombre_label')"></div>
          <div class="form-group"><label>{{ i18n.t('etiqueta_color') }}</label><div class="flex items-center gap-sm"><input v-model="form.color" type="color" style="width:50px;height:40px;border:none;cursor:pointer;"><span>{{ form.color }}</span></div></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('guardando_etiqueta') }}</span><span v-else>{{ editItem ? i18n.t('guardar') : i18n.t('crear') }}</span></button></div>
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
const { isSubmitting, execute } = useSubmitLock({ loadingText: 'Guardando etiqueta...' });

const etiquetas = ref([]); const showModal = ref(false); const editItem = ref(null);
const form = ref({ nombre:'', color:'#3b82f6' });
async function cargar() { try { const {data} = await api.get('/etiquetas'); etiquetas.value = data.etiquetas||[]; } catch(e){} }
function editar(e) { editItem.value = e; form.value = { nombre: e.nombre, color: e.color }; showModal.value = true; }
async function guardar() {
  try {
    await execute(async () => {
      if (editItem.value) { await api.put(`/etiquetas/${editItem.value.id}`, form.value); }
      else { await api.post('/etiquetas', form.value); }
      showModal.value = false; cargar();
    });
  } catch(e) {
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message || i18n.t('error')); }
  }
}
async function eliminar(id) { if(!await confirm.ask({ message: i18n.t('confirmar_eliminar_etiqueta'), confirmText: i18n.t('eliminar'), type: 'danger' })) return; try { await api.delete(`/etiquetas/${id}`); cargar(); } catch(e){} }
onMounted(cargar);
</script>

<style scoped>
@media (max-width: 1023px) {
  .grid-4 {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .grid-4 {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .grid-4 {
    grid-template-columns: 1fr;
  }
  .btn {
    min-height: 44px;
  }
}
</style>
