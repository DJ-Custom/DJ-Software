<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class NotificacionController extends Controller
{
    public function index()
    {
        $notificaciones = [];

        // 1. Productos bajos en stock
        $stockBajo = DB::table('productos')
            ->where('activo', 1)
            ->whereRaw('stock <= stock_minimo')
            ->where('stock_minimo', '>', 0)
            ->orderBy('stock', 'asc')
            ->limit(5)
            ->get(['id', 'nombre', 'stock', 'stock_minimo']);

        foreach ($stockBajo as $p) {
            $notificaciones[] = [
                'id' => 'stock_bajo_' . $p->id,
                'tipo' => 'stock_bajo',
                'icono' => 'fas fa-exclamation-triangle',
                'color' => '#ef4444',
                'titulo' => 'Stock bajo',
                'mensaje' => "'{$p->nombre}' tiene solo {$p->stock} unidad(es) (mín: {$p->stock_minimo})",
                'enlace' => '/productos',
                'fecha' => now()->toDateTimeString(),
            ];
        }

        // 2. Productos sin stock
        $sinStock = DB::table('productos')
            ->where('activo', 1)
            ->where('stock', '<=', 0)
            ->orderBy('nombre')
            ->limit(3)
            ->get(['id', 'nombre']);

        foreach ($sinStock as $p) {
            $notificaciones[] = [
                'id' => 'sin_stock_' . $p->id,
                'tipo' => 'sin_stock',
                'icono' => 'fas fa-box-open',
                'color' => '#f59e0b',
                'titulo' => 'Sin stock',
                'mensaje' => "'{$p->nombre}' está agotado",
                'enlace' => '/productos',
                'fecha' => now()->toDateTimeString(),
            ];
        }

        // 3. Cliente top del mes
        $clienteTop = DB::table('ventas')
            ->join('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->whereMonth('ventas.created_at', now()->month)
            ->whereYear('ventas.created_at', now()->year)
            ->where('ventas.estado', 'completada')
            ->select('clientes.id', 'clientes.nombre', DB::raw('SUM(ventas.total) as total_mes'))
            ->groupBy('clientes.id', 'clientes.nombre')
            ->orderByDesc('total_mes')
            ->first();

        if ($clienteTop) {
            $notificaciones[] = [
                'id' => 'cliente_top_' . $clienteTop->id,
                'tipo' => 'cliente_top',
                'icono' => 'fas fa-crown',
                'color' => '#eab308',
                'titulo' => 'Cliente del mes',
                'mensaje' => "{$clienteTop->nombre} es el cliente top con ₡" . number_format($clienteTop->total_mes, 0) . " este mes",
                'enlace' => '/clientes',
                'fecha' => now()->toDateTimeString(),
            ];
        }

        // 4. Producto top del mes
        $productoTop = DB::table('venta_detalle')
            ->join('productos', 'venta_detalle.producto_id', '=', 'productos.id')
            ->join('ventas', 'venta_detalle.venta_id', '=', 'ventas.id')
            ->whereMonth('ventas.created_at', now()->month)
            ->whereYear('ventas.created_at', now()->year)
            ->where('ventas.estado', 'completada')
            ->select('productos.id', 'productos.nombre', DB::raw('SUM(venta_detalle.cantidad) as cantidad_vendida'))
            ->groupBy('productos.id', 'productos.nombre')
            ->orderByDesc('cantidad_vendida')
            ->first();

        if ($productoTop) {
            $notificaciones[] = [
                'id' => 'producto_top_' . $productoTop->id,
                'tipo' => 'producto_top',
                'icono' => 'fas fa-fire',
                'color' => '#3b82f6',
                'titulo' => 'Producto top',
                'mensaje' => "'{$productoTop->nombre}' es el más vendido con {$productoTop->cantidad_vendida} unidad(es) este mes",
                'enlace' => '/productos',
                'fecha' => now()->toDateTimeString(),
            ];
        }

        // 5. Venta más reciente
        $ultimaVenta = DB::table('ventas')
            ->join('clientes', 'ventas.cliente_id', '=', 'clientes.id')
            ->where('ventas.estado', 'completada')
            ->orderByDesc('ventas.created_at')
            ->select('ventas.numero_factura', 'ventas.total', 'clientes.nombre as cliente_nombre', 'ventas.created_at')
            ->first();

        if ($ultimaVenta) {
            $notificaciones[] = [
                'id' => 'venta_reciente_' . md5($ultimaVenta->numero_factura . $ultimaVenta->created_at),
                'tipo' => 'venta_reciente',
                'icono' => 'fas fa-receipt',
                'color' => '#10b981',
                'titulo' => 'Venta reciente',
                'mensaje' => "Venta #{$ultimaVenta->numero_factura} por ₡" . number_format($ultimaVenta->total, 0) . " a {$ultimaVenta->cliente_nombre}",
                'enlace' => '/ventas',
                'fecha' => $ultimaVenta->created_at,
            ];
        }

        // 6. Devoluciones pendientes
        $devPendientes = DB::table('devoluciones')
            ->where('estado', 'pendiente')
            ->count();

        if ($devPendientes > 0) {
            $notificaciones[] = [
                'id' => 'devolucion_pendiente_' . date('Ym'),
                'tipo' => 'devolucion_pendiente',
                'icono' => 'fas fa-undo',
                'color' => '#8b5cf6',
                'titulo' => 'Devoluciones pendientes',
                'mensaje' => "Tienes {$devPendientes} devolución(es) pendientes de aprobar",
                'enlace' => '/devoluciones',
                'fecha' => now()->toDateTimeString(),
            ];
        }

        return response()->json([
            'notificaciones' => $notificaciones,
            'total' => count($notificaciones),
            'sin_leer' => count(array_filter($notificaciones, fn($n) => in_array($n['tipo'], ['stock_bajo', 'sin_stock', 'devolucion_pendiente']))),
        ]);
    }
}
