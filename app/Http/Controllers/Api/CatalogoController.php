<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Producto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CatalogoController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->get('page', 1));
        $limit = 24;

        $query = Producto::query()
            ->leftJoin('categorias', 'productos.categoria_id', '=', 'categorias.id')
            ->leftJoin('proveedores', 'productos.proveedor_id', '=', 'proveedores.id')
            ->select('productos.*', 'categorias.nombre as categoria_nombre', 'proveedores.nombre as proveedor_nombre')
            ->with(['inventarioUbicaciones.ubicacion', 'imagenes'])
            ->where('productos.activo', 1);

        // Búsqueda general
        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($qb) use ($q) {
                $qb->where('productos.nombre', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo_barras', 'LIKE', "%{$q}%")
                    ->orWhere('categorias.nombre', 'LIKE', "%{$q}%")
                    ->orWhere('proveedores.nombre', 'LIKE', "%{$q}%");
            });
        }

        if ($request->filled('categoria_id')) {
            $query->where('productos.categoria_id', $request->categoria_id);
        }

        if ($request->filled('proveedor_id')) {
            $query->where('productos.proveedor_id', $request->proveedor_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->whereHas('inventarioUbicaciones', function ($q) use ($request) {
                $q->where('ubicacion_id', $request->ubicacion_id);
            });
        }

        if ($request->filled('disponibilidad')) {
            $disp = $request->disponibilidad;
            if ($disp === 'agotados') {
                $query->whereHas('inventarioUbicaciones', function ($q) use ($request) {
                    if ($request->filled('ubicacion_id')) {
                        $q->where('ubicacion_id', $request->ubicacion_id);
                    }
                    $q->whereColumn('cantidad', '<=', 'cantidad_reservada');
                });
            } elseif ($disp === 'stock_bajo') {
                $query->whereHas('inventarioUbicaciones', function ($q) use ($request) {
                    if ($request->filled('ubicacion_id')) {
                        $q->where('ubicacion_id', $request->ubicacion_id);
                    }
                    $q->whereRaw('(cantidad - cantidad_reservada) <= COALESCE(stock_minimo, 0)');
                    $q->whereRaw('cantidad > cantidad_reservada');
                });
            } elseif ($disp === 'disponible') {
                $query->whereHas('inventarioUbicaciones', function ($q) use ($request) {
                    if ($request->filled('ubicacion_id')) {
                        $q->where('ubicacion_id', $request->ubicacion_id);
                    }
                    $q->whereRaw('(cantidad - cantidad_reservada) > 0');
                });
            }
        }

        if ($request->filled('precio_min')) {
            $query->where('productos.precio_venta', '>=', $request->precio_min);
        }
        if ($request->filled('precio_max')) {
            $query->where('productos.precio_venta', '<=', $request->precio_max);
        }

        if ($request->filled('margen_min')) {
            $query->where('productos.margen_ganancia', '>=', $request->margen_min);
        }
        if ($request->filled('margen_max')) {
            $query->where('productos.margen_ganancia', '<=', $request->margen_max);
        }

        $total = $query->count();

        $orderBy = $request->get('order_by', 'nombre');
        $orderDir = $request->get('order_dir', 'asc');
        $allowed = ['nombre', 'codigo', 'precio_venta', 'precio_compra', 'stock', 'categoria_nombre'];
        if (!in_array($orderBy, $allowed)) $orderBy = 'nombre';
        if (!in_array(strtolower($orderDir), ['asc', 'desc'])) $orderDir = 'asc';

        $productos = $query->orderBy('productos.' . $orderBy, $orderDir)
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();

        $ubicacionId = $request->get('ubicacion_id');
        foreach ($productos as $p) {
            if ($ubicacionId) {
                $inv = $p->inventarioUbicaciones->firstWhere('ubicacion_id', (int) $ubicacionId);
                $p->stock_total = $inv ? $inv->cantidad : 0;
                $p->stock_reservado = $inv ? $inv->cantidad_reservada : 0;
                $p->stock_disponible = $inv ? max(0, $inv->cantidad - $inv->cantidad_reservada) : 0;
                $p->stock_minimo_loc = $inv ? $inv->stock_minimo : null;
                $p->stock_maximo_loc = $inv ? $inv->stock_maximo : null;
                $p->estado_stock = $inv ? $inv->estadoStock() : 'agotado';
                $p->ultima_actualizacion = $inv ? $inv->updated_at : null;
            } else {
                $p->stock_total = $p->inventarioUbicaciones->sum('cantidad');
                $p->stock_reservado = $p->inventarioUbicaciones->sum('cantidad_reservada');
                $p->stock_disponible = max(0, $p->stock_total - $p->stock_reservado);
                $p->stock_minimo_loc = $p->stock_minimo;
                $p->stock_maximo_loc = $p->stock_maximo;
                $p->estado_stock = ($p->stock_disponible <= 0) ? 'agotado' : (($p->stock_disponible <= $p->stock_minimo) ? 'bajo' : 'medio');
                $p->ultima_actualizacion = $p->inventarioUbicaciones->max('updated_at');
            }

            // Margen calculado si no está guardado
            if (!$p->margen_ganancia && $p->precio_compra > 0) {
                $p->margen_ganancia = round((($p->precio_venta - $p->precio_compra) / $p->precio_compra) * 100, 2);
            }
            $p->ganancia_estimada = round($p->precio_venta - $p->precio_compra, 2);

            // Imagen principal
            $p->imagen_principal = $p->imagen ?: ($p->imagenes->first()?->ruta ?? null);
            unset($p->imagenes);
        }

        return response()->json([
            'productos' => $productos,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
        ]);
    }

    public function show($id)
    {
        $producto = Producto::with(['categoria', 'proveedor', 'inventarioUbicaciones.ubicacion', 'imagenes'])->find($id);
        if (!$producto) return response()->json(['error' => 'Producto no encontrado'], 404);

        $ubicacionId = request()->get('ubicacion_id');
        if ($ubicacionId) {
            $inv = $producto->inventarioUbicaciones->firstWhere('ubicacion_id', (int) $ubicacionId);
            $producto->stock_total = $inv ? $inv->cantidad : 0;
            $producto->stock_reservado = $inv ? $inv->cantidad_reservada : 0;
            $producto->stock_disponible = $inv ? max(0, $inv->cantidad - $inv->cantidad_reservada) : 0;
            $producto->estado_stock = $inv ? $inv->estadoStock() : 'agotado';
        } else {
            $producto->stock_total = $producto->inventarioUbicaciones->sum('cantidad');
            $producto->stock_reservado = $producto->inventarioUbicaciones->sum('cantidad_reservada');
            $producto->stock_disponible = max(0, $producto->stock_total - $producto->stock_reservado);
            $producto->estado_stock = ($producto->stock_disponible <= 0) ? 'agotado' : (($producto->stock_disponible <= $producto->stock_minimo) ? 'bajo' : 'medio');
        }

        if (!$producto->margen_ganancia && $producto->precio_compra > 0) {
            $producto->margen_ganancia = round((($producto->precio_venta - $producto->precio_compra) / $producto->precio_compra) * 100, 2);
        }
        $producto->ganancia_estimada = round($producto->precio_venta - $producto->precio_compra, 2);
        $producto->imagen_principal = $producto->imagen ?: ($producto->imagenes->first()?->ruta ?? null);

        // Movimientos recientes
        $movimientos = DB::table('inventario_movimientos as im')
            ->join('ubicaciones as u', 'im.ubicacion_id', '=', 'u.id')
            ->leftJoin('ubicaciones as ud', 'im.ubicacion_destino_id', '=', 'ud.id')
            ->where('im.producto_id', $id)
            ->orderByDesc('im.created_at')
            ->limit(10)
            ->select('im.*', 'u.nombre as ubicacion_nombre', 'ud.nombre as ubicacion_destino_nombre')
            ->get();

        return response()->json([
            'producto' => $producto,
            'movimientos' => $movimientos,
        ]);
    }

    public function dashboard(Request $request)
    {
        $ubicacionId = $request->get('ubicacion_id');

        $totalProductos = Producto::where('activo', 1)->count();

        $stockTotal = DB::table('inventario_ubicacion')
            ->when($ubicacionId, fn ($q) => $q->where('ubicacion_id', $ubicacionId))
            ->sum('cantidad');

        $stockReservado = DB::table('inventario_ubicacion')
            ->when($ubicacionId, fn ($q) => $q->where('ubicacion_id', $ubicacionId))
            ->sum('cantidad_reservada');

        $productosAgotados = Producto::where('activo', 1)
            ->whereHas('inventarioUbicaciones', function ($q) use ($ubicacionId) {
                if ($ubicacionId) $q->where('ubicacion_id', $ubicacionId);
                $q->whereRaw('cantidad <= cantidad_reservada');
            })
            ->count();

        $productosBajoStock = Producto::where('activo', 1)
            ->whereHas('inventarioUbicaciones', function ($q) use ($ubicacionId) {
                if ($ubicacionId) $q->where('ubicacion_id', $ubicacionId);
                $q->whereRaw('(cantidad - cantidad_reservada) <= COALESCE(stock_minimo, 0)');
                $q->whereRaw('cantidad > cantidad_reservada');
            })
            ->count();

        // Valor total del inventario al costo
        $valorInventario = DB::table('inventario_ubicacion as iu')
            ->join('productos as p', 'iu.producto_id', '=', 'p.id')
            ->when($ubicacionId, fn ($q) => $q->where('iu.ubicacion_id', $ubicacionId))
            ->selectRaw('SUM(iu.cantidad * p.precio_compra) as valor')
            ->value('valor') ?? 0;

        $valorVenta = DB::table('inventario_ubicacion as iu')
            ->join('productos as p', 'iu.producto_id', '=', 'p.id')
            ->when($ubicacionId, fn ($q) => $q->where('iu.ubicacion_id', $ubicacionId))
            ->selectRaw('SUM(iu.cantidad * p.precio_venta) as valor')
            ->value('valor') ?? 0;

        $productosMasVendidos = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [now()->subDays(30)->toDateString(), now()->toDateString()])
            ->selectRaw('p.id, p.nombre, p.codigo, SUM(vd.cantidad) as total_vendido')
            ->groupBy('p.id', 'p.nombre', 'p.codigo')
            ->orderByDesc('total_vendido')
            ->limit(5)
            ->get();

        return response()->json([
            'total_productos' => $totalProductos,
            'stock_total' => (int) $stockTotal,
            'stock_reservado' => (int) $stockReservado,
            'productos_agotados' => $productosAgotados,
            'productos_bajo_stock' => $productosBajoStock,
            'valor_inventario_costo' => round($valorInventario, 2),
            'valor_inventario_venta' => round($valorVenta, 2),
            'productos_mas_vendidos' => $productosMasVendidos,
        ]);
    }

    public function filtros()
    {
        $categorias = DB::table('categorias')->where('activo', 1)->orderBy('nombre')->select('id', 'nombre')->get();
        $ubicaciones = DB::table('ubicaciones')->where('activo', 1)->orderBy('nombre')->select('id', 'nombre')->get();
        $proveedores = DB::table('proveedores')->orderBy('nombre')->select('id', 'nombre')->get();

        return response()->json([
            'categorias' => $categorias,
            'ubicaciones' => $ubicaciones,
            'proveedores' => $proveedores,
        ]);
    }
}
