<template>
  <div>
    <div class="page-header">
      <input v-model="filtro" class="form-control filter-input" :placeholder="i18n.t('buscar_proveedor')" @input="cargar">
      <button class="btn btn-primary" @click="abrirForm()"><i class="fas fa-plus"></i> {{ i18n.t('nuevo_proveedor') }}</button>
    </div>

    <div class="card">
      <div class="card-body table-card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('nombre') }}</th><th>{{ i18n.t('proveedor_empresa') }}</th><th>{{ i18n.t('telefono') }}</th><th>{{ i18n.t('email') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="p in items" :key="p.id">
                <td><strong>{{ p.nombre }}</strong></td>
                <td>{{ p.empresa || '-' }}</td>
                <td>{{ p.telefono || '-' }}</td>
                <td>{{ p.email || '-' }}</td>
                <td><span :class="['badge', p.activo?'badge-success':'badge-danger']">{{ p.activo ? i18n.t('activo') : i18n.t('inactivo') }}</span></td>
                <td>
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(p.id)"><i class="fas fa-eye"></i></button>
                  <button class="btn btn-sm btn-ghost" @click="abrirForm(p)"><i class="fas fa-edit"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="6" class="empty-state">{{ i18n.t('no_hay_proveedores') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Form -->
    <div class="modal-overlay" :class="{active:showForm}" @click.self="showForm=false">
      <div class="modal modal-form">
        <div class="modal-header"><h3 class="modal-title">{{ editId ? i18n.t('editar_proveedor') : i18n.t('nuevo_proveedor') }}</h3><button class="modal-close" @click="showForm=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-grid-2">
            <div class="form-group"><label>{{ i18n.t('nombre') }} *</label><input v-model="form.nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('proveedor_empresa') }}</label><input v-model="form.empresa" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('proveedor_contacto') }}</label><input v-model="form.contacto_nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('telefono') }}</label><input v-model="form.telefono" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('email') }}</label><input v-model="form.email" class="form-control" type="email"></div>
            <div class="form-group"><label>{{ i18n.t('direccion') }}</label><input v-model="form.direccion" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('proveedor_notas') }}</label><textarea v-model="form.notas" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-save" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('guardando_proveedor') }}</span><span v-else>{{ editId ? i18n.t('editar') : i18n.t('crear') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDetalle}" @click.self="showDetalle=false">
      <div class="modal modal-form">
        <div class="modal-header"><h3 class="modal-title">{{ detalle?.nombre }}</h3><button class="modal-close" @click="showDetalle=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" v-if="detalle">
          <div class="info-grid mb-md">
            <div><strong>{{ i18n.t('proveedor_empresa') }}:</strong> {{ detalle.empresa||'N/A' }}</div>
            <div><strong>{{ i18n.t('proveedor_contacto') }}:</strong> {{ detalle.contacto_nombre||'N/A' }}</div>
            <div><strong>{{ i18n.t('telefono') }}:</strong> {{ detalle.telefono||'N/A' }}</div>
            <div><strong>{{ i18n.t('email') }}:</strong> {{ detalle.email||'N/A' }}</div>
            <div><strong>{{ i18n.t('total_compras') }}:</strong> {{ formatMoney(detalle.total_compras) }}</div>
          </div>
          <h4 class="mb-sm">{{ i18n.t('ultimas_compras') }}</h4>
          <div class="table-responsive" v-if="detalle.compras?.length">
            <table class="data-table"><thead><tr><th>{{ i18n.t('nombre') }}</th><th>{{ i18n.t('total_compras') }}</th><th>{{ i18n.t('estado') }}</th></tr></thead>
              <tbody><tr v-for="c in detalle.compras" :key="c.id"><td>{{ c.numero_compra }}</td><td>{{ formatMoney(c.total) }}</td><td><span :class="['badge',c.estado==='recibida'?'badge-success':'badge-warning']">{{ c.estado }}</span></td></tr></tbody>
            </table>
          </div>
          <p v-else class="text-muted">{{ i18n.t('no_hay_proveedores') }}</p>
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
import { useSubmitLock } from '../composables/useSubmitLock';
import { useCurrency } from '../composables/useCurrency';

const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando_proveedor') });

const items = ref([]); const filtro = ref(''); const showForm = ref(false); const showDetalle = ref(false);
const detalle = ref(null); const editId = ref(null);
const form = ref({ nombre:'', empresa:'', contacto_nombre:'', telefono:'', email:'', direccion:'', notas:'' });

onMounted(() => cargar());

async function cargar() { try { const {data}=await api.get('/proveedores',{params:{q:filtro.value}}); items.value=data.data||[]; } catch(e){} }
function abrirForm(p=null) { if(p) { editId.value=p.id; form.value={nombre:p.nombre,empresa:p.empresa,contacto_nombre:p.contacto_nombre,telefono:p.telefono,email:p.email,direccion:p.direccion,notas:p.notas}; } else { editId.value=null; form.value={nombre:'',empresa:'',contacto_nombre:'',telefono:'',email:'',direccion:'',notas:''}; } showForm.value=true; }
async function guardar() {
  try {
    await execute(async () => {
      if(editId.value) { await api.put(`/proveedores/${editId.value}`,form.value); } else { await api.post('/proveedores',form.value); }
      showForm.value=false; cargar();
    });
  } catch(e) {
    if (e.response?.status === 429) { toast.warning(i18n.t('error')); }
    else { toast.error(e.response?.data?.error||i18n.t('error')); }
  }
}
async function verDetalle(id) { try { const {data}=await api.get(`/proveedores/${id}`); detalle.value=data.proveedor; showDetalle.value=true; } catch(e){} }
</script>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.filter-input {
  width: 300px;
  min-width: 0;
}

.table-card-body {
  padding: 0;
}

.btn-save {
  min-height: 44px;
}

.modal-form {
  max-width: min(90vw, 600px);
}

.form-grid-2 {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.text-muted {
  color: var(--text-muted);
}

/* Tablet */
@media (max-width: 1023px) {
  .filter-input {
    width: 250px;
  }
}

/* Mobile */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
  }

  .page-header .btn {
    min-height: 44px;
  }

  .filter-input {
    width: 100%;
  }

  .form-grid-2 {
    grid-template-columns: 1fr;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .modal-form {
    max-width: 95vw;
    margin: 16px;
  }
}

/* Small mobile */
@media (max-width: 480px) {
  .page-header .btn {
    width: 100%;
    min-height: 48px;
  }

  .btn-save {
    width: 100%;
    min-height: 48px;
  }
}
</style>
