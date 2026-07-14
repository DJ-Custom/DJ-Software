<template>
  <div>
    <div class="flex items-center justify-between mb-lg">
      <h3 style="margin:0;">{{ i18n.t('listas_precios') }}</h3>
      <button class="btn btn-primary" @click="nuevaLista"><i class="fas fa-plus"></i> {{ i18n.t('listas_precios_nueva') }}</button>
    </div>

    <!-- Listas grid -->
    <div v-if="!listaActiva" class="grid-3 gap-md">
      <div v-for="l in listas" :key="l.id" class="card card-clickable" @click="abrirLista(l)">
        <div class="card-header"><h3 class="card-title">{{ l.nombre }}</h3><span class="badge badge-info">{{ l.descuento_porcentaje }}% {{ i18n.t('listas_precios_descuento') }}</span></div>
        <div class="card-body">
          <div class="text-muted-sm">{{ l.descripcion||i18n.t('listas_precios_sin_descripcion') }}</div>
          <div class="text-xs">{{ l.productos_count || 0 }} {{ i18n.t('listas_precios_total_productos') }} · {{ l.clientes_count || 0 }} {{ i18n.t('listas_precios_total_clientes') }}</div>
          <div class="flex gap-xs mt-md">
            <button class="btn btn-sm btn-ghost" @click.stop="editar(l)"><i class="fas fa-edit"></i></button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="!listaActiva && !listas.length" class="card empty-state">{{ i18n.t('listas_precios_sin_datos') }}</div>

    <!-- Detalle de lista -->
    <div v-if="listaActiva">
      <div class="flex items-center gap-md mb-lg flex-wrap">
        <button class="btn btn-secondary" @click="listaActiva=null"><i class="fas fa-arrow-left"></i> {{ i18n.t('listas_precios_volver') }}</button>
        <h3 style="margin:0;">{{ listaActiva.nombre }}</h3>
        <span class="badge badge-info">{{ listaActiva.descuento_porcentaje }}% {{ i18n.t('listas_precios_descuento_global') }}</span>
        <div style="flex:1;"></div>
        <button class="btn btn-primary" @click="guardarCambios"><i class="fas fa-save"></i> {{ i18n.t('listas_precios_guardar') }}</button>
      </div>

      <div class="grid-2 gap-md mb-lg">
        <!-- Clientes asignados -->
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-users"></i> {{ i18n.t('listas_precios_clientes') }}</h3></div>
          <div class="card-body">
            <div class="flex gap-sm mb-sm">
              <input v-model="buscarCliente" class="form-control input-full" :placeholder="i18n.t('listas_precios_buscar_cliente')" @input="buscarClientes">
            </div>
            <div v-if="clienteResults.length" class="search-results">
              <div v-for="c in clienteResults" :key="c.id" class="search-item" @click="asignarCliente(c)"><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ c.nombre }}</div>
            </div>
            <div v-for="c in clientesAsignados" :key="c.id" class="flex items-center justify-between list-item">
              <span>{{ c.nombre }}</span>
              <button class="btn btn-sm btn-danger" @click="quitarCliente(c.id)"><i class="fas fa-times"></i></button>
            </div>
            <div v-if="!clientesAsignados.length" class="empty-message">{{ i18n.t('listas_precios_sin_clientes') }}</div>
          </div>
        </div>

        <!-- Productos con precios específicos -->
        <div class="card">
          <div class="card-header"><h3 class="card-title"><i class="fas fa-tag"></i> {{ i18n.t('listas_precios_productos') }}</h3></div>
          <div class="card-body">
            <div class="flex gap-sm mb-sm">
              <input v-model="buscarProd" class="form-control input-full" :placeholder="i18n.t('listas_precios_agregar_producto')" @input="buscarProductos">
            </div>
            <div v-if="prodResults.length" class="search-results">
              <div v-for="p in prodResults" :key="p.id" class="search-item" @click="agregarProducto(p)"><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ p.nombre }} - {{ formatMoney(p.precio_venta) }}</div>
            </div>
            <div class="scroll-container-md">
              <div v-for="p in productosLista" :key="p.id" class="flex items-center gap-sm list-item">
                <span class="flex-1 text-sm">{{ p.producto_nombre }}</span>
                <input v-model.number="p.precio_especial" type="number" min="0" step="0.01" class="form-control price-input" @change="actualizarPrecio(p)">
                <button class="btn btn-sm btn-danger" @click="quitarProducto(p.id)"><i class="fas fa-trash"></i></button>
              </div>
            </div>
            <div v-if="!productosLista.length" class="empty-message">{{ i18n.t('listas_precios_sin_productos') }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal crear/editar -->
    <div class="modal-overlay" :class="{active:showModal}" @click.self="showModal=false">
      <div class="modal modal-responsive-lg"><div class="modal-header"><h3 class="modal-title">{{ editItem?i18n.t('editar'):i18n.t('nueva') }} {{ i18n.t('listas_precios') }}</h3><button class="modal-close" @click="showModal=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-grid-2 gap-md">
            <div class="form-group"><label>{{ i18n.t('listas_precios_nombre') }} *</label><input v-model="form.nombre" class="form-control"></div>
            <div class="form-group"><label>{{ i18n.t('listas_precios_descuento_global_label') }}</label><input v-model.number="form.descuento_porcentaje" type="number" min="0" max="100" class="form-control"></div>
          </div>
          <div class="form-group"><label>{{ i18n.t('listas_precios_descripcion') }}</label><textarea v-model="form.descripcion" class="form-control" rows="2"></textarea></div>

          <!-- Cliente selector en el modal -->
          <div class="form-group" style="margin-top:16px;">
            <label><i class="fas fa-users"></i> {{ i18n.t('listas_precios_clientes') }}</label>
            <input v-model="modalBuscarCliente" class="form-control" :placeholder="i18n.t('listas_precios_buscar_cliente')" @input="buscarClientesModal" style="margin-bottom:6px;">
            <div v-if="modalClienteResults.length" class="search-results">
              <div v-for="c in modalClienteResults" :key="c.id" class="search-item" @click="modalAgregarCliente(c)"><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ c.nombre }} <span style="color:var(--text-muted);">{{ c.email }}</span></div>
            </div>
            <div v-for="(c, i) in form.clientes" :key="i" class="flex items-center justify-between list-item">
              <span>{{ c.nombre }}</span>
              <button class="btn btn-sm btn-danger" @click="form.clientes.splice(i,1)"><i class="fas fa-times"></i></button>
            </div>
            <div v-if="!form.clientes?.length" class="empty-message">{{ i18n.t('listas_precios_sin_clientes') }}</div>
          </div>

          <!-- Productos selector en el modal -->
          <div class="form-group" style="margin-top:16px;">
            <label><i class="fas fa-tag"></i> {{ i18n.t('listas_precios_precio_lista') }}</label>
            <input v-model="modalBuscarProd" class="form-control" :placeholder="i18n.t('listas_precios_buscar_producto')" @input="buscarProductosModal" style="margin-bottom:6px;">
            <div v-if="modalProdResults.length" class="search-results">
              <div v-for="p in modalProdResults" :key="p.id" class="search-item" @click="modalAgregarProducto(p)"><i class="fas fa-plus" style="color:var(--success);margin-right:6px;"></i>{{ p.nombre }} - {{ formatMoney(p.precio_venta) }}</div>
            </div>
            <div class="scroll-container-md">
              <div v-for="(p, i) in form.productos" :key="i" class="flex items-center gap-sm list-item">
                <span class="flex-1 text-sm">{{ p.nombre }}</span>
                <span class="text-xs text-muted nowrap">{{ i18n.t('listas_precios_precio_original') }}: {{ formatMoney(p.precio_base) }}</span>
                <input v-model.number="p.precio_especial" type="number" min="0" step="0.01" class="form-control price-input" :placeholder="i18n.t('listas_precios_precio_label')">
                <button class="btn btn-sm btn-danger" @click="form.productos.splice(i,1)"><i class="fas fa-trash"></i></button>
              </div>
            </div>
            <div v-if="!form.productos?.length" class="empty-message">{{ i18n.t('listas_precios_sin_productos') }}</div>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="guardar" :disabled="isSubmitting"><i v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18n.t('listas_precios_guardando') }}</span><span v-else><i class="fas fa-save"></i> {{ i18n.t('guardar') }}</span></button></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useSubmitLock } from '../composables/useSubmitLock';
import { useCurrency } from '../composables/useCurrency';
import { useI18nStore } from '../stores/i18n';

const { fm: formatMoney } = useCurrency();

const toast = useToastStore();
const i18n = useI18nStore();
const { isSubmitting, execute } = useSubmitLock({ loadingText: 'Guardando...' });

const listas = ref([]); const showModal = ref(false); const editItem = ref(null); const form = ref({});
const listaActiva = ref(null);
const clientesAsignados = ref([]); const productosLista = ref([]);
const buscarCliente = ref(''); const clienteResults = ref([]);
const buscarProd = ref(''); const prodResults = ref([]);
const modalBuscarCliente = ref(''); const modalClienteResults = ref([]);
const modalBuscarProd = ref(''); const modalProdResults = ref([]);

async function cargar() { try { const {data} = await api.get('/listas-precios'); listas.value=data.listas||[]; } catch(e){ listas.value=[]; } }

function nuevaLista() { editItem.value=null; form.value={nombre:'',descripcion:'',descuento_porcentaje:0,clientes:[],productos:[]}; modalBuscarCliente.value=''; modalClienteResults.value=[]; modalBuscarProd.value=''; modalProdResults.value=[]; showModal.value=true; }
function editar(l) { editItem.value=l; form.value={nombre:l.nombre,descripcion:l.descripcion,descuento_porcentaje:l.descuento_porcentaje,clientes:[],productos:[]}; modalBuscarCliente.value=''; modalClienteResults.value=[]; modalBuscarProd.value=''; modalProdResults.value=[]; showModal.value=true; }

async function buscarClientesModal() {
  if (modalBuscarCliente.value.length < 2) { modalClienteResults.value = []; return; }
  try { const { data } = await api.get('/clientes/buscar', { params: { q: modalBuscarCliente.value } }); modalClienteResults.value = (data.clientes || []).filter(c => !form.value.clientes.find(fc => fc.id === c.id)); } catch(e) {}
}
function modalAgregarCliente(c) {
  if (!form.value.clientes.find(fc => fc.id === c.id)) {
    form.value.clientes.push({ id: c.id, nombre: c.nombre });
  }
  modalBuscarCliente.value = ''; modalClienteResults.value = [];
}
async function buscarProductosModal() {
  if (modalBuscarProd.value.length < 2) { modalProdResults.value = []; return; }
  try { const { data } = await api.get('/productos/buscar', { params: { q: modalBuscarProd.value, incluir_inactivos: 1 } }); modalProdResults.value = (data.productos || []).filter(p => !form.value.productos.find(fp => fp.producto_id === p.id)); } catch(e) {}
}
function modalAgregarProducto(p) {
  if (!form.value.productos.find(fp => fp.producto_id === p.id)) {
    form.value.productos.push({ producto_id: p.id, nombre: p.nombre, precio_base: p.precio_venta, precio_especial: p.precio_venta });
  }
  modalBuscarProd.value = ''; modalProdResults.value = [];
}

async function abrirLista(l) {
  listaActiva.value = l;
  try {
    const { data } = await api.get(`/listas-precios/${l.id}/detalle`);
    clientesAsignados.value = data.clientes || [];
    productosLista.value = data.productos || [];
  } catch(e) { clientesAsignados.value = []; productosLista.value = []; }
}

async function buscarClientes() {
  if (buscarCliente.value.length < 2) { clienteResults.value = []; return; }
  try { const { data } = await api.get('/clientes/buscar', { params: { q: buscarCliente.value } }); clienteResults.value = data.clientes || []; } catch(e) {}
}

async function asignarCliente(c) {
  try {
    await api.post(`/listas-precios/${listaActiva.value.id}/clientes`, { cliente_id: c.id });
    clientesAsignados.value.push(c);
    clienteResults.value = []; buscarCliente.value = '';
  } catch(e) { toast.error(i18n.t('listas_precios_error_agregar_cliente')); }
}

async function quitarCliente(clienteId) {
  try {
    await api.delete(`/listas-precios/${listaActiva.value.id}/clientes/${clienteId}`);
    clientesAsignados.value = clientesAsignados.value.filter(c => c.id !== clienteId);
  } catch(e) { toast.error(i18n.t('error')); }
}

async function buscarProductos() {
  if (buscarProd.value.length < 2) { prodResults.value = []; return; }
  try { const { data } = await api.get('/productos/buscar', { params: { q: buscarProd.value, incluir_inactivos: 1 } }); prodResults.value = data.productos || []; } catch(e) {}
}

async function agregarProducto(p) {
  try {
    await api.post(`/listas-precios/${listaActiva.value.id}/productos`, { producto_id: p.id, precio_especial: p.precio_venta });
    productosLista.value.push({ id: p.id, producto_nombre: p.nombre, precio_especial: p.precio_venta });
    prodResults.value = []; buscarProd.value = '';
  } catch(e) { toast.error(i18n.t('listas_precios_error_agregar_producto')); }
}

async function actualizarPrecio(p) {
  try { await api.put(`/listas-precios/${listaActiva.value.id}/productos/${p.id}`, { precio_especial: p.precio_especial }); } catch(e) { toast.error(i18n.t('error')); }
}

async function quitarProducto(productoId) {
  try {
    await api.delete(`/listas-precios/${listaActiva.value.id}/productos/${productoId}`);
    productosLista.value = productosLista.value.filter(p => p.id !== productoId);
  } catch(e) { toast.error(i18n.t('error')); }
}

async function guardarCambios() {
  try {
    await Promise.all(productosLista.value.map(p =>
      api.put(`/listas-precios/${listaActiva.value.id}/productos/${p.id}`, { precio_especial: p.precio_especial })
    ));
    toast.success(i18n.t('listas_precios_lista_guardada_exito'));
  } catch(e) { toast.error(i18n.t('listas_precios_lista_guardada_error')); }
}

async function guardar() {
  try {
    await execute(async () => {
      const payload = {
        nombre: form.value.nombre,
        descripcion: form.value.descripcion,
        descuento_porcentaje: form.value.descuento_porcentaje,
        clientes: (form.value.clientes || []).map(c => c.id),
        productos: (form.value.productos || []).map(p => ({ producto_id: p.producto_id, precio_especial: p.precio_especial })),
      };
      if(editItem.value) await api.put(`/listas-precios/${editItem.value.id}`, payload);
      else await api.post('/listas-precios', payload);
      showModal.value=false; cargar();
      toast.success(i18n.t('listas_precios_lista_guardada_exito'));
    });
  } catch(e){
    if (e.response?.status === 429) { toast.warning(i18n.t('solicitud_procesando')); }
    else { toast.error(e.response?.data?.message||i18n.t('error')); }
  }
}


onMounted(cargar);
</script>

<style scoped>
.modal-responsive-lg {
  max-width: min(90vw, 750px);
}

.input-full {
  flex: 1;
  width: 100%;
}

.search-results {
  max-height: 120px;
  overflow: auto;
  border: 1px solid var(--bg-hover);
  border-radius: 6px;
  margin-bottom: 8px;
}

.search-item {
  padding: 8px;
  cursor: pointer;
  border-bottom: 1px solid var(--bg-hover);
  font-size: 13px;
}

.search-item:hover {
  background: var(--bg-hover);
}

.scroll-container-md {
  max-height: 300px;
  overflow: auto;
}

.list-item {
  border-bottom: 1px solid var(--bg-hover);
  padding: 4px 0;
  font-size: 13px;
}

.empty-message {
  padding: 16px;
  text-align: center;
  color: var(--text-muted);
  font-size: 13px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-muted);
}

.card-clickable {
  cursor: pointer;
}

.text-muted-sm {
  font-size: 13px;
  color: var(--text-muted);
  margin-bottom: 8px;
}

.text-xs {
  font-size: 12px;
}

.text-sm {
  font-size: 13px;
}

.text-muted {
  color: var(--text-muted);
}

.nowrap {
  white-space: nowrap;
}

.price-input {
  width: 100px;
  font-size: 12px;
  min-width: 80px;
}

@media (max-width: 1023px) {
  .grid-3 {
    grid-template-columns: repeat(2, 1fr);
  }

  .grid-2 {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .grid-3 {
    grid-template-columns: 1fr;
  }

  .form-grid-2 {
    grid-template-columns: 1fr;
  }

  .modal-responsive-lg {
    max-width: min(95vw, 750px);
  }

  .btn {
    min-height: 44px;
  }

  .price-input {
    width: 80px;
    min-width: 60px;
  }

  .scroll-container-md {
    max-height: 200px;
  }

  .card-header {
    flex-wrap: wrap;
  }
}

@media (max-width: 480px) {
  .list-item {
    font-size: 12px;
    padding: 6px 0;
  }

  .search-item {
    font-size: 12px;
    padding: 6px 8px;
  }

  .price-input {
    width: 70px;
    min-width: 55px;
  }
}
</style>
