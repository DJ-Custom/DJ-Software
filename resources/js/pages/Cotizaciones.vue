<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <div class="flex gap-sm">
        <input v-model="filtro" class="form-control filter-input" :placeholder="i18n.t('cotizaciones_buscar')" @input="cargar">
        <select v-model="estado" class="form-control filter-select" @change="cargar">
          <option value="">{{ i18n.t('todos') }}</option>
          <option value="pendiente">{{ i18n.t('pendiente') }}</option>
          <option value="aprobada">{{ i18n.t('aprobada') }}</option>
          <option value="rechazada">{{ i18n.t('rechazada') }}</option>
        </select>
      </div>
      <button class="btn btn-primary" @click="showNueva=true"><i class="fas fa-plus"></i> {{ i18n.t('nueva_cotizacion') }}</button>
    </div>

    <div class="card">
      <div class="card-body" style="padding:0;">
        <div class="table-container">
          <table class="data-table">
            <thead><tr><th>{{ i18n.t('numero') }}</th><th>{{ i18n.t('cliente') }}</th><th>{{ i18n.t('total') }}</th><th>{{ i18n.t('estado') }}</th><th>{{ i18n.t('fecha') }}</th><th>{{ i18n.t('acciones') }}</th></tr></thead>
            <tbody>
              <tr v-for="c in items" :key="c.id">
                <td><strong>{{ c.numero_cotizacion }}</strong></td>
                <td>{{ c.cliente_nombre || i18n.t('cotizaciones_sin_cliente') }}</td>
                <td>{{ formatMoney(c.total) }}</td>
                <td><span :class="['badge', badgeEstado(c.estado)]">{{ c.estado }}</span></td>
                <td>{{ formatDate(c.created_at) }}</td>
                <td>
                  <button class="btn btn-sm btn-ghost" @click="verDetalle(c.id)"><i class="fas fa-eye"></i></button>
                  <button v-if="c.estado==='pendiente'" class="btn btn-sm btn-success" @click="aprobar(c.id)" :title="i18n.t('aprobar')"><i class="fas fa-check"></i></button>
                  <button v-if="c.estado==='pendiente'" class="btn btn-sm btn-danger" @click="rechazar(c.id)" :title="i18n.t('rechazar')"><i class="fas fa-times"></i></button>
                  <button v-if="c.estado==='aprobada'" class="btn btn-sm btn-primary" @click="convertirFactura(c.id)" title="Convertir a Factura"><i class="fas fa-file-invoice"></i></button>
                </td>
              </tr>
              <tr v-if="!items.length"><td colspan="6" style="text-align:center;padding:40px;color:var(--text-muted);">{{ i18n.t('sin_cotizaciones') }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Nueva -->
    <div class="modal-overlay" :class="{active:showNueva}" @click.self="showNueva=false">
      <div class="modal" style="max-width:min(90vw,800px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('nueva_cotizacion') }}</h3><button class="modal-close" @click="showNueva=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="grid-2 mb-md">
            <div class="form-group" style="position:relative;">
              <label>{{ i18n.t('cotizaciones_cliente_opcional') }}</label>
              <input v-model="buscarCliente" class="form-control" :placeholder="i18n.t('cotizaciones_buscar_cliente')" @input="buscarClientes">
              <div v-if="clienteResults.length" style="position:absolute;left:0;right:0;top:100%;z-index:20;max-height:150px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;background:var(--bg-card);margin-top:2px;">
                <div v-for="c in clienteResults" :key="c.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);font-size:13px;" @click="seleccionarCliente(c)"><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ c.nombre }} <span style="color:var(--text-muted);">{{ c.cedula }} {{ c.telefono }}</span></div>
              </div>
              <div v-if="form.cliente_id" class="mt-sm p-sm" style="border:1px solid var(--bg-hover);border-radius:8px;background:var(--bg-hover);font-size:13px;">
                <div class="flex items-center justify-between">
                  <div><strong>{{ form.cliente_nombre }}</strong></div>
                  <button class="btn btn-sm btn-danger" @click="quitarClienteCot"><i class="fas fa-times"></i></button>
                </div>
                <div style="color:var(--text-muted);">
                  <span v-if="form.cliente_cedula">{{ i18n.t('cliente_cedula') }}: {{ form.cliente_cedula }} · </span>
                  <span v-if="form.cliente_telefono">{{ i18n.t('telefono') }}: {{ form.cliente_telefono }} · </span>
                  <span v-if="form.cliente_email">{{ form.cliente_email }}</span>
                </div>
              </div>
            </div>
            <div class="form-group"><label>{{ i18n.t('fecha') }} Vencimiento</label><input v-model="form.fecha_vencimiento" type="date" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('buscar') }} {{ i18n.t('producto') }}</label><input v-model="buscarProd" class="form-control" :placeholder="i18n.t('cotizaciones_buscar_producto')" @input="buscarProductos"></div>
          <div v-if="prodResults.length" class="mb-md" style="max-height:150px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;">
            <div v-for="p in prodResults" :key="p.id" class="p-sm" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);" @click="agregarItem(p)">{{ p.nombre }} - {{ formatMoney(p.precio_venta) }}</div>
          </div>
          <table class="data-table mb-md" v-if="form.items.length">
            <thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('precio') }}</th><th>{{ i18n.t('subtotal') }}</th><th></th></tr></thead>
            <tbody>
              <tr v-for="(item,i) in form.items" :key="i">
                <td>{{ item.nombre }}</td>
                <td><input v-model.number="item.cantidad" type="number" min="1" class="form-control table-num-input"></td>
                <td><input v-model.number="item.precio_unitario" type="number" class="form-control table-price-input"></td>
                <td>{{ formatMoney(item.cantidad * item.precio_unitario) }}</td>
                <td><button class="btn btn-sm btn-danger" @click="form.items.splice(i,1)"><i class="fas fa-trash"></i></button></td>
              </tr>
            </tbody>
          </table>
          <div class="text-right"><strong>{{ i18n.t('total') }}: {{ formatMoney(totalForm) }}</strong></div>
          <div class="form-group mt-md"><label>{{ i18n.t('notas') }}</label><textarea v-model="form.notas" class="form-control" rows="2"></textarea></div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="!form.items.length || isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('creando_compra') }}</span><span v-else>{{ i18n.t('cotizaciones') }}</span></button></div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal-overlay" :class="{active:showDetalle}" @click.self="showDetalle=false">
      <div class="modal" style="max-width:min(90vw,700px);">
        <div class="modal-header" style="display:flex;justify-content:space-between;align-items:center;">
          <h3 class="modal-title">{{ detalle?.numero_cotizacion }}</h3>
          <div style="display:flex;gap:10px;align-items:center;">
            <button class="btn btn-sm btn-ghost" @click="abrirImprimir" :title="i18n.t('imprimir')"><i class="fas fa-print"></i> {{ i18n.t('imprimir') }}</button>
            <button class="modal-close" @click="showDetalle=false"><i class="fas fa-times"></i></button>
          </div>
        </div>
        <div class="modal-body" v-if="detalle">
          <div class="grid-2 mb-md">
            <div><strong>{{ i18n.t('cliente') }}:</strong> {{ detalle.cliente_nombre || 'N/A' }}</div>
            <div><strong>{{ i18n.t('estado') }}:</strong> <span :class="['badge',badgeEstado(detalle.estado)]">{{ detalle.estado }}</span></div>
            <div v-if="detalle.estado_aprobacion && detalle.estado_aprobacion !== 'pendiente'"><strong>{{ i18n.t('cotizaciones') }}:</strong> <span :class="['badge', detalle.estado_aprobacion==='aprobada'?'badge-success':'badge-danger']">{{ detalle.estado_aprobacion }}</span></div>
            <div v-if="detalle.motivo_rechazo"><strong>{{ i18n.t('motivo') }}:</strong> {{ detalle.motivo_rechazo }}</div>
          </div>
          <table class="data-table"><thead><tr><th>{{ i18n.t('producto') }}</th><th>{{ i18n.t('cant') }}</th><th>{{ i18n.t('precio') }}</th><th>{{ i18n.t('subtotal') }}</th></tr></thead>
            <tbody><tr v-for="item in detalle.items" :key="item.id"><td>{{ item.producto_nombre }}</td><td>{{ item.cantidad }}</td><td>{{ formatMoney(item.precio_unitario) }}</td><td>{{ formatMoney(item.subtotal) }}</td></tr></tbody>
          </table>
          <div class="mt-md text-right" style="font-size:18px;"><strong>{{ i18n.t('total') }}: {{ formatMoney(detalle.total) }}</strong></div>
          <div class="flex gap-sm mt-md" v-if="detalle.estado === 'pendiente'">
            <button class="btn btn-success" @click="aprobar(detalle.id); showDetalle=false;"><i class="fas fa-check"></i> {{ i18n.t('aprobar') }}</button>
            <button class="btn btn-danger" @click="showRechazo=true"><i class="fas fa-times"></i> {{ i18n.t('rechazar') }}</button>
          </div>
          <div v-if="detalle.estado === 'aprobada'" class="mt-md">
            <button class="btn btn-primary" @click="convertirFactura(detalle.id); showDetalle=false;"><i class="fas fa-file-invoice"></i> Convertir en Factura</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Rechazo -->
    <div class="modal-overlay" :class="{active:showRechazo}" @click.self="showRechazo=false">
      <div class="modal" style="max-width:min(90vw,400px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('rechazar') }} {{ i18n.t('cotizaciones') }}</h3><button class="modal-close" @click="showRechazo=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('motivo') }}</label><textarea v-model="motivoRechazo" class="form-control" rows="3" :placeholder="i18n.t('descripcion')"></textarea></div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showRechazo=false">{{ i18n.t('cancelar') }}</button>
          <button class="btn btn-danger" @click="confirmarRechazo"><i class="fas fa-times"></i> {{ i18n.t('confirmar') }}</button>
        </div>
      </div>
    </div>

    <!-- PRINT OVERLAY -->
    <teleport to="body">
      <div v-if="showPrint" class="cot-print-overlay" @click.self="showPrint=false">
        <div class="cot-print-actions">
          <button class="btn btn-primary" @click="window.print()"><i class="fas fa-print"></i> {{ i18n.t('imprimir') }}</button>
          <button class="btn btn-secondary" @click="showPrint=false"><i class="fas fa-times"></i> {{ i18n.t('cerrar') }}</button>
        </div>
        <div class="cot-print-sheet" :class="[config.tamano_papel, config.orientacion, config.estilo_layout]" :style="printStyles">
          <div v-if="config.mostrar_marca_agua" class="cot-print-watermark">{{ config.marca_agua_texto }}</div>

          <div class="cot-print-header" :style="{borderBottomColor: headerBorderColor}">
            <div class="cot-print-header-left">
              <div v-if="config.mostrar_logo && config.logo_path" class="cot-print-logo"><img :src="'/storage/'+config.logo_path" alt="Logo"></div>
              <div v-if="config.mostrar_nombre_negocio && empresa.nombre_negocio" class="cot-print-empresa">{{ empresa.nombre_negocio }}</div>
              <div v-if="config.mostrar_direccion && empresa.direccion" class="cot-print-meta">{{ empresa.direccion }}</div>
              <div v-if="config.mostrar_telefono && empresa.telefono" class="cot-print-meta">Tel: {{ empresa.telefono }}</div>
              <div v-if="config.mostrar_cedula && empresa.cedula_juridica" class="cot-print-meta">{{ i18n.t('cliente_cedula') }}: {{ empresa.cedula_juridica }}</div>
              <div v-if="config.header_text" class="cot-print-meta" style="margin-top:4px;font-style:italic;">{{ config.header_text }}</div>
            </div>
            <div class="cot-print-header-right">
              <div class="cot-print-doc-title">{{ i18n.t('cotizaciones') }}</div>
              <div v-if="config.mostrar_subtitulo" class="cot-print-doc-subtitle">{{ config.subtitulo_text }}</div>
              <div v-if="detalle?.numero_cotizacion" class="cot-print-doc-num">N° {{ detalle.numero_cotizacion }}</div>
              <div v-if="config.mostrar_fecha && detalle?.created_at" class="cot-print-doc-meta">{{ i18n.t('fecha') }}: {{ formatDate(detalle.created_at) }}</div>
              <div v-if="config.mostrar_fecha_vencimiento && detalle?.fecha_vencimiento" class="cot-print-doc-meta">Vence: {{ formatDate(detalle.fecha_vencimiento) }}</div>
            </div>
          </div>

          <div class="cot-print-info-row">
            <div v-if="config.mostrar_cliente" class="cot-print-info-box">
              <div class="cot-print-info-label">{{ i18n.t('cliente') }}</div>
              <div class="cot-print-info-value">{{ detalle?.cliente_nombre || 'N/A' }}</div>
            </div>
            <div v-if="config.mostrar_vendedor" class="cot-print-info-box">
              <div class="cot-print-info-label">{{ i18n.t('vendedor') }}</div>
              <div class="cot-print-info-value">{{ detalle?.usuario_nombre || 'N/A' }}</div>
            </div>
          </div>

          <table class="cot-print-table">
            <thead>
              <tr>
                <th style="width:40px;">#</th>
                <th>{{ i18n.t('descripcion') }}</th>
                <th style="width:70px;text-align:center;">{{ i18n.t('cant') }}</th>
                <th style="width:110px;text-align:right;">{{ i18n.t('precio') }}</th>
                <th style="width:130px;text-align:right;">{{ i18n.t('total') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, idx) in detalle?.items || []" :key="item.id">
                <td>{{ idx + 1 }}</td>
                <td>
                  <div v-if="config.mostrar_codigo_producto && item.codigo" class="cot-print-item-code">{{ item.codigo }}</div>
                  <div>{{ item.producto_nombre }}</div>
                </td>
                <td style="text-align:center;">{{ item.cantidad }}</td>
                <td style="text-align:right;">{{ formatMoney(item.precio_unitario) }}</td>
                <td style="text-align:right;font-weight:600;">{{ formatMoney(item.subtotal) }}</td>
              </tr>
            </tbody>
          </table>

          <div class="cot-print-totals">
            <div v-if="config.mostrar_totales_desglosados" class="cot-print-totals-inner">
              <div class="cot-print-total-row"><span>{{ i18n.t('subtotal') }}</span><span>{{ formatMoney(detalle?.subtotal) }}</span></div>
              <div v-if="config.mostrar_descuento && detalle?.descuento_total" class="cot-print-total-row"><span>{{ i18n.t('descuento') }}</span><span>-{{ formatMoney(detalle.descuento_total) }}</span></div>
              <div v-if="config.mostrar_detalle_impuesto && detalle?.impuesto_total" class="cot-print-total-row"><span>{{ i18n.t('impuesto') }}</span><span>{{ formatMoney(detalle.impuesto_total) }}</span></div>
            </div>
            <div class="cot-print-grand-total">
              <span>{{ i18n.t('total') }}</span>
              <span>{{ formatMoney(detalle?.total) }}</span>
            </div>
          </div>

          <div v-if="config.mostrar_condiciones && detalle?.condiciones" class="cot-print-terms">
            <strong>{{ i18n.t('cotizaciones') }}:</strong> {{ detalle.condiciones }}
          </div>
          <div v-if="config.mostrar_notas && detalle?.notas" class="cot-print-terms">
            <strong>{{ i18n.t('notas') }}:</strong> {{ detalle.notas }}
          </div>
          <div v-if="config.texto_terminos" class="cot-print-terms">
            <strong>Términos:</strong> {{ config.texto_terminos }}
          </div>
          <div v-if="config.mostrar_info_bancaria && config.info_bancaria" class="cot-print-terms">
            <strong>Datos Bancarios:</strong> {{ config.info_bancaria }}
          </div>
          <div v-if="config.mostrar_validez && detalle?.fecha_vencimiento" class="cot-print-validity">
            Esta cotización vence el {{ formatDate(detalle.fecha_vencimiento) }}.
          </div>

          <div v-if="config.mostrar_lineas_firma" class="cot-print-signatures">
            <div class="cot-print-sig">
              <div class="cot-print-sig-line"></div>
              <div class="cot-print-sig-label">{{ config.texto_firma_cliente }}</div>
            </div>
            <div class="cot-print-sig">
              <div class="cot-print-sig-line"></div>
              <div class="cot-print-sig-label">{{ config.texto_firma_empresa }}</div>
            </div>
          </div>

          <div v-if="config.footer_text" class="cot-print-footer">{{ config.footer_text }}</div>
          <div v-if="config.mostrar_numero_pagina" class="cot-print-page-num">Página 1 de 1</div>
        </div>
      </div>
    </teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const i18n = useI18nStore();
const { fm: formatMoney } = useCurrency();
import { useSubmitLock } from '../composables/useSubmitLock';

const toast = useToastStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('creando_compra') });

const items = ref([]); const filtro = ref(''); const estado = ref('');
const showNueva = ref(false); const showDetalle = ref(false); const detalle = ref(null);
const showRechazo = ref(false); const motivoRechazo = ref('');
const showPrint = ref(false);
const config = ref({
  fuente:'Arial', fuente_size:12, tamano_papel:'A4', orientacion:'portrait', estilo_layout:'moderno',
  color_fondo:'#ffffff', color_texto:'#1e293b', color_acento:'#01234e', color_encabezado:'#01234e', color_borde:'#01234e',
  mostrar_logo:true, mostrar_nombre_negocio:true, mostrar_direccion:true, mostrar_telefono:true, mostrar_cedula:false,
  mostrar_vendedor:true, mostrar_cliente:true, mostrar_fecha:true, mostrar_fecha_vencimiento:true,
  mostrar_detalle_impuesto:true, mostrar_descuento:true, mostrar_condiciones:true, mostrar_notas:true,
  mostrar_codigo_producto:false, mostrar_validez:true, mostrar_subtitulo:true, subtitulo_text:'Cotización Profesional',
  mostrar_lineas_firma:true, texto_firma_cliente:'Firma del Cliente', texto_firma_empresa:'Firma Autorizada',
  mostrar_marca_agua:false, marca_agua_texto:'COTIZACIÓN',
  mostrar_info_bancaria:false, info_bancaria:'',
  mostrar_totales_desglosados:true, mostrar_numero_pagina:false,
  header_text:'', footer_text:'¡Gracias por su preferencia!', condiciones_default:'', notas_default:'', texto_terminos:'',
  logo_path:null
});
const empresa = ref({ nombre_negocio:'', direccion:'', telefono:'', cedula_juridica:'', email_negocio:'' });
const form = ref({ cliente_id: null, cliente_nombre: '', fecha_vencimiento: '', items: [], notas: '' });
const buscarProd = ref(''); const prodResults = ref([]);
const buscarCliente = ref(''); const clienteResults = ref([]);
const totalForm = computed(() => form.value.items.reduce((s,i) => s + i.cantidad * i.precio_unitario, 0));

const printStyles = computed(() => ({
  backgroundColor: config.value.color_fondo,
  color: config.value.color_texto,
  fontFamily: config.value.fuente,
  fontSize: config.value.fuente_size + 'px',
  borderColor: config.value.color_borde,
}));

const headerBorderColor = computed(() => config.value.color_encabezado);

onMounted(() => { cargar(); cargarConfig(); cargarEmpresa(); });

async function cargar() {
  try { const { data } = await api.get('/cotizaciones', { params: { q: filtro.value, estado: estado.value } }); items.value = data.data || []; } catch(e) { console.error(e); }
}
async function buscarClientes() {
  if (buscarCliente.value.length < 2) { clienteResults.value = []; return; }
  try { const { data } = await api.get('/clientes/buscar', { params: { q: buscarCliente.value } }); clienteResults.value = data.clientes || []; } catch(e) {}
}
function seleccionarCliente(c) {
  form.value.cliente_id = c.id;
  form.value.cliente_nombre = c.nombre;
  form.value.cliente_cedula = c.cedula || '';
  form.value.cliente_telefono = c.telefono || '';
  form.value.cliente_email = c.email || '';
  buscarCliente.value = '';
  clienteResults.value = [];
}
function quitarClienteCot() {
  form.value.cliente_id = null;
  form.value.cliente_nombre = '';
  form.value.cliente_cedula = '';
  form.value.cliente_telefono = '';
  form.value.cliente_email = '';
  buscarCliente.value = '';
  clienteResults.value = [];
}

async function buscarProductos() {
  if (buscarProd.value.length < 2) { prodResults.value = []; return; }
  try { const { data } = await api.get('/productos/buscar', { params: { q: buscarProd.value } }); prodResults.value = data.productos || []; } catch(e) {}
}
function agregarItem(p) {
  form.value.items.push({ producto_id: p.id, nombre: p.nombre, cantidad: 1, precio_unitario: p.precio_venta, descuento: 0 });
  buscarProd.value = ''; prodResults.value = [];
}
async function guardar() {
  try {
    await execute(async () => {
      await api.post('/cotizaciones', form.value);
      showNueva.value = false;
      form.value = { cliente_id: null, cliente_nombre: '', fecha_vencimiento: '', items: [], notas: '' };
      cargar();
    });
  } catch(e) {
    if (e.response?.status === 429) {
      toast.warning(i18n.t('solicitud_procesando'));
    } else {
      toast.error(e.response?.data?.error||i18n.t('error'));
    }
  }
}
async function verDetalle(id) {
  try { const { data } = await api.get(`/cotizaciones/${id}`); detalle.value = data.cotizacion; showDetalle.value = true; } catch(e) {}
}
async function aprobar(id) {
  try {
    await api.post(`/cotizaciones/${id}/aprobar`);
    toast.success(i18n.t('cotizaciones_filtro_aprobada'));
    cargar();
  } catch(e) { toast.error(e.response?.data?.error || i18n.t('error')); }
}

function rechazar(id) {
  detalle.value = detalle.value || items.value.find(c => c.id === id);
  motivoRechazo.value = '';
  showRechazo.value = true;
}

async function confirmarRechazo() {
  if (!motivoRechazo.value.trim()) { toast.error(i18n.t('campo_requerido')); return; }
  const id = detalle.value?.id;
  if (!id) return;
  try {
    await api.post(`/cotizaciones/${id}/rechazar`, { motivo: motivoRechazo.value });
    toast.success(i18n.t('cotizaciones_filtro_rechazada'));
    showRechazo.value = false;
    showDetalle.value = false;
    cargar();
  } catch(e) { toast.error(e.response?.data?.error || i18n.t('error')); }
}

async function cargarConfig() {
  try {
    const { data } = await api.get('/cotizacion-designer');
    if (data.config) {
      Object.keys(config.value).forEach(k => {
        if (data.config[k] !== undefined && data.config[k] !== null) config.value[k] = data.config[k];
      });
    }
  } catch (e) { console.error(e); }
}
async function cargarEmpresa() {
  try {
    const { data } = await api.get('/configuracion/empresa');
    if (data.empresa) empresa.value = data.empresa;
  } catch (e) { console.error(e); }
}
function abrirImprimir() {
  showPrint.value = true;
  setTimeout(() => { window.print(); }, 300);
}

async function convertirFactura(id) {
  try {
    const { data } = await api.post(`/cotizaciones/${id}/convertir-factura`);
    toast.success('Factura creada exitosamente: ' + (data.numero_factura || ''));
    cargar();
  } catch(e) { toast.error(e.response?.data?.error || i18n.t('error')); }
}

function badgeEstado(e) { return { pendiente:'badge-warning', aprobada:'badge-success', rechazada:'badge-danger' }[e] || 'badge-secondary'; }
function formatDate(d) { if(!d) return ''; return new Date(d).toLocaleDateString('es-CR',{day:'2-digit',month:'short',year:'numeric'}); }
</script>

<style scoped>
/* Print overlay */
.cot-print-overlay {
  position: fixed; inset: 0; z-index: 2000;
  background: rgba(0,0,0,0.45); backdrop-filter: blur(10px);
  display: flex; flex-direction: column; align-items: center;
  padding: 20px; overflow-y: auto;
}
.cot-print-actions {
  position: sticky; top: 0; z-index: 10;
  display: flex; gap: 10px; margin-bottom: 14px;
  background: var(--bg-card); padding: 10px 16px; border-radius: 12px;
  box-shadow: var(--shadow-md);
}

/* Paper sheet */
.cot-print-sheet {
  position: relative;
  width: 210mm; min-height: 297mm;
  padding: 20mm;
  background: #fff;
  box-shadow: 0 4px 20px rgba(0,0,0,0.12);
  margin-bottom: 20px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
}
.cot-print-sheet.Letter { width: 216mm; min-height: 279mm; }
.cot-print-sheet.Legal { width: 216mm; min-height: 356mm; }
.cot-print-sheet.A5 { width: 148mm; min-height: 210mm; }
.cot-print-sheet.landscape { width: 297mm; min-height: 210mm; }
.cot-print-sheet.landscape.Letter { width: 279mm; min-height: 216mm; }
.cot-print-sheet.landscape.Legal { width: 356mm; min-height: 216mm; }
.cot-print-sheet.landscape.A5 { width: 210mm; min-height: 148mm; }

/* Watermark */
.cot-print-watermark {
  position: absolute; top: 50%; left: 50%;
  transform: translate(-50%, -50%) rotate(-30deg);
  font-size: 72px; font-weight: 900;
  color: rgba(0,0,0,0.06); pointer-events: none;
  text-transform: uppercase; letter-spacing: 6px; white-space: nowrap; z-index: 0;
}

/* Header */
.cot-print-header {
  display: flex; justify-content: space-between; align-items: flex-start;
  border-bottom: 3px solid #01234e; padding-bottom: 16px; margin-bottom: 20px;
  position: relative; z-index: 1;
}
.cot-print-header-left { flex: 1; }
.cot-print-header-right { text-align: right; }
.cot-print-logo img { max-height: 60px; max-width: 140px; }
.cot-print-empresa { font-size: 22px; font-weight: 800; margin-bottom: 4px; }
.cot-print-meta { font-size: 12px; color: #64748b; line-height: 1.5; }
.cot-print-doc-title { font-size: 28px; font-weight: 900; letter-spacing: 2px; color: #01234e; }
.cot-print-doc-subtitle { font-size: 13px; color: #64748b; margin-top: 2px; }
.cot-print-doc-num { font-size: 13px; font-weight: 700; margin-top: 6px; background: #f1f5f9; padding: 4px 10px; border-radius: 6px; display: inline-block; }
.cot-print-doc-meta { font-size: 12px; color: #64748b; margin-top: 4px; }

/* Info Row */
.cot-print-info-row { display: flex; gap: 16px; margin-bottom: 20px; position: relative; z-index: 1; }
.cot-print-info-box { flex: 1; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; background: #f8fafc; }
.cot-print-info-label { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #94a3b8; margin-bottom: 4px; }
.cot-print-info-value { font-size: 14px; font-weight: 700; color: #1e293b; }

/* Table */
.cot-print-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; position: relative; z-index: 1; }
.cot-print-table thead th { background: #01234e; color: #fff; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; padding: 10px 8px; text-align: left; }
.cot-print-table tbody td { padding: 10px 8px; border-bottom: 1px solid #e2e8f0; font-size: 13px; vertical-align: top; }
.cot-print-table tbody tr:last-child td { border-bottom: 2px solid #01234e; }
.cot-print-item-code { font-size: 10px; color: #94a3b8; font-weight: 600; margin-bottom: 2px; }

/* Totals */
.cot-print-totals { display: flex; flex-direction: column; align-items: flex-end; margin-bottom: 20px; position: relative; z-index: 1; }
.cot-print-totals-inner { width: 260px; }
.cot-print-total-row { display: flex; justify-content: space-between; font-size: 13px; padding: 6px 0; border-bottom: 1px dashed #e2e8f0; color: #475569; }
.cot-print-grand-total { display: flex; justify-content: space-between; width: 260px; background: #f1f5f9; padding: 12px 14px; border-radius: 8px; margin-top: 8px; font-size: 15px; font-weight: 800; color: #01234e; }

/* Terms */
.cot-print-terms { font-size: 12px; color: #475569; margin-bottom: 10px; line-height: 1.6; position: relative; z-index: 1; }
.cot-print-validity { font-size: 12px; font-style: italic; color: #64748b; margin-bottom: 16px; position: relative; z-index: 1; }

/* Signatures */
.cot-print-signatures { display: flex; gap: 40px; margin-top: 30px; margin-bottom: 20px; position: relative; z-index: 1; }
.cot-print-sig { flex: 1; text-align: center; }
.cot-print-sig-line { border-bottom: 1.5px solid #1e293b; height: 40px; margin-bottom: 8px; }
.cot-print-sig-label { font-size: 12px; font-weight: 600; color: #475569; }

/* Footer */
.cot-print-footer { text-align: center; font-size: 12px; color: #94a3b8; margin-top: 10px; position: relative; z-index: 1; }
.cot-print-page-num { text-align: center; font-size: 11px; color: #94a3b8; margin-top: 6px; position: relative; z-index: 1; }

/* Layout variations */
.moderno .cot-print-table thead th { background: v-bind('config.color_encabezado'); }
.moderno .cot-print-doc-title { color: v-bind('config.color_acento'); }
.moderno .cot-print-grand-total { color: v-bind('config.color_acento'); }

.clasico .cot-print-table thead th { background: #fff; color: v-bind('config.color_texto'); border-bottom: 2px solid v-bind('config.color_borde'); }
.clasico .cot-print-header { border-bottom: 2px solid v-bind('config.color_borde'); }

.minimal .cot-print-table thead th { background: transparent; color: v-bind('config.color_texto'); border-bottom: 2px solid v-bind('config.color_borde'); text-transform: none; letter-spacing: 0; font-weight: 600; }
.minimal .cot-print-header { border-bottom: 1px solid v-bind('config.color_borde'); }
.minimal .cot-print-info-box { background: transparent; border: none; padding: 0; }
.minimal .cot-print-grand-total { background: transparent; border-top: 2px solid v-bind('config.color_borde'); border-radius: 0; }

/* Print media */
@media print {
  .cot-print-overlay { background: #fff; padding: 0; overflow: visible; }
  .cot-print-actions { display: none !important; }
  .cot-print-sheet { box-shadow: none; border: none; margin: 0; width: 100% !important; min-height: auto; }
}

.filter-input { width: 100%; max-width: 250px; min-width: 0; }
.filter-select { width: 100%; max-width: 150px; min-width: 0; }
.table-num-input { width: 100%; max-width: 70px; min-width: 0; }
.table-price-input { width: 100%; max-width: 100px; min-width: 0; }

.btn, .filter-input, .filter-select, .form-control, .modal, .data-table {
  -webkit-tap-highlight-color: transparent;
}

@media (max-width: 1023px) {
  .filter-input { max-width: 200px; }
  .cot-print-sheet { width: 100% !important; min-height: auto; padding: 10mm; }
}

@media (max-width: 768px) {
  .flex.items-center.justify-between.mb-lg {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }
  .flex.gap-sm {
    flex-direction: column;
    gap: 8px;
  }
  .filter-input,
  .filter-select {
    max-width: 100%;
    width: 100%;
  }
  .btn {
    min-height: 44px;
    width: 100%;
    justify-content: center;
  }
  .btn-primary {
    min-height: 48px;
    font-size: 15px;
  }
  .table-num-input,
  .table-price-input {
    max-width: 100%;
    min-height: 40px;
    font-size: 16px;
  }
  .cot-print-sheet { padding: 5mm; }
  .cot-print-header { flex-direction: column; gap: 12px; }
  .cot-print-header-right { text-align: left; }
  .cot-print-info-row { flex-direction: column; }
  .cot-print-signatures { flex-direction: column; gap: 20px; }
  .cot-print-grand-total,
  .cot-print-totals-inner { width: 100%; }
}

@media (max-width: 480px) {
  .card-body { padding: 8px !important; }
  .data-table {
    display: block;
    width: 100%;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  .data-table thead {
    display: none;
  }
  .data-table tbody tr {
    display: flex;
    flex-direction: column;
    background: var(--bg-card);
    border: 1px solid var(--bg-hover);
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    box-shadow: var(--shadow-sm);
  }
  .data-table tbody td {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 0;
    border-bottom: 1px solid var(--bg-hover);
    font-size: 13px;
  }
  .data-table tbody td:last-child {
    border-bottom: none;
    justify-content: flex-end;
    gap: 6px;
    padding-top: 8px;
  }
  .data-table tbody td::before {
    content: attr(data-label);
    font-weight: 700;
    color: var(--text-muted);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  .data-table tbody td:last-child::before {
    display: none;
  }
  .btn {
    min-height: 44px;
    width: 100%;
    font-size: 14px;
    padding: 10px 16px;
  }
  .modal {
    max-width: 95vw !important;
    margin: 8px;
    max-height: 95vh;
    overflow-y: auto;
  }
  .modal-body { padding: 12px; }
  .modal-footer {
    flex-direction: column;
    gap: 8px;
  }
  .modal-footer .btn { width: 100%; }
  .grid-2 {
    grid-template-columns: 1fr;
  }
  .flex.gap-sm.mt-md {
    flex-direction: column;
    gap: 8px;
  }
  .flex.gap-sm.mt-md .btn { width: 100%; }
  .cot-print-sheet { padding: 3mm; font-size: 11px; }
  .cot-print-doc-title { font-size: 22px; }
  .cot-print-empresa { font-size: 18px; }
  .cot-print-table { font-size: 11px; }
  .cot-print-table thead th { font-size: 10px; padding: 8px 4px; }
  .cot-print-table tbody td { padding: 6px 4px; font-size: 11px; }
}
</style>
