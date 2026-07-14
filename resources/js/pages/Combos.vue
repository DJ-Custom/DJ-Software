<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex gap-sm">
        <button :class="['btn', tab==='combos'?'btn-primary':'btn-secondary']" @click="tab='combos'">{{ i18n.t('combos') }}</button>
        <button :class="['btn', tab==='cupones'?'btn-primary':'btn-secondary']" @click="tab='cupones';cargarCupones()">{{ i18n.t('combos_tab_cupones') }}</button>
        <button :class="['btn', tab==='promos'?'btn-primary':'btn-secondary']" @click="tab='promos';cargarPromos()">{{ i18n.t('combos_tab_promociones') }}</button>
      </div>
    </div>

    <!-- Combos -->
    <div v-if="tab==='combos'">
      <div class="flex justify-end mb-md"><button class="btn btn-primary" @click="showCombo=true"><i class="fas fa-plus"></i> {{ i18n.t('combos_nuevo_titulo') }}</button></div>
      <div class="grid-3 gap-md">
        <div v-for="c in combos" :key="c.id" class="card">
          <div class="card-body">
            <div class="flex items-center justify-between mb-sm">
              <h4>{{ c.nombre }}</h4>
              <span :class="['badge', c.activo?'badge-success':'badge-danger']">{{ c.activo?i18n.t('activo'):i18n.t('inactivo') }}</span>
            </div>
            <p style="font-size:13px;color:var(--text-secondary);">{{ c.descripcion }}</p>
            <div class="mb-sm"><strong>{{ i18n.t('precio') }}: {{ formatMoney(c.precio_combo) }}</strong></div>
            <div style="font-size:12px;" v-if="c.productos"><span v-for="(p,i) in c.productos" :key="i" class="badge badge-info mr-xs">{{ p.nombre }} x{{ p.cantidad }}</span></div>
            <div class="mt-sm"><button class="btn btn-sm btn-ghost" @click="toggleCombo(c.id)"><i :class="c.activo?'fas fa-toggle-on':'fas fa-toggle-off'"></i></button></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Cupones -->
    <div v-if="tab==='cupones'">
      <div class="flex justify-end mb-md"><button class="btn btn-primary" @click="showCupon=true"><i class="fas fa-plus"></i> {{ i18n.t('combos_cupones_nuevo') }}</button></div>
      <div class="card"><div class="card-body" style="padding:0;">
        <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('codigo') }}</th><th>{{ i18n.t('combos_cupones_tipo_descuento') }}</th><th>{{ i18n.t('combos_cupones_valor_descuento') }}</th><th>{{ i18n.t('combos_cupones_usos_maximos') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('estado') }}</th><th></th></tr></thead>
            <tbody><tr v-for="c in cupones" :key="c.id"><td><strong>{{ c.codigo }}</strong></td><td>{{ c.tipo_descuento }}</td><td>{{ c.tipo_descuento==='porcentaje'?c.valor_descuento+'%':formatMoney(c.valor_descuento) }}</td><td>{{ c.usos_actuales }}/{{ c.usos_maximos||'\u221E' }}</td><td>{{ c.fecha_inicio||'-' }} ~ {{ c.fecha_fin||'-' }}</td><td><span :class="['badge',c.activo?'badge-success':'badge-danger']">{{ c.activo?i18n.t('activo'):i18n.t('inactivo') }}</span></td><td><button class="btn btn-sm btn-ghost" @click="toggleCupon(c.id)"><i :class="c.activo?'fas fa-toggle-on':'fas fa-toggle-off'"></i></button></td></tr></tbody>
          </table>
        </div>
      </div></div>
    </div>

    <!-- Promociones -->
    <div v-if="tab==='promos'">
      <div class="flex justify-end mb-md"><button class="btn btn-primary" @click="showPromo=true"><i class="fas fa-plus"></i> {{ i18n.t('combos_promociones_nueva') }}</button></div>
      <div class="card"><div class="card-body" style="padding:0;">
        <div class="table-responsive">
          <table class="data-table"><thead><tr><th>{{ i18n.t('nombre') }}</th><th>{{ i18n.t('combos_promociones_tipo') }}</th><th>{{ i18n.t('combos_promociones_valor') }}</th><th>{{ i18n.t('aplica_a') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('estado') }}</th><th></th></tr></thead>
            <tbody><tr v-for="p in promos" :key="p.id"><td><strong>{{ p.nombre }}</strong></td><td>{{ p.tipo_descuento }}</td><td>{{ p.tipo_descuento==='porcentaje'?p.valor_descuento+'%':formatMoney(p.valor_descuento) }}</td><td>{{ p.aplica_a }}</td><td>{{ p.fecha_inicio||'-' }} ~ {{ p.fecha_fin||'-' }}</td><td><span :class="['badge',p.activo?'badge-success':'badge-danger']">{{ p.activo?i18n.t('activo'):i18n.t('inactivo') }}</span></td><td><button class="btn btn-sm btn-ghost" @click="togglePromo(p.id)"><i :class="p.activo?'fas fa-toggle-on':'fas fa-toggle-off'"></i></button></td></tr></tbody>
          </table>
        </div>
      </div></div>
    </div>

    <!-- Modal Combo -->
    <div class="modal-overlay" :class="{active:showCombo}" @click.self="showCombo=false">
      <div class="modal" style="max-width:min(90vw,600px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('combos_nuevo_titulo') }}</h3><button class="modal-close" @click="showCombo=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('nombre') }}</label><input v-model="fCombo.nombre" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('precio') }}</label><input v-model.number="fCombo.precio_combo" type="number" class="form-control" :min="0"></div>
          <div class="form-group"><label>{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label><input v-model="bProd" class="form-control" @input="buscarProductos" :placeholder="i18n.t('nombre_o_codigo')"></div>
          <div v-if="pResults.length" style="max-height:120px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="p in pResults" :key="p.id" class="p-sm" style="cursor:pointer;" @click="addComboProd(p)">{{ p.nombre }}</div>
          </div>
          <div v-for="(p,i) in fCombo.productos" :key="i" class="flex items-center gap-sm mt-sm"><span>{{ p.nombre }}</span><input v-model.number="p.cantidad" type="number" min="1" class="form-control table-num-input"><button class="btn btn-sm btn-danger" @click="fCombo.productos.splice(i,1)"><i class="fas fa-trash"></i></button></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="crearCombo">{{ i18n.t('crear') }}</button></div>
      </div>
    </div>

    <!-- Modal Cupón -->
    <div class="modal-overlay" :class="{active:showCupon}" @click.self="showCupon=false">
      <div class="modal">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('combos_cupones_nuevo') }}</h3><button class="modal-close" @click="showCupon=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2">
            <div class="form-group"><label>{{ i18n.t('codigo') }}</label><input v-model="fCupon.codigo" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('combos_cupones_tipo_descuento') }}</label><select v-model="fCupon.tipo_descuento" class="form-control"><option value="porcentaje">{{ i18n.t('combos_promociones_tipo') }}</option><option value="monto_fijo">{{ i18n.t('precio') }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('combos_cupones_valor_descuento') }}</label><input v-model.number="fCupon.valor_descuento" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('combos_cupones_usos_maximos') }}</label><input v-model.number="fCupon.usos_maximos" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('fecha') }}</label><input v-model="fCupon.fecha_inicio" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('fecha') }}</label><input v-model="fCupon.fecha_fin" type="date" class="form-control"></div>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="crearCupon">{{ i18n.t('crear') }}</button></div>
      </div>
    </div>

    <!-- Modal Promo -->
    <div class="modal-overlay" :class="{active:showPromo}" @click.self="showPromo=false">
      <div class="modal">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('combos_promociones_nueva') }}</h3><button class="modal-close" @click="showPromo=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2">
            <div class="form-group"><label>{{ i18n.t('nombre') }}</label><input v-model="fPromo.nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('combos_promociones_tipo') }}</label><select v-model="fPromo.tipo_descuento" class="form-control"><option value="porcentaje">{{ i18n.t('combos_promociones_tipo') }}</option><option value="monto_fijo">{{ i18n.t('precio') }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('combos_promociones_valor') }}</label><input v-model.number="fPromo.valor_descuento" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('combos_promociones_condiciones') }}</label><select v-model="fPromo.aplica_a" class="form-control"><option value="todos">{{ i18n.t('todos') }}</option><option value="categoria">{{ i18n.t('categoria') }}</option><option value="producto">{{ i18n.t('producto') }}</option></select></div>
            <div class="form-group"><label>{{ i18n.t('fecha') }}</label><input v-model="fPromo.fecha_inicio" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('fecha') }}</label><input v-model="fPromo.fecha_fin" type="date" class="form-control"></div>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="crearPromo">{{ i18n.t('crear') }}</button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();

const tab = ref('combos');
const combos = ref([]); const cupones = ref([]); const promos = ref([]);
const showCombo = ref(false); const showCupon = ref(false); const showPromo = ref(false);
const fCombo = ref({ nombre:'', descripcion:'', precio_combo:0, productos:[] });
const fCupon = ref({ codigo:'', tipo_descuento:'porcentaje', valor_descuento:0, usos_maximos:null, fecha_inicio:'', fecha_fin:'' });
const fPromo = ref({ nombre:'', tipo_descuento:'porcentaje', valor_descuento:0, aplica_a:'todos', fecha_inicio:'', fecha_fin:'' });
const bProd = ref(''); const pResults = ref([]);

onMounted(() => cargarCombos());
async function cargarCombos() { try { const {data}=await api.get('/combos'); combos.value=data.combos||[]; } catch(e){} }
async function cargarCupones() { try { const {data}=await api.get('/cupones'); cupones.value=data.cupones||[]; } catch(e){} }
async function cargarPromos() { try { const {data}=await api.get('/promociones'); promos.value=data.promociones||[]; } catch(e){} }
async function buscarProductos() { if(bProd.value.length<2){pResults.value=[];return;} try { const {data}=await api.get('/productos/buscar',{params:{q:bProd.value}}); pResults.value=data.productos||[]; } catch(e){} }
function addComboProd(p) { fCombo.value.productos.push({producto_id:p.id,nombre:p.nombre,cantidad:1}); bProd.value=''; pResults.value=[]; }
async function crearCombo() { try { await api.post('/combos',fCombo.value); showCombo.value=false; fCombo.value={nombre:'',descripcion:'',precio_combo:0,productos:[]}; cargarCombos(); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); } }
async function crearCupon() { try { await api.post('/cupones',fCupon.value); showCupon.value=false; cargarCupones(); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); } }
async function crearPromo() { try { await api.post('/promociones',fPromo.value); showPromo.value=false; cargarPromos(); } catch(e){ toast.error(e.response?.data?.error||i18n.t('error')); } }
async function toggleCombo(id) { try { await api.post(`/combos/${id}/toggle`); cargarCombos(); } catch(e){} }
async function toggleCupon(id) { try { await api.post(`/cupones/${id}/toggle`); cargarCupones(); } catch(e){} }
async function togglePromo(id) { try { await api.post(`/promociones/${id}/toggle`); cargarPromos(); } catch(e){} }
</script>

<style scoped>
.table-num-input { width: 100%; max-width: 60px; min-width: 0; }

@media (max-width: 768px) {
  .grid-3 {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .btn { min-height: 44px; }
}
</style>
