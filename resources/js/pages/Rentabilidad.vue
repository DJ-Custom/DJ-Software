<template>
  <div>
    <div class="flex items-center gap-md mb-lg flex-wrap">
      <div class="flex items-center gap-sm" style="flex:1; min-width:0;">
        <label class="form-label" style="margin:0; white-space:nowrap; flex-shrink:0;">{{ i18n.t('rentabilidad_desde') }}</label>
        <input v-model="desde" type="date" class="form-control" style="width:100%; max-width:160px; min-width:0;" @change="cargar">
      </div>
      <div class="flex items-center gap-sm" style="flex:1; min-width:0;">
        <label class="form-label" style="margin:0; white-space:nowrap; flex-shrink:0;">{{ i18n.t('rentabilidad_hasta') }}</label>
        <input v-model="hasta" type="date" class="form-control" style="width:100%; max-width:160px; min-width:0;" @change="cargar">
      </div>
      <select v-model="ubicacionId" class="form-control" style="width:100%; max-width:200px; min-width:0;" @change="cargar">
        <option value="">{{ i18n.t('rentabilidad_todas_ubicaciones') }}</option>
        <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
      </select>
      <button class="btn btn-secondary btn-sm" style="flex-shrink:0;" @click="cargar"><i class="fas fa-sync"></i> {{ i18n.t('actualizar') }}</button>
    </div>

    <div class="grid-4 mb-lg">
      <div class="stat-card">
        <div class="stat-value" style="color:var(--info);">{{ fm(totalIngresos) }}</div>
        <div class="stat-label">{{ i18n.t('rentabilidad_ingresos') }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" style="color:var(--danger);">{{ fm(totalCostos) }}</div>
        <div class="stat-label">{{ i18n.t('rentabilidad_costos') }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" :style="{color: totalMargen >= 0 ? 'var(--success)' : 'var(--danger)'}">{{ fm(totalMargen) }}</div>
        <div class="stat-label">{{ i18n.t('rentabilidad_margen_bruto') }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-value" :style="{color: margenPorcentaje >= 0 ? 'var(--success)' : 'var(--danger)'}">{{ margenPorcentaje }}%</div>
        <div class="stat-label">{{ i18n.t('rentabilidad_porcentaje_rentabilidad') }}</div>
      </div>
    </div>

    <div class="card">
      <div class="card-header flex justify-between items-center">
        <h3 class="card-title"><i class="fas fa-chart-line" style="margin-right:8px;"></i>{{ i18n.t('rentabilidad_titulo') }}</h3>
        <span class="badge badge-info">{{ productos.length }} {{ i18n.t('rentabilidad_productos') }}</span>
      </div>
      <div class="card-body" style="padding:0;">
        <div class="table-container" style="max-height: 600px;">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18n.t('rentabilidad_producto') }}</th>
                <th style="text-align:right;">{{ i18n.t('rentabilidad_unidades') }}</th>
                <th style="text-align:right;">{{ i18n.t('rentabilidad_ingresos') }}</th>
                <th style="text-align:right;">{{ i18n.t('rentabilidad_costo_total') }}</th>
                <th style="text-align:right;">{{ i18n.t('rentabilidad_margen') }}</th>
                <th style="text-align:right;">{{ i18n.t('rentabilidad_porcentaje_margen') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in productos" :key="p.id" class="animate-fade-in">
                <td :data-label="i18n.t('rentabilidad_producto')">
                  <strong>{{ p.nombre }}</strong>
                  <div style="font-size:12px;color:var(--text-muted);">{{ p.codigo }}</div>
                </td>
                <td :data-label="i18n.t('rentabilidad_unidades')" style="text-align:right;">{{ p.unidades }}</td>
                <td :data-label="i18n.t('rentabilidad_ingresos')" style="text-align:right;">{{ fm(p.ingresos) }}</td>
                <td :data-label="i18n.t('rentabilidad_costo_total')" style="text-align:right;">{{ fm(p.costo_total) }}</td>
                <td :data-label="i18n.t('rentabilidad_margen')" style="text-align:right; font-weight:700;" :style="{color: p.margen >= 0 ? 'var(--success)' : 'var(--danger)'}">{{ fm(p.margen) }}</td>
                <td :data-label="i18n.t('rentabilidad_porcentaje_margen')" style="text-align:right;">
                  <div class="flex items-center gap-sm" style="justify-content:flex-end;">
                    <div style="width:60px; background:var(--bg-hover); border-radius:4px; height:8px;">
                      <div :style="{
                        width: Math.min(Math.max(p.porcentaje, 0), 100) + '%',
                        height: '100%',
                        background: p.porcentaje >= 30 ? 'var(--success)' : p.porcentaje >= 15 ? 'var(--warning)' : 'var(--danger)',
                        borderRadius: '4px'
                      }"></div>
                    </div>
                    <span style="font-size:13px; min-width:36px; text-align:right; font-weight:600;">{{ p.porcentaje }}%</span>
                  </div>
                </td>
              </tr>
              <tr v-if="!productos.length && !loading">
                <td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">{{ i18n.t('rentabilidad_no_datos') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useI18nStore } from '../stores/i18n';
import { useCurrency } from '../composables/useCurrency';

const { fm } = useCurrency();
const i18n = useI18nStore();

const desde = ref(new Date(Date.now()-30*86400000).toISOString().split('T')[0]);
const hasta = ref(new Date().toISOString().split('T')[0]);
const ubicacionId = ref('');
const ubicaciones = ref([]);
const productos = ref([]);
const loading = ref(false);

const totalIngresos = computed(() => productos.value.reduce((s, p) => s + Number(p.ingresos || 0), 0));
const totalCostos = computed(() => productos.value.reduce((s, p) => s + Number(p.costo_total || 0), 0));
const totalMargen = computed(() => totalIngresos.value - totalCostos.value);
const margenPorcentaje = computed(() => totalIngresos.value > 0 ? Math.round((totalMargen.value / totalIngresos.value) * 100) : 0);

async function cargar() {
  loading.value = true;
  try {
    const params = { desde: desde.value, hasta: hasta.value };
    if (ubicacionId.value) params.ubicacion_id = ubicacionId.value;
    const { data } = await api.get('/reportes/rentabilidad-productos', { params });
    productos.value = data.productos || [];
  } catch (e) {
    productos.value = [];
    console.error(e);
  }
  loading.value = false;
}

async function cargarUbicaciones() {
  try {
    const { data } = await api.get('/configuracion/ubicaciones');
    ubicaciones.value = (data.ubicaciones || []).filter(u => u.activo);
  } catch (e) { console.error(e); }
}


onMounted(() => { cargar(); cargarUbicaciones(); });
</script>

<style scoped>
@media (max-width: 1023px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .flex.items-center.gap-md { flex-wrap: wrap; gap: 8px; }
}

@media (max-width: 768px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
  .flex { flex-wrap: wrap; gap: 8px; }
  .flex.items-center.gap-sm {
    flex-wrap: wrap;
    gap: 8px;
  }
  .flex.items-center.gap-sm > .form-control,
  .flex.items-center.gap-sm > select {
    max-width: 100% !important;
    min-width: 0 !important;
    flex: 1 1 100%;
  }
  .flex.items-center.gap-sm > label {
    flex: 0 0 auto;
  }
  .table-container {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    max-width: 100%;
  }
  .data-table { min-width: 600px; }
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    padding: 12px 16px;
  }
}

@media (max-width: 480px) {
  .grid-4 { grid-template-columns: 1fr; }
  .btn { min-height: 44px; width: 100%; font-size: 15px; }
  .data-table thead { display: none; }
  .data-table tbody tr {
    display: flex; flex-direction: column; padding: 12px; margin: 8px;
    border: 1px solid var(--border); border-radius: 8px;
    background: var(--bg-card); gap: 4px;
  }
  .data-table tbody td {
    display: flex; justify-content: space-between; align-items: center;
    padding: 4px 0; font-size: 14px; white-space: normal; border: none;
  }
  .data-table tbody td::before {
    content: attr(data-label); font-weight: 600; color: var(--text-secondary); min-width: 40%;
  }
  .data-table { min-width: 100%; }
}
</style>
