<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Categoria;
use App\Models\Producto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class ProductoController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->get('page', 1));
        $limit = 24;

        $query = Producto::query()
            ->leftJoin('categorias', 'productos.categoria_id', '=', 'categorias.id')
            ->leftJoin('proveedores', 'productos.proveedor_id', '=', 'proveedores.id')
            ->select('productos.*', 'categorias.nombre as categoria_nombre', 'proveedores.nombre as proveedor_nombre')
            ->with('inventarioUbicaciones', 'categoria', 'proveedor','variantes', 'imagenes');

        if ($request->filled('categoria_id')) {
            $query->where('productos.categoria_id', $request->categoria_id);
        }
        if ($request->filled('activo')) {
            $query->where('productos.activo', $request->activo);
        }
        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($qb) use ($q) {
                $qb->where('productos.nombre', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo_barras', 'LIKE', "%{$q}%");
            });
        }
        if ($request->filled('ubicacion_id')) {
            $ubiId = $request->ubicacion_id;
            $query->leftJoin('inventario_ubicacion as iu_filtro', function ($join) use ($ubiId) {
                $join->on('productos.id', '=', 'iu_filtro.producto_id')
                     ->where('iu_filtro.ubicacion_id', '=', $ubiId);
            });
            $query->addSelect(
                'iu_filtro.cantidad as ubicacion_cantidad',
                'iu_filtro.cantidad_reservada as ubicacion_reservada',
                'iu_filtro.stock_minimo as ubicacion_stock_minimo',
                'iu_filtro.stock_maximo as ubicacion_stock_maximo'
            );
            // Only show products that actually have a record in this location (even if qty=0)
            $query->whereNotNull('iu_filtro.id');
        }

        if ($request->filled('stock_estado')) {
            $estado = $request->stock_estado;
            if ($request->filled('ubicacion_id')) {
                // Use location-specific stock for filtering
                $minimoUbicacion = "COALESCE(iu_filtro.stock_minimo, productos.stock_minimo, 0)";
                if ($estado === 'sin_stock') {
                    $query->whereRaw('COALESCE(iu_filtro.cantidad, 0) <= 0');
                } elseif ($estado === 'bajo_stock') {
                    $query->whereRaw("COALESCE(iu_filtro.cantidad, 0) > 0")
                          ->whereRaw("COALESCE(iu_filtro.cantidad, 0) <= {$minimoUbicacion}");
                } elseif ($estado === 'suficiente') {
                    $query->whereRaw("COALESCE(iu_filtro.cantidad, 0) > {$minimoUbicacion}");
                }
            } else {
                if ($estado === 'sin_stock') {
                    $query->where('productos.stock', '<=', 0);
                } elseif ($estado === 'bajo_stock') {
                    $query->where('productos.stock', '>', 0)
                          ->whereColumn('productos.stock', '<=', 'productos.stock_minimo');
                } elseif ($estado === 'suficiente') {
                    $query->whereColumn('productos.stock', '>', 'productos.stock_minimo');
                }
            }
        }

        $total = $query->count();
        $productos = $query->orderBy('productos.nombre')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();

        return response()->json([
            'productos' => $productos,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'codigo' => 'required|string|max:100|unique:productos,codigo',
            'nombre' => 'required|string|max:200',
            'precio_venta' => 'required|numeric|min:0',
        ]);

        $lockKey = $this->generateLockKey('crear_producto', [
            'user' => $request->user()?->id,
            'codigo' => $request->codigo,
            'nombre' => $request->nombre,
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {

            $producto = Producto::create($request->only([
                'codigo', 'codigo_barras', 'nombre', 'descripcion', 'categoria_id', 'proveedor_id',
                'precio_compra', 'precio_venta', 'stock', 'stock_minimo', 'stock_maximo',
                'unidad', 'imagen', 'impuesto', 'margen_ganancia', 'peso',
                'costo_envio', 'costo_marketing', 'costo_logistica',
                'visible_web', 'activo',
            ]));

            if ($request->has('inventario_ubicaciones') && is_array($request->inventario_ubicaciones)) {
                foreach ($request->inventario_ubicaciones as $iu) {
                    if (!empty($iu['ubicacion_id']) && isset($iu['cantidad']) && $iu['cantidad'] >= 0) {
                        DB::table('inventario_ubicacion')->insert([
                            'producto_id' => $producto->id,
                            'ubicacion_id' => $iu['ubicacion_id'],
                            'cantidad' => $iu['cantidad'],
                            'cantidad_reservada' => $iu['cantidad_reservada'] ?? 0,
                            'stock_minimo' => $iu['stock_minimo'] ?? null,
                            'stock_maximo' => $iu['stock_maximo'] ?? null,
                            'created_at' => now(), 'updated_at' => now(),
                        ]);
                    }
                }
                // Sincronizar stock global
                $totalUbicaciones = DB::table('inventario_ubicacion')
                    ->where('producto_id', $producto->id)
                    ->sum('cantidad');
                $producto->update(['stock' => $totalUbicaciones]);
            } elseif ($request->filled('stock') && $request->stock > 0) {
                $ubicacionPrincipal = DB::table('ubicaciones')->where('activo', 1)->orderBy('id')->value('id');
                if ($ubicacionPrincipal) {
                    DB::table('inventario_ubicacion')->insert([
                        'producto_id' => $producto->id,
                        'ubicacion_id' => $ubicacionPrincipal,
                        'cantidad' => $request->stock,
                        'created_at' => now(), 'updated_at' => now(),
                    ]);
                    $producto->update(['stock' => $request->stock]);
                }
            }

            return response()->json(['success' => true, 'producto' => $producto, 'message' => 'Producto creado exitosamente']);
        }, response()->json(['error' => 'Ya se está procesando la creación de este producto. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $producto = Producto::with(['categoria', 'variantes', 'imagenes', 'proveedor'])->find($id);
        if (!$producto) return response()->json(['error' => 'Producto no encontrado'], 404);

        $inventario = DB::table('inventario_ubicacion as iu')
            ->join('ubicaciones as u', 'iu.ubicacion_id', '=', 'u.id')
            ->where('iu.producto_id', $id)
            ->select('iu.id', 'iu.ubicacion_id', 'u.nombre as ubicacion_nombre', 'u.tipo as ubicacion_tipo', 'iu.cantidad', 'iu.cantidad_reservada', 'iu.stock_minimo', 'iu.stock_maximo', 'iu.estado', 'iu.updated_at')
            ->get();

        $producto->inventario_ubicaciones = $inventario;

        return response()->json(['producto' => $producto]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'codigo' => [
                'required',
                'string',
                'max:100',
                Rule::unique('productos', 'codigo')->ignore($id),
            ],
            'nombre' => 'required|string|max:200',
            'precio_venta' => 'required|numeric|min:0',
        ]);
        
        $producto = Producto::find($id);
        if (!$producto) return response()->json(['error' => 'Producto no encontrado'], 404);

        $producto->update($request->only([
            'codigo', 'codigo_barras', 'nombre', 'descripcion', 'categoria_id', 'proveedor_id',
            'precio_compra', 'precio_venta', 'stock_minimo', 'stock_maximo',
            'unidad', 'imagen', 'impuesto', 'margen_ganancia', 'peso',
            'costo_envio', 'costo_marketing', 'costo_logistica',
            'visible_web', 'activo',
        ]));

        // Update per-location stock if provided
        if ($request->has('inventario_ubicaciones') && is_array($request->inventario_ubicaciones)) {
            foreach ($request->inventario_ubicaciones as $iu) {
                $ubicacionId = $iu['ubicacion_id'] ?? null;
                if (!$ubicacionId) continue;
                $cantidad = $iu['cantidad'] ?? 0;
                $cantidadReservada = $iu['cantidad_reservada'] ?? 0;
                $stockMinimo = $iu['stock_minimo'] ?? null;
                $stockMaximo = $iu['stock_maximo'] ?? null;

                $existe = DB::table('inventario_ubicacion')
                    ->where('producto_id', $id)
                    ->where('ubicacion_id', $ubicacionId)
                    ->first();

                if ($existe) {
                    DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                        'cantidad' => $cantidad,
                        'cantidad_reservada' => $cantidadReservada,
                        'stock_minimo' => $stockMinimo,
                        'stock_maximo' => $stockMaximo,
                        'updated_at' => now(),
                    ]);
                } else {
                    DB::table('inventario_ubicacion')->insert([
                        'producto_id' => $id,
                        'ubicacion_id' => $ubicacionId,
                        'cantidad' => $cantidad,
                        'cantidad_reservada' => $cantidadReservada,
                        'stock_minimo' => $stockMinimo,
                        'stock_maximo' => $stockMaximo,
                        'created_at' => now(), 'updated_at' => now(),
                    ]);
                }
            }

            // Sync global stock
            $totalUbicaciones = DB::table('inventario_ubicacion')
                ->where('producto_id', $id)
                ->sum('cantidad');
            DB::table('productos')->where('id', $id)->update(['stock' => $totalUbicaciones]);
        }

        return response()->json(['success' => true, 'producto' => $producto, 'message' => 'Producto actualizado']);
    }

    public function buscar(Request $request)
    {
        $q = trim($request->get('q', ''));
        if (strlen($q) < 1) return response()->json(['productos' => []]);

        $query = Producto::query()
            ->where(function ($qb) use ($q) {
                $qb->where('nombre', 'LIKE', "%{$q}%")
                    ->orWhere('codigo', 'LIKE', "%{$q}%")
                    ->orWhere('codigo_barras', 'LIKE', "%{$q}%");
            });

        if (!$request->boolean('incluir_inactivos')) {
            $query->where('activo', 1);
        }

        $productos = $query
            ->select('id', 'codigo', 'nombre', 'precio_compra', 'precio_venta', 'stock', 'impuesto', 'imagen', 'activo')
            ->limit(15)
            ->get();

        $ubicacionId = $request->get('ubicacion_id');
        if ($ubicacionId) {
            foreach ($productos as $p) {
                $inv = DB::table('inventario_ubicacion')
                    ->where('producto_id', $p->id)
                    ->where('ubicacion_id', $ubicacionId)
                    ->value('cantidad');
                $p->stock_ubicacion = $inv ?? 0;
            }
        }

        return response()->json(['productos' => $productos]);
    }

    public function categorias()
    {
        $categorias = Categoria::where('activo', 1)->orderBy('nombre')->get();
        return response()->json(['categorias' => $categorias]);
    }

    public function bajoStock()
    {
        $productos = Producto::bajoStock()
            ->leftJoin('categorias', 'productos.categoria_id', '=', 'categorias.id')
            ->select('productos.*', 'categorias.nombre as categoria_nombre')
            ->orderBy('productos.stock')
            ->limit(50)
            ->get();

        return response()->json(['productos' => $productos]);
    }

    public function masVendidos(Request $request)
    {
        $desde = $request->desde ?? today()->subDays(30)->toDateString();
        $hasta = $request->hasta ?? today()->toDateString();
        $limit = min(50, (int) ($request->limit ?? 12));

        $productos = DB::table('venta_detalle as vd')
            ->join('ventas as v', 'vd.venta_id', '=', 'v.id')
            ->join('productos as p', 'vd.producto_id', '=', 'p.id')
            ->where('v.estado', 'completada')
            ->whereBetween(DB::raw('DATE(v.created_at)'), [$desde, $hasta])
            ->selectRaw('p.id, p.nombre, p.codigo, p.precio_venta, p.stock, p.impuesto, SUM(vd.cantidad) as total_vendido')
            ->groupBy('p.id', 'p.nombre', 'p.codigo', 'p.precio_venta', 'p.stock', 'p.impuesto')
            ->orderByDesc('total_vendido')
            ->limit($limit)
            ->get();

        return response()->json(['productos' => $productos]);
    }

    public function destroy($id)
    {
        $producto = Producto::find($id);
        if (!$producto) {
            return response()->json(['error' => 'Producto no encontrado'], 404);
        }

        DB::table('inventario_ubicacion')->where('producto_id', $id)->delete();
        $producto->delete();

        return response()->json(['success' => true, 'message' => 'Producto eliminado']);
    }
}
