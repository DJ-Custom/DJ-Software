<template>
  <div>
    <div class="flex items-center justify-between mb-lg crm-topbar">
      <div class="flex items-center gap-md crm-stats">
        <div class="stat-card crm-stat"><div class="stat-value crm-stat-value">{{ fm(totalPipeline) }}</div><div class="stat-label">{{ i18n.t('crm_pipeline_total') }}</div></div>
        <div class="stat-card crm-stat"><div class="stat-value crm-stat-value stat-success">{{ fm(ganadasMes) }}</div><div class="stat-label">{{ i18n.t('crm_ganadas_mes') }}</div></div>
      </div>
      <div class="flex items-center gap-sm crm-actions">
        <button class="btn btn-sm btn-secondary btn-mobile-min" @click="showEtapa=true"><i class="fas fa-plus"></i> {{ i18n.t('crm_etapa') }}</button>
        <button class="btn btn-primary btn-mobile-min" @click="showOp=true;opForm={titulo:'',valor_estimado:0,probabilidad:50}"><i class="fas fa-plus"></i> {{ i18n.t('crm_oportunidad') }}</button>
      </div>
    </div>

    <div class="crm-pipeline">
      <div v-for="e in etapas" :key="e.id" class="crm-stage">
        <div class="crm-stage-header" :style="{borderColor: e.color}">
          <strong>{{ e.nombre }}</strong>
          <span class="badge badge-info">{{ fm(e.valor_total) }}</span>
        </div>
        <div class="crm-stage-body">
          <div v-for="o in e.oportunidades" :key="o.id" class="crm-card">
            <div class="flex items-center justify-between mb-xs">
              <strong class="crm-card-title">{{ o.titulo }}</strong>
              <div class="flex gap-xs">
                <button v-if="etapas.indexOf(e) < etapas.length-1" class="btn btn-sm btn-ghost" @click="mover(o.id, etapas[etapas.indexOf(e)+1].id)" :title="i18n.t('crm_avanzar')"><i class="fas fa-arrow-right"></i></button>
              </div>
            </div>
            <div class="crm-card-client">{{ o.cliente_nombre || i18n.t('crm_sin_cliente') }}</div>
            <div class="flex items-center justify-between mt-xs">
              <span class="crm-card-valor">{{ fm(o.valor_estimado) }}</span>
              <span class="badge badge-warning">{{ o.probabilidad }}%</span>
            </div>
            <div class="flex gap-xs mt-xs">
              <button class="btn btn-sm btn-success" @click="cerrar(o.id,'ganada')" :title="i18n.t('crm_avanzar')"><i class="fas fa-check"></i></button>
              <button class="btn btn-sm btn-danger" @click="cerrar(o.id,'perdida')" :title="i18n.t('rechazar')"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div v-if="!e.oportunidades?.length" class="crm-empty">{{ i18n.t('sin_datos') }}</div>
        </div>
      </div>
    </div>

    <div class="modal-overlay" :class="{active:showOp}" @click.self="showOp=false">
      <div class="modal modal-responsive-sm"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('crm_oportunidad') }}</h3><button class="modal-close" @click="showOp=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('crm_titulo_oportunidad') }} *</label><input v-model="opForm.titulo" class="form-control"></div>
          <div class="grid-2 gap-sm form-grid-responsive">
            <div class="form-group"><label>{{ i18n.t('crm_valor_estimado') }}</label><input v-model.number="opForm.valor_estimado" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('crm_probabilidad') }}</label><input v-model.number="opForm.probabilidad" type="number" min="0" max="100" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('crm_etapa') }}</label><select v-model="opForm.etapa_id" class="form-control"><option v-for="e in etapas" :key="e.id" :value="e.id">{{ e.nombre }}</option></select></div>
          <div class="form-group"><label>{{ i18n.t('crm_notas') }}</label><textarea v-model="opForm.notas" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-mobile-full" @click="crearOp"><i class="fas fa-save"></i> {{ i18n.t('crear') }}</button></div>
      </div>
    </div>

    <div class="modal-overlay" :class="{active:showEtapa}" @click.self="showEtapa=false">
      <div class="modal modal-responsive-sm"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('crm_nueva_etapa') }}</h3><button class="modal-close" @click="showEtapa=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('nombre') }}</label><input v-model="etapaForm.nombre" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('crm_color') }}</label><input v-model="etapaForm.color" type="color" class="color-input"></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-mobile-full" @click="crearEtapa">{{ i18n.t('crear') }}</button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm } = useCurrency();
const i18n = useI18nStore();

const toast = useToastStore();
const confirm = useConfirmStore();

const etapas = ref([]); const totalPipeline = ref(0); const ganadasMes = ref(0);
const showOp = ref(false); const showEtapa = ref(false);
const opForm = ref({titulo:'',valor_estimado:0,probabilidad:50,etapa_id:'',notas:''});
const etapaForm = ref({nombre:'',color:'#3b82f6'});
async function cargar() { try { const {data} = await api.get('/crm/dashboard'); etapas.value=data.etapas||[]; totalPipeline.value=data.total_pipeline; ganadasMes.value=data.ganadas_mes; } catch(e){} }
async function crearOp() { try { await api.post('/crm/oportunidades', opForm.value); showOp.value=false; cargar(); } catch(e){ toast.error(e.response?.data?.message||i18n.t('error')); } }
async function crearEtapa() { try { await api.post('/crm/etapas', etapaForm.value); showEtapa.value=false; cargar(); } catch(e){ toast.error(e.response?.data?.message||i18n.t('error')); } }
async function mover(id, etapaId) { try { await api.post(`/crm/oportunidades/${id}/mover`, {etapa_id:etapaId}); cargar(); } catch(e){} }
async function cerrar(id, estado) { if(!await confirm.ask({ message: `¿Marcar como ${estado}?`, confirmText: i18n.t('confirmar'), type: 'warning' })) return; try { await api.post(`/crm/oportunidades/${id}/cerrar`, {estado}); cargar(); } catch(e){} }
onMounted(cargar);
</script>

<style scoped>
.crm-pipeline { display:flex; gap:12px; overflow-x:auto; padding-bottom:12px; min-height:400px; -webkit-overflow-scrolling: touch; }
.crm-stage { min-width:260px; flex:1; background:var(--bg-card); border:1px solid var(--bg-hover); border-radius:12px; display:flex; flex-direction:column; }
.crm-stage-header { padding:12px 16px; border-bottom:3px solid; display:flex; justify-content:space-between; align-items:center; }
.crm-stage-body { padding:8px; flex:1; overflow-y:auto; }
.crm-card { background:var(--bg-hover); border-radius:8px; padding:12px; margin-bottom:8px; }
.crm-card-title { font-size: 13px; }
.crm-card-client { font-size: 12px; color: var(--text-muted); }
.crm-card-valor { font-weight: 600; color: var(--success); }
.crm-empty { text-align: center; color: var(--text-muted); padding: 20px; font-size: 12px; }

.crm-stat { padding: 12px 20px; }
.crm-stat-value { font-size: 18px; }
.stat-success { color: var(--success); }

.modal-responsive-sm { max-width: min(90vw, 450px); }

.color-input { width: 50px; height: 40px; border: none; }

.btn-mobile-full { min-height: 44px; }
.btn-mobile-min { min-height: 44px; }

.form-grid-responsive { grid-template-columns: 1fr 1fr; }

@media (max-width: 1023px) {
  .crm-pipeline { gap: 10px; }
  .crm-stage { min-width: 240px; }
}

@media (max-width: 768px) {
  .crm-topbar { flex-direction: column; align-items: stretch; gap: 12px; }
  .crm-stats { flex-wrap: wrap; }
  .crm-actions { justify-content: flex-end; }
  .crm-pipeline { min-height: 300px; }
  .crm-stage { min-width: 220px; }
  .form-grid-responsive { grid-template-columns: 1fr; }
  .modal-footer { flex-direction: column; }
  .modal-footer .btn { width: 100%; }
}

@media (max-width: 480px) {
  .crm-stats { flex-direction: column; align-items: stretch; }
  .crm-stat { padding: 10px 14px; }
  .crm-stat-value { font-size: clamp(14px, 4vw, 18px); }
  .crm-pipeline { min-height: 250px; }
  .crm-stage { min-width: 200px; }
}
</style>
