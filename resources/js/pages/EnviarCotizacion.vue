<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h2 class="text-2xl font-bold" style="color:var(--text-primary);"><i class="fas fa-paper-plane" style="color:var(--primary);"></i> {{ i18n.t('enviar_cotizacion_titulo') }}</h2>
    </div>

    <div class="grid-2 gap-lg">
      <!-- Left: Cotización y Destinatarios -->
      <div class="flex flex-col gap-md">
        <!-- Step 1: Seleccionar Cotización -->
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-file-alt"></i> 1. {{ i18n.t('enviar_cotizacion_seleccionar') }}</h3></div>
          <div class="card-body">
            <div class="form-group" style="position:relative;">
              <label>{{ i18n.t('enviar_cotizacion_buscar') }}</label>
              <input v-model="buscarCotizacion" class="form-control" :placeholder="i18n.t('enviar_cotizacion_numero_cliente')" @input="filtrarCotizaciones">
              <div v-if="cotizacionesFiltradas.length" style="position:absolute;left:0;right:0;top:100%;z-index:20;max-height:180px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;background:var(--bg-card);margin-top:2px;box-shadow:var(--shadow-md);">
                <div v-for="c in cotizacionesFiltradas" :key="c.id" class="p-sm flex items-center justify-between" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);font-size:13px;" @click="seleccionarCotizacion(c)">
                  <div><strong>{{ c.numero_cotizacion }}</strong> · {{ c.cliente_nombre || i18n.t('enviar_cotizacion_sin_cliente') }} · {{ formatMoney(c.total) }}</div>
                  <span :class="['badge', badgeEstado(c.estado)]" style="font-size:10px;">{{ c.estado }}</span>
                </div>
              </div>
            </div>

            <div v-if="cotizacionSel" class="mt-md p-md" style="background:var(--bg-hover);border-radius:var(--radius-lg);">
              <div class="flex items-center justify-between mb-sm">
                <strong style="font-size:15px;">{{ cotizacionSel.numero_cotizacion }}</strong>
                <button class="btn btn-xs btn-ghost" @click="cotizacionSel=null; detalleCot=null;"><i class="fas fa-times"></i></button>
              </div>
              <div style="font-size:13px;color:var(--text-muted);">
                <div>{{ i18n.t('cliente') }}: {{ cotizacionSel.cliente_nombre || i18n.t('enviar_cotizacion_sin_cliente') }}</div>
                <div>{{ i18n.t('total') }}: {{ formatMoney(cotizacionSel.total) }} · {{ i18n.t('estado') }}: <span :class="['badge', badgeEstado(cotizacionSel.estado)]">{{ cotizacionSel.estado }}</span></div>
                <div>{{ i18n.t('fecha') }}: {{ formatDate(cotizacionSel.created_at) }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Step 2: Destinatarios -->
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-users"></i> 2. {{ i18n.t('enviar_cotizacion_seleccionar_destinatarios') }}</h3></div>
          <div class="card-body">
            <!-- Clientes registrados -->
            <div class="form-group" style="position:relative;">
              <label>{{ i18n.t('clientes') }}</label>
              <input v-model="buscarCliente" class="form-control" :placeholder="i18n.t('enviar_cotizacion_buscar_contacto')" @input="filtrarClientes">
              <div v-if="clientesFiltrados.length" style="position:absolute;left:0;right:0;top:100%;z-index:20;max-height:150px;overflow:auto;border:1px solid var(--bg-hover);border-radius:8px;background:var(--bg-card);margin-top:2px;box-shadow:var(--shadow-md);">
                <div v-for="c in clientesFiltrados" :key="c.id" class="p-sm flex items-center justify-between" style="cursor:pointer;border-bottom:1px solid var(--bg-hover);font-size:13px;" @click="agregarCliente(c)">
                  <div><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ c.nombre }} <span style="color:var(--text-muted);">{{ c.email }}</span></div>
                </div>
              </div>
            </div>

            <div v-if="destinatariosClientes.length" class="mt-sm mb-md">
              <div v-for="c in destinatariosClientes" :key="c.id" class="flex items-center gap-sm mb-xs" style="background:rgba(16,185,129,0.08);padding:6px 10px;border-radius:var(--radius-full);font-size:13px;">
                <i class="fas fa-user" style="color:var(--success);font-size:11px;"></i>
                <span style="flex:1;"><strong>{{ c.nombre }}</strong> <span style="color:var(--text-muted);">{{ c.email }}</span></span>
                <button class="btn btn-xs btn-ghost" style="padding:2px 6px;" @click="quitarCliente(c.id)"><i class="fas fa-times" style="color:var(--danger);"></i></button>
              </div>
            </div>

            <!-- Emails libres -->
            <div class="form-group">
              <label>{{ i18n.t('enviar_cotizacion_agregar_destinatarios') }}</label>
              <div class="flex gap-sm">
                <input v-model="nuevoEmail" type="email" class="form-control" placeholder="correo@ejemplo.com" @keydown.enter.prevent="agregarEmail">
                <button class="btn btn-primary" @click="agregarEmail"><i class="fas fa-plus"></i></button>
              </div>
            </div>

            <div v-if="destinatariosEmails.length" class="mt-sm">
              <div v-for="(email, i) in destinatariosEmails" :key="i" class="flex items-center gap-sm mb-xs" style="background:rgba(42,157,244,0.08);padding:6px 10px;border-radius:var(--radius-full);font-size:13px;">
                <i class="fas fa-envelope" style="color:var(--primary);font-size:11px;"></i>
                <span style="flex:1;">{{ email }}</span>
                <button class="btn btn-xs btn-ghost" style="padding:2px 6px;" @click="quitarEmail(i)"><i class="fas fa-times" style="color:var(--danger);"></i></button>
              </div>
            </div>

            <div v-if="!destinatariosClientes.length && !destinatariosEmails.length" class="mt-sm" style="font-size:13px;color:var(--text-muted);text-align:center;padding:12px;">
              {{ i18n.t('enviar_cotizacion_seleccionar_destinatarios') }}
            </div>
          </div>
        </div>

        <!-- Step 3: Nota y Enviar -->
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-pen"></i> 3. {{ i18n.t('enviar_cotizacion_mensaje_correo') }}</h3></div>
          <div class="card-body">
            <div class="form-group">
              <textarea v-model="nota" class="form-control" rows="3" :placeholder="i18n.t('enviar_cotizacion_escribir_mensaje')"></textarea>
            </div>
            <div class="flex gap-sm mt-md">
              <button class="btn btn-primary" :disabled="!puedeEnviar || enviando" @click="enviar">
                <i v-if="enviando" class="fas fa-spinner fa-spin"></i>
                <i v-else class="fas fa-paper-plane"></i>
                {{ enviando ? i18n.t('procesando') : i18n.t('enviar_cotizacion_enviar_correo') }}
              </button>
              <button class="btn btn-ghost" @click="limpiar"><i class="fas fa-eraser"></i> {{ i18n.t('limpiar') }}</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Vista previa -->
      <div class="card" style="height:fit-content;">
        <div class="card-header flex justify-between">
          <h3 class="card-title"><i class="fas fa-eye"></i> {{ i18n.t('enviar_cotizacion_vista_previa') }}</h3>
          <span v-if="cotizacionSel" class="badge badge-info">{{ cotizacionSel.numero_cotizacion }}</span>
        </div>
        <div class="card-body" style="padding:0;background:var(--bg-hover);">
          <div v-if="!cotizacionSel" class="p-lg text-center" style="color:var(--text-muted);font-size:13px;">
            <i class="fas fa-file-alt" style="font-size:32px;display:block;margin-bottom:12px;opacity:0.4;"></i>
            {{ i18n.t('enviar_cotizacion_seleccionar') }}
          </div>
          <div v-else-if="previewHtml" v-html="previewHtml" style="max-height:600px;overflow:auto;background:#fff;border-radius:0;"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();

const buscarCotizacion = ref('');
const cotizaciones = ref([]);
const cotizacionesFiltradas = ref([]);
const cotizacionSel = ref(null);
const detalleCot = ref(null);

const buscarCliente = ref('');
const clientes = ref([]);
const clientesFiltrados = ref([]);
const destinatariosClientes = ref([]);

const nuevoEmail = ref('');
const destinatariosEmails = ref([]);

const nota = ref('');
const enviando = ref(false);
const previewHtml = ref('');

const puedeEnviar = computed(() => {
  return cotizacionSel.value && (destinatariosClientes.value.length > 0 || destinatariosEmails.value.length > 0);
});

// Cargar cotizaciones
async function cargarCotizaciones() {
  try {
    const { data } = await api.get('/cotizaciones', { params: { per_page: 100 } });
    cotizaciones.value = data.data || [];
  } catch (e) { console.error(e); }
}

function filtrarCotizaciones() {
  const q = buscarCotizacion.value.toLowerCase();
  if (!q) { cotizacionesFiltradas.value = []; return; }
  cotizacionesFiltradas.value = cotizaciones.value.filter(c =>
    (c.numero_cotizacion && c.numero_cotizacion.toLowerCase().includes(q)) ||
    (c.cliente_nombre && c.cliente_nombre.toLowerCase().includes(q))
  ).slice(0, 8);
}

async function seleccionarCotizacion(c) {
  cotizacionSel.value = c;
  buscarCotizacion.value = '';
  cotizacionesFiltradas.value = [];
  try {
    const { data } = await api.get(`/cotizaciones/${c.id}`);
    detalleCot.value = data.cotizacion;
    generarPreview();
  } catch (e) { console.error(e); }
}

// Clientes
async function cargarClientes() {
  try {
    const { data } = await api.get('/clientes', { params: { per_page: 500 } });
    clientes.value = (data.data || []).filter(c => c.email);
  } catch (e) { console.error(e); }
}

function filtrarClientes() {
  const q = buscarCliente.value.toLowerCase();
  if (!q) { clientesFiltrados.value = []; return; }
  const yaSeleccionados = destinatariosClientes.value.map(d => d.id);
  clientesFiltrados.value = clientes.value.filter(c =>
    !yaSeleccionados.includes(c.id) &&
    (c.nombre.toLowerCase().includes(q) || (c.email && c.email.toLowerCase().includes(q)))
  ).slice(0, 8);
}

function agregarCliente(c) {
  if (!destinatariosClientes.value.find(d => d.id === c.id)) {
    destinatariosClientes.value.push({ id: c.id, nombre: c.nombre, email: c.email });
  }
  buscarCliente.value = '';
  clientesFiltrados.value = [];
}

function quitarCliente(id) {
  destinatariosClientes.value = destinatariosClientes.value.filter(c => c.id !== id);
}

// Emails libres
function agregarEmail() {
  const email = nuevoEmail.value.trim().toLowerCase();
  if (!email) return;
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    toast.error(i18n.t('enviar_cotizacion_correo_electronico') + ' inválido');
    return;
  }
  if (destinatariosEmails.value.includes(email)) {
    toast.warning(i18n.t('enviar_cotizacion_correo_electronico') + ' ya está agregado');
    return;
  }
  destinatariosEmails.value.push(email);
  nuevoEmail.value = '';
}

function quitarEmail(i) {
  destinatariosEmails.value.splice(i, 1);
}

// Preview
function generarPreview() {
  if (!detalleCot.value) return;
  const c = detalleCot.value;

  const estadoColor = { aprobada: '#047857', rechazada: '#dc2626', facturada: '#2563eb' }[c.estado] || '#d97706';
  const estadoBg = { aprobada: '#ecfdf5', rechazada: '#fef2f2', facturada: '#eff6ff' }[c.estado] || '#fffbeb';

  const notaHtml = nota.value ? `<div style="margin-top:24px;padding:16px;background:#f0f9ff;border-left:4px solid #0284c7;border-radius:8px;"><strong style="color:#0369a1;font-size:14px;">Nota adicional</strong><p style="margin:8px 0 0 0;font-size:14px;color:#334155;line-height:1.5;">${nota.value.replace(/\n/g, '<br>')}</p></div>` : '';

  let rows = '';
  (c.items || []).forEach(item => {
    rows += `<tr>
      <td style="padding:14px 10px;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;">${item.codigo ? '<span style="display:block;font-size:11px;color:#64748b;font-weight:600;margin-bottom:2px;">' + item.codigo + '</span>' : ''}<strong>${item.producto_nombre}</strong></td>
      <td style="padding:14px 10px;text-align:center;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;font-weight:600;">${item.cantidad}</td>
      <td style="padding:14px 10px;text-align:right;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;">${formatMoney(item.precio_unitario)}</td>
      <td style="padding:14px 10px;text-align:right;font-size:14px;color:#1e293b;border-bottom:1px solid #e2e8f0;vertical-align:middle;font-weight:700;">${formatMoney(item.subtotal)}</td>
    </tr>`;
  });

  previewHtml.value = `<div style="padding:20px;background:#0f172a;font-family:system-ui,-apple-system,sans-serif;">
    <div style="max-width:680px;margin:0 auto;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 25px 50px -12px rgba(0,0,0,0.4);border:1px solid #1e293b;">

      <div style="background:linear-gradient(135deg,#0e3b58 0%,#006bb3 50%,#0ea5e9 100%);padding:32px 36px;color:#fff;position:relative;">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px;">
          <div>
            <div style="font-size:24px;font-weight:800;letter-spacing:-0.5px;">Empresa</div>
            <div style="font-size:13px;opacity:0.9;margin-top:6px;line-height:1.5;"><span>Dirección</span><br/><span>Tel: Teléfono</span></div>
          </div>
          <div style="text-align:right;background:rgba(255,255,255,0.12);padding:12px 20px;border-radius:12px;">
            <div style="font-size:11px;opacity:0.85;text-transform:uppercase;letter-spacing:1px;">${i18n.t('cotizacion_designer_cotizacion')}</div>
            <div style="font-size:20px;font-weight:800;letter-spacing:0.5px;margin-top:2px;">${c.numero_cotizacion}</div>
          </div>
        </div>
      </div>

      <div style="padding:28px 36px;background:#f8fafc;border-bottom:1px solid #e2e8f0;">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px;">
          <div>
            <div style="font-size:11px;color:#64748b;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;margin-bottom:4px;">${i18n.t('cliente')}</div>
            <div style="font-size:16px;font-weight:700;color:#0f172a;">${c.cliente_nombre || 'Cliente general'}</div>
          </div>
          <div style="text-align:right;">
            <div style="font-size:13px;color:#475569;margin-bottom:4px;"><strong style="color:#0f172a;">${i18n.t('fecha')}:</strong> ${formatDate(c.created_at)}</div>
            <div style="font-size:13px;color:#475569;margin-bottom:6px;"><strong style="color:#0f172a;">Vence:</strong> ${c.fecha_vencimiento ? formatDate(c.fecha_vencimiento) : 'N/A'}</div>
            <span style="display:inline-block;padding:5px 14px;border-radius:9999px;background:${estadoBg};color:${estadoColor};font-weight:700;font-size:12px;letter-spacing:0.3px;text-transform:uppercase;">${c.estado}</span>
          </div>
        </div>
      </div>

      <div style="padding:0 36px 28px;">
        <table style="width:100%;border-collapse:separate;border-spacing:0;font-size:14px;margin-top:24px;">
          <thead>
            <tr style="background:#0f172a;">
              <th style="padding:14px 10px;text-align:left;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;border-radius:8px 0 0 0;">${i18n.t('cotizacion_designer_descripcion')}</th>
              <th style="padding:14px 10px;text-align:center;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;">${i18n.t('cotizacion_designer_cantidad')}</th>
              <th style="padding:14px 10px;text-align:right;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;">${i18n.t('cotizacion_designer_precio_unitario')}</th>
              <th style="padding:14px 10px;text-align:right;font-size:12px;color:#ffffff;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;border-radius:0 8px 0 0;">${i18n.t('cotizacion_designer_subtotal')}</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>

        <div style="margin-top:8px;padding:24px;background:#f8fafc;border-radius:12px;border:1px solid #e2e8f0;">
          <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px;">
            <div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>${i18n.t('cotizacion_designer_subtotal_label')}</span><span style="font-weight:600;color:#0f172a;">${formatMoney(c.subtotal)}</span></div>
            ${c.descuento_total > 0 ? `<div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>${i18n.t('cotizacion_designer_descuento_label')}</span><span style="font-weight:600;color:#dc2626;">-${formatMoney(c.descuento_total)}</span></div>` : ''}
            ${c.impuesto_total > 0 ? `<div style="display:flex;justify-content:space-between;width:240px;font-size:14px;color:#475569;"><span>${i18n.t('cotizacion_designer_impuesto_label')}</span><span style="font-weight:600;color:#0f172a;">${formatMoney(c.impuesto_total)}</span></div>` : ''}
            <div style="display:flex;justify-content:space-between;width:260px;margin-top:10px;padding-top:12px;border-top:2px solid #0f172a;">
              <span style="font-size:16px;font-weight:800;color:#0f172a;">${i18n.t('cotizacion_designer_total_label')}</span>
              <span style="font-size:20px;font-weight:800;color:#006bb3;">${formatMoney(c.total)}</span>
            </div>
          </div>
        </div>

        ${notaHtml}
      </div>

      <div style="background:#0f172a;padding:24px 36px;text-align:center;color:#94a3b8;font-size:13px;line-height:1.6;">
        <div style="font-weight:600;color:#e2e8f0;margin-bottom:4px;">Este documento es una cotización y no constituye una factura</div>
        <div>Para aprobar o realizar consultas, responda este correo.</div>
      </div>

    </div>
  </div>`;
}

watch(nota, generarPreview);

// Enviar
async function enviar() {
  if (!puedeEnviar.value) return;
  enviando.value = true;
  try {
    const { data } = await api.post('/cotizaciones/enviar', {
      cotizacion_id: cotizacionSel.value.id,
      cliente_ids: destinatariosClientes.value.map(c => c.id),
      emails: destinatariosEmails.value,
      nota: nota.value || null,
    });
    if (data.success) {
      toast.success(`${i18n.t('enviado')} ${data.enviados} de ${data.total} destinatarios`);
      if (data.errores?.length) {
        data.errores.forEach(err => toast.error(err));
      }
      limpiar();
    } else {
      toast.error(data.error || i18n.t('error'));
    }
  } catch (e) {
    toast.error(e.response?.data?.error || i18n.t('error'));
  } finally {
    enviando.value = false;
  }
}

function limpiar() {
  cotizacionSel.value = null;
  detalleCot.value = null;
  buscarCotizacion.value = '';
  cotizacionesFiltradas.value = [];
  destinatariosClientes.value = [];
  destinatariosEmails.value = [];
  buscarCliente.value = '';
  nuevoEmail.value = '';
  nota.value = '';
  previewHtml.value = '';
}

function badgeEstado(e) {
  return { pendiente: 'badge-warning', aprobada: 'badge-success', rechazada: 'badge-danger' }[e] || 'badge-secondary';
}
function formatDate(d) { if (!d) return ''; return new Date(d).toLocaleDateString('es-CR', { day: '2-digit', month: 'short', year: 'numeric' }); }

// Init
cargarCotizaciones();
cargarClientes();
</script>

<style scoped>
.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

@media (max-width: 1023px) {
  .grid-2 { grid-template-columns: 1fr; }
}

@media (max-width: 768px) {
  .grid-2 { grid-template-columns: 1fr; }
}

@media (max-width: 480px) {
  .btn { min-height: 44px; }
}
</style>
