<?php

use App\Http\Controllers\Api\{
    AjusteInventarioController, AuditoriaController, AuthController, BusinessIntelligenceController,
    CajaController, CatalogoController, ClienteController, ComboController, CompraController, ConfiguracionController,
    ChatController, CotizacionController, CotizacionDesignerController, CuentasCobrarController, CrmController, DashboardController, DevolucionController, EmailBuilderController, EmailMarketingController,
    EtiquetaController, FacturacionElectronicaController, FormularioController, InventarioController, ListaPreciosController, NotaCreditoController, NotificacionController, NotificacionPersonalizadaController, PedidoController,
    PlanillaController, PresupuestoController, ProductividadController, ProductoController, ProveedorController, ReporteController, RolController,
    TesoreriaController, TicketDesignerController, TraspasoController, UsuarioController, VentaController
};
use Illuminate\Support\Facades\Route;

// Public routes (rate limited)
Route::middleware('throttle:10,1')->post('/login', [AuthController::class, 'login']);
Route::post('/auth/invalidate-token', [AuthController::class, 'invalidateToken']);

// Public webhook for external website forms
Route::middleware('throttle:30,1')->post('/webhook/formulario/{id}', [FormularioController::class, 'webhook']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/auth/check', [AuthController::class, 'check']);
    Route::post('/auth/toggle-theme', [AuthController::class, 'toggleTheme']);

    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);

    // Business Intelligence
    Route::get('/bi/dashboard', [BusinessIntelligenceController::class, 'dashboard']);

    // Ventas
    Route::get('/ventas', [VentaController::class, 'index']);
    Route::post('/ventas', [VentaController::class, 'store']);
    Route::get('/ventas/buscar', [VentaController::class, 'buscar']);
    Route::get('/ventas/{id}', [VentaController::class, 'show']);
    Route::post('/ventas/{id}/cancelar', [VentaController::class, 'cancelar']);
    Route::get('/ventas/{id}/ticket', [VentaController::class, 'ticket']);

    // Productos
    Route::get('/productos/buscar', [ProductoController::class, 'buscar']);
    Route::get('/productos/bajo-stock', [ProductoController::class, 'bajoStock']);
    Route::get('/productos/mas-vendidos', [ProductoController::class, 'masVendidos']);
    Route::get('/productos/categorias', [ProductoController::class, 'categorias']);
    Route::resource('productos', ProductoController::class);

    // Clientes
    Route::get('/clientes', [ClienteController::class, 'index']);
    Route::post('/clientes', [ClienteController::class, 'store']);
    Route::get('/clientes/buscar', [ClienteController::class, 'buscar']);
    Route::get('/clientes/estadisticas', [ClienteController::class, 'estadisticas']);
    Route::get('/clientes/notas-recientes', [ClienteController::class, 'notasRecientes']);
    Route::get('/clientes/{id}', [ClienteController::class, 'show']);
    Route::put('/clientes/{id}', [ClienteController::class, 'update']);
    Route::delete('/clientes/{id}', [ClienteController::class, 'destroy']);
    Route::post('/clientes/{id}/notas', [ClienteController::class, 'agregarNota']);
    Route::get('/clientes/{id}/notas', [ClienteController::class, 'notas']);
    Route::post('/clientes/{id}/etiquetas', [ClienteController::class, 'sincronizarEtiquetas']);

    // Usuarios
    Route::get('/usuarios', [UsuarioController::class, 'index']);
    Route::post('/usuarios', [UsuarioController::class, 'store']);
    Route::get('/usuarios/roles', [UsuarioController::class, 'roles']);
    Route::get('/usuarios/permisos', [UsuarioController::class, 'permisos']);
    Route::get('/usuarios/sesiones', [UsuarioController::class, 'sesiones']);
    Route::get('/usuarios/estadisticas', [UsuarioController::class, 'estadisticas']);
    Route::get('/usuarios/{id}', [UsuarioController::class, 'show']);
    Route::put('/usuarios/{id}', [UsuarioController::class, 'update']);
    Route::post('/usuarios/{id}/toggle', [UsuarioController::class, 'toggle']);
    Route::post('/roles', [UsuarioController::class, 'crearRol']);
    Route::put('/roles/{id}', [UsuarioController::class, 'actualizarRol']);
    Route::post('/roles/{id}/permisos', [UsuarioController::class, 'asignarPermisos']);

    // Caja
    Route::get('/caja/stats', [CajaController::class, 'stats']);
    Route::get('/caja/cajas', [CajaController::class, 'cajas']);
    Route::get('/caja/sesion-activa', [CajaController::class, 'sesionActiva']);
    Route::post('/caja/abrir', [CajaController::class, 'abrir']);
    Route::post('/caja/cerrar', [CajaController::class, 'cerrar']);
    Route::post('/caja/retiro', [CajaController::class, 'retiro']);
    Route::get('/caja/historial', [CajaController::class, 'historial']);

    // Cotizaciones
    Route::get('/cotizaciones', [CotizacionController::class, 'index']);
    Route::post('/cotizaciones', [CotizacionController::class, 'store']);
    Route::get('/cotizaciones/{id}', [CotizacionController::class, 'show']);
    Route::post('/cotizaciones/{id}/estado', [CotizacionController::class, 'cambiarEstado']);
    Route::post('/cotizaciones/{id}/aprobar', [CotizacionController::class, 'aprobar']);
    Route::post('/cotizaciones/{id}/rechazar', [CotizacionController::class, 'rechazar']);
    Route::post('/cotizaciones/{id}/convertir-factura', [CotizacionController::class, 'convertirFactura']);
    Route::post('/cotizaciones/enviar', [CotizacionController::class, 'enviar']);

    // Pedidos
    Route::get('/pedidos', [PedidoController::class, 'index']);
    Route::post('/pedidos', [PedidoController::class, 'store']);
    Route::get('/pedidos/{id}', [PedidoController::class, 'show']);
    Route::put('/pedidos/{id}', [PedidoController::class, 'update']);
    Route::delete('/pedidos/{id}', [PedidoController::class, 'destroy']);
    Route::post('/pedidos/{id}/estado', [PedidoController::class, 'cambiarEstado']);
    Route::post('/pedidos/{id}/pago', [PedidoController::class, 'registrarPago']);

    // Compras
    Route::get('/compras', [CompraController::class, 'index']);
    Route::post('/compras', [CompraController::class, 'store']);
    Route::get('/compras/{id}', [CompraController::class, 'show']);
    Route::post('/compras/{id}/recibir', [CompraController::class, 'recibir']);
    Route::post('/compras/{id}/cancelar', [CompraController::class, 'cancelar']);

    // Proveedores
    Route::get('/proveedores', [ProveedorController::class, 'index']);
    Route::post('/proveedores', [ProveedorController::class, 'store']);
    Route::get('/proveedores/buscar', [ProveedorController::class, 'buscar']);
    Route::get('/proveedores/{id}', [ProveedorController::class, 'show']);
    Route::put('/proveedores/{id}', [ProveedorController::class, 'update']);

    // Listas de Precios
    Route::get('/listas-precios', [ListaPreciosController::class, 'index']);
    Route::get('/listas-precios/precios-cliente', [ListaPreciosController::class, 'preciosCliente']);
    Route::post('/listas-precios', [ListaPreciosController::class, 'store']);
    Route::put('/listas-precios/{id}', [ListaPreciosController::class, 'update']);
    Route::get('/listas-precios/{id}/detalle', [ListaPreciosController::class, 'detalle']);
    Route::post('/listas-precios/{id}/clientes', [ListaPreciosController::class, 'asignarCliente']);
    Route::delete('/listas-precios/{id}/clientes/{clienteId}', [ListaPreciosController::class, 'quitarCliente']);
    Route::post('/listas-precios/{id}/productos', [ListaPreciosController::class, 'agregarProducto']);
    Route::put('/listas-precios/{id}/productos/{productoId}', [ListaPreciosController::class, 'actualizarProducto']);
    Route::delete('/listas-precios/{id}/productos/{productoId}', [ListaPreciosController::class, 'quitarProducto']);

    // Devoluciones
    Route::get('/devoluciones', [DevolucionController::class, 'index']);
    Route::post('/devoluciones', [DevolucionController::class, 'store']);
    Route::get('/devoluciones/buscar-venta', [DevolucionController::class, 'buscarVenta']);
    Route::get('/devoluciones/{id}', [DevolucionController::class, 'show']);
    Route::post('/devoluciones/{id}/aprobar', [DevolucionController::class, 'aprobar']);
    Route::post('/devoluciones/{id}/rechazar', [DevolucionController::class, 'rechazar']);
    Route::post('/devoluciones/{id}/cambio', [DevolucionController::class, 'cambioProducto']);

    // Notas de Crédito
    Route::get('/notas-credito', [NotaCreditoController::class, 'index']);
    Route::post('/notas-credito', [NotaCreditoController::class, 'store']);
    Route::get('/notas-credito/{id}', [NotaCreditoController::class, 'show']);
    Route::post('/notas-credito/{id}/cancelar', [NotaCreditoController::class, 'cancelar']);

    // Traspasos
    Route::get('/traspasos', [TraspasoController::class, 'index']);
    Route::post('/traspasos', [TraspasoController::class, 'store']);
    Route::get('/traspasos/ubicaciones', [TraspasoController::class, 'ubicaciones']);
    Route::get('/traspasos/{id}', [TraspasoController::class, 'show']);
    Route::post('/traspasos/{id}/enviar', [TraspasoController::class, 'enviar']);
    Route::post('/traspasos/{id}/recibir', [TraspasoController::class, 'recibir']);
    Route::post('/traspasos/{id}/cancelar', [TraspasoController::class, 'cancelar']);

    // Catálogo General (solo lectura)
    Route::get('/catalogo', [CatalogoController::class, 'index']);
    Route::get('/catalogo/dashboard', [CatalogoController::class, 'dashboard']);
    Route::get('/catalogo/filtros', [CatalogoController::class, 'filtros']);
    Route::get('/catalogo/{id}', [CatalogoController::class, 'show']);

    // Inventario por Ubicación
    Route::get('/inventario', [InventarioController::class, 'index']);
    Route::get('/inventario/dashboard', [InventarioController::class, 'dashboard']);
    Route::get('/inventario/movimientos', [InventarioController::class, 'movimientos']);
    Route::post('/inventario/transferir', [InventarioController::class, 'transferir']);
    Route::post('/inventario/actualizar-stock', [InventarioController::class, 'actualizarStock']);

    // Ajustes Inventario
    Route::get('/ajustes-inventario', [AjusteInventarioController::class, 'index']);
    Route::post('/ajustes-inventario', [AjusteInventarioController::class, 'store']);
    Route::get('/ajustes-inventario/{id}', [AjusteInventarioController::class, 'show']);
    Route::post('/ajustes-inventario/agregar-producto', [AjusteInventarioController::class, 'agregarProducto']);
    Route::post('/ajustes-inventario/{id}/aplicar', [AjusteInventarioController::class, 'aplicar']);
    Route::post('/ajustes-inventario/{id}/cancelar', [AjusteInventarioController::class, 'cancelar']);

    // Combos y Descuentos
    Route::get('/combos', [ComboController::class, 'index']);
    Route::post('/combos', [ComboController::class, 'store']);
    Route::get('/combos/{id}', [ComboController::class, 'show']);
    Route::post('/combos/{id}/toggle', [ComboController::class, 'toggle']);
    Route::get('/cupones', [ComboController::class, 'cupones']);
    Route::post('/cupones', [ComboController::class, 'crearCupon']);
    Route::post('/cupones/{id}/toggle', [ComboController::class, 'toggleCupon']);
    Route::get('/promociones', [ComboController::class, 'promociones']);
    Route::post('/promociones', [ComboController::class, 'crearPromocion']);
    Route::post('/promociones/{id}/toggle', [ComboController::class, 'togglePromocion']);

    // Etiquetas
    Route::get('/etiquetas', [EtiquetaController::class, 'index']);
    Route::post('/etiquetas', [EtiquetaController::class, 'store']);
    Route::put('/etiquetas/{id}', [EtiquetaController::class, 'update']);
    Route::delete('/etiquetas/{id}', [EtiquetaController::class, 'destroy']);

    // Reportes
    Route::get('/reportes/ventas-periodo', [ReporteController::class, 'ventasPeriodo']);
    Route::get('/reportes/productos-top', [ReporteController::class, 'productosTop']);
    Route::get('/reportes/ventas-geo', [ReporteController::class, 'ventasGeo']);
    Route::get('/reportes/clientes-top', [ReporteController::class, 'clientesTop']);
    Route::get('/reportes/vendedores', [ReporteController::class, 'vendedoresRanking']);
    Route::get('/reportes/metodos-pago', [ReporteController::class, 'metodosPago']);
    Route::get('/reportes/categorias', [ReporteController::class, 'categoriasVentas']);
    Route::get('/reportes/inventario-valor', [ReporteController::class, 'inventarioValor']);
    Route::get('/reportes/flujo-caja', [ReporteController::class, 'flujoCaja']);
    Route::get('/reportes/geo-dashboard', [ReporteController::class, 'geoDashboard']);
    Route::get('/reportes/geo-producto', [ReporteController::class, 'geoProducto']);
    Route::get('/reportes/geo-movimientos', [ReporteController::class, 'geoMovimientos']);
    Route::get('/reportes/geo-comparativa', [ReporteController::class, 'geoComparativa']);
    Route::get('/reportes/geo-tendencias', [ReporteController::class, 'geoTendencias']);
    Route::get('/reportes/rentabilidad-productos', [ReporteController::class, 'rentabilidadProductos']);

    // Auditoría
    Route::get('/auditoria', [AuditoriaController::class, 'index']);
    Route::get('/auditoria/{id}', [AuditoriaController::class, 'show']);

    // Productividad
    Route::get('/productividad', [ProductividadController::class, 'index']);
    Route::post('/productividad/sesion', [ProductividadController::class, 'registrarSesion']);
    Route::post('/productividad/cerrar-sesion', [ProductividadController::class, 'cerrarSesion']);
    Route::post('/productividad/heartbeat', [ProductividadController::class, 'heartbeat']);
    Route::post('/productividad/sync', [ProductividadController::class, 'sync']);
    Route::post('/productividad/pause', [ProductividadController::class, 'pause']);
    Route::post('/productividad/resume', [ProductividadController::class, 'resume']);

    // Planilla
    Route::get('/planilla/empleados', [PlanillaController::class, 'empleados']);
    Route::post('/planilla/empleados', [PlanillaController::class, 'crearEmpleado']);
    Route::put('/planilla/empleados/{id}', [PlanillaController::class, 'actualizarEmpleado']);
    Route::delete('/planilla/empleados/{id}', [PlanillaController::class, 'eliminarEmpleado']);

    // Configuración individual
    Route::get('/planilla/configuracion/{empleadoId}', [PlanillaController::class, 'obtenerConfiguracion']);
    Route::put('/planilla/configuracion/{empleadoId}', [PlanillaController::class, 'guardarConfiguracion']);

    // Validación y simulación
    Route::post('/planilla/validar-formula', [PlanillaController::class, 'validarFormula']);
    Route::post('/planilla/simular', [PlanillaController::class, 'simularFormula']);

    // Variables
    Route::get('/planilla/variables', [PlanillaController::class, 'variables']);
    Route::post('/planilla/variables', [PlanillaController::class, 'crearVariable']);
    Route::put('/planilla/variables/{id}', [PlanillaController::class, 'actualizarVariable']);
    Route::delete('/planilla/variables/{id}', [PlanillaController::class, 'eliminarVariable']);

    // Plantillas
    Route::get('/planilla/plantillas', [PlanillaController::class, 'plantillas']);
    Route::post('/planilla/plantillas', [PlanillaController::class, 'crearPlantilla']);
    Route::put('/planilla/plantillas/{id}', [PlanillaController::class, 'actualizarPlantilla']);
    Route::delete('/planilla/plantillas/{id}', [PlanillaController::class, 'eliminarPlantilla']);
    Route::post('/planilla/plantillas/{id}/asignar', [PlanillaController::class, 'asignarPlantilla']);

    // Historial
    Route::get('/planilla/historial/{empleadoId}', [PlanillaController::class, 'historial']);
    Route::post('/planilla/restaurar-version/{historialId}', [PlanillaController::class, 'restaurarVersion']);

    // Pagos
    Route::get('/planilla/pagos', [PlanillaController::class, 'pagos']);
    Route::post('/planilla/pagos', [PlanillaController::class, 'crearPago']);

    // Procesamiento masivo
    Route::post('/planilla/procesar', [PlanillaController::class, 'procesarNomina']);

    // Email Builder (nuevo constructor visual)
    Route::get('/email-builder/campaigns', [EmailBuilderController::class, 'campaigns']);
    Route::post('/email-builder/campaigns', [EmailBuilderController::class, 'storeCampaign']);
    Route::get('/email-builder/campaigns/{id}', [EmailBuilderController::class, 'showCampaign']);
    Route::put('/email-builder/campaigns/{id}', [EmailBuilderController::class, 'updateCampaign']);
    Route::delete('/email-builder/campaigns/{id}', [EmailBuilderController::class, 'destroyCampaign']);
    Route::post('/email-builder/campaigns/{id}/recipients', [EmailBuilderController::class, 'addRecipients']);
    Route::post('/email-builder/campaigns/{id}/send', [EmailBuilderController::class, 'sendCampaign']);
    Route::get('/email-builder/campaigns/{id}/analytics', [EmailBuilderController::class, 'analytics']);
    Route::get('/email-builder/templates', [EmailBuilderController::class, 'templates']);
    Route::post('/email-builder/templates', [EmailBuilderController::class, 'storeTemplate']);
    Route::get('/email-builder/templates/{id}', [EmailBuilderController::class, 'showTemplate']);
    Route::put('/email-builder/templates/{id}', [EmailBuilderController::class, 'updateTemplate']);
    Route::delete('/email-builder/templates/{id}', [EmailBuilderController::class, 'destroyTemplate']);
    Route::get('/email-builder/dashboard', [EmailBuilderController::class, 'dashboard']);
    Route::post('/email-builder/upload', [EmailBuilderController::class, 'uploadImage']);
    Route::get('/email-builder/images', [EmailBuilderController::class, 'listImages']);

    // CRM
    Route::get('/crm/dashboard', [CrmController::class, 'dashboard']);
    Route::get('/crm/oportunidades', [CrmController::class, 'oportunidades']);
    Route::post('/crm/oportunidades', [CrmController::class, 'crearOportunidad']);
    Route::post('/crm/oportunidades/{id}/mover', [CrmController::class, 'moverOportunidad']);
    Route::post('/crm/oportunidades/{id}/cerrar', [CrmController::class, 'cerrarOportunidad']);
    Route::get('/crm/etapas', [CrmController::class, 'etapas']);
    Route::post('/crm/etapas', [CrmController::class, 'crearEtapa']);
    Route::get('/crm/actividades', [CrmController::class, 'actividades']);
    Route::post('/crm/actividades', [CrmController::class, 'crearActividad']);

    // Tesorería
    Route::get('/tesoreria', [TesoreriaController::class, 'index']);
    Route::post('/tesoreria', [TesoreriaController::class, 'store']);
    Route::put('/tesoreria/{id}', [TesoreriaController::class, 'update']);
    Route::delete('/tesoreria/{id}', [TesoreriaController::class, 'destroy']);

    // Cuentas por Cobrar
    Route::get('/cuentas-cobrar', [CuentasCobrarController::class, 'index']);
    Route::post('/cuentas-cobrar', [CuentasCobrarController::class, 'store']);
    Route::put('/cuentas-cobrar/{id}', [CuentasCobrarController::class, 'update']);
    Route::delete('/cuentas-cobrar/{id}', [CuentasCobrarController::class, 'destroy']);
    Route::post('/cuentas-cobrar/{id}/pago', [CuentasCobrarController::class, 'registrarPago']);

    // Presupuestos
    Route::get('/presupuestos', [PresupuestoController::class, 'index']);
    Route::post('/presupuestos', [PresupuestoController::class, 'store']);
    Route::get('/presupuestos/{id}', [PresupuestoController::class, 'show']);

    // Facturación Electrónica
    Route::get('/facturacion-electronica', [FacturacionElectronicaController::class, 'index']);
    Route::post('/facturacion-electronica/emitir', [FacturacionElectronicaController::class, 'emitir']);
    Route::get('/facturacion-electronica/{id}', [FacturacionElectronicaController::class, 'show']);
    Route::post('/facturacion-electronica/{id}/reenviar', [FacturacionElectronicaController::class, 'reenviar']);

    // Ticket Designer
    Route::get('/ticket-designer', [TicketDesignerController::class, 'index']);
    Route::post('/ticket-designer', [TicketDesignerController::class, 'guardar']);
    Route::post('/ticket-designer/logo', [TicketDesignerController::class, 'subirLogo']);

    // Cotizacion Designer
    Route::get('/cotizacion-designer', [CotizacionDesignerController::class, 'index']);
    Route::post('/cotizacion-designer', [CotizacionDesignerController::class, 'guardar']);
    Route::post('/cotizacion-designer/logo', [CotizacionDesignerController::class, 'subirLogo']);

    // Configuración
    Route::get('/configuracion', [ConfiguracionController::class, 'index']);
    Route::post('/configuracion', [ConfiguracionController::class, 'guardar']);
    Route::get('/configuracion/empresa', [ConfiguracionController::class, 'empresa']);
    Route::post('/configuracion/empresa', [ConfiguracionController::class, 'guardarEmpresa']);
    Route::get('/configuracion/ubicaciones', [ConfiguracionController::class, 'ubicaciones']);
    Route::post('/configuracion/ubicaciones', [ConfiguracionController::class, 'crearUbicacion']);
    Route::put('/configuracion/ubicaciones/{id}', [ConfiguracionController::class, 'actualizarUbicacion']);

    Route::get('/configuracion/cajas', [ConfiguracionController::class, 'cajas']);
    Route::post('/configuracion/cajas', [ConfiguracionController::class, 'crearCaja']);
    Route::put('/configuracion/cajas/{id}', [ConfiguracionController::class, 'actualizarCaja']);

    Route::get('/configuracion/categorias', [ConfiguracionController::class, 'categorias']);
    Route::post('/configuracion/categorias', [ConfiguracionController::class, 'crearCategoria']);
    Route::put('/configuracion/categorias/{id}', [ConfiguracionController::class, 'actualizarCategoria']);

    Route::get('/configuracion/cliente-categorias', [ConfiguracionController::class, 'clienteCategorias']);
    Route::post('/configuracion/cliente-categorias', [ConfiguracionController::class, 'crearClienteCategoria']);
    Route::put('/configuracion/cliente-categorias/{id}', [ConfiguracionController::class, 'actualizarClienteCategoria']);
    Route::get('/configuracion/tasas-cambio', [ConfiguracionController::class, 'tasasCambio']);
    Route::post('/configuracion/tasas-cambio', [ConfiguracionController::class, 'guardarTasasCambio']);
    Route::post('/configuracion/idioma', [ConfiguracionController::class, 'idioma']);
    Route::post('/configuracion/divisa', [ConfiguracionController::class, 'divisa']);
    Route::get('/configuracion/preferencias', [ConfiguracionController::class, 'obtenerPreferencias']);

    Route::get('/configuracion/chats/retencion', [ConfiguracionController::class, 'retencionChats']);
    Route::post('/configuracion/chats/retencion', [ConfiguracionController::class, 'guardarRetencionChats']);
    Route::post('/configuracion/chats/limpiar', [ConfiguracionController::class, 'limpiarChats']);

    // Configuración SMTP / Email
    Route::get('/configuracion/smtp', [ConfiguracionController::class, 'smtpConfig']);
    Route::post('/configuracion/smtp', [ConfiguracionController::class, 'guardarSmtp']);
    Route::post('/configuracion/smtp/probar', [ConfiguracionController::class, 'probarSmtp']);

    // Roles y Permisos
    Route::get('/roles', [RolController::class, 'index']);
    Route::post('/roles', [RolController::class, 'store']);
    Route::put('/roles/{id}', [RolController::class, 'update']);
    Route::delete('/roles/{id}', [RolController::class, 'destroy']);
    Route::get('/roles/permisos', [RolController::class, 'permisosDisponibles']);

    // Notificaciones dinámicas del sistema
    Route::get('/notificaciones-sistema', [NotificacionController::class, 'index']);

    // Notificaciones personalizadas
    Route::get('/notificaciones', [NotificacionPersonalizadaController::class, 'index']);
    Route::post('/notificaciones', [NotificacionPersonalizadaController::class, 'store']);
    Route::post('/notificaciones/{id}/leida', [NotificacionPersonalizadaController::class, 'marcarLeida']);
    Route::post('/notificaciones/leer-todas', [NotificacionPersonalizadaController::class, 'marcarTodasLeidas']);
    Route::delete('/notificaciones/{id}', [NotificacionPersonalizadaController::class, 'destroy']);
    Route::delete('/notificaciones/{id}/descartar', [NotificacionPersonalizadaController::class, 'descartar']);
    Route::get('/notificaciones/tipos', [NotificacionPersonalizadaController::class, 'tipos']);
    Route::get('/notificaciones/unread-count', [NotificacionPersonalizadaController::class, 'unreadCount']);

    // Formularios / Sitio Web
    Route::get('/formularios', [FormularioController::class, 'index']);
    Route::post('/formularios', [FormularioController::class, 'store']);
    Route::get('/formularios/respuestas', [FormularioController::class, 'respuestas']);
    Route::post('/formularios/respuestas/{id}/atender', [FormularioController::class, 'atender']);

    // Chat Interno
    Route::get('/chats', [ChatController::class, 'index']);
    Route::post('/chats', [ChatController::class, 'store']);
    Route::get('/chats/{id}', [ChatController::class, 'show']);
    Route::get('/chats/{id}/mensajes', [ChatController::class, 'mensajes']);
    Route::post('/chats/{id}/mensajes', [ChatController::class, 'enviarMensaje']);
    Route::get('/chats/{chatId}/mensajes/{mensajeId}/adjunto', [ChatController::class, 'descargarAdjunto']);
    Route::get('/chats/{chatId}/mensajes/{mensajeId}/ver', [ChatController::class, 'verAdjunto']);
    Route::post('/chats/{id}/leido', [ChatController::class, 'marcarLeido']);
    Route::post('/chats/{id}/cerrar', [ChatController::class, 'cerrar']);
    Route::post('/chats/{id}/participantes', [ChatController::class, 'agregarParticipante']);
    Route::get('/chats-cerrados', [ChatController::class, 'cerrados']);
    Route::delete('/chats/{id}', [ChatController::class, 'destroy']);
});
