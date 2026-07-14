<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InventarioMovimiento;
use App\Models\InventarioUbicacion;
use App\Models\Producto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventarioController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->get('page', 1));
        $limit = 24;

        $query = Producto::query()
            ->leftJoin('categorias', 'productos.categoria_id', '=', 'categorias.id')
            ->select('productos.*', 'categorias.nombre as categoria_nombre')
            ->with(['inventarioUbicaciones.ubicacion'])
            ->where('productos.activo', 1);

        if ($request->filled('categoria_id')) {
            $query->where('productos.categoria_id', $request->categoria_id);
        }

        if ($request->filled('ubicacion_id')) {
            $query->whereHas('inventarioUbicaciones', function ($q) use ($request) {
                $q->where('ubicacion_id', $request->ubicacion_id);
            });
        }

        if ($request->filled('q')) {
            $q = $request->q;
            $query->where(function ($qb) use ($q) {
                $qb->where('productos.nombre', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo', 'LIKE', "%{$q}%")
                    ->orWhere('productos.codigo_barras', 'LIKE', "%{$q}%");
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

        $total = $query->count();
        $productos = $query->orderBy('productos.nombre')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();

        // Enrich with computed totals per requested location
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
        }

        return response()->json([
            'productos' => $productos,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
        ]);
    }

    public function dashboard(Request $request)
    {
        $ubicacionId = $request->get('ubicacion_id');

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

        $stockPorSucursal = DB::table('inventario_ubicacion as iu')
            ->join('ubicaciones as u', 'iu.ubicacion_id', '=', 'u.id')
            ->where('u.activo', 1)
            ->groupBy('u.id', 'u.nombre')
            ->selectRaw('u.id, u.nombre, SUM(iu.cantidad) as total')
            ->orderByDesc('total')
            ->get();

        $productosMasMovidos = DB::table('inventario_movimientos as im')
            ->join('productos as p', 'im.producto_id', '=', 'p.id')
            ->when($ubicacionId, fn ($q) => $q->where('im.ubicacion_id', $ubicacionId))
            ->whereBetween('im.created_at', [now()->subDays(30), now()])
            ->selectRaw('p.id, p.nombre, SUM(im.cantidad) as total_movido')
            ->groupBy('p.id', 'p.nombre')
            ->orderByDesc('total_movido')
            ->limit(10)
            ->get();

        return response()->json([
            'stock_total' => (int) $stockTotal,
            'stock_reservado' => (int) $stockReservado,
            'productos_agotados' => $productosAgotados,
            'productos_bajo_stock' => $productosBajoStock,
            'stock_por_sucursal' => $stockPorSucursal,
            'productos_mas_movidos' => $productosMasMovidos,
        ]);
    }

    public function movimientos(Request $request)
    {
        $query = InventarioMovimiento::query()
            ->with(['producto:id,nombre,codigo', 'ubicacion:id,nombre', 'ubicacionDestino:id,nombre', 'usuario:id,nombre'])
            ->orderByDesc('created_at');

        if ($request->filled('producto_id')) {
            $query->where('producto_id', $request->producto_id);
        }
        if ($request->filled('ubicacion_id')) {
            $query->where(function ($q) use ($request) {
                $q->where('ubicacion_id', $request->ubicacion_id)
                    ->orWhere('ubicacion_destino_id', $request->ubicacion_id);
            });
        }
        if ($request->filled('tipo')) {
            $query->where('tipo', $request->tipo);
        }

        $data = $query->paginate(30);
        return response()->json($data);
    }

    public function transferir(Request $request)
    {
        $request->validate([
            'producto_id' => 'required|exists:productos,id',
            'ubicacion_origen_id' => 'required|exists:ubicaciones,id',
            'ubicacion_destino_id' => 'required|exists:ubicaciones,id|different:ubicacion_origen_id',
            'cantidad' => 'required|integer|min:1',
            'notas' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            $invOrigen = DB::table('inventario_ubicacion')
                ->where('producto_id', $request->producto_id)
                ->where('ubicacion_id', $request->ubicacion_origen_id)
                ->first();

            $stockOrigen = $invOrigen ? $invOrigen->cantidad : 0;
            if ($stockOrigen < $request->cantidad) {
                DB::rollBack();
                return response()->json(['error' => 'Stock insuficiente en origen'], 400);
            }

            // Update origin
            if ($invOrigen) {
                DB::table('inventario_ubicacion')->where('id', $invOrigen->id)->update([
                    'cantidad' => DB::raw("cantidad - {$request->cantidad}"),
                    'updated_at' => now(),
                ]);
            }

            // Update destination
            $invDestino = DB::table('inventario_ubicacion')
                ->where('producto_id', $request->producto_id)
                ->where('ubicacion_id', $request->ubicacion_destino_id)
                ->first();

            if ($invDestino) {
                DB::table('inventario_ubicacion')->where('id', $invDestino->id)->update([
                    'cantidad' => DB::raw("cantidad + {$request->cantidad}"),
                    'updated_at' => now(),
                ]);
            } else {
                DB::table('inventario_ubicacion')->insert([
                    'producto_id' => $request->producto_id,
                    'ubicacion_id' => $request->ubicacion_destino_id,
                    'cantidad' => $request->cantidad,
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }

            // Update global stock (net zero, but keep consistency)
            // No global change for transfers

            // Log movements
            $stockDestinoAnterior = $invDestino ? $invDestino->cantidad : 0;

            DB::table('inventario_movimientos')->insert([
                'producto_id' => $request->producto_id,
                'ubicacion_id' => $request->ubicacion_origen_id,
                'ubicacion_destino_id' => $request->ubicacion_destino_id,
                'tipo' => 'transferencia',
                'cantidad' => $request->cantidad,
                'stock_anterior' => $stockOrigen,
                'stock_nuevo' => $stockOrigen - $request->cantidad,
                'referencia_tipo' => 'transferencia_directa',
                'usuario_id' => $request->user()->id,
                'notas' => $request->notas ?? 'Transferencia entre ubicaciones',
                'created_at' => now(),
            ]);

            DB::table('inventario_movimientos')->insert([
                'producto_id' => $request->producto_id,
                'ubicacion_id' => $request->ubicacion_destino_id,
                'ubicacion_destino_id' => $request->ubicacion_origen_id,
                'tipo' => 'entrada',
                'cantidad' => $request->cantidad,
                'stock_anterior' => $stockDestinoAnterior,
                'stock_nuevo' => $stockDestinoAnterior + $request->cantidad,
                'referencia_tipo' => 'transferencia_directa',
                'usuario_id' => $request->user()->id,
                'notas' => $request->notas ?? 'Recepción por transferencia',
                'created_at' => now(),
            ]);

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Transferencia realizada']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function actualizarStock(Request $request)
    {
        $request->validate([
            'producto_id' => 'required|exists:productos,id',
            'ubicacion_id' => 'required|exists:ubicaciones,id',
            'cantidad' => 'required|integer|min:0',
            'cantidad_reservada' => 'nullable|integer|min:0',
            'stock_minimo' => 'nullable|integer|min:0',
            'stock_maximo' => 'nullable|integer|min:0',
        ]);

        try {
            DB::beginTransaction();

            $inv = DB::table('inventario_ubicacion')
                ->where('producto_id', $request->producto_id)
                ->where('ubicacion_id', $request->ubicacion_id)
                ->first();

            $anterior = $inv ? $inv->cantidad : 0;
            $nuevo = $request->cantidad;
            $diferencia = $nuevo - $anterior;

            if ($inv) {
                DB::table('inventario_ubicacion')->where('id', $inv->id)->update([
                    'cantidad' => $nuevo,
                    'cantidad_reservada' => $request->cantidad_reservada ?? $inv->cantidad_reservada ?? 0,
                    'stock_minimo' => $request->stock_minimo ?? $inv->stock_minimo,
                    'stock_maximo' => $request->stock_maximo ?? $inv->stock_maximo,
                    'updated_at' => now(),
                ]);
            } else {
                DB::table('inventario_ubicacion')->insert([
                    'producto_id' => $request->producto_id,
                    'ubicacion_id' => $request->ubicacion_id,
                    'cantidad' => $nuevo,
                    'cantidad_reservada' => $request->cantidad_reservada ?? 0,
                    'stock_minimo' => $request->stock_minimo,
                    'stock_maximo' => $request->stock_maximo,
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }

            // Update global stock to match sum of all locations
            $totalUbicaciones = DB::table('inventario_ubicacion')
                ->where('producto_id', $request->producto_id)
                ->sum('cantidad');
            DB::table('productos')->where('id', $request->producto_id)->update(['stock' => $totalUbicaciones]);

            // Log movement if there was a change
            if ($diferencia !== 0) {
                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $request->producto_id,
                    'ubicacion_id' => $request->ubicacion_id,
                    'tipo' => $diferencia > 0 ? 'entrada' : 'salida',
                    'cantidad' => abs($diferencia),
                    'stock_anterior' => $anterior,
                    'stock_nuevo' => $nuevo,
                    'referencia_tipo' => 'ajuste_manual',
                    'usuario_id' => $request->user()->id,
                    'notas' => 'Ajuste manual de stock',
                    'created_at' => now(),
                ]);
            }

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Stock actualizado']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
