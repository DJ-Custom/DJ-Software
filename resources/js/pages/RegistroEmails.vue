<template>
  <div>
    <div class="flex items-center gap-sm mb-lg flex-wrap">
      <select v-model="filtro.estado" class="form-control filtro-select" @change="cargar"><option value="">{{ i18n.t('todos') }}</option><option value="enviado">{{ i18n.t('registro_emails_enviado') }}</option><option value="pendiente">{{ i18n.t('pendiente') }}</option><option value="error">{{ i18n.t('registro_emails_error') }}</option></select>
      <span class="badge badge-info">{{ total }} {{ i18n.t('registro_emails_registros') }}</span>
    </div>
    <div class="card"><div class="card-body table-responsive">
      <table class="data-table"><thead><tr><th>{{ i18n.t('registro_emails_campana') }}</th><th>{{ i18n.t('registro_emails_asunto') }}</th><th>{{ i18n.t('registro_emails_email') }}</th><th>{{ i18n.t('registro_emails_nombre') }}</th><th>{{ i18n.t('registro_emails_estado') }}</th><th>{{ i18n.t('registro_emails_enviado') }}</th><th>{{ i18n.t('registro_emails_error') }}</th></tr></thead>
        <tbody><tr v-for="r in registros" :key="r.id">
          <td>{{ r.campana_nombre }}</td><td>{{ r.asunto }}</td><td>{{ r.email }}</td><td>{{ r.nombre||'-' }}</td>
          <td><span :class="['badge', r.estado==='enviado'?'badge-success':r.estado==='error'?'badge-danger':'badge-warning']">{{ r.estado }}</span></td>
          <td>{{ fdate(r.enviado_at) }}</td>          <td class="error-cell">{{ r.error_mensaje||'-' }}</td>
        </tr></tbody>
      </table>
    </div></div>
    <div class="flex items-center justify-center gap-sm mt-md" v-if="pages > 1">
      <button class="btn btn-sm btn-ghost" :disabled="page<=1" @click="page--;cargar()"><i class="fas fa-chevron-left"></i></button>
      <span>{{ page }} / {{ pages }}</span>
      <button class="btn btn-sm btn-ghost" :disabled="page>=pages" @click="page++;cargar()"><i class="fas fa-chevron-right"></i></button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const registros = ref([]); const total = ref(0); const pages = ref(1); const page = ref(1);
const filtro = ref({estado:''});
async function cargar() { try { const {data} = await api.get('/email-marketing/registro', {params:{...filtro.value,page:page.value}}); registros.value=data.registros||[]; total.value=data.total; pages.value=data.pages; } catch(e){} }
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleString('es-CR',{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}); }
onMounted(cargar);
</script>

<style scoped>
.filtro-select {
    width: 140px;
    min-height: 44px;
}

.table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    padding: 0;
}

.error-cell {
    font-size: 11px;
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

@media (max-width: 1023px) {
    .data-table {
        min-width: 700px;
    }
}

@media (max-width: 768px) {
    .filtro-select {
        width: 100%;
        min-height: 44px;
    }

    .data-table {
        min-width: 650px;
    }

    .error-cell {
        max-width: 150px;
    }
}

@media (max-width: 480px) {
    .filtro-select {
        width: 100%;
        min-height: 44px;
    }

    .data-table th,
    .data-table td {
        padding: 8px 10px;
        font-size: 12px;
    }

    .error-cell {
        max-width: 120px;
        font-size: 10px;
    }
}
</style>
