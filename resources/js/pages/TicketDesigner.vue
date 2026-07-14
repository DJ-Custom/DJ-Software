<template>
  <div>
    <div class="grid-2 gap-lg">
      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-cog"></i> {{ i18n.t('ticket_designer_configuracion') }}</h3></div>
        <div class="card-body">
          <div class="grid-2 gap-sm">
            <div class="form-group"><label>{{ i18n.t('ticket_designer_ancho') }}</label><input v-model.number="config.ancho_mm" type="number" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('ticket_designer_fuente') }}</label><select v-model="config.fuente" class="form-control"><option>Courier New</option><option>Arial</option><option>Verdana</option><option>Tahoma</option><option>monospace</option></select></div>
            <div class="form-group"><label>{{ i18n.t('ticket_designer_tamano_fuente') }}</label><input v-model.number="config.fuente_size" type="number" class="form-control"></div>
          </div>
          <hr style="border-color:var(--bg-hover);margin:16px 0;">
          <h4 style="margin-bottom:12px;font-size:14px;">{{ i18n.t('ticket_designer_elementos_visibles') }}</h4>
          <div class="grid-2 gap-xs">
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_logo"> {{ i18n.t('ticket_designer_logo') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_nombre_negocio"> {{ i18n.t('ticket_designer_nombre_negocio') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_direccion"> {{ i18n.t('ticket_designer_direccion') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_telefono"> {{ i18n.t('ticket_designer_telefono') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_cedula"> {{ i18n.t('ticket_designer_cedula_juridica') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_vendedor"> {{ i18n.t('ticket_designer_vendedor') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_cliente"> {{ i18n.t('cliente') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_fecha"> {{ i18n.t('fecha') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_detalle_impuesto"> Detalle Impuesto</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_descuento"> {{ i18n.t('cotizacion_designer_descuento') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_metodo_pago"> {{ i18n.t('ticket_designer_metodo_pago') }}</label>
            <label class="flex items-center gap-sm"><input type="checkbox" v-model="config.mostrar_codigo_producto"> Código Producto</label>
          </div>
          <hr style="border-color:var(--bg-hover);margin:16px 0;">
          <div class="form-group"><label>Texto Encabezado</label><input v-model="config.header_text" class="form-control" placeholder="Texto adicional arriba"></div>
          <div class="form-group"><label>Texto Pie</label><input v-model="config.footer_text" class="form-control" placeholder="¡Gracias por su compra!"></div>
          <div class="form-group"><label>{{ i18n.t('ticket_designer_logo') }}</label><input type="file" accept="image/*" class="form-control" @change="subirLogo"></div>
          <div v-if="config.logo_path" class="mb-md"><img :src="'/storage/'+config.logo_path" style="max-height:60px;" alt="Logo"></div>
          <button class="btn btn-primary ticket-save-btn" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('guardando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('ticket_designer_guardar') }}</span></button>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-eye"></i> {{ i18n.t('ticket_designer_vista_previa') }}</h3></div>
        <div class="card-body" style="display:flex;justify-content:center;">
          <div :style="{width:config.ancho_mm+'mm',fontFamily:config.fuente,fontSize:config.fuente_size+'px',border:'1px solid #ccc',padding:'10px',background:'#fff',color:'#000',textAlign:'center'}">
            <div v-if="config.mostrar_logo && config.logo_path" style="margin-bottom:6px;"><img :src="'/storage/'+config.logo_path" style="max-height:50px;" alt="Logo"></div>
            <div v-if="config.mostrar_nombre_negocio" style="font-weight:bold;font-size:1.2em;">Mi Negocio</div>
            <div v-if="config.mostrar_direccion" style="font-size:0.85em;">San José, Costa Rica</div>
            <div v-if="config.mostrar_telefono" style="font-size:0.85em;">Tel: 8888-8888</div>
            <div v-if="config.mostrar_cedula" style="font-size:0.85em;">Cédula: 3-101-000000</div>
            <div v-if="config.header_text" style="margin-top:4px;font-size:0.85em;">{{ config.header_text }}</div>
            <hr style="border:1px dashed #000;margin:6px 0;">
            <div v-if="config.mostrar_fecha" style="text-align:left;font-size:0.85em;">{{ i18n.t('fecha') }}: {{ new Date().toLocaleString('es-CR') }}</div>
            <div style="text-align:left;font-size:0.85em;">{{ i18n.t('factura') }}: <strong>F-00001</strong></div>
            <div v-if="config.mostrar_vendedor" style="text-align:left;font-size:0.85em;">{{ i18n.t('ticket_designer_vendedor') }}: Admin</div>
            <div v-if="config.mostrar_cliente" style="text-align:left;font-size:0.85em;">{{ i18n.t('cliente') }}: Público General</div>
            <hr style="border:1px dashed #000;margin:6px 0;">
            <table style="width:100%;font-size:0.85em;text-align:left;"><thead><tr><th>{{ i18n.t('ticket_designer_productos') }}</th><th style="text-align:right;">{{ i18n.t('cotizacion_designer_cantidad') }}</th><th style="text-align:right;">{{ i18n.t('ticket_designer_total') }}</th></tr></thead>
              <tbody><tr><td>{{ config.mostrar_codigo_producto ? '[001] ' : '' }}Producto Ejemplo</td><td style="text-align:right;">2</td><td style="text-align:right;">₡5,000</td></tr></tbody>
            </table>
            <hr style="border:1px dashed #000;margin:6px 0;">
            <div style="text-align:right;font-size:0.85em;">{{ i18n.t('ticket_designer_subtotal') }}: ₡5,000</div>
            <div v-if="config.mostrar_descuento" style="text-align:right;font-size:0.85em;">{{ i18n.t('cotizacion_designer_descuento') }}: -₡500</div>
            <div v-if="config.mostrar_detalle_impuesto" style="text-align:right;font-size:0.85em;">IVA 13%: ₡585</div>
            <div style="text-align:right;font-weight:bold;font-size:1.1em;">{{ i18n.t('ticket_designer_total') }}: ₡5,085</div>
            <hr style="border:1px dashed #000;margin:6px 0;">
            <div v-if="config.mostrar_metodo_pago" style="text-align:right;font-size:0.85em;">{{ i18n.t('ticket_designer_metodo_pago') }}: {{ i18n.t('efectivo') }}</div>
            <div v-if="config.footer_text" style="margin-top:6px;font-size:0.8em;">{{ config.footer_text }}</div>
          </div>
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

const toast = useToastStore();
const i18n = useI18nStore();
import { useSubmitLock } from '../composables/useSubmitLock';
const { isSubmitting, execute } = useSubmitLock({ loadingText: i18n.t('guardando') });

const config = ref({ ancho_mm:80, fuente:'Courier New', fuente_size:12, mostrar_logo:true, mostrar_nombre_negocio:true, mostrar_direccion:true, mostrar_telefono:true, mostrar_cedula:false, mostrar_vendedor:true, mostrar_cliente:true, mostrar_fecha:true, mostrar_detalle_impuesto:true, mostrar_descuento:true, mostrar_metodo_pago:true, mostrar_codigo_producto:false, mostrar_sinpe_info:false, header_text:'', footer_text:'¡Gracias por su compra!', logo_path:null });
async function cargar() { try { const {data} = await api.get('/ticket-designer'); if(data.config) { Object.keys(config.value).forEach(k=>{ if(data.config[k]!==undefined && data.config[k]!==null) config.value[k]=data.config[k]; }); } } catch(e){} }
async function guardar() {
  try {
    await execute(async () => { await api.post('/ticket-designer', config.value); toast.success(i18n.t('config_guardada')); });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(i18n.t('error')); }
  }
}
async function subirLogo(e) { const file = e.target.files[0]; if(!file) return; const fd = new FormData(); fd.append('logo', file); try { const {data} = await api.post('/ticket-designer/logo', fd, { headers: { 'Content-Type': 'multipart/form-data' } }); config.value.logo_path = data.path; toast.success(i18n.t('registro_guardado')); } catch(er){ toast.error(i18n.t('error')); } }
onMounted(cargar);
</script>

<style scoped>
.ticket-save-btn {
  width: 100%;
}

@media (max-width: 1023px) {
  .grid-2.gap-lg {
    display: grid;
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .grid-2.gap-sm {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .ticket-save-btn {
    min-height: 44px;
    font-size: clamp(14px, 3vw, 16px);
  }
}
</style>
