<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RolController extends Controller
{
    public function index()
    {
        $roles = Role::orderBy('nombre')->get()->map(function ($r) {
            $r->usuarios_count = DB::table('usuarios')->where('rol_id', $r->id)->count();
            return $r;
        });
        return response()->json(['roles' => $roles]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:100',
            'descripcion' => 'nullable|string',
            'permisos' => 'nullable|array',
        ]);

        $rol = Role::create([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'permisos' => $request->permisos ?? [],
            'activo' => $request->activo ?? true,
        ]);

        return response()->json(['success' => true, 'rol' => $rol]);
    }

    public function update(Request $request, $id)
    {
        $rol = Role::find($id);
        if (!$rol) return response()->json(['error' => 'Rol no encontrado'], 404);

        $data = $request->only(['nombre', 'descripcion', 'permisos', 'activo']);
        if (isset($data['permisos']) && !is_array($data['permisos'])) {
            $data['permisos'] = json_decode($data['permisos'], true) ?? [];
        }

        $rol->update($data);
        return response()->json(['success' => true, 'rol' => $rol]);
    }

    public function destroy($id)
    {
        $usuarios = DB::table('usuarios')->where('rol_id', $id)->count();
        if ($usuarios > 0) {
            return response()->json(['error' => 'No se puede eliminar el rol porque tiene usuarios asignados'], 422);
        }
        Role::destroy($id);
        return response()->json(['success' => true]);
    }

    public function permisosDisponibles()
    {
        $modulos = [
            ['seccion' => 'Principal', 'items' => [
                ['slug' => 'dashboard', 'nombre' => 'Dashboard', 'icono' => 'fas fa-home'],
                ['slug' => 'business_intelligence', 'nombre' => 'Business Intelligence', 'icono' => 'fas fa-brain'],
                ['slug' => 'geo_business', 'nombre' => 'GeoBusiness', 'icono' => 'fas fa-map-marked-alt'],
                ['slug' => 'reportes', 'nombre' => 'Reportes', 'icono' => 'fas fa-chart-bar'],
                ['slug' => 'reportes_exportar', 'nombre' => '— Exportar reportes', 'icono' => 'fas fa-file-export'],
            ]],
            ['seccion' => 'Punto de Venta', 'items' => [
                ['slug' => 'caja', 'nombre' => 'Caja Rápida', 'icono' => 'fas fa-cash-register'],
                ['slug' => 'caja_cerrar', 'nombre' => '— Cerrar caja', 'icono' => 'fas fa-lock'],
                ['slug' => 'caja_descuento', 'nombre' => '— Aplicar descuentos', 'icono' => 'fas fa-percent'],
                ['slug' => 'ventas', 'nombre' => 'Historial Ventas', 'icono' => 'fas fa-receipt'],
                ['slug' => 'ventas_ver_detalle', 'nombre' => '— Ver detalle', 'icono' => 'fas fa-eye'],
                ['slug' => 'ventas_editar', 'nombre' => '— Editar ventas', 'icono' => 'fas fa-pen'],
                ['slug' => 'ventas_eliminar', 'nombre' => '— Eliminar ventas', 'icono' => 'fas fa-trash'],
                ['slug' => 'ventas_exportar', 'nombre' => '— Exportar ventas', 'icono' => 'fas fa-file-export'],
                ['slug' => 'ventas_reembolsar', 'nombre' => '— Reembolsar', 'icono' => 'fas fa-undo-alt'],
                ['slug' => 'devoluciones', 'nombre' => 'Devoluciones', 'icono' => 'fas fa-undo'],
                ['slug' => 'devoluciones_aprobar', 'nombre' => '— Aprobar devoluciones', 'icono' => 'fas fa-check'],
                ['slug' => 'notas_credito', 'nombre' => 'Notas de Crédito', 'icono' => 'fas fa-file-invoice'],
                ['slug' => 'notas_credito_anular', 'nombre' => '— Anular NC', 'icono' => 'fas fa-ban'],
                ['slug' => 'cotizaciones', 'nombre' => 'Cotizaciones', 'icono' => 'fas fa-file-alt'],
                ['slug' => 'cotizaciones_crear', 'nombre' => '— Crear cotizaciones', 'icono' => 'fas fa-plus'],
                ['slug' => 'cotizaciones_editar', 'nombre' => '— Editar cotizaciones', 'icono' => 'fas fa-pen'],
                ['slug' => 'cotizaciones_eliminar', 'nombre' => '— Eliminar cotizaciones', 'icono' => 'fas fa-trash'],
                ['slug' => 'cotizaciones_aprobar', 'nombre' => '— Aprobar/rechazar', 'icono' => 'fas fa-check-circle'],
                ['slug' => 'cotizaciones_convertir', 'nombre' => '— Convertir a factura', 'icono' => 'fas fa-file-invoice'],
                ['slug' => 'cotizaciones_ver_todas', 'nombre' => '— Ver todas las cotizaciones', 'icono' => 'fas fa-eye'],
                ['slug' => 'enviar_cotizacion', 'nombre' => 'Enviar Cotización', 'icono' => 'fas fa-paper-plane'],
                ['slug' => 'cotizacion_designer', 'nombre' => 'Diseñador Cotización', 'icono' => 'fas fa-file-invoice'],
                ['slug' => 'pedidos', 'nombre' => 'Pedidos', 'icono' => 'fas fa-clipboard-list'],
                ['slug' => 'pedidos_editar', 'nombre' => '— Editar pedidos', 'icono' => 'fas fa-pen'],
                ['slug' => 'pedidos_eliminar', 'nombre' => '— Eliminar pedidos', 'icono' => 'fas fa-trash'],
                ['slug' => 'combos', 'nombre' => 'Combos y Descuentos', 'icono' => 'fas fa-tags'],
                ['slug' => 'combos_crear', 'nombre' => '— Crear combos', 'icono' => 'fas fa-plus'],
                ['slug' => 'combos_editar', 'nombre' => '— Editar combos', 'icono' => 'fas fa-pen'],
                ['slug' => 'ticket_designer', 'nombre' => 'Ticket de Venta', 'icono' => 'fas fa-print'],
            ]],
            ['seccion' => 'Inventario', 'items' => [
                ['slug' => 'productos', 'nombre' => 'Productos', 'icono' => 'fas fa-boxes-stacked'],
                ['slug' => 'productos_crear', 'nombre' => '— Crear productos', 'icono' => 'fas fa-plus'],
                ['slug' => 'productos_editar', 'nombre' => '— Editar productos', 'icono' => 'fas fa-pen'],
                ['slug' => 'productos_eliminar', 'nombre' => '— Eliminar productos', 'icono' => 'fas fa-trash'],
                ['slug' => 'productos_ajustar_precio', 'nombre' => '— Ajustar precios', 'icono' => 'fas fa-dollar-sign'],
                ['slug' => 'productos_gestionar_stock', 'nombre' => '— Gestionar stock', 'icono' => 'fas fa-cubes'],
                ['slug' => 'catalogo', 'nombre' => 'Catálogo General', 'icono' => 'fas fa-book-open'],
                ['slug' => 'inventario_ubicacion', 'nombre' => 'Inventario por Ubicación', 'icono' => 'fas fa-warehouse'],
                ['slug' => 'etiquetas', 'nombre' => 'Etiquetas', 'icono' => 'fas fa-tag'],
                ['slug' => 'traspasos', 'nombre' => 'Traspasos', 'icono' => 'fas fa-exchange-alt'],
                ['slug' => 'traspasos_aprobar', 'nombre' => '— Aprobar traspasos', 'icono' => 'fas fa-check'],
                ['slug' => 'traspasos_enviar', 'nombre' => '— Enviar traspasos', 'icono' => 'fas fa-paper-plane'],
                ['slug' => 'ajustes_inventario', 'nombre' => 'Ajustes Inventario', 'icono' => 'fas fa-sliders-h'],
                ['slug' => 'ajustes_inventario_aprobar', 'nombre' => '— Aprobar ajustes', 'icono' => 'fas fa-check-circle'],
                ['slug' => 'rentabilidad', 'nombre' => 'Rentabilidad', 'icono' => 'fas fa-coins'],
            ]],
            ['seccion' => 'Compras', 'items' => [
                ['slug' => 'compras', 'nombre' => 'Compras', 'icono' => 'fas fa-shopping-cart'],
                ['slug' => 'compras_crear', 'nombre' => '— Crear compras', 'icono' => 'fas fa-plus'],
                ['slug' => 'compras_editar', 'nombre' => '— Editar compras', 'icono' => 'fas fa-pen'],
                ['slug' => 'compras_eliminar', 'nombre' => '— Eliminar compras', 'icono' => 'fas fa-trash'],
                ['slug' => 'compras_recibir', 'nombre' => '— Recibir compras', 'icono' => 'fas fa-box-open'],
                ['slug' => 'proveedores', 'nombre' => 'Proveedores', 'icono' => 'fas fa-truck'],
                ['slug' => 'proveedores_crear', 'nombre' => '— Crear proveedores', 'icono' => 'fas fa-plus'],
                ['slug' => 'proveedores_editar', 'nombre' => '— Editar proveedores', 'icono' => 'fas fa-pen'],
            ]],
            ['seccion' => 'CRM y Marketing', 'items' => [
                ['slug' => 'clientes', 'nombre' => 'Clientes', 'icono' => 'fas fa-users'],
                ['slug' => 'clientes_crear', 'nombre' => '— Crear clientes', 'icono' => 'fas fa-user-plus'],
                ['slug' => 'clientes_editar', 'nombre' => '— Editar clientes', 'icono' => 'fas fa-pen'],
                ['slug' => 'clientes_eliminar', 'nombre' => '— Eliminar clientes', 'icono' => 'fas fa-trash'],
                ['slug' => 'clientes_ver_credito', 'nombre' => '— Ver límite de crédito', 'icono' => 'fas fa-credit-card'],
                ['slug' => 'crm', 'nombre' => 'CRM', 'icono' => 'fas fa-handshake'],
                ['slug' => 'crm_editar_pipeline', 'nombre' => '— Editar pipeline', 'icono' => 'fas fa-project-diagram'],
                ['slug' => 'email_builder', 'nombre' => 'Constructor de Correos', 'icono' => 'fas fa-paint-brush'],
                ['slug' => 'email_builder_enviar', 'nombre' => '— Enviar campañas', 'icono' => 'fas fa-paper-plane'],
                ['slug' => 'plantillas_email', 'nombre' => 'Plantillas Email', 'icono' => 'fas fa-palette'],
                ['slug' => 'registro_emails', 'nombre' => 'Registro de Emails', 'icono' => 'fas fa-inbox'],
                ['slug' => 'formularios', 'nombre' => 'Sitio Web', 'icono' => 'fas fa-globe'],
                ['slug' => 'formularios_editar', 'nombre' => '— Editar formularios', 'icono' => 'fas fa-pen'],
            ]],
            ['seccion' => 'Finanzas', 'items' => [
                ['slug' => 'cuentas_cobrar', 'nombre' => 'Cuentas por Cobrar', 'icono' => 'fas fa-hand-holding-usd'],
                ['slug' => 'cuentas_cobrar_cobrar', 'nombre' => '— Registrar cobros', 'icono' => 'fas fa-money-bill'],
                ['slug' => 'cuentas_cobrar_condonar', 'nombre' => '— Condonar deuda', 'icono' => 'fas fa-hand-holding-heart'],
                ['slug' => 'listas_precios', 'nombre' => 'Listas de Precios', 'icono' => 'fas fa-list-ol'],
                ['slug' => 'listas_precios_crear', 'nombre' => '— Crear listas', 'icono' => 'fas fa-plus'],
                ['slug' => 'contabilidad', 'nombre' => 'Contabilidad', 'icono' => 'fas fa-calculator'],
                ['slug' => 'contabilidad_asientos', 'nombre' => '— Crear asientos', 'icono' => 'fas fa-plus-circle'],
                ['slug' => 'tesoreria', 'nombre' => 'Tesorería', 'icono' => 'fas fa-vault'],
                ['slug' => 'tesoreria_movimientos', 'nombre' => '— Registrar movimientos', 'icono' => 'fas fa-exchange-alt'],
                ['slug' => 'presupuestos', 'nombre' => 'Presupuestos', 'icono' => 'fas fa-file-invoice-dollar'],
                ['slug' => 'presupuestos_aprobar', 'nombre' => '— Aprobar presupuestos', 'icono' => 'fas fa-check'],
                ['slug' => 'facturacion_electronica', 'nombre' => 'Facturación Electrónica', 'icono' => 'fas fa-file-signature'],
                ['slug' => 'facturacion_electronica_enviar', 'nombre' => '— Enviar a Hacienda', 'icono' => 'fas fa-paper-plane'],
            ]],
            ['seccion' => 'Comunicación', 'items' => [
                ['slug' => 'chats', 'nombre' => 'Chat Interno', 'icono' => 'fas fa-comments'],
                ['slug' => 'chats_cerrados', 'nombre' => 'Chats Cerrados', 'icono' => 'fas fa-archive'],
                ['slug' => 'chats_administrar', 'nombre' => '— Administrar chats', 'icono' => 'fas fa-user-shield'],
                ['slug' => 'notificaciones', 'nombre' => 'Notificaciones', 'icono' => 'fas fa-bell'],
                ['slug' => 'notificaciones_enviar', 'nombre' => '— Enviar notificaciones', 'icono' => 'fas fa-broadcast-tower'],
            ]],
            ['seccion' => 'Administración', 'items' => [
                ['slug' => 'usuarios', 'nombre' => 'Usuarios y Permisos', 'icono' => 'fas fa-user-shield'],
                ['slug' => 'usuarios_crear', 'nombre' => '— Crear usuarios', 'icono' => 'fas fa-user-plus'],
                ['slug' => 'usuarios_editar', 'nombre' => '— Editar usuarios', 'icono' => 'fas fa-user-edit'],
                ['slug' => 'usuarios_eliminar', 'nombre' => '— Eliminar usuarios', 'icono' => 'fas fa-user-times'],
                ['slug' => 'usuarios_reset_password', 'nombre' => '— Resetear contraseñas', 'icono' => 'fas fa-key'],
                ['slug' => 'roles', 'nombre' => 'Roles y Permisos', 'icono' => 'fas fa-user-cog'],
                ['slug' => 'roles_crear', 'nombre' => '— Crear roles', 'icono' => 'fas fa-plus'],
                ['slug' => 'roles_editar', 'nombre' => '— Editar roles', 'icono' => 'fas fa-pen'],
                ['slug' => 'planilla', 'nombre' => 'Planilla', 'icono' => 'fas fa-money-check-alt'],
                ['slug' => 'planilla_procesar', 'nombre' => '— Procesar nómina', 'icono' => 'fas fa-cogs'],
                ['slug' => 'planilla_configurar', 'nombre' => '— Configurar fórmulas', 'icono' => 'fas fa-calculator'],
                ['slug' => 'planilla_plantillas', 'nombre' => '— Gestionar plantillas', 'icono' => 'fas fa-copy'],
                ['slug' => 'planilla_simular', 'nombre' => '— Simular cálculos', 'icono' => 'fas fa-play-circle'],
                ['slug' => 'planilla_historial', 'nombre' => '— Ver historial', 'icono' => 'fas fa-history'],
                ['slug' => 'productividad', 'nombre' => 'Productividad', 'icono' => 'fas fa-user-clock'],
                ['slug' => 'productividad_ver_todos', 'nombre' => '— Ver productividad de todos', 'icono' => 'fas fa-users'],
                ['slug' => 'auditoria', 'nombre' => 'Auditoría', 'icono' => 'fas fa-shield-alt'],
                ['slug' => 'auditoria_exportar', 'nombre' => '— Exportar auditoría', 'icono' => 'fas fa-file-export'],
                ['slug' => 'configuracion', 'nombre' => 'Configuración', 'icono' => 'fas fa-cog'],
                ['slug' => 'configuracion_avanzada', 'nombre' => '— Config. avanzada', 'icono' => 'fas fa-cogs'],
                ['slug' => 'configuracion_empresa', 'nombre' => '— Datos de empresa', 'icono' => 'fas fa-building'],
                ['slug' => 'configuracion_sucursales', 'nombre' => '— Sucursales', 'icono' => 'fas fa-store'],
            ]],
        ];
        return response()->json(['modulos' => $modulos]);
    }
}
