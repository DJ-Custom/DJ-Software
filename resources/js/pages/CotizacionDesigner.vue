<template>
  <div>
    <div class="grid-2 gap-lg">
      <!-- CONFIG PANEL -->
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-cog"></i> {{ i18n.t('cotizacion_designer_configuracion') }}</h3></div>
        <div class="card-body" style="max-height:85vh;overflow:auto;">
          <!-- Papel & Layout -->
          <h4 style="margin-bottom:10px;font-size:13px;font-weight:700;"><i class="fas fa-file-alt"></i> {{ i18n.t('cotizacion_designer_papel_diseno') }}</h4>
          <div class="grid-3 gap-sm">
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_tamano_papel') }}</label>
              <select v-model="config.tamano_papel" class="form-control">
                <option>A4</option><option>Letter</option><option>Legal</option><option>A5</option>
              </select>
            </div>
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_orientacion') }}</label>
              <select v-model="config.orientacion" class="form-control">
                <option value="portrait">{{ i18n.t('cotizacion_designer_vertical') }}</option><option value="landscape">{{ i18n.t('cotizacion_designer_horizontal') }}</option>
              </select>
            </div>
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_estilo_layout') }}</label>
              <select v-model="config.estilo_layout" class="form-control">
                <option value="moderno">{{ i18n.t('cotizacion_designer_moderno') }}</option><option value="clasico">{{ i18n.t('cotizacion_designer_clasico') }}</option><option value="minimal">{{ i18n.t('cotizacion_designer_minimal') }}</option>
              </select>
            </div>
          </div>

          <!-- Colores -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-palette"></i> {{ i18n.t('cotizacion_designer_colores') }}</h4>
          <div class="grid-3 gap-sm">
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_fondo') }}</label><input type="color" v-model="config.color_fondo" class="form-control" style="height:38px;padding:2px;"></div>
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_texto') }}</label><input type="color" v-model="config.color_texto" class="form-control" style="height:38px;padding:2px;"></div>
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_acento') }}</label><input type="color" v-model="config.color_acento" class="form-control" style="height:38px;padding:2px;"></div>
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_encabezado') }}</label><input type="color" v-model="config.color_encabezado" class="form-control" style="height:38px;padding:2px;"></div>
            <div class="form-group"><label>Borde</label><input type="color" v-model="config.color_borde" class="form-control" style="height:38px;padding:2px;"></div>
          </div>

          <!-- Tipografía -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-font"></i> {{ i18n.t('cotizacion_designer_tipografia') }}</h4>
          <div class="grid-3 gap-sm">
            <div class="form-group"><label>{{ i18n.t('cotizacion_designer_fuente_cuerpo') }}</label>
              <select v-model="config.fuente" class="form-control">
                <option>Arial</option><option>Helvetica</option><option>Georgia</option><option>Verdana</option><option>Courier New</option><option>Tahoma</option><option>Segoe UI</option>
              </select>
            </div>
            <div class="form-group"><label>Tamaño Fuente (px)</label><input v-model.number="config.fuente_size" type="number" min="8" max="24" class="form-control"></div>
          </div>

          <!-- Elementos visibles -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-eye"></i> {{ i18n.t('ticket_designer_elementos_visibles') }}</h4>
          <div class="grid-2 gap-xs" style="font-size:13px;">
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_logo"> {{ i18n.t('cotizacion_designer_logo') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_nombre_negocio"> {{ i18n.t('cotizacion_designer_nombre_empresa') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_direccion"> {{ i18n.t('cotizacion_designer_direccion_empresa') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_telefono"> {{ i18n.t('cotizacion_designer_telefono_empresa') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_cedula"> {{ i18n.t('cotizacion_designer_cedula_juridica') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_vendedor"> {{ i18n.t('ticket_designer_vendedor') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_cliente"> {{ i18n.t('cliente') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_fecha"> {{ i18n.t('fecha') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_fecha_vencimiento"> Fecha Vencimiento</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_detalle_impuesto"> {{ i18n.t('cotizacion_designer_impuesto') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_descuento"> {{ i18n.t('cotizacion_designer_descuento') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_condiciones"> Condiciones</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_notas"> Notas</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_codigo_producto"> Código Producto</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_validez"> Validez</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_subtitulo"> Subtítulo</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_lineas_firma"> Líneas de Firma</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_marca_agua"> Marca de Agua</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_info_bancaria"> Info Bancaria</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_totales_desglosados"> Totales Desglosados</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_numero_pagina"> {{ i18n.t('cotizacion_designer_numeracion_pagina') }}</label>
          </div>

          <!-- Textos personalizados -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-pen"></i> Textos Personalizados</h4>
          <div class="form-group"><label>Subtítulo</label><input v-model="config.subtitulo_text" class="form-control"></div>
          <div class="form-group"><label>Texto Encabezado</label><input v-model="config.header_text" class="form-control" placeholder="Texto adicional arriba"></div>
          <div class="form-group"><label>{{ i18n.t('cotizacion_designer_texto_pie') }}</label><input v-model="config.footer_text" class="form-control" placeholder="¡Gracias por su preferencia!"></div>
          <div class="form-group"><label>Condiciones por Defecto</label><textarea v-model="config.condiciones_default" class="form-control" rows="2"></textarea></div>
          <div class="form-group"><label>Notas por Defecto</label><textarea v-model="config.notas_default" class="form-control" rows="2"></textarea></div>
          <div class="form-group"><label>{{ i18n.t('cotizacion_designer_terminos') }}</label><textarea v-model="config.texto_terminos" class="form-control" rows="3" placeholder="Términos legales..."></textarea></div>
          <div class="form-group"><label>Info Bancaria</label><textarea v-model="config.info_bancaria" class="form-control" rows="2" placeholder="Banco, IBAN, etc."></textarea></div>

          <!-- Firmas -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-signature"></i> Firmas</h4>
          <div class="grid-2 gap-sm">
            <div class="form-group"><label>Texto Firma Cliente</label><input v-model="config.texto_firma_cliente" class="form-control"></div>
            <div class="form-group"><label>Texto Firma Empresa</label><input v-model="config.texto_firma_empresa" class="form-control"></div>
          </div>

          <!-- Logo -->
          <h4 style="margin:16px 0 10px;font-size:13px;font-weight:700;"><i class="fas fa-image"></i> {{ i18n.t('cotizacion_designer_logo') }}</h4>
          <div class="form-group"><input type="file" accept="image/*" class="form-control" @change="subirLogo"></div>
          <div v-if="config.logo_path" class="mb-md"><img :src="'/storage/'+config.logo_path" style="max-height:60px;" alt="Logo"></div>

          <button class="btn btn-primary mt-md cotizacion-save-btn" @click="guardar" :disabled="isSubmitting">
            <i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i>
            <span v-if="isSubmitting">{{ i18n.t('guardando') }}</span>
            <span v-else><i class="fas fa-save"></i> {{ i18n.t('cotizacion_designer_guardar') }}</span>
          </button>
        </div>
      </div>

      <!-- PREVIEW PANEL -->
      <div class="card">
        <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
          <h3 class="card-title"><i class="fas fa-eye"></i> {{ i18n.t('cotizacion_designer_vista_previa') }} A4</h3>
          <span class="badge badge-info">{{ config.tamano_papel }} · {{ config.orientacion === 'portrait' ? i18n.t('cotizacion_designer_vertical') : i18n.t('cotizacion_designer_horizontal') }}</span>
        </div>
        <div class="card-body" style="display:flex;justify-content:center;overflow:auto;background:#f1f5f9;">
          <div class="a4-preview" :class="[config.tamano_papel, config.orientacion, config.estilo_layout]" :style="previewStyles">
            <!-- Watermark -->
            <div v-if="config.mostrar_marca_agua" class="preview-watermark">{{ config.marca_agua_texto }}</div>

            <!-- Header -->
            <div class="preview-header" :style="headerStyles">
              <div class="preview-header-left">
                <div v-if="config.mostrar_logo && config.logo_path" class="preview-logo"><img :src="'/storage/'+config.logo_path" alt="Logo"></div>
                <div v-if="config.mostrar_nombre_negocio" class="preview-empresa">Mi Negocio S.A.</div>
                <div v-if="config.mostrar_direccion" class="preview-meta">San José, Costa Rica</div>
                <div v-if="config.mostrar_telefono" class="preview-meta">Tel: 8888-8888</div>
                <div v-if="config.mostrar_cedula" class="preview-meta">Cédula: 3-101-000000</div>
                <div v-if="config.header_text" class="preview-meta" style="margin-top:4px;font-style:italic;">{{ config.header_text }}</div>
              </div>
              <div class="preview-header-right">
                <div class="preview-doc-title">{{ i18n.t('cotizacion_designer_cotizacion') }}</div>
                <div v-if="config.mostrar_subtitulo" class="preview-doc-subtitle">{{ config.subtitulo_text }}</div>
                <div class="preview-doc-num">N° COT-20260522-0001</div>
                <div v-if="config.mostrar_fecha" class="preview-doc-meta">{{ i18n.t('fecha') }}: {{ previewDate }}</div>
                <div v-if="config.mostrar_fecha_vencimiento" class="preview-doc-meta">Vence: {{ previewVence }}</div>
              </div>
            </div>

            <!-- Client / Seller Info -->
            <div class="preview-info-row">
              <div v-if="config.mostrar_cliente" class="preview-info-box">
                <div class="preview-info-label">{{ i18n.t('cliente') }}</div>
                <div class="preview-info-value">Cliente Ejemplo S.A.</div>
                <div class="preview-info-sub">contacto@cliente.com</div>
              </div>
              <div v-if="config.mostrar_vendedor" class="preview-info-box">
                <div class="preview-info-label">{{ i18n.t('ticket_designer_vendedor') }}</div>
                <div class="preview-info-value">Juan Pérez</div>
                <div class="preview-info-sub">ventas@minegocio.com</div>
              </div>
            </div>

            <!-- Items Table -->
            <table class="preview-table">
              <thead>
                <tr>
                  <th style="width:40px;">#</th>
                  <th>{{ i18n.t('cotizacion_designer_descripcion') }}</th>
                  <th style="width:70px;text-align:center;">{{ i18n.t('cotizacion_designer_cantidad') }}</th>
                  <th style="width:110px;text-align:right;">{{ i18n.t('cotizacion_designer_precio_unitario') }}</th>
                  <th style="width:130px;text-align:right;">{{ i18n.t('cotizacion_designer_total') }}</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>1</td>
                  <td>
                    <div v-if="config.mostrar_codigo_producto" class="preview-item-code">SKU-001</div>
                    <div>Producto Ejemplo Premium</div>
                  </td>
                  <td style="text-align:center;">2</td>
                  <td style="text-align:right;">₡2,500</td>
                  <td style="text-align:right;font-weight:600;">₡5,000</td>
                </tr>
                <tr>
                  <td>2</td>
                  <td>
                    <div v-if="config.mostrar_codigo_producto" class="preview-item-code">SKU-002</div>
                    <div>Servicio de Instalación</div>
                  </td>
                  <td style="text-align:center;">1</td>
                  <td style="text-align:right;">₡8,500</td>
                  <td style="text-align:right;font-weight:600;">₡8,500</td>
                </tr>
              </tbody>
            </table>

            <!-- Totals -->
            <div class="preview-totals">
              <div v-if="config.mostrar_totales_desglosados" class="preview-totals-inner">
                <div class="preview-total-row"><span>{{ i18n.t('cotizacion_designer_subtotal_label') }}</span><span>₡13,500</span></div>
                <div v-if="config.mostrar_descuento" class="preview-total-row"><span>{{ i18n.t('cotizacion_designer_descuento_label') }}</span><span>-₡500</span></div>
                <div v-if="config.mostrar_detalle_impuesto" class="preview-total-row"><span>IVA 13%</span><span>₡1,690</span></div>
              </div>
              <div class="preview-grand-total">
                <span>{{ i18n.t('cotizacion_designer_total_label') }}</span>
                <span>₡14,690</span>
              </div>
            </div>

            <!-- Terms -->
            <div v-if="config.mostrar_condiciones && config.condiciones_default" class="preview-terms">
              <strong>Condiciones:</strong> {{ config.condiciones_default }}
            </div>
            <div v-if="config.mostrar_notas && config.notas_default" class="preview-terms">
              <strong>Notas:</strong> {{ config.notas_default }}
            </div>
            <div v-if="config.texto_terminos" class="preview-terms">
              <strong>{{ i18n.t('cotizacion_designer_terminos') }}:</strong> {{ config.texto_terminos }}
            </div>
            <div v-if="config.mostrar_info_bancaria && config.info_bancaria" class="preview-terms">
              <strong>Datos Bancarios:</strong> {{ config.info_bancaria }}
            </div>
            <div v-if="config.mostrar_validez" class="preview-validity">
              Esta cotización tiene una validez de 15 días calendario.
            </div>

            <!-- Signature Lines -->
            <div v-if="config.mostrar_lineas_firma" class="preview-signatures">
              <div class="preview-sig">
                <div class="preview-sig-line"></div>
                <div class="preview-sig-label">{{ config.texto_firma_cliente }}</div>
              </div>
              <div class="preview-sig">
                <div class="preview-sig-line"></div>
                <div class="preview-sig-label">{{ config.texto_firma_empresa }}</div>
              </div>
            </div>

            <!-- Footer -->
            <div v-if="config.footer_text" class="preview-footer">{{ config.footer_text }}</div>
            <div v-if="config.mostrar_numero_pagina" class="preview-page-num">{{ i18n.t('cotizacion_designer_numeracion_pagina') }} 1 de 1</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';

const toast = useToastStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando') });

const config = ref({
  ancho_mm:80, fuente:'Arial', fuente_size:12,
  tamano_papel:'A4', orientacion:'portrait', estilo_layout:'moderno',
  mostrar_logo:true, mostrar_nombre_negocio:true, mostrar_direccion:true, mostrar_telefono:true, mostrar_cedula:false,
  mostrar_vendedor:true, mostrar_cliente:true, mostrar_fecha:true, mostrar_fecha_vencimiento:true,
  mostrar_detalle_impuesto:true, mostrar_descuento:true, mostrar_condiciones:true, mostrar_notas:true,
  mostrar_codigo_producto:false, mostrar_validez:true,
  mostrar_subtitulo:true, subtitulo_text:'Cotización Profesional',
  mostrar_lineas_firma:true, texto_firma_cliente:'Firma del Cliente', texto_firma_empresa:'Firma Autorizada',
  mostrar_marca_agua:false, marca_agua_texto:'COTIZACIÓN',
  mostrar_info_bancaria:false, info_bancaria:'',
  mostrar_totales_desglosados:true, mostrar_numero_pagina:false,
  header_text:'', footer_text:'¡Gracias por su preferencia!',
  condiciones_default:'', notas_default:'', texto_terminos:'',
  color_fondo:'#ffffff', color_texto:'#1e293b', color_acento:'#01234e',
  color_encabezado:'#01234e', color_borde:'#01234e',
  logo_path:null
});

const previewDate = computed(() => new Date().toLocaleDateString('es-CR'));
const previewVence = computed(() => {
  const d = new Date();
  d.setDate(d.getDate() + 15);
  return d.toLocaleDateString('es-CR');
});

const previewStyles = computed(() => ({
  backgroundColor: config.value.color_fondo,
  color: config.value.color_texto,
  fontFamily: config.value.fuente,
  fontSize: config.value.fuente_size + 'px',
  borderColor: config.value.color_borde,
}));

const headerStyles = computed(() => ({
  borderBottomColor: config.value.color_encabezado,
}));

async function cargar() {
  try {
    const {data} = await api.get('/cotizacion-designer');
    if(data.config) {
      Object.keys(config.value).forEach(k=>{
        if(data.config[k]!==undefined && data.config[k]!==null) config.value[k]=data.config[k];
      });
    }
  } catch(e){}
}

async function guardar() {
  try {
    await execute(async () => { await api.post('/cotizacion-designer', config.value); toast.success(i18n.t('config_guardada')); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(i18n.t('error')); }
  }
}

async function subirLogo(e) {
  const file = e.target.files[0];
  if(!file) return;
  const fd = new FormData();
  fd.append('logo', file);
  try {
    const {data} = await api.post('/cotizacion-designer/logo', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
    config.value.logo_path = data.path;
    toast.success(i18n.t('registro_guardado'));
  } catch(er){ toast.error(i18n.t('error')); }
}

onMounted(cargar);
</script>

<style scoped>
/* Paper sizes */
.a4-preview {
  position: relative;
  width: 210mm;
  min-height: 297mm;
  padding: 20mm;
  background: #fff;
  box-shadow: 0 4px 20px rgba(0,0,0,0.12);
  margin: 10px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
}
.a4-preview.Letter { width: 216mm; min-height: 279mm; }
.a4-preview.Legal { width: 216mm; min-height: 356mm; }
.a4-preview.A5 { width: 148mm; min-height: 210mm; }
.a4-preview.landscape { width: 297mm; min-height: 210mm; }
.a4-preview.landscape.Letter { width: 279mm; min-height: 216mm; }
.a4-preview.landscape.Legal { width: 356mm; min-height: 216mm; }
.a4-preview.landscape.A5 { width: 210mm; min-height: 148mm; }

/* Watermark */
.preview-watermark {
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%) rotate(-30deg);
  font-size: 72px;
  font-weight: 900;
  color: rgba(0,0,0,0.06);
  pointer-events: none;
  text-transform: uppercase;
  letter-spacing: 6px;
  white-space: nowrap;
  z-index: 0;
}

/* Header */
.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  border-bottom: 3px solid #01234e;
  padding-bottom: 16px;
  margin-bottom: 20px;
  position: relative;
  z-index: 1;
}
.preview-header-left { flex: 1; }
.preview-header-right { text-align: right; }
.preview-logo img { max-height: 60px; max-width: 140px; }
.preview-empresa { font-size: 22px; font-weight: 800; margin-bottom: 4px; }
.preview-meta { font-size: 12px; color: #64748b; line-height: 1.5; }
.preview-doc-title { font-size: 28px; font-weight: 900; letter-spacing: 2px; color: #01234e; }
.preview-doc-subtitle { font-size: 13px; color: #64748b; margin-top: 2px; }
.preview-doc-num { font-size: 13px; font-weight: 700; margin-top: 6px; background: #f1f5f9; padding: 4px 10px; border-radius: 6px; display: inline-block; }
.preview-doc-meta { font-size: 12px; color: #64748b; margin-top: 4px; }

/* Info Row */
.preview-info-row { display: flex; gap: 16px; margin-bottom: 20px; position: relative; z-index: 1; }
.preview-info-box { flex: 1; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; background: #f8fafc; }
.preview-info-label { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #94a3b8; margin-bottom: 4px; }
.preview-info-value { font-size: 14px; font-weight: 700; color: #1e293b; }
.preview-info-sub { font-size: 12px; color: #64748b; margin-top: 2px; }

/* Table */
.preview-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; position: relative; z-index: 1; }
.preview-table thead th { background: #01234e; color: #fff; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; padding: 10px 8px; text-align: left; }
.preview-table tbody td { padding: 10px 8px; border-bottom: 1px solid #e2e8f0; font-size: 13px; vertical-align: top; }
.preview-table tbody tr:last-child td { border-bottom: 2px solid #01234e; }
.preview-item-code { font-size: 10px; color: #94a3b8; font-weight: 600; margin-bottom: 2px; }

/* Totals */
.preview-totals { display: flex; flex-direction: column; align-items: flex-end; margin-bottom: 20px; position: relative; z-index: 1; }
.preview-totals-inner { width: 260px; }
.preview-total-row { display: flex; justify-content: space-between; font-size: 13px; padding: 6px 0; border-bottom: 1px dashed #e2e8f0; color: #475569; }
.preview-grand-total { display: flex; justify-content: space-between; width: 260px; background: #f1f5f9; padding: 12px 14px; border-radius: 8px; margin-top: 8px; font-size: 15px; font-weight: 800; color: #01234e; }

/* Terms */
.preview-terms { font-size: 12px; color: #475569; margin-bottom: 10px; line-height: 1.6; position: relative; z-index: 1; }
.preview-validity { font-size: 12px; font-style: italic; color: #64748b; margin-bottom: 16px; position: relative; z-index: 1; }

/* Signatures */
.preview-signatures { display: flex; gap: 40px; margin-top: 30px; margin-bottom: 20px; position: relative; z-index: 1; }
.preview-sig { flex: 1; text-align: center; }
.preview-sig-line { border-bottom: 1.5px solid #1e293b; height: 40px; margin-bottom: 8px; }
.preview-sig-label { font-size: 12px; font-weight: 600; color: #475569; }

/* Footer */
.preview-footer { text-align: center; font-size: 12px; color: #94a3b8; margin-top: 10px; position: relative; z-index: 1; }
.preview-page-num { text-align: center; font-size: 11px; color: #94a3b8; margin-top: 6px; position: relative; z-index: 1; }

/* Layout variations */
.moderno .preview-table thead th { background: v-bind('config.color_encabezado'); }
.moderno .preview-doc-title { color: v-bind('config.color_acento'); }
.moderno .preview-grand-total { color: v-bind('config.color_acento'); }

.clasico .preview-table thead th { background: #fff; color: v-bind('config.color_texto'); border-bottom: 2px solid v-bind('config.color_borde'); }
.clasico .preview-header { border-bottom: 2px solid v-bind('config.color_borde'); }

.minimal .preview-table thead th { background: transparent; color: v-bind('config.color_texto'); border-bottom: 2px solid v-bind('config.color_borde'); text-transform: none; letter-spacing: 0; font-weight: 600; }
.minimal .preview-header { border-bottom: 1px solid v-bind('config.color_borde'); }
.minimal .preview-info-box { background: transparent; border: none; padding: 0; }
.minimal .preview-grand-total { background: transparent; border-top: 2px solid v-bind('config.color_borde'); border-radius: 0; }

.cotizacion-save-btn {
  width: 100%;
}

@media (max-width: 1023px) {
  .grid-2.gap-lg {
    display: grid;
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .a4-preview {
    width: 100% !important;
    min-height: auto;
    padding: 10mm;
    transform: none;
    margin: 0;
  }
  .a4-preview.landscape {
    width: 100% !important;
    min-height: auto;
  }
  .a4-preview .preview-header {
    flex-direction: column;
    gap: 12px;
  }
  .a4-preview .preview-header-right {
    text-align: left;
  }
  .a4-preview .preview-info-row {
    flex-direction: column;
  }
  .a4-preview .preview-table {
    font-size: 11px;
  }
  .a4-preview .preview-totals-inner,
  .a4-preview .preview-grand-total {
    width: 100%;
  }
  .a4-preview .preview-signatures {
    flex-direction: column;
    gap: 20px;
  }
  .preview-totals-inner,
  .preview-grand-total {
    width: 100% !important;
  }
  .grid-3.gap-sm {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .cotizacion-save-btn {
    min-height: 44px;
    font-size: clamp(14px, 3vw, 16px);
  }
  .a4-preview .preview-doc-title {
    font-size: clamp(18px, 5vw, 28px);
  }
  .a4-preview .preview-empresa {
    font-size: clamp(16px, 4vw, 22px);
  }
}
</style>
