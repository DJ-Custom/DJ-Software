<template>
  <div>
    <!-- Header con tabs -->
    <div class="flex items-center justify-between mb-lg">
      <div class="flex items-center gap-sm" style="flex-wrap: wrap;">
        <button v-for="t in tabs" :key="t.key"
          :class="['btn btn-sm', tab === t.key ? 'btn-primary' : 'btn-ghost']"
          @click="switchTab(t.key)">
          <i :class="t.icon"></i> {{ t.label() }}
        </button>
      </div>
      <div class="flex items-center gap-sm">
        <button v-if="tab === 'empleados'" class="btn btn-primary" @click="showModal = true; resetForm()">
          <i class="fas fa-plus"></i> {{ i18n.t('planilla_nuevo_empleado') }}
        </button>
        <button v-if="tab === 'pagos'" class="btn btn-primary" @click="showModal = true; resetPagoForm()">
          <i class="fas fa-plus"></i> {{ i18n.t('planilla_nuevo_pago') }}
        </button>
      </div>
    </div>

    <!-- Vista: Configuración de empleado -->
    <EmployeePayrollConfig v-if="configuringEmployee" :empleado="configuringEmployee" @back="configuringEmployee = null" @saved="cargar" />

    <!-- Tab: Empleados -->
    <div v-if="tab === 'empleados' && !configuringEmployee" class="card">
      <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ i18n.t('planilla_nombre') }}</th>
              <th>{{ i18n.t('planilla_cedula') }}</th>
              <th>{{ i18n.t('planilla_puesto') }}</th>
              <th>{{ i18n.t('planilla_depto') }}</th>
              <th>{{ i18n.t('planilla_salario_base') }}</th>
              <th>{{ i18n.t('planilla_tipo_salario') }}</th>
              <th>{{ i18n.t('planilla_estado') }}</th>
              <th>Notas</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="e in empleados" :key="e.id">
              <td><strong>{{ e.nombre }}</strong></td>
              <td>{{ e.cedula }}</td>
              <td>{{ e.puesto }}</td>
              <td>{{ e.departamento || '-' }}</td>
              <td>{{ fm(e.salario_base) }}</td>
              <td>
                <span class="badge" :class="tipoBadge(e.configuracion?.tipo_salario)">
                  {{ formatTipoSalario(e.configuracion?.tipo_salario) }}
                </span>
              </td>
              <td>
                <span :class="['badge', e.activo ? 'badge-success' : 'badge-danger']">
                  {{ e.activo ? i18n.t('activo') : i18n.t('inactivo') }}
                </span>
              </td>
              <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" :title="e.notas_empleado">{{ e.notas_empleado || '-' }}</td>
              <td>
                <button class="btn btn-sm btn-ghost" @click="configuringEmployee = e" :title="i18n.t('planilla_configurar')">
                  <i class="fas fa-cog"></i>
                </button>
                <button class="btn btn-sm btn-ghost" @click="editarEmpleado(e)" :title="i18n.t('editar')">
                  <i class="fas fa-edit"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Tab: Pagos -->
    <div v-if="tab === 'pagos'" class="card">
      <div class="card-body">
        <div style="padding: 12px 16px; display: flex; justify-content: flex-end;">
          <DateRangeDownloader :fetch-data="fetchPagosRange" filename="planilla_pagos" :columns="pagosColumns" />
        </div>
      </div>
      <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>{{ i18n.t('planilla_empleados') }}</th>
              <th>{{ i18n.t('planilla_periodo') }}</th>
              <th>{{ i18n.t('planilla_base') }}</th>
              <th>{{ i18n.t('planilla_extras') }}</th>
              <th>{{ i18n.t('planilla_bonos') }}</th>
              <th>{{ i18n.t('planilla_incentivos') }}</th>
              <th>{{ i18n.t('planilla_ccss') }}</th>
              <th>{{ i18n.t('planilla_deducciones') }}</th>
              <th>{{ i18n.t('planilla_neto') }}</th>
              <th>{{ i18n.t('planilla_estado') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in pagos" :key="p.id">
              <td><strong>{{ p.empleado?.nombre || p.empleado_nombre }}</strong></td>
              <td>{{ p.periodo }}</td>
              <td>{{ fm(p.salario_base) }}</td>
              <td>{{ fm(p.monto_horas_extra) }}</td>
              <td>{{ fm(p.bonificaciones) }}</td>
              <td>{{ fm(p.incentivos) }}</td>
              <td>{{ fm(p.ccss_obrero) }}</td>
              <td class="text-danger">{{ fm((p.deducciones || 0) + (p.rebajos || 0) + (p.embargos || 0) + (p.otras_deducciones || 0)) }}</td>
              <td style="font-weight: 700; color: var(--success);">{{ fm(p.salario_neto) }}</td>
              <td>
                <span :class="['badge', p.estado === 'pagado' ? 'badge-success' : 'badge-warning']">{{ p.estado }}</span>
              </td>
            </tr>
          </tbody>
        </table>
        </div>
      </div>
    </div>

    <!-- Tab: Plantillas -->
    <div v-if="tab === 'plantillas'">
      <TemplateManager />
    </div>

    <!-- Tab: Simulación -->
    <div v-if="tab === 'simulacion'">
      <div class="sim-select-emp">
        <div class="form-group" style="max-width: 300px;">
          <label>{{ i18n.t('planilla_seleccionar_empleado') }}</label>
          <select v-model="simEmpleadoId" class="form-control" @change="loadSimEmpleado">
            <option :value="null">— {{ i18n.t('planilla_seleccionar') }} —</option>
            <option v-for="e in empleados" :key="e.id" :value="e.id">{{ e.nombre }}</option>
          </select>
        </div>
      </div>
      <SimulationPanel v-if="simFormula" :formula="simFormula" :empleado="simEmpleado" />
      <div v-else class="empty-hint">
        <i class="fas fa-info-circle"></i> {{ i18n.t('planilla_seleccionar_empleado_simular') }}
      </div>
    </div>

    <!-- Tab: Historial global -->
    <div v-if="tab === 'historial_global'">
      <div class="form-group" style="max-width: 300px; margin-bottom: 12px;">
        <label>{{ i18n.t('planilla_seleccionar_empleado') }}</label>
        <select v-model="histEmpleadoId" class="form-control" @change="loadHist">
          <option :value="null">— {{ i18n.t('planilla_seleccionar') }} —</option>
          <option v-for="e in empleados" :key="e.id" :value="e.id">{{ e.nombre }}</option>
        </select>
      </div>
      <PayrollHistory v-if="histEmpleadoId" :empleado-id="histEmpleadoId" @restore="restaurarVersion" />
    </div>

    <!-- Modal: Nuevo/Editar Empleado -->
    <div class="modal-overlay" :class="{ active: showModal }" @click.self="showModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3 class="modal-title">
            {{ modalType === 'empleado'
              ? (editItem ? i18n.t('editar') : i18n.t('nuevo')) + ' ' + i18n.t('planilla_empleados')
              : i18n.t('planilla_nuevo_pago') }}
          </h3>
          <button class="modal-close" @click="showModal = false"><i class="fas fa-times"></i></button>
        </div>

        <!-- Form Empleado -->
        <div class="modal-body" v-if="modalType === 'empleado'">
          <div class="grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('planilla_nombre') }} *</label><input v-model="empForm.nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_cedula') }} *</label><input v-model="empForm.cedula" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_puesto') }} *</label><input v-model="empForm.puesto" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_departamento') }}</label><input v-model="empForm.departamento" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_salario_base') }}</label><input v-model.number="empForm.salario_base" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_fecha_ingreso') }}</label><input v-model="empForm.fecha_ingreso" type="date" class="form-control"></div>
            <div class="form-group">
              <label>Tipo Contrato</label>
              <select v-model="empForm.tipo_contrato" class="form-control">
                <option value="indefinido">Indefinido</option>
                <option value="temporal">Temporal</option>
                <option value="servicios">Servicios Prof.</option>
              </select>
            </div>
            <div class="form-group"><label>Cuenta Banco</label><input v-model="empForm.cuenta_banco" class="form-control"></div>
          </div>
          <div class="form-group" style="grid-column: 1 / -1;">
            <label>Notas del Empleado (datos que influyen en el pago)</label>
            <textarea v-model="empForm.notas_empleado" class="form-control" rows="3" placeholder="Información relevante para el cálculo de pago..."></textarea>
          </div>
        </div>

        <!-- Form Pago -->
        <div class="modal-body" v-if="modalType === 'pago'">
          <div class="grid-2 gap-sm">
            <div class="form-group">
              <label>{{ i18n.t('planilla_empleados') }} *</label>
              <select v-model="pagoForm.empleado_id" class="form-control" @change="autoSalario">
                <option v-for="e in empleados" :key="e.id" :value="e.id">{{ e.nombre }}</option>
              </select>
            </div>
            <div class="form-group"><label>{{ i18n.t('planilla_periodo') }} *</label><input v-model="pagoForm.periodo" type="date" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_salario_base') }}</label><input v-model.number="pagoForm.salario_base" type="number" class="form-control"></div>
            <div class="form-group"><label>Jornada Laboral (horas/día)</label><input v-model.number="pagoForm.jornada_laboral" type="number" class="form-control" placeholder="8"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_horas_extras') }} {{ i18n.t('cantidad') }}</label><input v-model.number="pagoForm.horas_extra_cantidad" type="number" class="form-control"></div>
            <div class="form-group"><label>Horas Dobles</label><input v-model.number="pagoForm.horas_dobles_cantidad" type="number" class="form-control"></div>
            <div class="form-group"><label>Horas Nocturnas</label><input v-model.number="pagoForm.horas_nocturnas_cantidad" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_bonos') }}</label><input v-model.number="pagoForm.bonificaciones" type="number" class="form-control"></div>
            <div class="form-group"><label>Comisiones</label><input v-model.number="pagoForm.comisiones" type="number" class="form-control"></div>
            <div class="form-group"><label>Incentivos</label><input v-model.number="pagoForm.incentivos" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('planilla_deducciones') }}</label><input v-model.number="pagoForm.deducciones" type="number" class="form-control"></div>
            <div class="form-group"><label>Rebajos</label><input v-model.number="pagoForm.rebajos" type="number" class="form-control"></div>
            <div class="form-group"><label>Embargos</label><input v-model.number="pagoForm.embargos" type="number" class="form-control"></div>
            <div class="form-group"><label>Otros Ingresos</label><input v-model.number="pagoForm.otros_ingresos" type="number" class="form-control"></div>
            <div class="form-group"><label>Otras Deducciones</label><input v-model.number="pagoForm.otras_deducciones" type="number" class="form-control"></div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-primary" @click="guardar">
            <i class="fas fa-save"></i> {{ i18n.t('guardar') }}
          </button>
        </div>
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
import EmployeePayrollConfig from '../components/planilla/EmployeePayrollConfig.vue';
import TemplateManager from '../components/planilla/TemplateManager.vue';
import SimulationPanel from '../components/planilla/SimulationPanel.vue';
import PayrollHistory from '../components/planilla/PayrollHistory.vue';
import DateRangeDownloader from '../components/DateRangeDownloader.vue';

const { fm } = useCurrency();
const i18n = useI18nStore();
const toast = useToastStore();

const tab = ref('empleados');
const showModal = ref(false);
const modalType = ref('empleado');
const editItem = ref(null);
const empleados = ref([]);
const pagos = ref([]);
const empForm = ref({});
const pagoForm = ref({});
const configuringEmployee = ref(null);

const pagosColumns = [
  { key: 'empleado_nombre', label: 'Empleado' },
  { key: 'periodo', label: 'Período' },
  { key: 'salario_base', label: 'Salario Base' },
  { key: 'monto_horas_extra', label: 'Horas Extra' },
  { key: 'bonificaciones', label: 'Bonificaciones' },
  { key: 'incentivos', label: 'Incentivos' },
  { key: 'ccss_obrero', label: 'CCSS' },
  { key: 'salario_neto', label: 'Salario Neto' },
  { key: 'estado', label: 'Estado' },
];

async function fetchPagosRange(desde, hasta) {
  const { data } = await api.get('/planilla/pagos');
  return (data.pagos || []).map(p => ({
    empleado_nombre: p.empleado?.nombre || '', periodo: p.periodo,
    salario_base: p.salario_base, monto_horas_extra: p.monto_horas_extra,
    bonificaciones: p.bonificaciones, incentivos: p.incentivos,
    ccss_obrero: p.ccss_obrero, salario_neto: p.salario_neto, estado: p.estado,
  }));
}

// Simulación
const simEmpleadoId = ref(null);
const simEmpleado = ref(null);
const simFormula = ref(null);

// Historial
const histEmpleadoId = ref(null);

const tabs = [
  { key: 'empleados', label: () => i18n.t('planilla_empleados'), icon: 'fas fa-users' },
  { key: 'pagos', label: () => i18n.t('planilla_pagos'), icon: 'fas fa-money-bill' },
  { key: 'plantillas', label: () => i18n.t('planilla_plantillas'), icon: 'fas fa-copy' },
  { key: 'simulacion', label: () => i18n.t('planilla_simulacion'), icon: 'fas fa-play-circle' },
  { key: 'historial_global', label: () => i18n.t('planilla_historial'), icon: 'fas fa-history' },
];

function switchTab(key) {
  tab.value = key;
  configuringEmployee.value = null;
}

function resetForm() {
  modalType.value = 'empleado';
  editItem.value = null;
  empForm.value = { nombre: '', cedula: '', puesto: '', departamento: '', salario_base: 0, fecha_ingreso: '', tipo_contrato: 'indefinido', cuenta_banco: '', notas_empleado: '' };
}

function resetPagoForm() {
  modalType.value = 'pago';
  pagoForm.value = { empleado_id: '', periodo: new Date().toISOString().split('T')[0], salario_base: 0, jornada_laboral: 8, horas_extra_cantidad: 0, horas_dobles_cantidad: 0, horas_nocturnas_cantidad: 0, bonificaciones: 0, comisiones: 0, incentivos: 0, deducciones: 0, rebajos: 0, embargos: 0, otros_ingresos: 0, otras_deducciones: 0 };
}

async function cargar() {
  try {
    const [e, p] = await Promise.all([api.get('/planilla/empleados'), api.get('/planilla/pagos')]);
    empleados.value = e.data.empleados || [];
    pagos.value = p.data.pagos || [];
  } catch (e) { /* silent */ }
}

function editarEmpleado(e) {
  editItem.value = { id: e.id };
  empForm.value = {
    nombre: e.nombre || '',
    cedula: e.cedula || '',
    puesto: e.puesto || '',
    departamento: e.departamento || '',
    salario_base: e.salario_base || 0,
    fecha_ingreso: e.fecha_ingreso || '',
    tipo_contrato: e.tipo_contrato || 'indefinido',
    cuenta_banco: e.cuenta_banco || '',
    notas_empleado: e.notas_empleado || '',
    telefono: e.telefono || '',
    email: e.email || '',
  };
  modalType.value = 'empleado';
  showModal.value = true;
}

function autoSalario() {
  const e = empleados.value.find(x => x.id == pagoForm.value.empleado_id);
  if (e) pagoForm.value.salario_base = e.salario_base;
}

function tipoSalarioConfig(tipo) {
  const map = { fijo: 'Fijo', por_hora: 'Por Hora', por_comision: 'Por Comisión', mixto: 'Mixto' };
  return map[tipo] || 'Fijo';
}

function tipoBadge(tipo) {
  const map = { fijo: 'badge-success', por_hora: 'badge-info', por_comision: 'badge-warning', mixto: 'badge-primary' };
  return map[tipo] || 'badge-success';
}

async function guardar() {
  try {
    if (modalType.value === 'empleado') {
      if (editItem.value?.id) {
        await api.put(`/planilla/empleados/${editItem.value.id}`, empForm.value);
      } else {
        await api.post('/planilla/empleados', empForm.value);
      }
    } else {
      await api.post('/planilla/pagos', pagoForm.value);
    }
    showModal.value = false;
    cargar();
  } catch (e) {
    if (e.response?.status === 429) toast.warning(i18n.t('solicitud_procesando'));
    else toast.error(e.response?.data?.message || i18n.t('error'));
  }
}

async function loadSimEmpleado() {
  if (!simEmpleadoId.value) { simEmpleado.value = null; simFormula.value = null; return; }
  simEmpleado.value = empleados.value.find(e => e.id === simEmpleadoId.value);
  try {
    const res = await api.get(`/planilla/configuracion/${simEmpleadoId.value}`);
    simFormula.value = res.data.configuracion?.formula_texto || null;
  } catch (e) { simFormula.value = null; }
}

async function loadHist() { /* PayrollHistory component handles its own loading */ }

async function restaurarVersion(h) {
  try {
    await api.post(`/planilla/restaurar-version/${h.id}`);
    toast.success(i18n.t('planilla_version_restaurada'));
    cargar();
  } catch (e) {
    toast.error(e.response?.data?.message || i18n.t('error'));
  }
}

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
  
  .sim-select-emp .form-group {
    max-width: 100%;
  }
}

@media (max-width: 480px) {
  .flex.items-center.justify-between.mb-lg {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .flex.items-center.gap-sm {
    flex-wrap: wrap;
  }
  
  .card-body {
    padding: 8px;
  }
  
  .btn {
    font-size: clamp(12px, 2.5vw, 14px);
  }
  
  .empty-hint {
    font-size: clamp(12px, 2.5vw, 14px);
    padding: 12px;
    text-align: center;
  }
}
</style>
