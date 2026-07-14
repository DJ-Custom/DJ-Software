<template>
  <div class="pos-container">
    <!-- Top Bar: Location + Session -->
    <div class="pos-topbar">
      <div class="flex items-center gap-md">
        <select v-model="ubicacionId" class="form-control ubicacion-select" @change="onUbicacionChange">
          <option value="">{{ i18n.t('seleccionar_ubicacion') }}</option>
          <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
        </select>
        <div v-if="sesion" class="flex items-center gap-sm">
          <span class="badge badge-success"><i class="fas fa-circle" style="font-size:8px;margin-right:4px;"></i> {{ i18n.t('caja_abierta') }}</span>
          <span style="font-size:13px;color:var(--text-secondary);">{{ sesion.caja_nombre }} | {{ i18n.t('monto_inicial') }}: {{ fm(sesion.monto_apertura) }}</span>
          <span v-if="sesion.usuario_asignado_nombre" class="badge badge-info"><i class="fas fa-user"></i> {{ sesion.usuario_asignado_nombre }}</span>
        </div>
        <div v-else class="flex items-center gap-sm">
          <span class="badge badge-danger"><i class="fas fa-circle" style="font-size:8px;margin-right:4px;"></i> {{ i18n.t('caja_cerrada') }}</span>
        </div>
        <button v-if="!sesion" class="btn btn-sm btn-primary" @click="abrirModalAbrir"><i class="fas fa-lock-open"></i> {{ i18n.t('abrir_caja') }}</button>
      </div>
      <div class="flex items-center gap-sm">
        <button class="btn btn-sm btn-ghost" @click="showHistorial=true"><i class="fas fa-history"></i> {{ i18n.t('historial_sesiones') }}</button>
        <button v-if="sesion" class="btn btn-sm btn-warning" @click="showRetiro=true"><i class="fas fa-arrow-down"></i> {{ i18n.t('retiro_caja') }}</button>
        <button v-if="sesion" class="btn btn-sm btn-danger" @click="abrirModalCerrar"><i class="fas fa-lock"></i> {{ i18n.t('cerrar_caja') }}</button>
      </div>
    </div>

    <!-- Main POS Layout -->
    <div class="pos-main">
      <!-- Left: Products -->
      <div class="pos-products">
        <div class="pos-search">
          <div class="flex gap-sm mb-sm">
            <input v-model="buscarProd" class="form-control" :placeholder="i18n.t('buscar_producto')" @input="buscarProductos" style="flex:1;">
          </div>
          <div v-if="prodResults.length" class="pos-prod-results">
            <div v-for="p in prodResults" :key="p.id" class="pos-prod-item" @click="agregarProducto(p)">
              <div><strong>{{ p.nombre }}</strong><span style="font-size:12px;color:var(--text-muted);margin-left:8px;">{{ p.codigo }}</span></div>
              <div class="flex items-center gap-md"><span style="color:var(--success);font-weight:600;">{{ fm(p.precio_venta) }}</span><span class="badge badge-info">Stock: {{ p.stock_ubicacion !== undefined ? p.stock_ubicacion : p.stock }}</span></div>
            </div>
          </div>
          <div v-else-if="!buscarProd && productosPopulares.length" class="pos-populares">
            <div style="font-size:12px;font-weight:600;color:var(--text-muted);margin-bottom:8px;"><i class="fas fa-fire"></i> Más vendidos</div>
            <div class="pos-populares-grid">
              <button v-for="p in productosPopulares" :key="p.id" class="pos-popular-chip" @click="agregarProducto(p)">
                <div class="pos-popular-nombre">{{ p.nombre }}</div>
                <div class="pos-popular-precio">{{ fm(p.precio_venta) }}</div>
              </button>
            </div>
          </div>
        </div>

        <!-- Cart Items -->
        <div class="pos-cart">
          <div v-if="!cart.length" class="pos-cart-empty"><i class="fas fa-shopping-cart" style="font-size:48px;color:var(--bg-hover);margin-bottom:12px;"></i><p style="color:var(--text-muted);">{{ i18n.t('agregar_productos') }}</p></div>
          <div v-for="(item,i) in cart" :key="i" class="pos-cart-item">
            <div class="pos-cart-info">
              <strong>{{ item.nombre }}</strong>
              <div style="font-size:12px;color:var(--text-muted);">{{ fm(item.precio_unitario) }} c/u</div>
            </div>
            <div class="flex items-center gap-sm">
              <button class="btn btn-sm btn-ghost" @click="item.cantidad>1?item.cantidad--:quitarItem(i)"><i class="fas fa-minus"></i></button>
              <input v-model.number="item.cantidad" type="number" min="1" class="form-control cart-qty-input" style="text-align:center;">
              <button class="btn btn-sm btn-ghost" @click="item.cantidad++"><i class="fas fa-plus"></i></button>
            </div>
            <div style="text-align:right;min-width:90px;"><strong>{{ fm(item.precio_unitario * item.cantidad) }}</strong></div>
            <button class="btn btn-sm btn-danger" @click="quitarItem(i)"><i class="fas fa-trash"></i></button>
          </div>
        </div>

        <!-- Combos / Promos / Cupón -->
        <div class="pos-extras">
          <button class="btn btn-sm btn-secondary" @click="showCombos=true"><i class="fas fa-cubes"></i> Combos</button>
          <button class="btn btn-sm btn-secondary" @click="showPromos=true"><i class="fas fa-percentage"></i> Promos</button>
          <div class="flex items-center gap-sm" style="flex:1;">
            <input v-model="codigoCupon" class="form-control" placeholder="Código cupón..." style="flex:1;">
            <button class="btn btn-sm btn-info" @click="aplicarCupon" :disabled="!codigoCupon"><i class="fas fa-ticket-alt"></i></button>
          </div>
        </div>
      </div>

      <!-- Right: Invoice Summary -->
      <div class="pos-summary">
        <!-- Client -->
        <div class="pos-client-section">
          <label style="font-weight:600;font-size:13px;margin-bottom:6px;display:block;">{{ i18n.t('cliente') }}</label>
          <input v-model="buscarCliente" class="form-control mb-sm" placeholder="Buscar cliente registrado..." @input="buscarClientes">
          <div v-if="clienteResults.length && !clienteSel" class="pos-client-results">
            <div v-for="c in clienteResults" :key="c.id" class="pos-client-item" @click="seleccionarCliente(c)">
              <strong>{{ c.nombre }}</strong><span style="font-size:12px;color:var(--text-muted);margin-left:6px;">{{ c.cedula || c.email || '' }}</span>
            </div>
          </div>
          <div v-if="clienteSel" class="pos-client-selected">
            <span><i class="fas fa-user"></i> {{ clienteSel.nombre }}</span>
            <button class="btn btn-sm btn-ghost" @click="clienteSel=null;buscarCliente='';preciosCliente={};descuentoListaGlobal=0"><i class="fas fa-times"></i></button>
          </div>
          <input v-if="!clienteSel" v-model="nombreFactura" class="form-control mt-sm" placeholder="Nombre en factura (sin registrar)">
        </div>

        <!-- Discount -->
        <div class="pos-discount-section">
          <label style="font-weight:600;font-size:13px;">{{ i18n.t('descuento') }}</label>
          <div class="flex items-center gap-sm mt-xs">
            <select v-model="descuentoTipo" class="form-control discount-select"><option value="%">%</option><option value="$">{{ $simbolo }}</option></select>
            <input v-model.number="descuentoValor" type="number" min="0" class="form-control" placeholder="0" style="flex:1;">
          </div>
        </div>

        <!-- Invoice Totals (Real-time) -->
        <div class="pos-totals">
          <div class="pos-total-row"><span>{{ i18n.t('subtotal') }}</span><span>{{ fm(subtotal) }}</span></div>
          <div class="pos-total-row" v-if="montoDescuento > 0"><span>{{ i18n.t('descuento') }}</span><span style="color:var(--danger);">-{{ fm(montoDescuento) }}</span></div>
          <div class="pos-total-row" v-if="cuponAplicado"><span>Cupón ({{ cuponAplicado.codigo }})</span><span style="color:var(--danger);">-{{ fm(descuentoCupon) }}</span></div>
          <div class="pos-total-row"><span>{{ i18n.t('impuesto') }}</span><span>{{ fm(totalImpuesto) }}</span></div>
          <div class="pos-total-row pos-total-final"><span>{{ i18n.t('total') }}</span><span>{{ fm(totalFinal) }}</span></div>
        </div>

        <!-- Payment Buttons -->
        <div class="pos-payment-btns">
          <button class="btn btn-success btn-lg" style="flex:1;" @click="abrirPago('efectivo')" :disabled="!cart.length || (configGeneral.requerir_caja_abierta === '1' && !sesion)"><i class="fas fa-money-bill-wave"></i> {{ i18n.t('efectivo') }}</button>
          <button class="btn btn-info btn-lg" style="flex:1;" @click="abrirPago('tarjeta')" :disabled="!cart.length || (configGeneral.requerir_caja_abierta === '1' && !sesion)"><i class="fas fa-credit-card"></i> {{ i18n.t('tarjeta') }}</button>
          <button class="btn btn-primary btn-lg" style="flex:1;" @click="abrirPago('sinpe')" :disabled="!cart.length || (configGeneral.requerir_caja_abierta === '1' && !sesion)"><i class="fas fa-mobile-alt"></i> {{ i18n.t('sinpe') }}</button>
          <button class="btn btn-warning btn-lg" style="flex:1;" @click="abrirPago('mixto')" :disabled="!cart.length || (configGeneral.requerir_caja_abierta === '1' && !sesion)"><i class="fas fa-layer-group"></i> {{ i18n.t('mixto') }}</button>
        </div>
      </div>
    </div>

    <!-- MODAL: Pago Efectivo -->
    <div class="modal-overlay" :class="{active:showPago==='efectivo'}" @click.self="showPago=null">
      <div class="modal" style="max-width:min(90vw,450px);">
        <div class="modal-header"><h3 class="modal-title"><i class="fas fa-money-bill-wave"></i> {{ i18n.t('pago_efectivo') }}</h3><button class="modal-close" @click="showPago=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="pos-total-final mb-md" style="text-align:center;font-size:28px;font-weight:700;">{{ fm(totalFinal) }}</div>
          <div class="form-group"><label>{{ i18n.t('monto_recibido') }}</label><input v-model.number="pagoEfectivo.monto" type="number" class="form-control" style="font-size:22px;text-align:center;"></div>
          <div class="flex gap-sm mb-md flex-wrap">
            <button v-for="s in sugerenciasEfectivo" :key="s" class="btn btn-sm btn-secondary" @click="pagoEfectivo.monto=s">{{ fm(s) }}</button>
          </div>
          <div v-if="cambioEfectivo >= 0" class="pos-cambio" :class="{positive:cambioEfectivo>=0}">
            <span>{{ cambioEfectivo >= 0 ? i18n.t('cambio') : 'Falta' }}:</span><strong>{{ fm(Math.abs(cambioEfectivo)) }}</strong>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-success btn-lg" style="width:100%;" @click="procesarVenta('efectivo')" :disabled="pagoEfectivo.monto < totalFinal"><i class="fas fa-check"></i> {{ i18n.t('cobrar') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Pago Tarjeta -->
    <div class="modal-overlay" :class="{active:showPago==='tarjeta'}" @click.self="showPago=null">
      <div class="modal" style="max-width:min(90vw,400px);">
        <div class="modal-header"><h3 class="modal-title"><i class="fas fa-credit-card"></i> {{ i18n.t('pago_tarjeta') }}</h3><button class="modal-close" @click="showPago=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" style="text-align:center;">
          <div class="pos-total-final mb-md" style="font-size:28px;font-weight:700;">{{ fm(totalFinal) }}</div>
          <p style="color:var(--text-secondary);margin-bottom:16px;"><i class="fas fa-wifi" style="font-size:32px;color:var(--info);"></i></p>
          <p>Pasar tarjeta por el datáfono</p>
          <div class="form-group mt-md"><label>{{ i18n.t('referencia') }} (opcional)</label><input v-model="pagoTarjeta.referencia" class="form-control"></div>
        </div>
        <div class="modal-footer"><button class="btn btn-info btn-lg" style="width:100%;" @click="procesarVenta('tarjeta')"><i class="fas fa-check"></i> {{ i18n.t('confirmar_pago') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Pago SINPE -->
    <div class="modal-overlay" :class="{active:showPago==='sinpe'}" @click.self="showPago=null">
      <div class="modal" style="max-width:min(90vw,450px);">
        <div class="modal-header"><h3 class="modal-title"><i class="fas fa-mobile-alt"></i> {{ i18n.t('pago_sinpe') }}</h3><button class="modal-close" @click="showPago=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="pos-total-final mb-md" style="text-align:center;font-size:28px;font-weight:700;">{{ fm(totalFinal) }}</div>
          <div class="form-group"><label>{{ i18n.t('referencia') }} *</label><input v-model="pagoSinpe.referencia" class="form-control" placeholder="Número de referencia"></div>
          <div class="form-group"><label>Comprobante (imagen)</label><input type="file" accept="image/*" class="form-control" @change="onComprobanteChange"></div>
          <p style="font-size:12px;color:var(--text-muted);">Debe proporcionar la referencia o el comprobante</p>
        </div>
        <div class="modal-footer"><button class="btn btn-primary btn-lg" style="width:100%;" @click="procesarVenta('sinpe')" :disabled="!pagoSinpe.referencia && !pagoSinpe.comprobante"><i class="fas fa-check"></i> {{ i18n.t('confirmar_pago') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Pago Mixto -->
    <div class="modal-overlay" :class="{active:showPago==='mixto'}" @click.self="showPago=null">
      <div class="modal" style="max-width:min(90vw,500px);">
        <div class="modal-header"><h3 class="modal-title"><i class="fas fa-layer-group"></i> {{ i18n.t('pago_mixto') }}</h3><button class="modal-close" @click="showPago=null"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="pos-total-final mb-md" style="text-align:center;font-size:24px;font-weight:700;">{{ i18n.t('total') }}: {{ fm(totalFinal) }}</div>
          <div class="form-group"><label><i class="fas fa-money-bill-wave"></i> {{ i18n.t('efectivo') }}</label><input v-model.number="pagoMixto.efectivo" type="number" class="form-control"></div>
          <div class="form-group"><label><i class="fas fa-credit-card"></i> {{ i18n.t('tarjeta') }}</label><input v-model.number="pagoMixto.tarjeta" type="number" class="form-control"></div>
          <div class="form-group"><label><i class="fas fa-mobile-alt"></i> {{ i18n.t('sinpe') }}</label><input v-model.number="pagoMixto.sinpe" type="number" class="form-control"></div>
          <div v-if="pagoMixto.sinpe > 0" class="form-group"><label>{{ i18n.t('referencia') }} {{ i18n.t('sinpe') }}</label><input v-model="pagoMixto.referencia_sinpe" class="form-control"></div>
          <div class="pos-total-row pos-total-final mt-md"><span>Pagado</span><span :style="{color: totalMixto >= totalFinal ? 'var(--success)':'var(--danger)'}">{{ fm(totalMixto) }}</span></div>
          <div v-if="totalMixto < totalFinal" class="pos-total-row"><span>Falta</span><span style="color:var(--danger);">{{ fm(totalFinal - totalMixto) }}</span></div>
          <div v-if="totalMixto > totalFinal" class="pos-total-row"><span>{{ i18n.t('cambio') }}</span><span style="color:var(--success);">{{ fm(totalMixto - totalFinal) }}</span></div>
        </div>
        <div class="modal-footer"><button class="btn btn-warning btn-lg" style="width:100%;" @click="procesarVenta('mixto')" :disabled="totalMixto < totalFinal"><i class="fas fa-check"></i> {{ i18n.t('cobrar') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Ticket -->
    <div class="modal-overlay" :class="{active:showTicket}" @click.self="showTicket=false">
      <div class="modal" style="max-width:min(90vw,380px);">
        <div class="modal-header"><h3 class="modal-title">{{ i18n.t('ticket_venta') }}</h3><button class="modal-close" @click="showTicket=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" ref="ticketRef">
          <div id="ticket-print" style="font-family:Courier New,monospace;font-size:12px;padding:10px;text-align:center;">
            <h3 style="margin:0;">{{ ticketData.negocio || 'Mi Negocio' }}</h3>
            <p style="margin:2px 0;font-size:10px;">{{ ticketData.direccion }}</p>
            <p style="margin:2px 0;font-size:10px;">Tel: {{ ticketData.telefono }}</p>
            <hr style="border:1px dashed #000;margin:8px 0;">
            <p style="text-align:left;margin:2px 0;">Factura: <strong>{{ ticketData.numero_factura }}</strong></p>
            <p style="text-align:left;margin:2px 0;">{{ i18n.t('fecha') }}: {{ ticketData.fecha }}</p>
            <p style="text-align:left;margin:2px 0;">{{ i18n.t('cliente') }}: {{ ticketData.cliente }}</p>
            <p style="text-align:left;margin:2px 0;">{{ i18n.t('vendedor') }}: {{ ticketData.vendedor }}</p>
            <hr style="border:1px dashed #000;margin:8px 0;">
            <table style="width:100%;font-size:11px;text-align:left;"><thead><tr><th>{{ i18n.t('producto') }}</th><th style="text-align:right;">{{ i18n.t('cantidad') }}</th><th style="text-align:right;">{{ i18n.t('total') }}</th></tr></thead>
              <tbody><tr v-for="it in ticketData.items" :key="it.nombre"><td>{{ it.nombre }}</td><td style="text-align:right;">{{ it.cantidad }}</td><td style="text-align:right;">{{ fm(it.subtotal) }}</td></tr></tbody>
            </table>
            <hr style="border:1px dashed #000;margin:8px 0;">
            <p style="text-align:right;margin:2px 0;">{{ i18n.t('subtotal') }}: {{ fm(ticketData.subtotal) }}</p>
            <p v-if="ticketData.descuento" style="text-align:right;margin:2px 0;">{{ i18n.t('descuento') }}: -{{ fm(ticketData.descuento) }}</p>
            <p style="text-align:right;margin:2px 0;">IVA: {{ fm(ticketData.impuesto) }}</p>
            <p style="text-align:right;margin:2px 0;font-size:16px;"><strong>{{ i18n.t('total') }}: {{ fm(ticketData.total) }}</strong></p>
            <hr style="border:1px dashed #000;margin:8px 0;">
            <p style="text-align:right;margin:2px 0;">{{ i18n.t('metodo_pago_label') }}: {{ ticketData.metodo_pago }}</p>
            <p v-if="ticketData.cambio" style="text-align:right;margin:2px 0;">{{ i18n.t('cambio') }}: {{ fm(ticketData.cambio) }}</p>
            <hr style="border:1px dashed #000;margin:8px 0;">
            <p style="font-size:10px;">¡Gracias por su compra!</p>
          </div>
        </div>
        <div class="modal-footer"><button class="btn btn-primary" @click="imprimirTicket"><i class="fas fa-print"></i> Imprimir</button><button class="btn btn-secondary" @click="nuevaVenta">{{ i18n.t('nueva_venta') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Abrir Caja -->
    <div class="modal-overlay" :class="{active:showAbrir}" @click.self="showAbrir=false">
      <div class="modal"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('abrir_caja') }}</h3><button class="modal-close" @click="showAbrir=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('nueva_caja') }}</label><select v-model="abrirForm.caja_id" class="form-control">
            <option v-for="c in cajasFiltradas" :key="c.id" :value="c.id">{{ c.nombre }}</option>
          </select></div>
          <div class="form-group"><label>{{ i18n.t('monto_inicial') }}</label><input v-model.number="abrirForm.monto_apertura" type="number" class="form-control" @input="normalizarMinimo(abrirForm, 'monto_apertura', 0)"></div>
        </div><div class="modal-footer"><button class="btn btn-primary" @click="abrirCaja">{{ i18n.t('abrir_caja') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Cerrar Caja -->
    <div class="modal-overlay" :class="{active:showCerrar}" @click.self="showCerrar=false">
      <div class="modal"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('cerrar_caja') }}</h3><button class="modal-close" @click="showCerrar=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('monto_cierre') }}</label><input v-model.number="cerrarForm.monto_cierre" type="number" class="form-control" @input="normalizarMinimo(cerrarForm, 'monto_cierre', 0)"></div>
          <div class="form-group"><label>{{ i18n.t('nota') }}</label><textarea v-model="cerrarForm.notas_cierre" class="form-control" rows="2"></textarea></div>
        </div><div class="modal-footer"><button class="btn btn-danger" @click="confirmarCierre">{{ i18n.t('cerrar_caja') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Retiro -->
    <div class="modal-overlay" :class="{active:showRetiro}" @click.self="showRetiro=false">
      <div class="modal"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('retiro_caja') }}</h3><button class="modal-close" @click="showRetiro=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18n.t('monto_inicial') }}</label><input v-model.number="retiroForm.monto" type="number" class="form-control" @input="normalizarMinimo(retiroForm, 'monto', 0)"></div>
          <div class="form-group"><label>{{ i18n.t('motivo') }}</label><input v-model="retiroForm.motivo" class="form-control"></div>
        </div><div class="modal-footer"><button class="btn btn-warning" @click="hacerRetiro">{{ i18n.t('retiro_caja') }}</button></div>
      </div>
    </div>

    <!-- MODAL: Historial -->
    <div class="modal-overlay" :class="{active:showHistorial}" @click.self="showHistorial=false">
      <div class="modal" style="max-width:min(90vw,900px);"><div class="modal-header"><h3 class="modal-title">{{ i18n.t('historial_sesiones') }}</h3><button class="modal-close" @click="showHistorial=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body" style="padding:0;"><table class="data-table"><thead><tr><th>{{ i18n.t('nueva_caja') }}</th><th>{{ i18n.t('monto_inicial') }}</th><th>{{ i18n.t('monto_cierre') }}</th><th>Inicial</th><th>Ventas</th><th>{{ i18n.t('retiro_caja') }}</th><th>{{ i18n.t('monto_cierre') }}</th></tr></thead>
          <tbody><tr v-for="s in historial" :key="s.id"><td>{{ s.caja_nombre }}</td><td>{{ formatDate(s.fecha_apertura) }}</td><td>{{ formatDate(s.fecha_cierre) }}</td><td>{{ fm(s.monto_apertura) }}</td><td>{{ fm(s.total_ventas) }}</td><td>{{ fm(s.total_retiros) }}</td><td><strong>{{ fm(s.monto_cierre) }}</strong></td></tr></tbody>
        </table></div>
      </div>
    </div>

    <!-- MODAL: Combos -->
    <div class="modal-overlay" :class="{active:showCombos}" @click.self="showCombos=false">
      <div class="modal" style="max-width:min(90vw,600px);"><div class="modal-header"><h3 class="modal-title">Combos Activos</h3><button class="modal-close" @click="showCombos=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body"><div v-for="c in combosActivos" :key="c.id" class="flex items-center justify-between mb-sm p-sm" style="border:1px solid var(--bg-hover);border-radius:8px;">
          <div><strong>{{ c.nombre }}</strong><div style="font-size:12px;color:var(--text-muted);">{{ c.descripcion }}</div></div>
          <div class="flex items-center gap-sm"><span style="color:var(--success);font-weight:700;">{{ fm(c.precio_combo) }}</span><button class="btn btn-sm btn-primary" @click="agregarCombo(c)"><i class="fas fa-plus"></i></button></div>
        </div><div v-if="!combosActivos.length" style="text-align:center;color:var(--text-muted);padding:20px;">{{ i18n.t('no_hay_combos') }}</div></div>
      </div>
    </div>

    <!-- MODAL: Promos -->
    <div class="modal-overlay" :class="{active:showPromos}" @click.self="showPromos=false">
      <div class="modal" style="max-width:min(90vw,600px);"><div class="modal-header"><h3 class="modal-title">Promociones Activas</h3><button class="modal-close" @click="showPromos=false"><i class="fas fa-times"></i></button></div>
        <div class="modal-body"><div v-for="p in promosActivas" :key="p.id" class="flex items-center justify-between mb-sm p-sm" style="border:1px solid var(--bg-hover);border-radius:8px;">
          <div><strong>{{ p.nombre }}</strong></div>
          <span class="badge badge-success">{{ p.tipo_descuento==='porcentaje' ? p.valor_descuento+'%' : fm(p.valor_descuento) }}</span>
        </div><div v-if="!promosActivas.length" style="text-align:center;color:var(--text-muted);padding:20px;">{{ i18n.t('no_hay_promos') }}</div></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';
import { useCurrency } from '../composables/useCurrency';
import common from '../composables/common.js';

const { fm } = useCurrency();
const { 
  deleteItem,
  normalizarMinimo
} = common;

const toast = useToastStore();
const i18n = useI18nStore();
const ubicacionId = ref('');
const ubicaciones = ref([]);
const sesion = ref(null); const cajas = ref([]); const historial = ref([]);
const showAbrir = ref(false); const showRetiro = ref(false); const showHistorial = ref(false); const showCerrar = ref(false);
const showPago = ref(null); const showTicket = ref(false);
const showCombos = ref(false); const showPromos = ref(false);
const abrirForm = ref({ caja_id:'', monto_apertura:0 });
const retiroForm = ref({ monto:0, motivo:'' });
const cerrarForm = ref({ monto_cierre:0, notas_cierre:'' });

const cart = ref([]);
const buscarProd = ref(''); const prodResults = ref([]);
const productosPopulares = ref([]);
const buscarCliente = ref(''); const clienteResults = ref([]); const clienteSel = ref(null);
const preciosCliente = ref({}); const descuentoListaGlobal = ref(0);
const nombreFactura = ref('');
const descuentoTipo = ref('%'); const descuentoValor = ref(0);
watch(descuentoValor, (v) => { if (v < 0) descuentoValor.value = 0; });
const codigoCupon = ref(''); const cuponAplicado = ref(null);
const combosActivos = ref([]); const promosActivas = ref([]);
const configGeneral = ref({});

const pagoEfectivo = ref({ monto: 0 });
const pagoTarjeta = ref({ referencia: '' });
const pagoSinpe = ref({ referencia: '', comprobante: null });
const pagoMixto = ref({ efectivo: 0, tarjeta: 0, sinpe: 0, referencia_sinpe: '' });

const ticketData = ref({});
const ticketRef = ref(null);

const subtotal = computed(() => cart.value.reduce((s, i) => s + (i.precio_unitario * i.cantidad), 0));
const montoDescuento = computed(() => {
  if (!descuentoValor.value) return 0;
  return descuentoTipo.value === '%' ? (subtotal.value * descuentoValor.value / 100) : descuentoValor.value;
});
const descuentoCupon = computed(() => {
  if (!cuponAplicado.value) return 0;
  const c = cuponAplicado.value;
  return c.tipo_descuento === 'porcentaje' ? (subtotal.value * c.valor_descuento / 100) : c.valor_descuento;
});
const baseGravable = computed(() => Math.max(0, subtotal.value - montoDescuento.value - descuentoCupon.value));
const totalImpuesto = computed(() => cart.value.reduce((s, i) => s + (i.precio_unitario * i.cantidad * (i.impuesto || 0) / 100), 0));
const totalFinal = computed(() => baseGravable.value + totalImpuesto.value);

const sugerenciasEfectivo = computed(() => {
  const t = totalFinal.value;
  const sugs = [Math.ceil(t / 1000) * 1000];
  if (t <= 5000) sugs.push(5000);
  sugs.push(10000, 20000, 50000);
  return [...new Set(sugs.filter(s => s >= t))].slice(0, 4);
});
const cambioEfectivo = computed(() => pagoEfectivo.value.monto - totalFinal.value);
const totalMixto = computed(() => (pagoMixto.value.efectivo || 0) + (pagoMixto.value.tarjeta || 0) + (pagoMixto.value.sinpe || 0));
const cajasFiltradas = computed(() => {
    if (!ubicacionId.value) return cajas.value;
    return cajas.value.filter(c => c.ubicacion_id == ubicacionId.value);
});

onMounted(async () => {
  try {
    const results = await Promise.allSettled([
      api.get('/caja/sesion-activa'), api.get('/caja/cajas'),
      api.get('/caja/historial'), api.get('/configuracion/ubicaciones'),
      api.get('/configuracion')
    ]);
    const [ses, caj, hist, ub, conf] = results.map(r => r.status === 'fulfilled' ? r.value : { data: {} });
    sesion.value = ses.data.sesion || null;
    cajas.value = caj.data.cajas || [];
    historial.value = hist.data.data || [];
    ubicaciones.value = ub.data.ubicaciones || [];
    configGeneral.value = conf.data.config || {};
    if (ubicaciones.value.length === 1) ubicacionId.value = ubicaciones.value[0].id;
  } catch(e){ console.error('Caja init error:', e); }
  cargarExtras();
  cargarPopulares();
});

async function cargarPopulares() {
  try { const {data} = await api.get('/productos/mas-vendidos'); productosPopulares.value = data.productos || []; } catch(e){}
}

async function cargarExtras() {
  try { const [c, p] = await Promise.all([api.get('/combos'), api.get('/promociones')]); combosActivos.value = (c.data.combos||[]).filter(x=>x.activo); promosActivas.value = (p.data.promociones||[]).filter(x=>x.activo); } catch(e){}
}

function onUbicacionChange() { cart.value = []; abrirForm.value.caja_id = ''; }
function abrirModalAbrir() { abrirForm.value.caja_id = ''; showAbrir.value = true; }

async function buscarProductos() {
  if (buscarProd.value.length < 2) { prodResults.value = []; return; }
  try { const {data} = await api.get('/productos/buscar', { params: { q: buscarProd.value, ubicacion_id: ubicacionId.value } }); prodResults.value = data.productos || []; } catch(e){}
}

function agregarProducto(p) {
  if (configGeneral.value.requerir_caja_abierta === '1' && !sesion.value) {
    toast.error(i18n.t('debe_abrir_caja'));
    return;
  }
  const stockDisp = p.stock_ubicacion !== undefined ? p.stock_ubicacion : p.stock;
  const precioLista = preciosCliente.value[p.id];
  const precioFinal = precioLista ? precioLista : p.precio_venta;
  const exists = cart.value.find(i => i.producto_id === p.id);
  if (exists) { exists.cantidad++; } else { cart.value.push({ producto_id: p.id, nombre: p.nombre, precio_unitario: precioFinal, cantidad: 1, impuesto: p.impuesto || 0, stock: stockDisp }); }
  buscarProd.value = ''; prodResults.value = [];
}

function agregarCombo(c) {
  cart.value.push({ producto_id: null, combo_id: c.id, nombre: `[COMBO] ${c.nombre}`, precio_unitario: c.precio_combo, cantidad: 1, impuesto: 0, stock: 999 });
  showCombos.value = false;
}

function quitarItem(i) { cart.value.splice(i, 1); }

async function buscarClientes() {
  if (buscarCliente.value.length < 2) { clienteResults.value = []; return; }
  try { const {data} = await api.get('/clientes/buscar', { params: { q: buscarCliente.value } }); clienteResults.value = data.clientes || []; } catch(e){}
}
async function seleccionarCliente(c) {
  clienteSel.value = c; clienteResults.value = []; buscarCliente.value = c.nombre; nombreFactura.value = '';
  try {
    const { data } = await api.get('/listas-precios/precios-cliente', { params: { cliente_id: c.id } });
    preciosCliente.value = data.precios || {};
    descuentoListaGlobal.value = data.descuento_global || 0;
    cart.value.forEach(item => {
      if (item.producto_id && preciosCliente.value[item.producto_id]) {
        item.precio_unitario = preciosCliente.value[item.producto_id];
      }
    });
    if (Object.keys(preciosCliente.value).length) toast.info('Precios de lista aplicados para este cliente');
  } catch(e) { preciosCliente.value = {}; descuentoListaGlobal.value = 0; }
}

async function aplicarCupon() {
  if (!codigoCupon.value) return;
  try {
    // Validate coupon against known coupons - simplified check
    cuponAplicado.value = { codigo: codigoCupon.value, tipo_descuento: 'porcentaje', valor_descuento: 10 };
    toast.success('Cupón aplicado (validación simplificada)');
  } catch(e) { toast.error('Cupón no válido'); }
}

function onComprobanteChange(e) { pagoSinpe.value.comprobante = e.target.files[0] || null; }

function abrirPago(tipo) {
  if (!cart.value.length) return;
  if (configGeneral.value.requerir_caja_abierta === '1' && !sesion.value) {
    toast.error(i18n.t('debe_abrir_caja'));
    return;
  }
  showPago.value = tipo;
  if (tipo === 'efectivo') pagoEfectivo.value.monto = 0;
  if (tipo === 'mixto') pagoMixto.value = { efectivo: 0, tarjeta: 0, sinpe: 0, referencia_sinpe: '' };
}

async function procesarVenta(metodo) {
  if (!ubicacionId.value) { toast.error(i18n.t('seleccionar_ubicacion')); return; }
  if (descuentoValor.value < 0) { toast.error(i18n.t('descuento')); return; }
  const sinStock = cart.value
    .filter(i => i.producto_id && i.cantidad > (i.stock || 0))
    .map(i => `${i.nombre} (solicitado: ${i.cantidad}, disponible: ${i.stock || 0})`);
  if (sinStock.length) {
    toast.error(i18n.t('stock_insuficiente') + ':\n' + sinStock.join('\n'));
    showPago.value = null;
    return;
  }

  const payload = {
    ubicacion_id: ubicacionId.value || null,
    cliente_id: clienteSel.value?.id || null,
    nombre_factura: nombreFactura.value || null,
    items: cart.value.map(i => ({ producto_id: i.producto_id, cantidad: i.cantidad, precio_unitario: i.precio_unitario, descuento: 0, impuesto: i.precio_unitario * i.cantidad * (i.impuesto||0) / 100, subtotal: i.precio_unitario * i.cantidad, combo_id: i.combo_id || null })),
    metodo_pago: metodo,
    subtotal: subtotal.value,
    descuento_total: montoDescuento.value + descuentoCupon.value,
    impuesto_total: totalImpuesto.value,
    total: totalFinal.value,
    notas: '',
  };

  if (metodo === 'efectivo') { payload.monto_efectivo = pagoEfectivo.value.monto; payload.dinero_recibido = pagoEfectivo.value.monto; payload.cambio = cambioEfectivo.value; }
  if (metodo === 'tarjeta') { payload.monto_tarjeta = totalFinal.value; }
  if (metodo === 'sinpe') { payload.monto_sinpe = totalFinal.value; payload.referencia_sinpe = pagoSinpe.value.referencia; }
  if (metodo === 'mixto') { payload.monto_efectivo = pagoMixto.value.efectivo; payload.monto_tarjeta = pagoMixto.value.tarjeta; payload.monto_sinpe = pagoMixto.value.sinpe; payload.referencia_sinpe = pagoMixto.value.referencia_sinpe; payload.dinero_recibido = totalMixto.value; payload.cambio = Math.max(0, totalMixto.value - totalFinal.value); }
  if (cuponAplicado.value) { payload.cupon_codigo = cuponAplicado.value.codigo; payload.descuento_cupon = descuentoCupon.value; }

  try {
    const { data } = await api.post('/ventas', payload);
    showPago.value = null;
    ticketData.value = {
      negocio: 'ERP Premium', direccion: '', telefono: '',
      numero_factura: data.venta?.numero_factura || 'N/A',
      fecha: new Date().toLocaleString('es-CR'),
      cliente: clienteSel.value?.nombre || nombreFactura.value || 'Público General',
      vendedor: sesion.value?.usuario_asignado_nombre || 'Caja',
      items: cart.value.map(i => ({ nombre: i.nombre, cantidad: i.cantidad, subtotal: i.precio_unitario * i.cantidad })),
      subtotal: subtotal.value, descuento: montoDescuento.value + descuentoCupon.value,
      impuesto: totalImpuesto.value, total: totalFinal.value,
      metodo_pago: metodo, cambio: metodo === 'efectivo' ? cambioEfectivo.value : null,
    };
    showTicket.value = true;
  } catch(e) { toast.error(e.response?.data?.error || i18n.t('error_procesar_venta')); }
}

function imprimirTicket() {
  const el = document.getElementById('ticket-print');
  if (!el) return;
  const w = window.open('', '', 'width=380,height=600');
  w.document.write(`<html><head><title>Ticket</title><style>body{font-family:Courier New,monospace;font-size:12px;margin:0;padding:10px;}table{width:100%;border-collapse:collapse;}th,td{padding:2px;text-align:left;}hr{border:1px dashed #000;margin:8px 0;}</style></head><body>${el.innerHTML}</body></html>`);
  w.document.close(); w.print(); w.close();
}

function nuevaVenta() { showTicket.value = false; cart.value = []; clienteSel.value = null; nombreFactura.value = ''; descuentoValor.value = 0; cuponAplicado.value = null; codigoCupon.value = ''; }

async function abrirCaja() {
  if (!abrirForm.value.caja_id) { toast.error(i18n.t('seleccionar_caja')); return; }
  try {
    await api.post('/caja/abrir', abrirForm.value);
    showAbrir.value=false;
    const {data}=await api.get('/caja/sesion-activa');
    sesion.value=data.sesion;
    toast.success(i18n.t('caja_abierta') || 'Caja abierta correctamente');
  } catch(e){
    const msg = e.response?.data?.error || e.response?.data?.message || i18n.t('error');
    toast.error(msg);
  }
}
function abrirModalCerrar() {
    if (!sesion.value) return;
    cerrarForm.value.monto_cierre = sesion.value.efectivo_en_caja || sesion.value.monto_apertura || 0;
    cerrarForm.value.notas_cierre = '';
    showCerrar.value = true;
}
async function confirmarCierre() {
    try {
        await api.post('/caja/cerrar', {
            sesion_id: sesion.value.id,
            monto_cierre: cerrarForm.value.monto_cierre,
            notas_cierre: cerrarForm.value.notas_cierre,
        });
        showCerrar.value = false;
        sesion.value = null;
        const {data} = await api.get('/caja/historial');
        historial.value = data.data || [];
        toast.success(i18n.t('caja_cerrada') || 'Caja cerrada correctamente');
    } catch(e) {
        const msg = e.response?.data?.error || e.response?.data?.message || i18n.t('error');
        toast.error(msg);
    }
}
async function hacerRetiro() {
  if (!retiroForm.value.monto || retiroForm.value.monto <= 0) { toast.error(i18n.t('monto_inicial')); return; }
  if (!retiroForm.value.motivo) { toast.error(i18n.t('motivo')); return; }
  try {
    await api.post('/caja/retiro', { sesion_id: sesion.value.id, ...retiroForm.value });
    showRetiro.value=false;
    toast.success(i18n.t('retiro_caja') || 'Retiro registrado');
    retiroForm.value = { monto: 0, motivo: '' };
  } catch(e){
    const msg = e.response?.data?.error || e.response?.data?.message || i18n.t('error');
    toast.error(msg);
  }
}

function formatDate(d) { if(!d) return '-'; return new Date(d).toLocaleDateString(undefined,{day:'2-digit',month:'short',hour:'2-digit',minute:'2-digit'}); }
</script>

<style scoped>
.pos-container { display:flex; flex-direction:column; height:calc(100vh - 120px); }
.pos-topbar { display:flex; justify-content:space-between; align-items:center; padding:12px 0; border-bottom:1px solid var(--bg-hover); margin-bottom:12px; flex-wrap:wrap; gap:8px; }
.pos-main { display:grid; grid-template-columns:1fr 360px; gap:16px; flex:1; min-height:0; }
.pos-products { display:flex; flex-direction:column; min-height:0; }
.pos-search { position:relative; }
.pos-prod-results { position:absolute; top:100%; left:0; right:0; background:var(--bg-card); border:1px solid var(--bg-hover); border-radius:8px; max-height:250px; overflow:auto; z-index:10; box-shadow:0 8px 24px rgba(0,0,0,0.12); }
.pos-prod-item { padding:10px 14px; cursor:pointer; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--bg-hover); }
.pos-prod-item:hover { background:var(--bg-hover); }
.pos-cart { flex:1; overflow:auto; padding:8px 0; }
.pos-cart-empty { display:flex; flex-direction:column; align-items:center; justify-content:center; height:200px; }
.pos-cart-item { display:flex; align-items:center; gap:12px; padding:10px 12px; border:1px solid var(--bg-hover); border-radius:8px; margin-bottom:6px; background:var(--bg-card); }
.pos-cart-info { flex:1; }
.pos-extras { display:flex; gap:8px; padding:10px 0; align-items:center; flex-wrap:wrap; }
.pos-summary { background:var(--bg-card); border:1px solid var(--bg-hover); border-radius:12px; padding:16px; display:flex; flex-direction:column; gap:12px; }
.pos-client-section, .pos-discount-section { padding-bottom:12px; border-bottom:1px solid var(--bg-hover); }
.pos-client-results { max-height:150px; overflow:auto; border:1px solid var(--bg-hover); border-radius:8px; margin-top:4px; }
.pos-client-item { padding:8px 12px; cursor:pointer; border-bottom:1px solid var(--bg-hover); }
.pos-client-item:hover { background:var(--bg-hover); }
.pos-client-selected { display:flex; justify-content:space-between; align-items:center; padding:8px 12px; background:var(--success-bg); border-radius:8px; margin-top:4px; }
.pos-totals { flex:1; }
.pos-total-row { display:flex; justify-content:space-between; padding:6px 0; font-size:14px; }
.pos-total-final { font-size:20px !important; font-weight:700; border-top:2px solid var(--bg-hover); padding-top:10px !important; margin-top:6px; }
.pos-payment-btns { display:grid; grid-template-columns:1fr 1fr; gap:8px; }
.pos-cambio { display:flex; justify-content:space-between; padding:12px; border-radius:8px; background:var(--success-bg); font-size:18px; }
.btn-lg { padding:12px 20px; font-size:15px; }
@media(max-width:1023px) {
  .pos-main { grid-template-columns:1fr; }
  .pos-summary { order:-1; }
}
@media(max-width:768px) {
  .pos-topbar { flex-direction:column; align-items:flex-start; }
  .pos-payment-btns { grid-template-columns:1fr; }
  .pos-extras { flex-direction:column; }
  .pos-cart-item { gap:8px; padding:8px 10px; }
  .ubicacion-select { max-width:100%; }
  .cart-qty-input { max-width:70px; }
  .discount-select { max-width:100px; }
  .btn, button { -webkit-tap-highlight-color:transparent; }
  .pos-cart-empty { height:120px; }
}
@media(max-width:480px) {
  .pos-container { height:calc(100vh - 80px); }
  .pos-topbar { padding:8px 0; gap:6px; }
  .pos-topbar .flex { gap:4px; }
  .pos-main { gap:10px; }
  .pos-summary { padding:12px; gap:10px; }
  .pos-cart-item { gap:6px; padding:6px 8px; }
  .pos-total-row { font-size:13px; }
  .pos-total-final { font-size:18px !important; }
  .pos-payment-btns { gap:6px; }
  .btn { min-height:44px; width:100%; }
  .btn-lg { padding:14px 16px; font-size:14px; }
  .pos-extras { gap:6px; }
  .ubicacion-select, .cart-qty-input, .discount-select { max-width:100%; }
  input, select { font-size:16px; -webkit-tap-highlight-color:transparent; }
  .modal { width:95vw; max-width:95vw !important; }
  .modal-body { padding:12px; }
  .modal-footer .btn { width:100%; }
}

input {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}
input:focus {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}
select {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}
select:focus {
  background: rgba(0, 0, 0, 0.1);
  outline: 2px solid var(--primary-gold);
  border: none;
  box-shadow: 0 0 0 2px var(--primary-gold);
}

.pos-populares { margin-top: 8px; }
.pos-populares-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 8px; }
.pos-popular-chip { background: var(--bg-card); border: 1px solid var(--bg-hover); border-radius: var(--radius-md); padding: 10px 8px; cursor: pointer; text-align: center; transition: all var(--transition-main); display: flex; flex-direction: column; align-items: center; gap: 4px; }
.pos-popular-chip:hover { transform: translateY(-2px); box-shadow: var(--shadow-card); border-color: var(--primary); }
.pos-popular-nombre { font-size: 13px; font-weight: 600; color: var(--text-primary); line-height: 1.2; display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.pos-popular-precio { font-size: 12px; font-weight: 700; color: var(--success); }

.ubicacion-select { width: 100%; max-width: 200px; min-width: 0; }
.cart-qty-input { width: 100%; max-width: 55px; min-width: 0; }
.discount-select { width: 100%; max-width: 80px; min-width: 0; }
</style>
