<template>
  <div>
    <div class="flex gap-sm mb-lg" style="flex-wrap:wrap;">
      <button :class="['btn', tab === 'empresa' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'empresa'">{{
        i18nStore.t('config_empresa') }}</button>
      <button :class="['btn', tab === 'ubicaciones' ? 'btn-primary' : 'btn-secondary']"
        @click="tab = 'ubicaciones'; cargarUbicaciones()">{{ i18nStore.t('config_ubicaciones') }}</button>
      <button :class="['btn', tab === 'cajas' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'cajas'; cargarCajas()">{{
        i18nStore.t('config_cajas') }}</button>
      <button :class="['btn', tab === 'categorias' ? 'btn-primary' : 'btn-secondary']"
        @click="tab = 'categorias'; cargarCategorias()">{{ i18nStore.t('config_categorias') }}</button>
      <button :class="['btn', tab === 'cliente-categorias' ? 'btn-primary' : 'btn-secondary']"
        @click="tab = 'cliente-categorias'; cargarClienteCategorias()"><i class="fas fa-users"></i> {{
          i18nStore.t('config_cliente_cat') }}</button>
      <button :class="['btn', tab === 'idioma' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'idioma'"><i
          class="fas fa-globe"></i> {{ i18nStore.t('config_idioma') }}</button>
      <button :class="['btn', tab === 'general' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'general'; cargarConfig()">{{
        i18nStore.t('config_general') }}</button>
      <button :class="['btn', tab === 'chats' ? 'btn-primary' : 'btn-secondary']"
        @click="tab = 'chats'; cargarRetencionChats()"><i class="fas fa-comments"></i> {{ i18nStore.t('config_chats')
        }}</button>
      <button :class="['btn', tab === 'webapi' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'webapi'; cargarConfigWeb()"><i
          class="fas fa-globe"></i> {{ i18nStore.t('config_webapi') }}</button>
      <button :class="['btn', tab === 'smtp' ? 'btn-primary' : 'btn-secondary']" @click="tab = 'smtp'; cargarSmtp()"><i
          class="fas fa-envelope"></i> SMTP / Email</button>
    </div>

    <!-- Empresa -->
    <div v-if="tab === 'empresa'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-building"></i> {{ i18nStore.t('config_empresa') }}</h3>
      </div>
      <div class="card-body">
        <div class="grid-2 gap-md">
          <div class="form-group"><label>{{ i18nStore.t('nombre_negocio') }}</label><input
              v-model="empresa.nombre_negocio" class="form-control"></div>
          <div class="form-group"><label>Cédula Jurídica</label><input v-model="empresa.cedula_juridica"
              class="form-control"></div>
          <div class="form-group"><label>{{ i18nStore.t('telefono_label') }}</label><input v-model="empresa.telefono"
              class="form-control"></div>
          <div class="form-group"><label>Email</label><input v-model="empresa.email_negocio" class="form-control"
              type="email"></div>
          <div class="form-group"><label>Email Remitente (para campañas)</label><input v-model="empresa.email_remitente"
              class="form-control" type="email" placeholder="noreply@tunegocio.com"></div>
          <div class="form-group"><label>{{ i18nStore.t('direccion_label') }}</label><input v-model="empresa.direccion"
              class="form-control"></div>
          <div class="form-group"><label>Website</label><input v-model="empresa.website" class="form-control"></div>
          <div class="form-group"><label>{{ i18nStore.t('moneda_label') }}</label><input v-model="empresa.moneda"
              class="form-control" placeholder="CRC"></div>
          <div class="form-group"><label>{{ i18nStore.t('simbolo') }}</label><input v-model="empresa.simbolo_moneda"
              class="form-control" placeholder="₡"></div>
          <div class="form-group"><label>Impuesto Default (%)</label><input v-model="empresa.impuesto_default"
              type="number" class="form-control"></div>
          <div class="form-group"><label>SINPE Número</label><input v-model="empresa.sinpe_numero" class="form-control">
          </div>
        </div>
        <div class="form-group"><label>Pie de Ticket</label><textarea v-model="empresa.ticket_footer"
            class="form-control" rows="2"></textarea></div>
        <button class="btn btn-primary mt-md" @click="guardarEmpresa" :disabled="isSubmitting"><i v-if="isSubmitting"
            class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
            v-else>{{ i18nStore.t('guardar') }}</span></button>
      </div>
    </div>

    <!-- Ubicaciones -->
    <div v-if="tab === 'ubicaciones'">
      <div class="flex justify-between align-center mb-md">
        <div class="search-bar">
          <i class="fas fa-search search-icon"></i>
          <input v-model="filtroUbicaciones.q" class="search-input"
            :placeholder="i18nStore.t('config_ubicaciones') + '...'">
          <select v-model="filtroUbicaciones.tipo" class="search-select">
            <option value="">{{ i18nStore.t('seleccionar') }}</option>
            <option value="sucursal">{{ i18nStore.t('sucursal') }}</option>
            <option value="bodega">{{ i18nStore.t('bodega') }}</option>
            <option value="almacen">{{ i18nStore.t('almacen') }}</option>
          </select>
          <select v-model="filtroUbicaciones.estado" class="search-select">
            <option value="">{{ i18nStore.t('seleccionar') }}</option>
            <option value="activo">{{ i18nStore.t('activo') }}</option>
            <option value="inactivo">{{ i18nStore.t('inactivo') }}</option>
          </select>
          <span v-if="ubicacionesFiltradas.length !== ubicaciones.length" class="search-badge">{{
            ubicacionesFiltradas.length }} resultado{{ ubicacionesFiltradas.length === 1 ? '' : 's' }}</span>
        </div>
        <button class="btn btn-primary" @click="abrirModalUbicacion()"><i class="fas fa-plus"></i> {{
          i18nStore.t('crear') }} {{ i18nStore.t('config_ubicaciones') }}</button>
      </div>
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18nStore.t('nombre') }}</th>
                <th>{{ i18nStore.t('ubicacion_tipo') }}</th>
                <th>{{ i18nStore.t('direccion_label') }}</th>
                <th>{{ i18nStore.t('telefono_label') }}</th>
                <th>{{ i18nStore.t('responsable') }}</th>
                <th>{{ i18nStore.t('config_ubicaciones') }}</th>
                <th>Principal</th>
                <th>{{ i18nStore.t('estado') }}</th>
                <th>{{ i18nStore.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="u in ubicacionesFiltradas" :key="u.id">
                <td><strong>{{ u.nombre }}</strong></td>
                <td>{{ u.tipo }}</td>
                <td>{{ u.direccion || '-' }}</td>
                <td>{{ u.telefono || '-' }}</td>
                <td>{{ u.responsable || '-' }}</td>
                <td><span v-if="u.lat && u.lng" class="badge badge-info"><i class="fas fa-map-marker-alt"></i> {{
                    formatCoord(u.lat) }}, {{ formatCoord(u.lng) }}</span><span v-else class="badge badge-warning">Sin
                    coordenadas</span></td>
                <td>{{ u.es_principal ? 'Sí' : 'No' }}</td>
                <td><span :class="['badge', u.activo ? 'badge-success' : 'badge-danger']">{{
                  u.activo ? i18nStore.t('activo') : i18nStore.t('inactivo') }}</span></td>
                <td><button class="btn btn-sm btn-ghost" @click="abrirModalUbicacion(u)"><i
                      class="fas fa-edit"></i></button></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Cajas -->
    <div v-if="tab === 'cajas'">
      <div class="flex justify-between align-center mb-md">
        <div class="search-bar">
          <i class="fas fa-search search-icon"></i>
          <input v-model="filtroCajas.q" class="search-input" :placeholder="i18nStore.t('config_cajas') + '...'">
          <select v-model="filtroCajas.estado" class="search-select">
            <option value="">{{ i18nStore.t('seleccionar') }}</option>
            <option value="activo">{{ i18nStore.t('activo') }}</option>
            <option value="inactivo">{{ i18nStore.t('inactivo') }}</option>
          </select>
          <span v-if="cajasFiltradas.length !== cajas.length" class="search-badge">{{ cajasFiltradas.length }}
            resultado{{ cajasFiltradas.length === 1 ? '' : 's' }}</span>
        </div>
        <button class="btn btn-primary" @click="abrirModalCaja()"><i class="fas fa-plus"></i> {{ i18nStore.t('crear') }}
          {{ i18nStore.t('config_cajas') }}</button>
      </div>
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>{{ i18nStore.t('nombre') }}</th>
                <th>{{ i18nStore.t('config_ubicaciones') }}</th>
                <th>Usuario Asignado</th>
                <th>{{ i18nStore.t('estado') }}</th>
                <th>{{ i18nStore.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in cajasFiltradas" :key="c.id">
                <td><strong>{{ c.nombre }}</strong></td>
                <td>{{ c.ubicacion_nombre || '-' }}</td>
                <td>{{ c.usuario_nombre || '—' }}</td>
                <td><span :class="['badge', c.activo ? 'badge-success' : 'badge-danger']">{{
                  c.activo ? i18nStore.t('activo') : i18nStore.t('inactivo') }}</span></td>
                <td><button class="btn btn-sm btn-ghost" @click="abrirModalCaja(c)"><i class="fas fa-edit"></i></button>
                </td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Categorías -->
    <div v-if="tab === 'categorias'">
      <div class="flex justify-end mb-md"><button class="btn btn-primary" @click="abrirModalCategoria()"><i
            class="fas fa-plus"></i> {{ i18nStore.t('crear') }} {{ i18nStore.t('config_categorias') }}</button></div>
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Color</th>
                <th>{{ i18nStore.t('nombre') }}</th>
                <th>{{ i18nStore.t('descripcion') }}</th>
                <th>{{ i18nStore.t('estado') }}</th>
                <th>{{ i18nStore.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in categorias" :key="c.id">
                <td><span class="color-dot" :style="{ backgroundColor: c.color || '#3b82f6' }"></span></td>
                <td><strong>{{ c.nombre }}</strong></td>
                <td>{{ c.descripcion || '-' }}</td>
                <td><span :class="['badge', c.activo ? 'badge-success' : 'badge-danger']">{{
                  c.activo ? i18nStore.t('activo') : i18nStore.t('inactivo') }}</span></td>
                <td><button class="btn btn-sm btn-ghost" @click="abrirModalCategoria(c)"><i
                      class="fas fa-edit"></i></button></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Categorías de Clientes -->
    <div v-if="tab === 'cliente-categorias'">
      <div class="flex justify-end mb-md"><button class="btn btn-primary" @click="abrirModalClienteCategoria()"><i
            class="fas fa-plus"></i> {{ i18nStore.t('crear') }} {{ i18nStore.t('config_cliente_cat') }}</button></div>
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Color</th>
                <th>{{ i18nStore.t('nombre') }}</th>
                <th>{{ i18nStore.t('descripcion') }}</th>
                <th>{{ i18nStore.t('estado') }}</th>
                <th>{{ i18nStore.t('acciones') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="c in clienteCategorias" :key="c.id">
                <td><span class="color-dot" :style="{ backgroundColor: c.color || '#3b82f6' }"></span></td>
                <td><strong>{{ c.nombre }}</strong></td>
                <td>{{ c.descripcion || '-' }}</td>
                <td><span :class="['badge', c.activo ? 'badge-success' : 'badge-danger']">{{
                  c.activo ? i18nStore.t('activo') : i18nStore.t('inactivo') }}</span></td>
                <td><button class="btn btn-sm btn-ghost" @click="abrirModalClienteCategoria(c)"><i
                      class="fas fa-edit"></i></button></td>
              </tr>
            </tbody>
          </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Web / API -->
    <div v-if="tab === 'webapi'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-globe"></i> {{ i18nStore.t('config_webapi') }}</h3>
      </div>
      <div class="card-body">
        <div class="grid-2 gap-md">
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;"><i class="fas fa-link"></i> URL Base del
              Webhook</label>
            <input v-model="webhookUrl" class="form-control" placeholder="https://mi-dominio.com">
            <p style="font-size:12px;color:var(--text-muted);margin-top:4px;">URL pública donde se recibirán los leads.
              Deja vacío para usar la URL actual del sistema.</p>
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;"><i class="fas fa-toggle-on"></i> {{
              i18nStore.t('estado') }} de la API de Leads</label>
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer;margin-top:8px;">
              <input v-model="apiActiva" type="checkbox" true-value="1" false-value="0" style="width:18px;height:18px;">
              <span :class="['badge', apiActiva === '1' || apiActiva === true ? 'badge-success' : 'badge-danger']">{{
                apiActiva === '1' || apiActiva === true ? i18nStore.t('activo') : i18nStore.t('inactivo') }}</span>
            </label>
            <p style="font-size:12px;color:var(--text-muted);margin-top:4px;">Si está inactiva, los formularios externos
              no podrán enviar leads.</p>
          </div>
        </div>
        <button class="btn btn-primary mt-md" @click="guardarConfigWeb" :disabled="isSubmitting"><i v-if="isSubmitting"
            class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
            v-else>{{ i18nStore.t('guardar') }}</span></button>
      </div>
    </div>

    <!-- General -->
    <div v-if="tab === 'general'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-cogs"></i> {{ i18nStore.t('config_general') }}</h3>
      </div>
      <div class="card-body">
        <div class="grid-2 gap-md">
          <div v-for="(val, key) in config" :key="key" v-show="key !== 'requerir_caja_abierta'" class="form-group">
            <label>{{ key }}</label>
            <input v-model="config[key]" class="form-control">
          </div>
        </div>
        <div class="form-group mt-md" style="border-top:1px solid var(--bg-hover);padding-top:16px;">
          <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:600;">
            <input v-model="config.requerir_caja_abierta" type="checkbox" true-value="1" false-value="0"
              style="width:20px;height:20px;">
            Requerir caja abierta para usar la Caja Rápida
          </label>
          <p style="font-size:13px;color:var(--text-muted);margin-top:6px;margin-left:28px;">Si está activo, no se
            podrán realizar ventas desde la Caja Rápida a menos que el usuario tenga una sesión de caja abierta.</p>
        </div>
        <button class="btn btn-primary mt-md" @click="guardarConfig" :disabled="isSubmitting"><i v-if="isSubmitting"
            class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
            v-else>{{ i18nStore.t('guardar') }}</span></button>
      </div>
    </div>

    <!-- Chats -->
    <div v-if="tab === 'chats'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-broom"></i> {{ i18nStore.t('config_chats') }}</h3>
      </div>
      <div class="card-body">
        <div class="grid-2 gap-md">
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:8px;display:block;"><i class="fas fa-clock"></i> Retención de
              datos de chats</label>
            <select v-model="chatRetencion" class="form-control" @change="guardarRetencionChats">
              <option value="never">{{ i18nStore.t('nunca_borrar') }}</option>
              <option value="3m">{{ i18nStore.t('borrar_mensajes', { n: 3 }) }}</option>
              <option value="6m">{{ i18nStore.t('borrar_mensajes', { n: 6 }) }}</option>
              <option value="1y">{{ i18nStore.t('borrar_mensajes', { n: 12 }) }}</option>
              <option value="2y">{{ i18nStore.t('borrar_mensajes', { n: 24 }) }}</option>
            </select>
            <p style="font-size:13px;color:var(--text-muted);margin-top:6px;">Los chats vacíos (sin mensajes) también se
              eliminarán al ejecutar la limpieza automática o manual.</p>
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:8px;display:block;"><i class="fas fa-chart-bar"></i> Uso
              actual</label>
            <div style="background:var(--bg-tertiary);border-radius:8px;padding:12px;">
              <div class="flex justify-between" style="margin-bottom:6px;"><span>{{ i18nStore.t('config_chats') }}
                  activos:</span><strong>{{ chatStats.total_chats }}</strong></div>
              <div class="flex justify-between" style="margin-bottom:6px;"><span>Mensajes totales:</span><strong>{{
                chatStats.total_mensajes }}</strong></div>
              <div class="flex justify-between"><span>Archivos adjuntos:</span><strong>{{ chatStats.total_archivos
                  }}</strong></div>
            </div>
          </div>
        </div>
        <div style="margin-top:20px;padding-top:16px;border-top:1px solid var(--bg-hover);">
          <label style="font-weight:600;display:block;margin-bottom:8px;"><i class="fas fa-exclamation-triangle"
              style="color:var(--warning);"></i> {{ i18nStore.t('acciones') }}</label>
          <div class="flex gap-sm" style="flex-wrap:wrap;align-items:center;">
            <button class="btn btn-danger" @click="limpiarChats('retencion')"
              :disabled="isSubmitting || chatRetencion === 'never'">
              <i class="fas fa-broom"></i> Borrar según retención
            </button>
            <button class="btn btn-danger" @click="limpiarChats('all')" :disabled="isSubmitting">
              <i class="fas fa-trash-alt"></i> Borrar TODO ahora
            </button>
          </div>
          <p style="font-size:12px;color:var(--text-muted);margin-top:8px;"><i class="fas fa-info-circle"></i> "Borrar
            según retención" elimina mensajes y archivos anteriores al período configurado. "Borrar TODO ahora" elimina
            <strong>todos</strong> los mensajes, chats y archivos sin importar la fecha.</p>
        </div>
      </div>
    </div>

    <!-- Idioma y Divisa -->
    <div v-if="tab === 'idioma'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-globe"></i> {{ i18nStore.t('config_idioma') }}</h3>
      </div>
      <div class="card-body">
        <div class="grid-2 gap-md">
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:8px;display:block;"><i class="fas fa-language"></i> Idioma del
              Sistema</label>
            <div class="flex gap-sm">
              <button :class="['btn', i18nStore.locale === 'es' ? 'btn-primary' : 'btn-secondary']"
                @click="cambiarIdioma('es')"><img src="https://flagcdn.com/w20/cr.png"
                  style="margin-right:6px;vertical-align:middle;" alt="ES"> Español</button>
              <button :class="['btn', i18nStore.locale === 'en' ? 'btn-primary' : 'btn-secondary']"
                @click="cambiarIdioma('en')"><img src="https://flagcdn.com/w20/us.png"
                  style="margin-right:6px;vertical-align:middle;" alt="EN"> English</button>
            </div>
            <p style="font-size:12px;color:var(--text-muted);margin-top:8px;">{{ i18nStore.locale === 'es' ? 'El cambio de idioma se aplica inmediatamente en la interfaz.' : 'Language change applies immediately across the interface.' }}</p>
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:8px;display:block;"><i class="fas fa-coins"></i> Divisa
              Principal</label>
            <div class="flex gap-sm">
              <button v-for="d in currencyStore.divisasDisponibles" :key="d.codigo"
                :class="['btn', currencyStore.divisa === d.codigo ? 'btn-primary' : 'btn-secondary']"
                @click="cambiarDivisa(d.codigo)">{{ d.simbolo }} {{ d.codigo }}</button>
            </div>
            <p style="font-size:12px;color:var(--text-muted);margin-top:8px;">{{ i18nStore.locale === 'es' ? 'Todos los montos del sistema se mostrarán en la divisa seleccionada.' : 'All amounts in the system will be shown in the selected currency.' }}</p>
          </div>
        </div>
        <div style="margin-top:24px;padding:16px;background:var(--bg-tertiary);border-radius:10px;">
          <h4 style="margin:0 0 12px;font-size:14px;"><i class="fas fa-exchange-alt"></i> Tasas de Cambio (base CRC)
          </h4>
          <div class="grid-2 gap-md">
            <div class="form-group"><label>1 USD = CRC</label><input v-model.number="tasaUSD" type="number" min="0"
                step="0.01" class="form-control"></div>
            <div class="form-group"><label>1 EUR = CRC</label><input v-model.number="tasaEUR" type="number" min="0"
                step="0.01" class="form-control"></div>
          </div>
          <button class="btn btn-primary mt-md" @click="guardarTasas"><i class="fas fa-save"></i> {{
            i18nStore.t('guardar') }} Tasas</button>
        </div>
      </div>
    </div>

    <!-- SMTP / Email -->
    <div v-if="tab === 'smtp'" class="card">
      <div class="card-header">
        <h3 class="card-title"><i class="fas fa-envelope"></i> Configuración SMTP / Correo</h3>
      </div>
      <div class="card-body">
        <p style="font-size:13px;color:var(--text-muted);margin-bottom:20px;">
          Configura el servidor de correo para enviar cotizaciones, campañas de email y notificaciones.
        </p>
        <div class="grid-2 gap-md">
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;"><i class="fas fa-toggle-on"></i> Estado SMTP</label>
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer;margin-top:4px;">
              <input v-model="smtp.activo" type="checkbox" true-value="1" false-value="0" style="width:18px;height:18px;">
              <span :class="['badge', smtp.activo === '1' ? 'badge-success' : 'badge-danger']">{{
                smtp.activo === '1' ? 'Activo' : 'Inactivo' }}</span>
            </label>
            <p style="font-size:12px;color:var(--text-muted);margin-top:4px;">Activa para enviar correos reales. Desactivado usa el log de Laravel.</p>
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;">Servidor (Host) *</label>
            <input v-model="smtp.host" class="form-control" placeholder="smtp.gmail.com">
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;">Puerto *</label>
            <input v-model="smtp.port" type="number" class="form-control" placeholder="587">
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;">Cifrado *</label>
            <select v-model="smtp.encryption" class="form-control">
              <option value="tls">TLS (STARTTLS - Puerto 587)</option>
              <option value="ssl">SSL (Puerto 465)</option>
            </select>
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;">Usuario SMTP *</label>
            <input v-model="smtp.username" class="form-control" placeholder="tu@email.com">
          </div>
          <div class="form-group">
            <label style="font-weight:600;margin-bottom:6px;display:block;">Contraseña SMTP</label>
            <input v-model="smtp.password" type="password" class="form-control" placeholder="••••••••">
            <p style="font-size:11px;color:var(--text-muted);margin-top:4px;" v-if="smtp.password && smtp.password.startsWith('*')">
              <i class="fas fa-lock"></i> Contraseña actual oculta. Deja vacío para no cambiar.</p>
          </div>
        </div>
        <div class="flex gap-sm mt-md" style="flex-wrap:wrap;">
          <button class="btn btn-primary" @click="guardarSmtp" :disabled="isSubmitting"><i v-if="isSubmitting"
              class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">Guardando...</span><span
              v-else><i class="fas fa-save"></i> Guardar Configuración</span></button>
          <button class="btn btn-secondary" @click="probarSmtp" :disabled="isTestingSmtp"><i v-if="isTestingSmtp"
              class="fas fa-spinner fa-spin"></i> <span v-if="isTestingSmtp">Probando...</span><span
              v-else><i class="fas fa-paper-plane"></i> Enviar Correo de Prueba</span></button>
        </div>
        <div v-if="smtpTestResult" :class="['mt-md', 'p-md', 'rounded-lg', smtpTestResult.success ? 'bg-success-subtle' : 'bg-danger-subtle']"
          style="border:1px solid var(--border);border-radius:8px;padding:12px;">
          <strong :style="{ color: smtpTestResult.success ? 'var(--success)' : 'var(--danger)' }">
            <i :class="smtpTestResult.success ? 'fas fa-check-circle' : 'fas fa-times-circle'"></i>
            {{ smtpTestResult.message }}
          </strong>
        </div>
        <div style="margin-top:20px;padding:16px;background:var(--bg-tertiary);border-radius:10px;">
          <h4 style="margin:0 0 10px;font-size:13px;"><i class="fas fa-info-circle"></i> Configuraciones populares</h4>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:8px;font-size:12px;">
            <div style="padding:8px;background:var(--bg-card);border-radius:6px;cursor:pointer;border:1px solid var(--border);" @click="smtp.host='smtp.gmail.com';smtp.port=587;smtp.encryption='tls'">
              <strong>Gmail</strong><br><span style="color:var(--text-muted);">smtp.gmail.com:587 TLS</span>
            </div>
            <div style="padding:8px;background:var(--bg-card);border-radius:6px;cursor:pointer;border:1px solid var(--border);" @click="smtp.host='smtp.office365.com';smtp.port=587;smtp.encryption='tls'">
              <strong>Outlook/365</strong><br><span style="color:var(--text-muted);">smtp.office365.com:587 TLS</span>
            </div>
            <div style="padding:8px;background:var(--bg-card);border-radius:6px;cursor:pointer;border:1px solid var(--border);" @click="smtp.host='smtp.mailgun.org';smtp.port=587;smtp.encryption='tls'">
              <strong>Mailgun</strong><br><span style="color:var(--text-muted);">smtp.mailgun.org:587 TLS</span>
            </div>
            <div style="padding:8px;background:var(--bg-card);border-radius:6px;cursor:pointer;border:1px solid var(--border);" @click="smtp.host='smtp.sendgrid.net';smtp.port=587;smtp.encryption='tls'">
              <strong>SendGrid</strong><br><span style="color:var(--text-muted);">smtp.sendgrid.net:587 TLS</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ubicación -->
    <div class="modal-overlay" :class="{ active: showUbicacion }" @click.self="cerrarModalUbicacion">
      <div class="modal" style="max-width: min(90vw, 720px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingUbicacionId ? i18nStore.t('editar') : i18nStore.t('crear') }} {{
            i18nStore.t('config_ubicaciones') }}</h3><button class="modal-close" @click="cerrarModalUbicacion"><i
              class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="grid-2">
            <div class="form-group"><label>{{ i18nStore.t('nombre') }} *</label><input v-model="fUbicacion.nombre"
                class="form-control"></div>
            <div class="form-group"><label>{{ i18nStore.t('ubicacion_tipo') }}</label><select v-model="fUbicacion.tipo"
                class="form-control">
                <option value="sucursal">{{ i18nStore.t('sucursal') }}</option>
                <option value="bodega">{{ i18nStore.t('bodega') }}</option>
                <option value="almacen">{{ i18nStore.t('almacen') }}</option>
              </select></div>
            <div class="form-group"><label>{{ i18nStore.t('direccion_label') }}</label><input
                v-model="fUbicacion.direccion" class="form-control"></div>
            <div class="form-group"><label>{{ i18nStore.t('telefono_label') }}</label><input
                v-model="fUbicacion.telefono" class="form-control"></div>
            <div class="form-group"><label>{{ i18nStore.t('responsable') }}</label><input
                v-model="fUbicacion.responsable" class="form-control"></div>
            <div class="form-group"><label><input v-model="fUbicacion.activo" type="checkbox"
                  style="margin-right:6px;">{{ i18nStore.t('activo') }}</label></div>
          </div>
          <div class="form-group">
            <label>Coordenadas (Lat, Lng)</label>
            <div class="flex gap-sm">
              <input v-model="fUbicacion.lat" class="form-control" placeholder="Latitud" type="number" step="any"
                style="flex:1;">
              <input v-model="fUbicacion.lng" class="form-control" placeholder="Longitud" type="number" step="any"
                style="flex:1;">
              <button class="btn btn-secondary" @click="usarUbicacionActual"><i class="fas fa-crosshairs"></i>
                GPS</button>
            </div>
          </div>
          <div class="form-group">
            <label>Buscar en mapa</label>
            <div class="flex gap-sm">
              <input v-model="buscarDir" class="form-control" placeholder="Ej: San José, Costa Rica"
                @keyup.enter="buscarDireccion">
              <button class="btn btn-secondary" @click="buscarDireccion"><i class="fas fa-search"></i></button>
            </div>
          </div>
          <div ref="mapPickerRef" id="map-picker"></div>
          <p style="font-size:11px;color:var(--text-muted);margin-top:6px;"><i class="fas fa-info-circle"></i> Haga clic
            en el mapa para seleccionar la ubicación exacta.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="cerrarModalUbicacion">{{ i18nStore.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardarUbicacion" :disabled="isSubmitting"><i v-if="isSubmitting"
              class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
              v-else>{{ editingUbicacionId ? i18nStore.t('editar') : i18nStore.t('crear') }}</span></button>
        </div>
      </div>
    </div>

    <!-- Modal Caja -->
    <div class="modal-overlay" :class="{ active: showCaja }" @click.self="showCaja = false">
      <div class="modal" style="max-width: min(90vw, 480px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingCajaId ? i18nStore.t('editar') : i18nStore.t('crear') }} {{
            i18nStore.t('config_cajas') }}</h3><button class="modal-close" @click="showCaja = false"><i
              class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18nStore.t('nombre') }} *</label><input v-model="fCaja.nombre"
              class="form-control" placeholder="Ej: Caja Principal"></div>
          <div class="form-group"><label>{{ i18nStore.t('config_ubicaciones') }}</label><select
              v-model="fCaja.ubicacion_id" class="form-control">
              <option :value="null">— {{ i18nStore.t('seleccionar') }} —</option>
              <option v-for="u in ubicaciones" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select></div>
          <div class="form-group"><label>Usuario Asignado</label><select v-model="fCaja.usuario_id"
              class="form-control">
              <option :value="null">— Ninguno —</option>
              <option v-for="u in usuariosActivos" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select></div>
          <div class="form-group"><label><input v-model="fCaja.activo" type="checkbox" style="margin-right:6px;">{{
            i18nStore.t('activo') }}</label></div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCaja = false">{{ i18nStore.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardarCaja" :disabled="isSubmitting"><i v-if="isSubmitting"
              class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
              v-else>{{ editingCajaId ? i18nStore.t('editar') : i18nStore.t('crear') }}</span></button>
        </div>
      </div>
    </div>

    <!-- Modal Categoría -->
    <div class="modal-overlay" :class="{ active: showCategoria }" @click.self="showCategoria = false">
      <div class="modal" style="max-width: min(90vw, 480px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingCategoriaId ? i18nStore.t('editar') : i18nStore.t('crear') }} {{
            i18nStore.t('config_categorias') }}</h3><button class="modal-close" @click="showCategoria = false"><i
              class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18nStore.t('nombre') }} *</label><input v-model="fCategoria.nombre"
              class="form-control" placeholder="Ej: Electrónica"></div>
          <div class="form-group"><label>{{ i18nStore.t('descripcion') }}</label><input v-model="fCategoria.descripcion"
              class="form-control" placeholder="Opcional"></div>
          <div class="form-group"><label>Color</label><input v-model="fCategoria.color" type="color"
              class="form-control" style="height:40px;padding:4px;"></div>
          <div class="form-group"><label>Icono (clase FontAwesome)</label><input v-model="fCategoria.icono"
              class="form-control" placeholder="Ej: fas fa-laptop"></div>
          <div class="form-group"><label><input v-model="fCategoria.activo" type="checkbox" style="margin-right:6px;">{{
            i18nStore.t('activo') }}</label></div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCategoria = false">{{ i18nStore.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardarCategoria" :disabled="isSubmitting"><i v-if="isSubmitting"
              class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{ i18nStore.t('guardando') }}</span><span
              v-else>{{ editingCategoriaId ? i18nStore.t('editar') : i18nStore.t('crear') }}</span></button>
        </div>
      </div>
    </div>

    <!-- Modal Categoría de Cliente -->
    <div class="modal-overlay" :class="{ active: showClienteCategoria }" @click.self="showClienteCategoria = false">
      <div class="modal" style="max-width: min(90vw, 480px);">
        <div class="modal-header">
          <h3 class="modal-title">{{ editingClienteCategoriaId ? i18nStore.t('editar') : i18nStore.t('crear') }} {{
            i18nStore.t('config_cliente_cat') }}</h3><button class="modal-close" @click="showClienteCategoria = false"><i
              class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
          <div class="form-group"><label>{{ i18nStore.t('nombre') }} *</label><input v-model="fClienteCategoria.nombre"
              class="form-control" placeholder="Ej: VIP"></div>
          <div class="form-group"><label>{{ i18nStore.t('descripcion') }}</label><input
              v-model="fClienteCategoria.descripcion" class="form-control" placeholder="Opcional"></div>
          <div class="form-group"><label>Color</label><input v-model="fClienteCategoria.color" type="color"
              class="form-control" style="height:40px;padding:4px;"></div>
          <div class="form-group"><label>Icono (clase FontAwesome)</label><input v-model="fClienteCategoria.icono"
              class="form-control" placeholder="Ej: fas fa-crown"></div>
          <div class="form-group"><label><input v-model="fClienteCategoria.activo" type="checkbox"
                style="margin-right:6px;">{{ i18nStore.t('activo') }}</label></div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showClienteCategoria = false">{{ i18nStore.t('cancelar') }}</button>
          <button class="btn btn-primary" @click="guardarClienteCategoria" :disabled="isSubmitting"><i
              v-if="isSubmitting" class="fas fa-spinner fa-spin"></i> <span v-if="isSubmitting">{{
                i18nStore.t('guardando') }}</span><span v-else>{{ editingClienteCategoriaId ? i18nStore.t('editar') :
                i18nStore.t('crear') }}</span></button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch, onBeforeUnmount } from 'vue';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useAuthStore } from '../stores/auth';
import { useSubmitLock } from '../composables/useSubmitLock';
import { useCurrencyStore } from '../stores/currency';
import { useI18nStore } from '../stores/i18n';
import common from '../composables/common.js';

import {
  map as createLeafletMap,
  tileLayer as createTileLayer,
  divIcon as createDivIcon,
  marker as createMarker
} from 'leaflet';

import 'leaflet/dist/leaflet.css';

const toast = useToastStore();
const authStore = useAuthStore();
const currencyStore = useCurrencyStore();
const i18nStore = useI18nStore();

const { normalizarMinimo } = common;
void normalizarMinimo;

const { isSubmitting, execute } = useSubmitLock({
  loadingText: i18nStore.t('guardando')
});

const tab = ref('empresa');

const tasaUSD = ref(520);
const tasaEUR = ref(570);

const empresa = ref({});
const ubicaciones = ref([]);
const config = ref({});
const cajas = ref([]);
const categorias = ref([]);
const clienteCategorias = ref([]);

const chatRetencion = ref('never');

const chatStats = ref({
  total_chats: 0,
  total_mensajes: 0,
  total_archivos: 0
});

const webhookUrl = ref('');
const apiActiva = ref('1');

const smtp = ref({
  smtp_host: '',
  smtp_port: '587',
  smtp_username: '',
  smtp_password: '',
  smtp_encryption: 'tls',
  smtp_activo: '0'
});
const isTestingSmtp = ref(false);
const smtpTestResult = ref(null);

const showUbicacion = ref(false);
const editingUbicacionId = ref(null);

const fUbicacion = ref({
  nombre: '',
  tipo: 'sucursal',
  direccion: '',
  telefono: '',
  responsable: '',
  lat: '',
  lng: '',
  activo: true
});

const buscarDir = ref('');
const mapPickerRef = ref(null);

let mapPicker = null;
let pickerMarker = null;

const filtroUbicaciones = ref({
  q: '',
  tipo: '',
  estado: ''
});

const filtroCajas = ref({
  q: '',
  estado: ''
});

const showCaja = ref(false);
const editingCajaId = ref(null);

const fCaja = ref({
  nombre: '',
  ubicacion_id: null,
  usuario_id: null,
  activo: true
});

const usuarios = ref([]);

const showCategoria = ref(false);
const editingCategoriaId = ref(null);

const fCategoria = ref({
  nombre: '',
  descripcion: '',
  color: '#3b82f6',
  icono: '',
  activo: true
});

const showClienteCategoria = ref(false);
const editingClienteCategoriaId = ref(null);

const fClienteCategoria = ref({
  nombre: '',
  descripcion: '',
  color: '#3b82f6',
  icono: '',
  activo: true
});

onMounted(() => {
  cargarEmpresa();
  cargarTasas();
});

onBeforeUnmount(() => {
  destruirMapaPicker();
});

async function cargarTasas() {
  try {
    const { data } = await api.get('/configuracion/tasas-cambio');

    if (data.tasas) {
      tasaUSD.value = data.tasas.USD || 520;
      tasaEUR.value = data.tasas.EUR || 570;
    }
  } catch (e) {
    console.error('cargarTasas error:', e);
  }
}

async function cambiarIdioma(lang) {
  await i18nStore.setLocale(lang);

  toast.success(
    lang === 'es'
      ? 'Idioma cambiado a Español'
      : 'Language changed to English'
  );
}

async function cambiarDivisa(codigo) {
  await currencyStore.setDivisa(codigo);

  toast.success(
    i18nStore.locale === 'es'
      ? `Divisa cambiada a ${codigo}`
      : `Currency changed to ${codigo}`
  );
}

async function guardarTasas() {
  try {
    await api.post('/configuracion/tasas-cambio', {
      USD: tasaUSD.value,
      EUR: tasaEUR.value
    });

    currencyStore.loadFromServer(null, {
      USD: tasaUSD.value,
      EUR: tasaEUR.value
    });

    toast.success(
      i18nStore.locale === 'es'
        ? 'Tasas de cambio guardadas'
        : 'Exchange rates saved'
    );
  } catch (e) {
    toast.error(
      i18nStore.locale === 'es'
        ? 'Error al guardar tasas'
        : 'Error saving rates'
    );
  }
}

async function cargarEmpresa() {
  try {
    const { data } = await api.get('/configuracion/empresa');
    empresa.value = data.empresa || {};
  } catch (e) {
    console.error('cargarEmpresa error:', e);
  }
}

async function guardarEmpresa() {
  try {
    await execute(async () => {
      await api.post('/configuracion/empresa', empresa.value);
      toast.success(i18nStore.t('config_guardada'));
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(i18nStore.t('error_config'));
    }
  }
}

async function cargarUbicaciones() {
  try {
    const { data } = await api.get('/configuracion/ubicaciones');
    ubicaciones.value = data.ubicaciones || [];
  } catch (e) {
    console.error('cargarUbicaciones error:', e);
  }
}

function abrirModalUbicacion(u = null) {
  editingUbicacionId.value = u ? u.id : null;

  fUbicacion.value = u
    ? {
      nombre: u.nombre,
      tipo: u.tipo || 'sucursal',
      direccion: u.direccion || '',
      telefono: u.telefono || '',
      responsable: u.responsable || '',
      lat: u.lat || '',
      lng: u.lng || '',
      activo: u.activo !== false
    }
    : {
      nombre: '',
      tipo: 'sucursal',
      direccion: '',
      telefono: '',
      responsable: '',
      lat: '',
      lng: '',
      activo: true
    };

  buscarDir.value = '';
  showUbicacion.value = true;

  nextTick(() => {
    initMapPicker();
  });
}

function cerrarModalUbicacion() {
  showUbicacion.value = false;
  destruirMapaPicker();
}

function destruirMapaPicker() {
  if (mapPicker) {
    mapPicker.remove();
    mapPicker = null;
    pickerMarker = null;
  }
}

async function guardarUbicacion() {
  try {
    const payload = { ...fUbicacion.value };

    if (payload.lat === '') payload.lat = null;
    if (payload.lng === '') payload.lng = null;

    if (editingUbicacionId.value) {
      await api.put(`/configuracion/ubicaciones/${editingUbicacionId.value}`, payload);
    } else {
      await api.post('/configuracion/ubicaciones', payload);
    }

    cerrarModalUbicacion();
    cargarUbicaciones();

    toast.success(i18nStore.t('config_guardada'));
  } catch (e) {
    toast.error(e.response?.data?.error || i18nStore.t('error'));
  }
}

function formatCoord(v) {
  return Number(v).toFixed(5);
}

function initMapPicker() {
  if (!mapPickerRef.value || mapPicker) return;

  const lat = parseFloat(fUbicacion.value.lat) || 9.7;
  const lng = parseFloat(fUbicacion.value.lng) || -84.0;

  mapPicker = createLeafletMap(mapPickerRef.value, {
    zoomControl: false
  }).setView([lat, lng], 12);

  const dark =
    authStore.theme === 'dark' ||
    document.documentElement.dataset.theme === 'dark';

  createTileLayer(
    dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    {
      attribution: dark
        ? '&copy; OpenStreetMap &copy; CARTO'
        : '&copy; OpenStreetMap contributors',
      subdomains: dark ? 'abcd' : 'abc',
      maxZoom: 19
    }
  ).addTo(mapPicker);

  updatePickerMarker(lat, lng);

  mapPicker.on('click', (e) => {
    fUbicacion.value.lat = String(e.latlng.lat);
    fUbicacion.value.lng = String(e.latlng.lng);
    updatePickerMarker(e.latlng.lat, e.latlng.lng);
  });

  setTimeout(() => {
    if (mapPicker) {
      mapPicker.invalidateSize();
    }
  }, 250);
}

function updatePickerMarker(lat, lng) {
  if (!mapPicker) return;

  if (pickerMarker) {
    mapPicker.removeLayer(pickerMarker);
  }

  const iconHtml = `
    <div style="
      width:16px;
      height:16px;
      background:var(--danger);
      border:2px solid #fff;
      border-radius:50%;
      box-shadow:0 0 0 2px var(--danger);
      transform:translate(-50%,-50%);
    "></div>
  `;

  const icon = createDivIcon({
    className: 'picker-marker',
    html: iconHtml,
    iconSize: [16, 16],
    iconAnchor: [8, 8]
  });

  pickerMarker = createMarker([lat, lng], { icon }).addTo(mapPicker);
}

async function buscarDireccion() {
  if (!buscarDir.value.trim()) return;

  try {
    const q = encodeURIComponent(buscarDir.value.trim());

    const res = await fetch(
      `https://nominatim.openstreetmap.org/search?format=json&q=${q}&limit=1`
    );

    const data = await res.json();

    if (data && data.length) {
      const r = data[0];

      fUbicacion.value.lat = String(r.lat);
      fUbicacion.value.lng = String(r.lon);

      if (mapPicker) {
        mapPicker.setView([parseFloat(r.lat), parseFloat(r.lon)], 14);
        updatePickerMarker(parseFloat(r.lat), parseFloat(r.lon));
      } else {
        nextTick(() => {
          initMapPicker();
        });
      }
    } else {
      toast.error('Dirección no encontrada');
    }
  } catch (e) {
    toast.error('Error al buscar dirección');
  }
}

function usarUbicacionActual() {
  if (!navigator.geolocation) {
    toast.error('Geolocalización no disponible');
    return;
  }

  navigator.geolocation.getCurrentPosition(
    (pos) => {
      fUbicacion.value.lat = String(pos.coords.latitude);
      fUbicacion.value.lng = String(pos.coords.longitude);

      if (mapPicker) {
        mapPicker.setView(
          [pos.coords.latitude, pos.coords.longitude],
          14
        );

        updatePickerMarker(
          pos.coords.latitude,
          pos.coords.longitude
        );
      }
    },
    () => {
      toast.error('No se pudo obtener la ubicación');
    }
  );
}

watch(
  () => authStore.theme,
  () => {
    if (mapPicker && showUbicacion.value) {
      const center = mapPicker.getCenter();
      const zoom = mapPicker.getZoom();

      destruirMapaPicker();

      nextTick(() => {
        initMapPicker();

        if (mapPicker) {
          mapPicker.setView(center, zoom);
          mapPicker.invalidateSize();
        }
      });
    }
  }
);

const ubicacionesFiltradas = computed(() => {
  const f = filtroUbicaciones.value;

  return ubicaciones.value.filter((u) => {
    const q = f.q.toLowerCase();

    const matchQ =
      !q ||
      (u.nombre || '').toLowerCase().includes(q) ||
      (u.direccion || '').toLowerCase().includes(q) ||
      (u.responsable || '').toLowerCase().includes(q) ||
      (u.telefono || '').toLowerCase().includes(q);

    const matchTipo = !f.tipo || u.tipo === f.tipo;

    const matchEstado =
      !f.estado ||
      (f.estado === 'activo' ? u.activo : !u.activo);

    return matchQ && matchTipo && matchEstado;
  });
});

const cajasFiltradas = computed(() => {
  const f = filtroCajas.value;

  return cajas.value.filter((c) => {
    const q = f.q.toLowerCase();

    const matchQ =
      !q ||
      (c.nombre || '').toLowerCase().includes(q) ||
      (c.ubicacion_nombre || '').toLowerCase().includes(q);

    const matchEstado =
      !f.estado ||
      (f.estado === 'activo' ? c.activo : !c.activo);

    return matchQ && matchEstado;
  });
});

async function cargarConfig() {
  try {
    const { data } = await api.get('/configuracion');
    config.value = data.config || {};
  } catch (e) {
    console.error('cargarConfig error:', e);
  }
}

async function guardarConfig() {
  try {
    await execute(async () => {
      await api.post('/configuracion', {
        config: config.value
      });

      toast.success(i18nStore.t('config_guardada'));
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(i18nStore.t('error_config'));
    }
  }
}

async function cargarCajas() {
  try {
    const results = await Promise.allSettled([
      api.get('/configuracion/cajas'),
      api.get('/usuarios'),
      api.get('/configuracion/ubicaciones')
    ]);

    const [cj, us, ub] = results.map((r) =>
      r.status === 'fulfilled' ? r.value : { data: {} }
    );

    cajas.value = cj.data.cajas || [];
    usuarios.value = us.data.usuarios || [];
    ubicaciones.value = ub.data.ubicaciones || [];
  } catch (e) {
    console.error('cargarCajas error:', e);
  }
}

const usuariosActivos = computed(() =>
  usuarios.value.filter((u) => u.activo)
);

function abrirModalCaja(c = null) {
  editingCajaId.value = c ? c.id : null;

  fCaja.value = c
    ? {
      nombre: c.nombre,
      ubicacion_id: c.ubicacion_id,
      usuario_id: c.usuario_id,
      activo: c.activo
    }
    : {
      nombre: '',
      ubicacion_id: null,
      usuario_id: null,
      activo: true
    };

  showCaja.value = true;
}

async function guardarCaja() {
  try {
    await execute(async () => {
      if (editingCajaId.value) {
        await api.put(`/configuracion/cajas/${editingCajaId.value}`, fCaja.value);
      } else {
        await api.post('/configuracion/cajas', fCaja.value);
      }

      showCaja.value = false;
      cargarCajas();
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(
        e.response?.data?.error ||
        e.response?.data?.message ||
        (e.response?.data?.errors
          ? Object.values(e.response.data.errors).flat().join('. ')
          : 'Error al crear la caja')
      );
    }
  }
}

async function cargarCategorias() {
  try {
    const { data } = await api.get('/configuracion/categorias');
    categorias.value = data.categorias || [];
  } catch (e) {
    console.error('cargarCategorias error:', e);
  }
}

function abrirModalCategoria(c = null) {
  editingCategoriaId.value = c ? c.id : null;

  fCategoria.value = c
    ? {
      nombre: c.nombre,
      descripcion: c.descripcion || '',
      color: c.color || '#3b82f6',
      icono: c.icono || '',
      activo: c.activo
    }
    : {
      nombre: '',
      descripcion: '',
      color: '#3b82f6',
      icono: '',
      activo: true
    };

  showCategoria.value = true;
}

async function guardarCategoria() {
  try {
    await execute(async () => {
      if (editingCategoriaId.value) {
        await api.put(
          `/configuracion/categorias/${editingCategoriaId.value}`,
          fCategoria.value
        );
      } else {
        await api.post('/configuracion/categorias', fCategoria.value);
      }

      showCategoria.value = false;
      cargarCategorias();
    });
  } catch (e) {
    const data = e.response?.data || {};

    if (data?.errors) {
      const mensajes = Object.values(data.errors).flat().join('\n');
      toast.error(mensajes);
      return;
    }

    toast.error(data?.message || data?.error || i18nStore.t('error'));
  }
}

async function cargarRetencionChats() {
  try {
    const { data } = await api.get('/configuracion/chats/retencion');

    chatRetencion.value = data.retencion || 'never';

    chatStats.value = {
      total_chats: data.total_chats || 0,
      total_mensajes: data.total_mensajes || 0,
      total_archivos: data.total_archivos || 0
    };
  } catch (e) {
    toast.error(i18nStore.t('error_config'));
  }
}

async function guardarRetencionChats() {
  try {
    await api.post('/configuracion/chats/retencion', {
      retencion: chatRetencion.value
    });

    toast.success(i18nStore.t('config_guardada'));
  } catch (e) {
    toast.error(i18nStore.t('error_config'));
  }
}

async function limpiarChats(tipo) {
  const confirmar = confirm(
    tipo === 'all'
      ? i18nStore.t('confirmar_eliminar_chats')
      : i18nStore.t('confirmar_eliminar_chats')
  );

  if (!confirmar) return;

  try {
    await execute(async () => {
      const { data } = await api.post('/configuracion/chats/limpiar', {
        tipo
      });

      if (data.success) {
        toast.success(i18nStore.t('config_guardada'));
        await cargarRetencionChats();
      }
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      const msg = e.response?.data?.error || i18nStore.t('error');
      toast.error(msg);
    }
  }
}

async function cargarClienteCategorias() {
  try {
    const { data } = await api.get('/configuracion/cliente-categorias');
    clienteCategorias.value = data.categorias || [];
  } catch (e) {
    console.error('cargarClienteCategorias error:', e);
  }
}

function abrirModalClienteCategoria(c = null) {
  editingClienteCategoriaId.value = c ? c.id : null;

  fClienteCategoria.value = c
    ? {
      nombre: c.nombre,
      descripcion: c.descripcion || '',
      color: c.color || '#3b82f6',
      icono: c.icono || '',
      activo: c.activo
    }
    : {
      nombre: '',
      descripcion: '',
      color: '#3b82f6',
      icono: '',
      activo: true
    };

  showClienteCategoria.value = true;
}

async function guardarClienteCategoria() {
  try {
    await execute(async () => {
      if (editingClienteCategoriaId.value) {
        await api.put(
          `/configuracion/cliente-categorias/${editingClienteCategoriaId.value}`,
          fClienteCategoria.value
        );
      } else {
        await api.post(
          '/configuracion/cliente-categorias',
          fClienteCategoria.value
        );
      }

      showClienteCategoria.value = false;
      cargarClienteCategorias();
    });
  } catch (e) {
    const data = e.response?.data || {};

    if (data?.errors) {
      const mensajes = Object.values(data.errors).flat().join('\n');
      toast.error(mensajes);
      return;
    }

    toast.error(data?.message || data?.error || i18nStore.t('error'));
  }
}

async function cargarConfigWeb() {
  try {
    const { data } = await api.get('/configuracion');
    const cfg = data.config || {};

    webhookUrl.value = cfg['api_webhook_url'] || '';
    apiActiva.value = cfg['api_webhook_activa'] ?? '1';
  } catch (e) {
    console.error('cargarConfigWeb error:', e);
  }
}

async function guardarConfigWeb() {
  try {
    await execute(async () => {
      await api.post('/configuracion', {
        config: {
          api_webhook_url: webhookUrl.value,
          api_webhook_activa: apiActiva.value
        }
      });

      toast.success(i18nStore.t('config_guardada'));
    });
  } catch (e) {
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(i18nStore.t('error_config'));
    }
  }
}

async function cargarSmtp() {
  try {
    const { data } = await api.get('/configuracion/smtp');
    if (data.smtp) {
      smtp.value = {
        smtp_host: data.smtp.smtp_host || '',
        smtp_port: data.smtp.smtp_port || '587',
        smtp_username: data.smtp.smtp_username || '',
        smtp_password: data.smtp.smtp_password || '',
        smtp_encryption: data.smtp.smtp_encryption || 'tls',
        smtp_activo: data.smtp.smtp_activo || '0'
      };
    }
  } catch (e) {
    console.error('cargarSmtp error:', e);
  }
}

async function guardarSmtp() {
  try {
    smtpTestResult.value = null;
    await execute(async () => {
      await api.post('/configuracion/smtp', smtp.value);
      toast.success('Configuración SMTP guardada');
    });
  } catch (e) {
    if (e.response?.status === 422) {
      const errors = e.response.data.errors || {};
      const msgs = Object.values(errors).flat().join('. ');
      toast.error(msgs || 'Error de validación');
    } else if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else {
      toast.error(e.response?.data?.error || 'Error al guardar configuración SMTP');
    }
  }
}

async function probarSmtp() {
  try {
    isTestingSmtp.value = true;
    smtpTestResult.value = null;
    const { data } = await api.post('/configuracion/smtp/probar');
    smtpTestResult.value = data;
    if (data.success) {
      toast.success(data.message);
    } else {
      toast.error(data.message);
    }
  } catch (e) {
    const msg = e.response?.data?.message || 'Error al probar conexión SMTP';
    smtpTestResult.value = { success: false, message: msg };
    toast.error(msg);
  } finally {
    isTestingSmtp.value = false;
  }
}
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #0b1120;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: var(--radius-md);
  padding: 6px 12px;
  flex: 1;
  max-width: 720px;
}

.search-icon {
  color: #94a3b8;
  font-size: 14px;
}

.search-input {
  flex: 1;
  background: transparent;
  border: none;
  color: #e2e8f0;
  font-size: 14px;
  outline: none;
  padding: 4px 0;
  min-width: 120px;
}

.search-input::placeholder {
  color: #64748b;
}

.search-select {
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: var(--radius-sm);
  color: #e2e8f0;
  font-size: 13px;
  padding: 6px 10px;
  outline: none;
  cursor: pointer;
}

.search-badge {
  background: var(--primary);
  color: white;
  font-size: 11px;
  font-weight: 600;
  padding: 3px 8px;
  border-radius: var(--radius-full);
  white-space: nowrap;
}

.color-dot {
  display: inline-block;
  width: 16px;
  height: 16px;
  border-radius: 4px;
  border: 1px solid rgba(0, 0, 0, 0.15);
}

#map-picker {
  height: 280px;
  border-radius: var(--radius-md);
  border: 1px solid var(--bg-hover);
}

:deep(.picker-marker) {
  background: transparent !important;
  border: none !important;
}

:deep(.leaflet-container) {
  background: var(--bg-hover);
  font-family: var(--font-main);
  border-radius: var(--radius-md);
}

:deep(.leaflet-popup-content-wrapper) {
  border-radius: 8px;
  background: var(--bg-card);
  color: var(--text-primary);
}

:deep(.leaflet-popup-tip) {
  background: var(--bg-card);
}

@media (max-width: 768px) {
  .modal {
    max-width: min(90vw, 500px);
  }
  
  .grid-2 {
    grid-template-columns: 1fr;
  }
  
  .search-bar {
    flex-direction: column;
    align-items: stretch;
    max-width: 100%;
  }
  
  .search-bar .search-select {
    width: 100%;
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
  
  #map-picker {
    height: 220px;
  }
  
  .flex.justify-between.align-center.mb-md {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .flex.justify-between.align-center.mb-md > .search-bar {
    max-width: 100%;
  }
  
  .flex.justify-between.align-center.mb-md > .btn {
    align-self: flex-start;
  }
  
  .flex.justify-end.mb-md {
    justify-content: stretch;
  }
  
  .flex.justify-end.mb-md > .btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .flex.gap-sm.mb-lg {
    flex-wrap: wrap;
    gap: 8px;
  }
  
  .flex.gap-sm.mb-lg > .btn {
    flex: 1;
    min-width: 0;
    justify-content: center;
    font-size: clamp(11px, 2.5vw, 14px);
    padding: 10px 8px;
  }
  
  .card-body {
    padding: 8px;
  }
  
  .color-dot {
    width: 12px;
    height: 12px;
  }
  
  .search-input {
    min-width: 0;
  }
  
  .grid-2.gap-md {
    gap: 12px;
  }
  
  .flex.gap-sm {
    flex-wrap: wrap;
  }
  
  .flex.gap-sm > .btn {
    flex: 1;
    min-width: 0;
  }
  
  #map-picker {
    height: 180px;
  }
}
</style>
