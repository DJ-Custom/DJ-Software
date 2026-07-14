<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function stats(Request $request)
    {
        $user = $request->user();

        // Ventas del día
        $ventasHoy = DB::table('ventas')
            ->whereDate('created_at', today())
            ->where('estado', 'completada')
            ->selectRaw('COUNT(*) as cantidad, COALESCE(SUM(total), 0) as total')
            ->first();

        // Ventas del mes
        $ventasMes = DB::table('ventas')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->where('estado', 'completada')
            ->selectRaw('COUNT(*) as cantidad, COALESCE(SUM(total), 0) as total')
            ->first();

        // Productos en stock
        $productosStock = DB::table('productos')
            ->where('activo', 1)
            ->count();

        // Productos bajo stock
        $bajosStock = DB::table('productos')
            ->where('activo', 1)
            ->whereColumn('stock', '<=', 'stock_minimo')
            ->count();

        // Total clientes
        $totalClientes = DB::table('clientes')
            ->where('activo', 1)
            ->count();

        // Devoluciones pendientes
        $devolucionesPendientes = DB::table('devoluciones')
            ->where('estado', 'pendiente')
            ->count();

        // Ticket promedio hoy
        $ticketPromedioHoy = DB::table('ventas')
            ->whereDate('created_at', today())
            ->where('estado', 'completada')
            ->avg('total') ?? 0;

        // Ticket promedio mes
        $ticketPromedioMes = DB::table('ventas')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->where('estado', 'completada')
            ->avg('total') ?? 0;

        // Ventas semana vs semana anterior
        $inicioSemana = now()->startOfWeek();
        $finSemana = now();
        $inicioSemanaAnt = now()->subWeek()->startOfWeek();
        $finSemanaAnt = now()->subWeek();

        $ventasSemana = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween('created_at', [$inicioSemana, $finSemana])
            ->sum('total');
        $ventasSemanaAnt = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween('created_at', [$inicioSemanaAnt, $finSemanaAnt])
            ->sum('total');

        // Margen bruto estimado (mes)
        $margenBruto = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereMonth('v.created_at', now()->month)
            ->whereYear('v.created_at', now()->year)
            ->selectRaw('COALESCE(SUM(vd.subtotal - (vd.cantidad * p.precio_compra)), 0) as margen')
            ->value('margen') ?? 0;

        // Productos sin movimiento (30 días)
        $sinMovimiento = DB::table('productos')
            ->where('activo', 1)
            ->whereNotExists(function ($q) {
                $q->select(DB::raw(1))
                    ->from('venta_detalle')
                    ->join('ventas', 'ventas.id', '=', 'venta_detalle.venta_id')
                    ->whereColumn('venta_detalle.producto_id', 'productos.id')
                    ->where('ventas.estado', 'completada')
                    ->where('ventas.created_at', '>=', now()->subDays(30));
            })
            ->count();

        // Clientes nuevos este mes
        $clientesNuevos = DB::table('clientes')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        // Clientes recurrentes (más de 1 compra)
        $clientesRecurrentesQuery = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->whereNotNull('cliente_id')
            ->select('cliente_id')
            ->groupBy('cliente_id')
            ->havingRaw('COUNT(*) > 1');

        $clientesRecurrentes = DB::query()
            ->fromSub($clientesRecurrentesQuery, 'clientes_recurrentes')
            ->count();

        // Valor inventario
        $valorInventario = DB::table('productos')
            ->where('activo', 1)
            ->selectRaw('COALESCE(SUM(stock * precio_compra), 0) as valor')
            ->value('valor') ?? 0;

        // Cuentas por cobrar
        $cuentasPorCobrar = DB::table('ventas')
            ->where('estado', 'completada')
            ->where('metodo_pago', 'pendiente')
            ->sum('total') ?? 0;

        // Top vendedor del mes
        $topVendedor = DB::table('ventas')
            ->join('usuarios', 'usuarios.id', '=', 'ventas.usuario_id')
            ->where('ventas.estado', 'completada')
            ->whereMonth('ventas.created_at', now()->month)
            ->whereYear('ventas.created_at', now()->year)
            ->selectRaw('usuarios.nombre, COUNT(*) as ventas, SUM(ventas.total) as total')
            ->groupBy('usuarios.id', 'usuarios.nombre')
            ->orderByDesc('total')
            ->first();

        // Ventas recientes
        $ventasRecientes = DB::table('ventas')
            ->leftJoin('usuarios', 'ventas.usuario_id', '=', 'usuarios.id')
            ->leftJoin('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->where('ventas.estado', 'completada')
            ->orderByDesc('ventas.created_at')
            ->limit(10)
            ->select(
                'ventas.id', 'ventas.numero_factura', 'ventas.total',
                'ventas.metodo_pago', 'ventas.created_at',
                'usuarios.nombre as cajero',
                'clientes.nombre as cliente_nombre'
            )
            ->get();

        // Productos bajo stock (detalle)
        $productosBajoStock = DB::table('productos')
            ->leftJoin('categorias', 'productos.categoria_id', '=', 'categorias.id')
            ->where('productos.activo', 1)
            ->whereColumn('productos.stock', '<=', 'productos.stock_minimo')
            ->orderBy('productos.stock')
            ->limit(10)
            ->select(
                'productos.id', 'productos.nombre', 'productos.codigo',
                'productos.stock', 'productos.stock_minimo',
                'categorias.nombre as categoria'
            )
            ->get();

        // Productos más vendidos hoy
        $topHoy = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereDate('v.created_at', today())
            ->selectRaw('p.nombre, SUM(vd.cantidad) as unidades, SUM(vd.subtotal) as ingresos')
            ->groupBy('p.id', 'p.nombre')
            ->orderByDesc('unidades')
            ->limit(5)
            ->get();

        // Compras del mes
        $comprasMes = DB::table('compras')
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->where('estado', 'completada')
            ->sum('total') ?? 0;

        return response()->json([
            'ventas_hoy' => $ventasHoy,
            'ventas_mes' => $ventasMes,
            'productos_stock' => $productosStock,
            'bajos_stock' => $bajosStock,
            'total_clientes' => $totalClientes,
            'devoluciones_pendientes' => $devolucionesPendientes,
            'ticket_promedio_hoy' => round($ticketPromedioHoy, 2),
            'ticket_promedio_mes' => round($ticketPromedioMes, 2),
            'ventas_semana' => round($ventasSemana, 2),
            'ventas_semana_anterior' => round($ventasSemanaAnt, 2),
            'crecimiento_semanal' => $ventasSemanaAnt > 0 ? round((($ventasSemana - $ventasSemanaAnt) / $ventasSemanaAnt) * 100, 1) : 0,
            'margen_bruto' => round($margenBruto, 2),
            'sin_movimiento' => $sinMovimiento,
            'clientes_nuevos' => $clientesNuevos,
            'clientes_recurrentes' => $clientesRecurrentes,
            'valor_inventario' => round($valorInventario, 2),
            'cuentas_por_cobrar' => round($cuentasPorCobrar, 2),
            'top_vendedor' => $topVendedor,
            'top_hoy' => $topHoy,
            'compras_mes' => round($comprasMes, 2),
            'ventas_recientes' => $ventasRecientes,
            'productos_bajo_stock' => $productosBajoStock,
        ]);
    }
}
