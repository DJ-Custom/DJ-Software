<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReporteController extends Controller
{
    public function ventasPeriodo(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $ventas = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween(DB::raw('DATE(created_at)'), [$desde, $hasta])
            ->selectRaw('DATE(created_at) as fecha, COUNT(*) as cantidad, SUM(total) as monto')
            ->groupByRaw('DATE(created_at)')
            ->orderByRaw('DATE(created_at)')
            ->get();

        $totales = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween(DB::raw('DATE(created_at)'), [$desde, $hasta])
            ->selectRaw('COUNT(*) as cantidad, COALESCE(SUM(total),0) as monto, COALESCE(AVG(total),0) as promedio')
            ->first();

        return response()->json(['ventas' => $ventas, 'totales' => $totales]);
    }

    public function productosTop(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $productos = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw('p.id, p.nombre, p.codigo, SUM(vd.cantidad) as total_vendido, SUM(vd.subtotal) as total_monto')
            ->groupBy('p.id', 'p.nombre', 'p.codigo')
            ->orderByDesc('total_vendido')->limit(20)->get();

        return response()->json(['productos' => $productos]);
    }

    public function clientesTop(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $clientes = DB::table('ventas as v')
            ->join('clientes as c', 'v.cliente_id', '=', 'c.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw('c.id, c.nombre, c.email, COUNT(*) as total_compras, SUM(v.total) as total_monto')
            ->groupBy('c.id', 'c.nombre', 'c.email')
            ->orderByDesc('total_monto')->limit(20)->get();

        return response()->json(['clientes' => $clientes]);
    }

    public function vendedoresRanking(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $vendedores = DB::table('ventas as v')
            ->join('usuarios as u', 'v.usuario_id', '=', 'u.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw('u.id, u.nombre, COUNT(*) as total_ventas, SUM(v.total) as total_monto')
            ->groupBy('u.id', 'u.nombre')
            ->orderByDesc('total_monto')->get();

        return response()->json(['vendedores' => $vendedores]);
    }

    public function metodosPago(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $metodos = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween(DB::raw('DATE(created_at)'), [$desde, $hasta])
            ->selectRaw('metodo_pago, COUNT(*) as cantidad, SUM(total) as monto')
            ->groupBy('metodo_pago')->get();

        return response()->json(['metodos' => $metodos]);
    }

    public function categoriasVentas(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $categorias = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->leftJoin('categorias as cat', 'p.categoria_id', '=', 'cat.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw("COALESCE(cat.nombre, 'Sin categoría') as categoria, SUM(vd.cantidad) as unidades, SUM(vd.subtotal) as monto")
            ->groupBy('cat.nombre')
            ->orderByDesc('monto')->get();

        return response()->json(['categorias' => $categorias]);
    }

    public function inventarioValor()
    {
        $valor = DB::table('productos')->where('activo', 1)
            ->selectRaw('SUM(stock * precio_compra) as valor_costo, SUM(stock * precio_venta) as valor_venta, COUNT(*) as total_productos, SUM(stock) as total_unidades')
            ->first();

        $porCategoria = DB::table('productos as p')
            ->leftJoin('categorias as c', 'p.categoria_id', '=', 'c.id')
            ->where('p.activo', 1)
            ->selectRaw("COALESCE(c.nombre, 'Sin categoría') as categoria, SUM(p.stock) as unidades, SUM(p.stock * p.precio_compra) as valor")
            ->groupBy('c.nombre')->orderByDesc('valor')->get();

        return response()->json(['valor' => $valor, 'por_categoria' => $porCategoria]);
    }

    public function flujoCaja(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();

        $ingresos = DB::table('ventas')
            ->where('estado', 'completada')
            ->whereBetween(DB::raw('DATE(created_at)'), [$desde, $hasta])
            ->selectRaw('DATE(created_at) as fecha, SUM(total) as monto')
            ->groupByRaw('DATE(created_at)')
            ->get();

        $egresos = DB::table('compras')
            ->where('estado', 'recibida')
            ->whereBetween(DB::raw('DATE(created_at)'), [$desde, $hasta])
            ->selectRaw('DATE(created_at) as fecha, SUM(total) as monto')
            ->groupByRaw('DATE(created_at)')
            ->get();

        return response()->json(['ingresos' => $ingresos, 'egresos' => $egresos]);
    }

    public function ventasGeo(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $productoId = $request->producto_id;

        if ($productoId) {
            $query = DB::table('ubicaciones as u')
                ->leftJoin('ventas as v', function ($join) use ($desde, $hasta) {
                    $join->on('u.id', '=', 'v.ubicacion_id')
                        ->where('v.estado', 'completada')
                        ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
                })
                ->leftJoin('venta_detalle as vd', function ($join) use ($productoId) {
                    $join->on('v.id', '=', 'vd.venta_id')
                        ->where('vd.producto_id', $productoId);
                })
                ->where('u.activo', 1)
                ->whereNotNull('u.lat')
                ->whereNotNull('u.lng')
                ->selectRaw('u.id, u.nombre, u.direccion, u.lat, u.lng,
                    COALESCE(SUM(vd.cantidad), 0) as cantidad_producto,
                    COALESCE(SUM(vd.subtotal), 0) as monto_producto,
                    COUNT(DISTINCT v.id) as cantidad_ventas')
                ->groupBy('u.id', 'u.nombre', 'u.direccion', 'u.lat', 'u.lng')
                ->orderByDesc('cantidad_producto')
                ->get();

            $heatmap = DB::table('ventas as v')
                ->join('ubicaciones as u', 'v.ubicacion_id', '=', 'u.id')
                ->join('venta_detalle as vd', 'v.id', '=', 'vd.venta_id')
                ->where('v.estado', 'completada')
                ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
                ->where('vd.producto_id', $productoId)
                ->whereNotNull('u.lat')
                ->whereNotNull('u.lng')
                ->selectRaw('u.lat, u.lng, vd.cantidad as weight')
                ->get()
                ->map(fn($p) => [(float)$p->lat, (float)$p->lng, (float)$p->weight])
                ->toArray();

            return response()->json([
                'ubicaciones' => $query,
                'heatmap' => $heatmap,
                'producto_id' => $productoId,
            ]);
        }

        $query = DB::table('ubicaciones as u')
            ->leftJoin('ventas as v', function ($join) use ($desde, $hasta) {
                $join->on('u.id', '=', 'v.ubicacion_id')
                    ->where('v.estado', 'completada')
                    ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
            })
            ->where('u.activo', 1)
            ->whereNotNull('u.lat')
            ->whereNotNull('u.lng')
            ->selectRaw('u.id, u.nombre, u.direccion, u.lat, u.lng, COUNT(DISTINCT v.id) as cantidad_ventas, COALESCE(SUM(v.total), 0) as total_ventas')
            ->groupBy('u.id', 'u.nombre', 'u.direccion', 'u.lat', 'u.lng')
            ->orderByDesc('total_ventas')
            ->get();

        $heatmap = DB::table('ventas as v')
            ->join('ubicaciones as u', 'v.ubicacion_id', '=', 'u.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->whereNotNull('u.lat')
            ->whereNotNull('u.lng')
            ->selectRaw('u.lat, u.lng, v.total as weight')
            ->get()
            ->map(fn($p) => [(float)$p->lat, (float)$p->lng, (float)$p->weight])
            ->toArray();

        return response()->json([
            'ubicaciones' => $query,
            'heatmap' => $heatmap,
        ]);
    }

    public function geoDashboard(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $ubicacionId = $request->ubicacion_id;
        $productoId = $request->producto_id;
        $categoriaId = $request->categoria_id;

        // Base venta query with filters
        $ventaQuery = DB::table('ventas as v')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $ventaQuery->where('v.ubicacion_id', $ubicacionId);

        // KPIs
        $kpis = (clone $ventaQuery)
            ->selectRaw('COUNT(*) as total_ventas, COALESCE(SUM(v.total),0) as total_ingresos, COALESCE(AVG(v.total),0) as ticket_promedio')
            ->first();

        $productosVendidos = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $productosVendidos->where('v.ubicacion_id', $ubicacionId);
        if ($productoId) $productosVendidos->where('vd.producto_id', $productoId);
        if ($categoriaId) $productosVendidos->join('productos as pcat', 'vd.producto_id', '=', 'pcat.id')->where('pcat.categoria_id', $categoriaId);
        $kpis->total_productos_vendidos = $productosVendidos->sum('vd.cantidad') ?? 0;

        // Daily trend
        $trend = (clone $ventaQuery)
            ->selectRaw('DATE(v.created_at) as fecha, COUNT(*) as cantidad, COALESCE(SUM(v.total),0) as monto')
            ->groupByRaw('DATE(v.created_at)')
            ->orderByRaw('DATE(v.created_at)')
            ->get();

        // Top products by location
        $topProductsQuery = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $topProductsQuery->where('v.ubicacion_id', $ubicacionId);
        if ($productoId) $topProductsQuery->where('vd.producto_id', $productoId);
        if ($categoriaId) $topProductsQuery->where('p.categoria_id', $categoriaId);
        $topProductos = $topProductsQuery
            ->selectRaw('p.id, p.nombre, p.codigo, SUM(vd.cantidad) as total_vendido, SUM(vd.subtotal) as total_monto')
            ->groupBy('p.id', 'p.nombre', 'p.codigo')
            ->orderByDesc('total_vendido')->limit(10)->get();

        // Location summary
        $locQuery = DB::table('ubicaciones as u')
            ->leftJoin('ventas as v', function ($join) use ($desde, $hasta) {
                $join->on('u.id', '=', 'v.ubicacion_id')
                    ->where('v.estado', 'completada')
                    ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
            })
            ->where('u.activo', 1)
            ->selectRaw('u.id, u.nombre, u.direccion, u.lat, u.lng, COUNT(DISTINCT v.id) as cantidad_ventas, COALESCE(SUM(v.total),0) as total_ventas, COUNT(DISTINCT v.usuario_id) as vendedores')
            ->groupBy('u.id', 'u.nombre', 'u.direccion', 'u.lat', 'u.lng')
            ->orderByDesc('total_ventas')->get();

        $totalGral = $locQuery->sum('total_ventas');
        $maxVentas = $locQuery->max('cantidad_ventas') ?: 1;
        $maxIngresos = $locQuery->max('total_ventas') ?: 1;
        foreach ($locQuery as $l) {
            $l->porcentaje = $totalGral > 0 ? round(($l->total_ventas / $totalGral) * 100, 1) : 0;
            $l->rendimiento = $l->cantidad_ventas >= $maxVentas * 0.7 ? 'alto' : ($l->cantidad_ventas >= $maxVentas * 0.3 ? 'medio' : 'bajo');
        }

        // Categories pie data
        $categorias = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->leftJoin('categorias as c', 'p.categoria_id', '=', 'c.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $categorias->where('v.ubicacion_id', $ubicacionId);
        $categorias = $categorias
            ->selectRaw("COALESCE(c.nombre, 'Sin categoría') as categoria, SUM(vd.cantidad) as unidades, SUM(vd.subtotal) as monto")
            ->groupBy('c.nombre')->orderByDesc('monto')->get();

        return response()->json([
            'kpis' => $kpis,
            'trend' => $trend,
            'top_productos' => $topProductos,
            'ubicaciones' => $locQuery,
            'categorias' => $categorias,
        ]);
    }

    public function geoProducto(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $productoId = $request->producto_id;
        $ubicacionId = $request->ubicacion_id;

        if (!$productoId) {
            return response()->json(['error' => 'producto_id requerido'], 400);
        }

        $producto = DB::table('productos')->where('id', $productoId)->first();
        if (!$producto) return response()->json(['error' => 'Producto no encontrado'], 404);

        // Sales by location
        $ventasPorUbicacion = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('ubicaciones as u', 'v.ubicacion_id', '=', 'u.id')
            ->where('vd.producto_id', $productoId)
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $ventasPorUbicacion->where('v.ubicacion_id', $ubicacionId);
        $ventasPorUbicacion = $ventasPorUbicacion
            ->selectRaw('u.id, u.nombre, SUM(vd.cantidad) as cantidad, SUM(vd.subtotal) as monto, COUNT(DISTINCT v.id) as ventas')
            ->groupBy('u.id', 'u.nombre')
            ->orderByDesc('cantidad')->get();

        // Daily trend for this product
        $trend = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->where('vd.producto_id', $productoId)
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $trend->where('v.ubicacion_id', $ubicacionId);
        $trend = $trend
            ->selectRaw('DATE(v.created_at) as fecha, SUM(vd.cantidad) as cantidad, SUM(vd.subtotal) as monto')
            ->groupByRaw('DATE(v.created_at)')
            ->orderByRaw('DATE(v.created_at)')
            ->get();

        // Stock by location
        $stockUbicaciones = DB::table('inventario_ubicacion as iu')
            ->join('ubicaciones as u', 'iu.ubicacion_id', '=', 'u.id')
            ->where('iu.producto_id', $productoId)
            ->select('u.nombre', 'iu.cantidad')
            ->get();

        // Movement history for this product
        $movimientos = DB::table('inventario_movimientos as im')
            ->join('usuarios as us', 'im.usuario_id', '=', 'us.id')
            ->where('im.producto_id', $productoId)
            ->whereBetween(DB::raw('DATE(im.created_at)'), [$desde, $hasta])
            ->selectRaw('im.tipo, im.cantidad, im.stock_anterior, im.stock_nuevo, im.referencia_tipo, im.notas, us.nombre as usuario, DATE(im.created_at) as fecha')
            ->orderByDesc('im.created_at')->limit(50)->get();

        return response()->json([
            'producto' => $producto,
            'ventas_por_ubicacion' => $ventasPorUbicacion,
            'trend' => $trend,
            'stock_ubicaciones' => $stockUbicaciones,
            'movimientos' => $movimientos,
        ]);
    }

    public function geoMovimientos(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $ubicacionId = $request->ubicacion_id;
        $productoId = $request->producto_id;
        $tipo = $request->tipo;

        $query = DB::table('inventario_movimientos as im')
            ->join('productos as p', 'im.producto_id', '=', 'p.id')
            ->join('usuarios as u', 'im.usuario_id', '=', 'u.id')
            ->whereBetween(DB::raw('DATE(im.created_at)'), [$desde, $hasta]);

        if ($productoId) $query->where('im.producto_id', $productoId);
        if ($tipo) $query->where('im.tipo', $tipo);

        // For ubicacion filter, we need to infer from referencia_tipo
        if ($ubicacionId) {
            $query->where(function ($q) use ($ubicacionId) {
                // Ventas from ubicacion
                $q->whereIn('im.referencia_tipo', ['venta', 'ajuste'])
                  ->whereExists(function ($sq) use ($ubicacionId) {
                      $sq->select(DB::raw(1))
                         ->from('ventas as vsub')
                         ->whereColumn('vsub.id', 'im.referencia_id')
                         ->where('vsub.ubicacion_id', $ubicacionId);
                  });
            });
        }

        $data = $query
            ->selectRaw('im.id, im.tipo, im.cantidad, im.stock_anterior, im.stock_nuevo, im.referencia_tipo, im.referencia_id, im.notas, u.nombre as usuario, p.nombre as producto, p.codigo, DATE(im.created_at) as fecha')
            ->orderByDesc('im.created_at')
            ->paginate(30);

        return response()->json(['movimientos' => $data]);
    }

    public function geoComparativa(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $productoId = $request->producto_id;

        $ubicaciones = DB::table('ubicaciones as u')
            ->leftJoin('ventas as v', function ($join) use ($desde, $hasta) {
                $join->on('u.id', '=', 'v.ubicacion_id')
                    ->where('v.estado', 'completada')
                    ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
            })
            ->leftJoin('venta_detalle as vd', 'v.id', '=', 'vd.venta_id')
            ->where('u.activo', 1);
        if ($productoId) $ubicaciones->where('vd.producto_id', $productoId);

        $ubicaciones = $ubicaciones
            ->selectRaw('u.id, u.nombre, COUNT(DISTINCT v.id) as ventas, COALESCE(SUM(v.total),0) as ingresos, COALESCE(SUM(vd.cantidad),0) as productos_vendidos, COUNT(DISTINCT v.usuario_id) as vendedores, COUNT(DISTINCT v.cliente_id) as clientes')
            ->groupBy('u.id', 'u.nombre')
            ->orderByDesc('ingresos')->get();

        // Calculate averages and growth (simplified)
        $totalVentas = $ubicaciones->sum('ventas');
        $totalIngresos = $ubicaciones->sum('ingresos');
        foreach ($ubicaciones as $u) {
            $u->ticket_promedio = $u->ventas > 0 ? round($u->ingresos / $u->ventas, 0) : 0;
            $u->porcentaje_ventas = $totalVentas > 0 ? round(($u->ventas / $totalVentas) * 100, 1) : 0;
            $u->porcentaje_ingresos = $totalIngresos > 0 ? round(($u->ingresos / $totalIngresos) * 100, 1) : 0;
        }

        // Product comparison across locations
        $productosComp = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->join('ubicaciones as u', 'v.ubicacion_id', '=', 'u.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw('p.id as producto_id, p.nombre as producto, u.id as ubicacion_id, u.nombre as ubicacion, SUM(vd.cantidad) as cantidad, SUM(vd.subtotal) as monto')
            ->groupBy('p.id', 'p.nombre', 'u.id', 'u.nombre')
            ->orderByDesc('monto')->limit(50)->get();

        return response()->json([
            'ubicaciones' => $ubicaciones,
            'productos_por_ubicacion' => $productosComp,
        ]);
    }

    public function geoTendencias(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $ubicacionId = $request->ubicacion_id;
        $agrupar = $request->agrupar ?? 'dia'; // dia, semana, mes

        $selectRaw = match ($agrupar) {
            'semana' => "strftime('%Y-%W', v.created_at) as periodo, strftime('%Y-%W', v.created_at) as fecha_label",
            'mes' => "strftime('%Y-%m', v.created_at) as periodo, strftime('%Y-%m', v.created_at) as fecha_label",
            default => 'DATE(v.created_at) as periodo, DATE(v.created_at) as fecha_label',
        };

        $groupRaw = match ($agrupar) {
            'semana' => "strftime('%Y-%W', v.created_at)",
            'mes' => "strftime('%Y-%m', v.created_at)",
            default => 'DATE(v.created_at)',
        };

        $query = DB::table('ventas as v')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);
        if ($ubicacionId) $query->where('v.ubicacion_id', $ubicacionId);

        $data = $query
            ->selectRaw("{$selectRaw}, COUNT(*) as ventas, COALESCE(SUM(v.total),0) as ingresos, COALESCE(AVG(v.total),0) as ticket_promedio")
            ->groupByRaw($groupRaw)
            ->orderByRaw($groupRaw)
            ->get();

        return response()->json(['tendencias' => $data]);
    }

    public function rentabilidadProductos(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $ubicacionId = $request->ubicacion_id;

        $query = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta]);

        if ($ubicacionId) {
            $query->where('v.ubicacion_id', $ubicacionId);
        }

        $productos = $query
            ->selectRaw('p.id, p.nombre, p.codigo, p.precio_compra,
                SUM(vd.cantidad) as unidades,
                SUM(vd.subtotal) as ingresos,
                SUM(vd.cantidad * p.precio_compra) as costo_total')
            ->groupBy('p.id', 'p.nombre', 'p.codigo', 'p.precio_compra')
            ->orderByDesc('ingresos')
            ->get();

        foreach ($productos as $p) {
            $p->margen = $p->ingresos - $p->costo_total;
            $p->porcentaje = $p->ingresos > 0 ? round(($p->margen / $p->ingresos) * 100, 1) : 0;
        }

        return response()->json(['productos' => $productos]);
    }
}
