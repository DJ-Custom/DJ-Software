<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AjusteInventarioController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('ajustes_inventario as a')
            ->leftJoin('usuarios as u', 'a.usuario_id', '=', 'u.id')
            ->leftJoin('ubicaciones as ub', 'a.ubicacion_id', '=', 'ub.id')
            ->select('a.*', 'u.nombre as usuario_nombre', 'ub.nombre as ubicacion_nombre');

        if ($request->estado) $query->where('a.estado', $request->estado);
        $data = $query->orderByDesc('a.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['tipo' => 'required', 'motivo' => 'required']);

        $num = 'AJ-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        $id = DB::table('ajustes_inventario')->insertGetId([
            'numero_ajuste' => $num, 'tipo' => $request->tipo,
            'motivo' => $request->motivo, 'motivo_detalle' => $request->motivo_detalle,
            'ubicacion_id' => $request->ubicacion_id,
            'usuario_id' => $request->user()->id,
            'estado' => 'borrador', 'notas' => $request->notas,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'id' => $id, 'numero_ajuste' => $num]);
    }

    public function show($id)
    {
        $ajuste = DB::table('ajustes_inventario as a')
            ->leftJoin('usuarios as u', 'a.usuario_id', '=', 'u.id')
            ->leftJoin('ubicaciones as ub', 'a.ubicacion_id', '=', 'ub.id')
            ->where('a.id', $id)
            ->select('a.*', 'u.nombre as usuario_nombre', 'ub.nombre as ubicacion_nombre')
            ->first();
        if (!$ajuste) return response()->json(['error' => 'No encontrado'], 404);

        $ajuste->items = DB::table('ajuste_detalle as ad')
            ->join('productos as p', 'ad.producto_id', '=', 'p.id')
            ->where('ad.ajuste_id', $id)
            ->select('ad.*', 'p.nombre as producto_nombre', 'p.codigo', 'p.stock as stock_actual')
            ->get();

        return response()->json(['ajuste' => $ajuste]);
    }

    public function agregarProducto(Request $request)
    {
        $request->validate(['ajuste_id' => 'required', 'producto_id' => 'required']);

        $prod = DB::table('productos')->where('id', $request->producto_id)->first();
        if (!$prod) return response()->json(['error' => 'Producto no encontrado'], 404);

        $ajuste = DB::table('ajustes_inventario')->where('id', $request->ajuste_id)->first();
        $ubicacionId = $ajuste->ubicacion_id ?? null;

        $stockSistema = $prod->stock;
        if ($ubicacionId) {
            $inv = DB::table('inventario_ubicacion')
                ->where('producto_id', $request->producto_id)
                ->where('ubicacion_id', $ubicacionId)
                ->first();
            $stockSistema = $inv ? $inv->cantidad : 0;
        }

        $stockFisico = $request->stock_fisico;
        $cantidadAjuste = $request->cantidad_ajuste ?? 0;

        // For conteo, derive cantidad_ajuste from stock_fisico if provided
        if ($ajuste->tipo === 'conteo' && $stockFisico !== null && $stockFisico !== '') {
            $cantidadAjuste = (float) $stockFisico - (float) $stockSistema;
        } elseif ($ajuste->tipo === 'conteo' && $cantidadAjuste != 0) {
            // Fallback: if only cantidad_ajuste is sent, derive stock_fisico
            $stockFisico = (float) $stockSistema + (float) $cantidadAjuste;
        }

        DB::table('ajuste_detalle')->insert([
            'ajuste_id' => $request->ajuste_id, 'producto_id' => $request->producto_id,
            'stock_sistema' => $stockSistema,
            'stock_fisico' => $stockFisico,
            'cantidad_ajuste' => $cantidadAjuste,
            'notas' => $request->notas, 'created_at' => now(),
        ]);

        return response()->json(['success' => true]);
    }

    public function aplicar(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $ajuste = DB::table('ajustes_inventario')->where('id', $id)->first();
            $items = DB::table('ajuste_detalle')->where('ajuste_id', $id)->get();
            $ubicacionId = $ajuste->ubicacion_id ?? null;

            foreach ($items as $item) {
                $stockGlobalAnterior = DB::table('productos')->where('id', $item->producto_id)->value('stock');
                $stockUbicacionAnterior = 0;
                $inv = null;
                if ($ubicacionId) {
                    $inv = DB::table('inventario_ubicacion')
                        ->where('producto_id', $item->producto_id)
                        ->where('ubicacion_id', $ubicacionId)
                        ->first();
                    $stockUbicacionAnterior = $inv ? $inv->cantidad : 0;
                }
                $cantidad = $item->cantidad_ajuste;

                if ($ajuste->tipo === 'entrada') {
                    DB::table('productos')->where('id', $item->producto_id)->increment('stock', abs($cantidad));
                    if ($ubicacionId) {
                        if ($inv) {
                            DB::table('inventario_ubicacion')->where('id', $inv->id)->update([
                                'cantidad' => DB::raw("cantidad + " . abs($cantidad)),
                                'updated_at' => now(),
                            ]);
                        } else {
                            DB::table('inventario_ubicacion')->insert([
                                'producto_id' => $item->producto_id,
                                'ubicacion_id' => $ubicacionId,
                                'cantidad' => abs($cantidad),
                                'created_at' => now(), 'updated_at' => now(),
                            ]);
                        }
                    }
                } elseif ($ajuste->tipo === 'salida') {
                    DB::table('productos')->where('id', $item->producto_id)->decrement('stock', abs($cantidad));
                    if ($ubicacionId && $inv) {
                        DB::table('inventario_ubicacion')->where('id', $inv->id)->update([
                            'cantidad' => DB::raw("cantidad - " . abs($cantidad)),
                            'updated_at' => now(),
                        ]);
                    }
                } else { // conteo
                    $diferencia = 0;
                    if ($item->stock_fisico !== null && $item->stock_fisico !== '') {
                        if ($ubicacionId) {
                            $diferencia = (float) $item->stock_fisico - (float) $stockUbicacionAnterior;
                        } else {
                            $diferencia = (float) $item->stock_fisico - (float) $stockGlobalAnterior;
                        }
                    } elseif ((float) $item->cantidad_ajuste != 0) {
                        $diferencia = (float) $item->cantidad_ajuste;
                    }

                    if ($diferencia != 0 || ($item->stock_fisico !== null && $item->stock_fisico !== '')) {
                        DB::table('productos')->where('id', $item->producto_id)->update(['stock' => DB::raw("stock + {$diferencia}")]);
                        if ($ubicacionId) {
                            $nuevaCantidad = ($item->stock_fisico !== null && $item->stock_fisico !== '')
                                ? (float) $item->stock_fisico
                                : max(0, (float) $stockUbicacionAnterior + (float) $diferencia);
                            if ($inv) {
                                DB::table('inventario_ubicacion')->where('id', $inv->id)->update([
                                    'cantidad' => $nuevaCantidad,
                                    'updated_at' => now(),
                                ]);
                            } else {
                                DB::table('inventario_ubicacion')->insert([
                                    'producto_id' => $item->producto_id,
                                    'ubicacion_id' => $ubicacionId,
                                    'cantidad' => $nuevaCantidad,
                                    'created_at' => now(), 'updated_at' => now(),
                                ]);
                            }
                        }
                        $cantidad = $diferencia;
                    }
                }

                $stockGlobalNuevo = DB::table('productos')->where('id', $item->producto_id)->value('stock');
                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $item->producto_id,
                    'tipo' => $cantidad >= 0 ? 'entrada' : 'salida',
                    'cantidad' => abs($cantidad),
                    'stock_anterior' => $stockGlobalAnterior,
                    'stock_nuevo' => $stockGlobalNuevo,
                    'referencia_tipo' => 'ajuste', 'referencia_id' => $id,
                    'usuario_id' => $request->user()->id,
                    'notas' => "Ajuste: {$ajuste->numero_ajuste}",
                    'created_at' => now(),
                ]);
            }

            DB::table('ajustes_inventario')->where('id', $id)->update([
                'estado' => 'aplicado', 'aplicado_at' => now(), 'updated_at' => now()
            ]);

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Ajuste aplicado']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function cancelar($id)
    {
        DB::table('ajustes_inventario')->where('id', $id)->update(['estado' => 'cancelado', 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }
}
