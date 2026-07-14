<template>
  <div>
    <div class="flex items-center gap-sm mb-lg flex-wrap">
      <select v-model="filtro.modulo" class="form-control" @change="cargar"><option value="">{{ i18n.t('auditoria_todos_modulos') }}</option><option v-for="m in modulos" :key="m" :value="m">{{ m }}</option></select>
      <select v-model="filtro.accion" class="form-control" @change="cargar"><option value="">{{ i18n.t('auditoria_accion') }}</option><option value="POST">POST</option><option value="PUT">PUT</option><option value="DELETE">DELETE</option></select>
      <input v-model="filtro.desde" type="date" class="form-control" @change="cargar">
      <input v-model="filtro.hasta" type="date" class="form-control" @change="cargar">
      <span class="badge badge-info">{{ total }} {{ i18n.t('auditoria_registros') }}</span>
    </div>
    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('auditoria_fecha') }}</th><th>{{ i18n.t('auditoria_usuario') }}</th><th>{{ i18n.t('auditoria_accion') }}</th><th>{{ i18n.t('auditoria_modulo') }}</th><th>{{ i18n.t('descripcion') }}</th><th>IP</th><th>{{ i18n.t('auditoria_codigo') }}</th><th></th></tr></thead>
          <tbody><tr v-for="r in registros" :key="r.id">
            <td style="font-size:12px;">{{ fdate(r.created_at) }}</td>
            <td><strong>{{ r.usuario_nombre || i18n.t('auditoria_sistema') }}</strong></td>
            <td><span :class="['badge', r.accion==='DELETE'?'badge-danger':r.accion==='POST'?'badge-success':'badge-warning']">{{ r.accion }}</span></td>
            <td>{{ r.modulo }}</td>
            <td style="max-width:250px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">{{ r.descripcion }}</td>
            <td style="font-size:12px;">{{ r.ip }}</td>
            <td><span :class="['badge', r.codigo_respuesta < 400 ? 'badge-success':'badge-danger']">{{ r.codigo_respuesta }}</span></td>
            <td><button class="btn btn-sm btn-ghost" @click="verDetalle(r)"><i class="fas fa-eye"></i></button></td>
          </tr></tbody>
        </table>
        </div>
      </div>
    </div>
    <div class="flex items-center justify-center gap-sm mt-md" v-if="pages > 1">
      <button class="btn btn-sm btn-ghost" :disabled="page<=1" @click="page--;cargar()"><i class="fas fa-chevron-left"></i></button>
      <span>{{ page }} / {{ pages }}</span>
      <button class="btn btn-sm btn-ghost" :disabled="page>=pages" @click="page++;cargar()"><i class="fas fa-chevron-right"></i></button>
    </div>

    <div class="modal-overlay" :class="{active:!!detalle}" @click.self="detalle=null">
      <div class="modal" style="max-width: min(90vw, 600px);" v-if="detalle"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('auditoria_detalle') }}</h3><button class="modal-close" @click="detalle=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 gap-sm mb-md">
            <div><strong>{{ i18n.t('auditoria_usuario') }}:</strong> {{ detalle.usuario_nombre || i18n.t('auditoria_sistema') }}</div>
            <div><strong>{{ i18n.t('auditoria_accion') }}:</strong> {{ detalle.accion }}</div>
            <div><strong>{{ i18n.t('auditoria_modulo') }}:</strong> {{ detalle.modulo }}</div>
            <div><strong>IP:</strong> {{ detalle.ip }}</div>
            <div><strong>{{ i18n.t('auditoria_fecha') }}:</strong> {{ fdate(detalle.created_at) }}</div>
            <div><strong>{{ i18n.t('auditoria_codigo') }}:</strong> {{ detalle.codigo_respuesta }}</div>
          </div>
          <div class="mb-sm"><strong>URL:</strong> {{ detalle.url }}</div>
          <div class="mb-sm"><strong>{{ i18n.t('tesoreria_descripcion') }}:</strong> {{ detalle.descripcion }}</div>
          <div class="mb-sm"><strong>User Agent:</strong><div style="font-size:11px;word-break:break-all;">{{ detalle.user_agent }}</div></div>
          <div v-if="detalle.auditable_type" class="mb-sm"><strong>Registro:</strong> {{ detalle.auditable_type }} #{{ detalle.auditable_id }}</div>
          <div v-if="detalle.old_values"><strong>Datos anteriores:</strong><pre style="max-height:200px;overflow:auto;font-size:11px;background:var(--bg-hover);padding:10px;border-radius:8px;">{{ formatJSON(detalle.old_values) }}</pre></div>
          <div v-if="detalle.new_values"><strong>Datos nuevos:</strong><pre style="max-height:200px;overflow:auto;font-size:11px;background:var(--bg-hover);padding:10px;border-radius:8px;">{{ formatJSON(detalle.new_values) }}</pre></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useI18nStore } from '../stores/i18n';
const i18n = useI18nStore();
const registros = ref([]); const modulos = ref([]); const total = ref(0); const pages = ref(1); const page = ref(1);
const filtro = ref({ modulo:'', accion:'', desde:'', hasta:'' }); const detalle = ref(null);
async function cargar() { try { const {data} = await api.get('/auditoria', {params:{...filtro.value, page: page.value}}); registros.value = data.registros||[]; total.value = data.total; pages.value = data.pages; modulos.value = data.modulos||[]; } catch(e){} }
function verDetalle(r) { detalle.value = r; }
function fdate(d) { if(!d) return '-'; return new Date(d).toLocaleString('es-CR',{day:'2-digit',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit'}); }
function formatJSON(d) { try { return JSON.stringify(typeof d === 'string' ? JSON.parse(d) : d, null, 2); } catch(e) { return d; } }
onMounted(cargar);
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
  
  pre {
    max-height: 150px;
    font-size: clamp(10px, 2vw, 11px);
  }
}

@media (max-width: 480px) {
  .flex.items-center.gap-sm.mb-lg.flex-wrap {
    flex-direction: column;
    align-items: stretch;
  }
  
  .flex.items-center.gap-sm.mb-lg.flex-wrap > * {
    min-width: 100%;
  }
  
  .card-body {
    padding: 8px;
  }
  
  .badge {
    font-size: clamp(10px, 2vw, 11px);
  }
  
  .flex.items-center.justify-center.gap-sm.mt-md {
    font-size: clamp(12px, 2.5vw, 14px);
  }
}
</style>
