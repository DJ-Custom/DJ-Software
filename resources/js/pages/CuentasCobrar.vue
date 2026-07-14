<template>
  <div>
    <div class="grid-3 mb-lg">
      <div class="stat-card"><div class="stat-value">{{ fm(totalPendiente) }}</div><div class="stat-label">{{ i18n.t('cuentas_cobrar_pendiente_cobro') }}</div></div>
      <div class="stat-card"><div class="stat-value">{{ fm(totalVencido) }}</div><div class="stat-label">{{ i18n.t('cuentas_cobrar_vencido') }}</div></div>
      <div class="stat-card"><div class="stat-value">{{ cantidadCuentas }}</div><div class="stat-label">{{ i18n.t('cuentas_cobrar_cuentas_activas') }}</div></div>
    </div>
    <div class="card"><div class="card-body" style="padding:0;">
      <div class="table-responsive">
        <table class="data-table"><thead><tr><th>{{ i18n.t('cuentas_cobrar_cliente') }}</th><th>{{ i18n.t('cuentas_cobrar_factura_venta') }}</th><th>{{ i18n.t('cuentas_cobrar_monto_total') }}</th><th>{{ i18n.t('cuentas_cobrar_saldo_pendiente') }}</th><th>{{ i18n.t('cuentas_cobrar_vencimiento') }}</th><th>{{ i18n.t('cuentas_cobrar_estado') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
          <tbody><tr v-for="c in cuentas" :key="c.id">
            <td><strong>{{ c.cliente_nombre||'-' }}</strong></td><td>{{ c.numero_factura||c.venta_id }}</td>
            <td>{{ fm(c.monto_total) }}</td><td style="font-weight:700;color:var(--danger);">{{ fm(c.saldo_pendiente) }}</td>
            <td :style="{color:c.vencido?'var(--danger)':'inherit'}">{{ c.fecha_vencimiento||'-' }}</td>
            <td><span :class="['badge', c.estado==='pagada'?'badge-success':c.estado==='vencida'?'badge-danger':'badge-warning']">{{ c.estado }}</span></td>
            <td>
              <button v-if="c.estado!=='pagada'" class="btn btn-sm btn-success" @click="registrarPago(c)" :title="i18n.t('cuentas_cobrar_registrar_pago')"><i class="fas fa-dollar-sign"></i></button>
              <button class="btn btn-sm btn-ghost" @click="editarCuenta(c)" :title="i18n.t('editar')"><i class="fas fa-edit"></i></button>
              <button class="btn btn-sm btn-ghost btn-danger-icon" @click="eliminarCuenta(c)" :title="i18n.t('eliminar')"><i class="fas fa-trash"></i></button>
            </td>
          </tr></tbody>
        </table>
      </div>
    </div></div>
    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('cuentas_cobrar_registrar_pago') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('cuentas_cobrar_monto_pagar') }}</label><input v-model.number="pagoForm.monto" type="number" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('fecha') }}</label><input v-model="pagoForm.fecha" type="date" class="form-control"></div>
          <div class="form-group"><label>{{ i18n.t('metodo_pago') }}</label><select v-model="pagoForm.metodo_pago" class="form-control"><option value="efectivo">{{ i18n.t('efectivo') }}</option><option value="transferencia">Transferencia</option><option value="cheque">Cheque</option></select></div>
          <div class="form-group"><label>{{ i18n.t('referencia') }}</label><input v-model="pagoForm.referencia" class="form-control"></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardarPago" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('procesando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('guardar') }}</span></button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm } = useCurrency();
const i18n = useI18nStore();

const toast = useToastStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('procesando') });

const cuentas = ref([]); const showModal = ref(false); const pagoForm = ref({});
const editingCuentaId = ref(null);
const totalPendiente = computed(() => cuentas.value.filter(c=>c.estado!=='pagada').reduce((s,c)=>s+Number(c.saldo_pendiente||0),0));
const totalVencido = computed(() => cuentas.value.filter(c=>c.vencido).reduce((s,c)=>s+Number(c.saldo_pendiente||0),0));
const cantidadCuentas = computed(() => cuentas.value.length);
async function cargar() { try { const {data} = await api.get('/cuentas-cobrar'); cuentas.value=data.cuentas||[]; } catch(e){ cuentas.value=[]; } }
function registrarPago(c) { editingCuentaId.value = null; pagoForm.value = {cuenta_id:c.id, monto:c.saldo_pendiente, fecha:new Date().toISOString().split('T')[0], metodo_pago:'efectivo', referencia:''}; showModal.value=true; }

function editarCuenta(c) {
    editingCuentaId.value = c.id;
    pagoForm.value = {
        monto_total: c.monto_total,
        fecha_vencimiento: c.fecha_vencimiento || '',
        notas: c.notas || ''
    };
    showModal.value = true;
}

async function eliminarCuenta(c) {
    if (!confirm('¿Eliminar esta cuenta por cobrar?')) return;
    try {
        await api.delete(`/cuentas-cobrar/${c.id}`);
        toast.success(i18n.t('eliminado'));
        cargar();
    } catch (e) { toast.error(e.response?.data?.error || i18n.t('error')); }
}

async function guardarPago() {
  try {
    await execute(async () => {
        if (editingCuentaId.value) {
            await api.put(`/cuentas-cobrar/${editingCuentaId.value}`, pagoForm.value);
        } else {
            await api.post(`/cuentas-cobrar/${pagoForm.value.cuenta_id}/pago`, pagoForm.value);
        }
        editingCuentaId.value = null;
        showModal.value = false;
        cargar();
    });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message||i18n.t('error')); }
  }
}
onMounted(cargar);
</script>

<style scoped>
.modal-responsive {
  max-width: min(90vw, 400px);
}

@media (max-width: 1023px) {
  .grid-3 {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .grid-3 {
    grid-template-columns: 1fr;
  }

  .stat-card .stat-value {
    font-size: clamp(1rem, 3vw, 1.5rem);
  }

  .modal-responsive {
    max-width: min(95vw, 400px);
  }

  .btn {
    min-height: 44px;
  }
}

.btn-danger-icon { color: var(--danger, #ef4444); }

@media (max-width: 480px) {
  .data-table {
    font-size: 13px;
  }

  .data-table th,
  .data-table td {
    padding: 6px 8px;
    white-space: nowrap;
  }
}
</style>
