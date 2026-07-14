<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BusinessIntelligenceController extends Controller
{
    public function dashboard(Request $request)
    {
        $periodo = $request->get('periodo', '30');
        $desde = match($periodo) {
            '7' => now()->subDays(7),
            '30' => now()->subDays(30),
            '90' => now()->subDays(90),
            '365' => now()->subYear(),
            default => $request->get('desde') ? \Carbon\Carbon::parse($request->get('desde')) : now()->subDays(30),
        };
        $hasta = $request->get('hasta') ? \Carbon\Carbon::parse($request->get('hasta')) : now();

        $ventasMes = DB::table('ventas')->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [now()->startOfMonth(), now()])->sum('total');
        $ventasMesAnt = DB::table('ventas')->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [now()->subMonth()->startOfMonth(), now()->subMonth()->endOfMonth()])->sum('total');

        $devolucionesMes = DB::table('devoluciones')->where('estado', 'aprobada')
            ->whereBetween('created_at', [now()->startOfMonth(), now()])->count();
        $ventasCountMes = DB::table('ventas')->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [now()->startOfMonth(), now()])->count();

        $inventarioValor = DB::table('productos')->where('activo', 1)->selectRaw('SUM(stock * precio_compra) as valor')->value('valor') ?? 0;
        $sinMovimiento = DB::table('productos')->where('activo', 1)
            ->where(function($q) { $q->whereNull('updated_at')->orWhere('updated_at', '<', now()->subDays(30)); })->count();
        $stockBajo = DB::table('productos')->where('activo', 1)->whereColumn('stock', '<=', 'stock_minimo')->count();

        // Rentabilidad por producto
        $rentabilidadProductos = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween('v.created_at', [$desde, $hasta])
            ->selectRaw('p.nombre, SUM(vd.cantidad) as unidades, SUM(vd.subtotal) as ingresos, SUM(vd.cantidad * p.precio_compra) as costo')
            ->groupBy('p.id', 'p.nombre')
            ->orderByDesc('ingresos')
            ->limit(10)
            ->get();

        foreach ($rentabilidadProductos as $rp) {
            $rp->margen = round($rp->ingresos - $rp->costo, 2);
            $rp->porcentaje = $rp->ingresos > 0 ? round((($rp->ingresos - $rp->costo) / $rp->ingresos) * 100, 1) : 0;
        }

        // Productos con más devoluciones
        $productosDevoluciones = DB::table('devolucion_detalle as dd')
            ->join('devoluciones as d', 'dd.devolucion_id', '=', 'd.id')
            ->join('productos as p', 'dd.producto_id', '=', 'p.id')
            ->where('d.estado', 'aprobada')
            ->whereBetween('d.created_at', [$desde, $hasta])
            ->selectRaw('p.nombre, COUNT(*) as devoluciones, SUM(dd.cantidad) as unidades_devueltas')
            ->groupBy('p.id', 'p.nombre')
            ->orderByDesc('devoluciones')
            ->limit(10)
            ->get();

        // Rotación de inventario (unidades vendidas / stock promedio)
        $rotacion = DB::table('productos as p')
            ->join('venta_detalle as vd', 'vd.producto_id', '=', 'p.id')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->where('v.estado', 'completada')
            ->whereBetween('v.created_at', [$desde, $hasta])
            ->where('p.activo', 1)
            ->where('p.stock', '>', 0)
            ->selectRaw('p.nombre, p.stock, SUM(vd.cantidad) as vendido, ROUND(SUM(vd.cantidad) / p.stock, 2) as rotacion')
            ->groupBy('p.id', 'p.nombre', 'p.stock')
            ->havingRaw('SUM(vd.cantidad) > 0')
            ->orderByDesc('rotacion')
            ->limit(10)
            ->get();

        // ABC analysis (Pareto de productos por ingresos)
        $abc = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween('v.created_at', [$desde, $hasta])
            ->selectRaw('p.nombre, SUM(vd.subtotal) as ingresos, SUM(vd.cantidad) as unidades')
            ->groupBy('p.id', 'p.nombre')
            ->orderByDesc('ingresos')
            ->get();

        $totalIngresosABC = $abc->sum('ingresos');
        $acumulado = 0;
        foreach ($abc as $item) {
            $acumulado += $item->ingresos;
            $item->pct_acumulado = $totalIngresosABC > 0 ? round(($acumulado / $totalIngresosABC) * 100, 1) : 0;
            if ($item->pct_acumulado <= 80) {
                $item->clase = 'A';
            } elseif ($item->pct_acumulado <= 95) {
                $item->clase = 'B';
            } else {
                $item->clase = 'C';
            }
        }

        // Ticket promedio
        $ticketPromedio = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween('created_at', [$desde, $hasta])
            ->avg('total') ?? 0;

        return response()->json([
            'kpis' => [
                'ventas_mes' => round($ventasMes, 2),
                'ventas_mes_anterior' => round($ventasMesAnt, 2),
                'crecimiento' => $ventasMesAnt > 0 ? round((($ventasMes - $ventasMesAnt) / $ventasMesAnt) * 100, 1) : 0,
                'devoluciones_mes' => $devolucionesMes,
                'tasa_devolucion' => $ventasCountMes > 0 ? round(($devolucionesMes / $ventasCountMes) * 100, 1) : 0,
                'inventario_valor' => round($inventarioValor, 2),
                'sin_movimiento_30d' => $sinMovimiento,
                'stock_bajo' => $stockBajo,
                'ticket_promedio' => round($ticketPromedio, 2),
            ],
            'tendencia_ventas' => $this->tendenciaVentas($desde, $hasta),
            'top_productos' => $this->topProductos($desde, $hasta),
            'top_clientes' => $this->topClientes($desde, $hasta),
            'metodos_pago' => $this->metodosPago($desde, $hasta),
            'ventas_por_hora' => $this->ventasPorHora($desde, $hasta),
            'ventas_por_dia' => $this->ventasPorDia($desde, $hasta),
            'ventas_por_categoria' => $this->ventasPorCategoria($desde, $hasta),
            'rentabilidad_productos' => $rentabilidadProductos,
            'productos_devoluciones' => $productosDevoluciones,
            'rotacion_inventario' => $rotacion,
            'abc_analysis' => $abc->take(15),
        ]);
    }

    private function tendenciaVentas($desde, $hasta)
    {
        return DB::table('ventas')->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [$desde, $hasta])
            ->selectRaw("DATE_FORMAT(created_at, '%Y-%m') as mes, SUM(total) as total, COUNT(*) as cantidad")
            ->groupByRaw("DATE_FORMAT(created_at, '%Y-%m')")
            ->orderBy('mes')->get();
    }

    private function topProductos($desde, $hasta)
    {
        return DB::table('venta_detalle')
            ->join('ventas', 'ventas.id', '=', 'venta_detalle.venta_id')
            ->join('productos', 'productos.id', '=', 'venta_detalle.producto_id')
            ->where('ventas.estado', '!=', 'cancelada')
            ->whereBetween('ventas.created_at', [$desde, $hasta])
            ->selectRaw('productos.nombre, SUM(venta_detalle.cantidad) as unidades, SUM(venta_detalle.subtotal) as ingresos')
            ->groupBy('productos.id', 'productos.nombre')
            ->orderByDesc('ingresos')->limit(10)->get();
    }

    private function topClientes($desde, $hasta)
    {
        return DB::table('ventas')
            ->join('clientes', 'clientes.id', '=', 'ventas.cliente_id')
            ->where('ventas.estado', '!=', 'cancelada')
            ->whereBetween('ventas.created_at', [$desde, $hasta])
            ->selectRaw('clientes.nombre, COUNT(*) as compras, SUM(ventas.total) as total')
            ->groupBy('clientes.id', 'clientes.nombre')
            ->orderByDesc('total')->limit(10)->get();
    }

    private function metodosPago($desde, $hasta)
    {
        return DB::table('ventas')
            ->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [$desde, $hasta])
            ->selectRaw('metodo_pago, COUNT(*) as cantidad, SUM(total) as total')
            ->groupBy('metodo_pago')->orderByDesc('total')->get();
    }

    private function ventasPorHora($desde, $hasta)
    {
        return DB::table('ventas')
            ->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [$desde, $hasta])
            ->selectRaw('HOUR(created_at) as hora, COUNT(*) as cantidad, SUM(total) as total')
            ->groupByRaw('HOUR(created_at)')->orderBy('hora')->get();
    }

    private function ventasPorDia($desde, $hasta)
    {
        return DB::table('ventas')
            ->where('estado', '!=', 'cancelada')
            ->whereBetween('created_at', [$desde, $hasta])
            ->selectRaw("DATE(created_at) as fecha, COUNT(*) as cantidad, SUM(total) as total")
            ->groupByRaw('DATE(created_at)')->orderBy('fecha')->get();
    }

    private function ventasPorCategoria($desde, $hasta)
    {
        return DB::table('venta_detalle')
            ->join('ventas', 'ventas.id', '=', 'venta_detalle.venta_id')
            ->join('productos', 'productos.id', '=', 'venta_detalle.producto_id')
            ->leftJoin('categorias', 'categorias.id', '=', 'productos.categoria_id')
            ->where('ventas.estado', '!=', 'cancelada')
            ->whereBetween('ventas.created_at', [$desde, $hasta])
            ->selectRaw("COALESCE(categorias.nombre, 'Sin Categoría') as categoria, SUM(venta_detalle.subtotal) as total, SUM(venta_detalle.cantidad) as unidades")
            ->groupByRaw("COALESCE(categorias.nombre, 'Sin Categoría')")
            ->orderByDesc('total')->get();
    }
}
