<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TraspasoController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('traspasos as t')
            ->leftJoin('ubicaciones as o', 't.ubicacion_origen_id', '=', 'o.id')
            ->leftJoin('ubicaciones as d', 't.ubicacion_destino_id', '=', 'd.id')
            ->select('t.*', 'o.nombre as origen_nombre', 'd.nombre as destino_nombre');

        if ($request->estado) $query->where('t.estado', $request->estado);
        $data = $query->orderByDesc('t.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate([
            'ubicacion_origen_id' => 'required|exists:ubicaciones,id',
            'ubicacion_destino_id' => 'required|exists:ubicaciones,id',
            'items' => 'required|array|min:1',
        ]);

        try {
            DB::beginTransaction();

            foreach ($request->items as $item) {
                $stockUbicacion = DB::table('inventario_ubicacion')
                    ->where('producto_id', $item['producto_id'])
                    ->where('ubicacion_id', $request->ubicacion_origen_id)
                    ->value('cantidad') ?? 0;

                $producto = DB::table('productos')->where('id', $item['producto_id'])->first();
                if (!$producto) {
                    DB::rollBack();
                    return response()->json(['error' => "Producto ID {$item['producto_id']} no encontrado"], 400);
                }
                if ($stockUbicacion < $item['cantidad']) {
                    DB::rollBack();
                    return response()->json(['error' => "Stock insuficiente para '{$producto->nombre}' en origen. Disponible: {$stockUbicacion}"], 400);
                }
            }

            $date = date('Ymd');
            $cnt = DB::table('traspasos')->whereDate('created_at', today())->count() + 1;
            $num = 'TR-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

            $trId = DB::table('traspasos')->insertGetId([
                'numero_traspaso' => $num,
                'ubicacion_origen_id' => $request->ubicacion_origen_id,
                'ubicacion_destino_id' => $request->ubicacion_destino_id,
                'usuario_envio_id' => $request->user()->id,
                'estado' => 'pendiente',
                'notas' => $request->notas,
                'created_at' => now(), 'updated_at' => now(),
            ]);

            foreach ($request->items as $item) {
                DB::table('traspaso_detalle')->insert([
                    'traspaso_id' => $trId, 'producto_id' => $item['producto_id'],
                    'cantidad_enviada' => $item['cantidad'], 'cantidad_recibida' => 0,
                    'diferencia' => 0, 'created_at' => now(),
                ]);
            }

            DB::commit();
            return response()->json(['success' => true, 'traspaso_id' => $trId, 'numero_traspaso' => $num]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $tr = DB::table('traspasos as t')
            ->leftJoin('ubicaciones as o', 't.ubicacion_origen_id', '=', 'o.id')
            ->leftJoin('ubicaciones as d', 't.ubicacion_destino_id', '=', 'd.id')
            ->where('t.id', $id)
            ->select('t.*', 'o.nombre as origen_nombre', 'd.nombre as destino_nombre')
            ->first();
        if (!$tr) return response()->json(['error' => 'No encontrado'], 404);

        $tr->items = DB::table('traspaso_detalle as td')
            ->join('productos as p', 'td.producto_id', '=', 'p.id')
            ->where('td.traspaso_id', $id)
            ->select('td.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        return response()->json(['traspaso' => $tr]);
    }

    public function enviar(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $traspaso = DB::table('traspasos')->where('id', $id)->first();
            if (!$traspaso) return response()->json(['error' => 'No encontrado'], 404);
            if ($traspaso->estado !== 'pendiente') return response()->json(['error' => 'Solo traspasos pendientes pueden enviarse'], 400);

            $items = DB::table('traspaso_detalle')->where('traspaso_id', $id)->get();
            foreach ($items as $item) {
                $stockAnterior = DB::table('inventario_ubicacion')
                    ->where('producto_id', $item->producto_id)
                    ->where('ubicacion_id', $traspaso->ubicacion_origen_id)
                    ->value('cantidad') ?? 0;

                if ($stockAnterior < $item->cantidad_enviada) {
                    DB::rollBack();
                    $prod = DB::table('productos')->where('id', $item->producto_id)->first();
                    return response()->json(['error' => "Stock insuficiente en origen para '{$prod->nombre}'"], 400);
                }

                $existe = DB::table('inventario_ubicacion')
                    ->where('producto_id', $item->producto_id)
                    ->where('ubicacion_id', $traspaso->ubicacion_origen_id)
                    ->first();

                if ($existe) {
                    DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                        'cantidad' => DB::raw("cantidad - {$item->cantidad_enviada}"),
                        'updated_at' => now(),
                    ]);
                }

                DB::table('productos')->where('id', $item->producto_id)->decrement('stock', $item->cantidad_enviada);

                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $item->producto_id,
                    'tipo' => 'salida',
                    'cantidad' => $item->cantidad_enviada,
                    'stock_anterior' => $stockAnterior,
                    'stock_nuevo' => $stockAnterior - $item->cantidad_enviada,
                    'referencia_tipo' => 'traspaso',
                    'referencia_id' => $id,
                    'usuario_id' => $request->user()->id,
                    'notas' => 'Traspaso enviado a ' . DB::table('ubicaciones')->where('id', $traspaso->ubicacion_destino_id)->value('nombre'),
                    'created_at' => now(),
                ]);
            }

            DB::table('traspasos')->where('id', $id)->update([
                'estado' => 'en_transito', 'fecha_envio' => now(), 'updated_at' => now()
            ]);
            DB::commit();
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function recibir(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $traspaso = DB::table('traspasos')->where('id', $id)->first();
            if (!$traspaso) return response()->json(['error' => 'No encontrado'], 404);
            if ($traspaso->estado !== 'en_transito') return response()->json(['error' => 'Solo traspasos en tránsito pueden recibirse'], 400);

            $items = DB::table('traspaso_detalle')->where('traspaso_id', $id)->get();
            foreach ($items as $item) {
                $cantidadRecibida = $item->cantidad_enviada;
                if ($request->items) {
                    foreach ($request->items as $reqItem) {
                        if ($reqItem['id'] == $item->id) {
                            $cantidadRecibida = $reqItem['cantidad_recibida'];
                            DB::table('traspaso_detalle')->where('id', $item->id)->update([
                                'cantidad_recibida' => $cantidadRecibida,
                                'diferencia' => $cantidadRecibida - $item->cantidad_enviada,
                                'notas_diferencia' => $reqItem['notas_diferencia'] ?? null,
                            ]);
                            break;
                        }
                    }
                }

                $stockAnteriorDestino = DB::table('inventario_ubicacion')
                    ->where('producto_id', $item->producto_id)
                    ->where('ubicacion_id', $traspaso->ubicacion_destino_id)
                    ->value('cantidad') ?? 0;

                $existe = DB::table('inventario_ubicacion')
                    ->where('producto_id', $item->producto_id)
                    ->where('ubicacion_id', $traspaso->ubicacion_destino_id)
                    ->first();

                if ($existe) {
                    DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                        'cantidad' => DB::raw("cantidad + {$cantidadRecibida}"),
                        'updated_at' => now(),
                    ]);
                } else {
                    DB::table('inventario_ubicacion')->insert([
                        'producto_id' => $item->producto_id,
                        'ubicacion_id' => $traspaso->ubicacion_destino_id,
                        'cantidad' => $cantidadRecibida,
                        'created_at' => now(), 'updated_at' => now(),
                    ]);
                }

                DB::table('productos')->where('id', $item->producto_id)->increment('stock', $cantidadRecibida);

                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $item->producto_id,
                    'tipo' => 'entrada',
                    'cantidad' => $cantidadRecibida,
                    'stock_anterior' => $stockAnteriorDestino,
                    'stock_nuevo' => $stockAnteriorDestino + $cantidadRecibida,
                    'referencia_tipo' => 'traspaso',
                    'referencia_id' => $id,
                    'usuario_id' => $request->user()->id,
                    'notas' => 'Traspaso recibido desde ' . DB::table('ubicaciones')->where('id', $traspaso->ubicacion_origen_id)->value('nombre'),
                    'created_at' => now(),
                ]);
            }

            DB::table('traspasos')->where('id', $id)->update([
                'estado' => 'recibido', 'fecha_recepcion' => now(),
                'usuario_recepcion_id' => $request->user()->id,
                'notas_recepcion' => $request->notas_recepcion,
                'updated_at' => now(),
            ]);
            DB::commit();
            return response()->json(['success' => true, 'message' => 'Traspaso recibido']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function cancelar(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $traspaso = DB::table('traspasos')->where('id', $id)->first();
            if (!$traspaso) return response()->json(['error' => 'No encontrado'], 404);

            if ($traspaso->estado === 'en_transito') {
                $items = DB::table('traspaso_detalle')->where('traspaso_id', $id)->get();
                foreach ($items as $item) {
                    $stockAnterior = DB::table('inventario_ubicacion')
                        ->where('producto_id', $item->producto_id)
                        ->where('ubicacion_id', $traspaso->ubicacion_origen_id)
                        ->value('cantidad') ?? 0;

                    $existe = DB::table('inventario_ubicacion')
                        ->where('producto_id', $item->producto_id)
                        ->where('ubicacion_id', $traspaso->ubicacion_origen_id)
                        ->first();

                    if ($existe) {
                        DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                            'cantidad' => DB::raw("cantidad + {$item->cantidad_enviada}"),
                            'updated_at' => now(),
                        ]);
                    } else {
                        DB::table('inventario_ubicacion')->insert([
                            'producto_id' => $item->producto_id,
                            'ubicacion_id' => $traspaso->ubicacion_origen_id,
                            'cantidad' => $item->cantidad_enviada,
                            'created_at' => now(), 'updated_at' => now(),
                        ]);
                    }

                    DB::table('productos')->where('id', $item->producto_id)->increment('stock', $item->cantidad_enviada);

                    DB::table('inventario_movimientos')->insert([
                        'producto_id' => $item->producto_id,
                        'tipo' => 'entrada',
                        'cantidad' => $item->cantidad_enviada,
                        'stock_anterior' => $stockAnterior,
                        'stock_nuevo' => $stockAnterior + $item->cantidad_enviada,
                        'referencia_tipo' => 'traspaso',
                        'referencia_id' => $id,
                        'usuario_id' => $request->user()->id,
                        'notas' => 'Devolución por cancelación de traspaso',
                        'created_at' => now(),
                    ]);
                }
            }

            DB::table('traspasos')->where('id', $id)->update(['estado' => 'cancelado', 'updated_at' => now()]);
            DB::commit();
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function ubicaciones()
    {
        $ubicaciones = DB::table('ubicaciones')->where('activo', 1)->orderByDesc('es_principal')->orderBy('nombre')->get();
        return response()->json(['ubicaciones' => $ubicaciones]);
    }
}
