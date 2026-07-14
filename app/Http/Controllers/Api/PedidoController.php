<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PedidoController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('pedidos as p')
            ->leftJoin('clientes as cl', 'p.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'p.usuario_id', '=', 'u.id')
            ->select('p.*', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre');

        if ($request->estado) $query->where('p.estado', $request->estado);
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('p.numero_pedido', 'like', "%{$request->q}%")
                  ->orWhere('cl.nombre', 'like', "%{$request->q}%");
            });
        }

        $data = $query->orderByDesc('p.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['items' => 'required|array|min:1']);

        $lockKey = $this->generateLockKey('crear_pedido', [
            'user' => $request->user()?->id,
            'cliente' => $request->cliente_id,
            'items_hash' => md5(json_encode($request->items)),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            try {
                DB::beginTransaction();
                $date = date('Ymd');
                $cnt = DB::table('pedidos')->whereDate('created_at', today())->count() + 1;
                $numPedido = 'PED-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

                $pedidoId = DB::table('pedidos')->insertGetId([
                    'numero_pedido' => $numPedido,
                    'cliente_id' => $request->cliente_id,
                    'usuario_id' => $request->user()->id,
                    'subtotal' => 0, 'descuento_total' => $request->descuento_total ?? 0,
                    'impuesto_total' => 0, 'total' => 0,
                    'monto_adelanto' => 0, 'monto_pendiente' => 0,
                    'estado' => 'pendiente',
                    'tipo_entrega' => $request->tipo_entrega ?? 'en_tienda',
                    'direccion_entrega' => $request->direccion_entrega,
                    'fecha_entrega_estimada' => $request->fecha_entrega_estimada,
                    'reservar_inventario' => $request->reservar_inventario ?? false,
                    'notas' => $request->notas,
                    'created_at' => now(), 'updated_at' => now(),
                ]);

                $subtotal = 0; $impuestoTotal = 0;
                $ubicacionPrincipal = DB::table('ubicaciones')->where('activo', 1)->orderBy('id')->value('id');
                foreach ($request->items as $item) {
                    $prod = DB::table('productos')->where('id', $item['producto_id'])->first();
                    $impPct = $prod ? (float)$prod->impuesto : 0;
                    $subItem = ($item['precio_unitario'] * $item['cantidad']) - ($item['descuento'] ?? 0);
                    $impItem = round($subItem * $impPct / 100, 2);
                    $subtotal += $subItem; $impuestoTotal += $impItem;

                    $reservado = 0;
                    if ($request->reservar_inventario && $prod && $prod->stock >= $item['cantidad']) {
                        DB::table('productos')->where('id', $item['producto_id'])->decrement('stock', $item['cantidad']);
                        if ($ubicacionPrincipal) {
                            $existe = DB::table('inventario_ubicacion')
                                ->where('producto_id', $item['producto_id'])
                                ->where('ubicacion_id', $ubicacionPrincipal)
                                ->first();
                            if ($existe) {
                                DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                    'cantidad' => DB::raw("cantidad - {$item['cantidad']}"),
                                    'updated_at' => now(),
                                ]);
                            }
                        }
                        $reservado = 1;
                    }

                    DB::table('pedido_detalle')->insert([
                        'pedido_id' => $pedidoId, 'producto_id' => $item['producto_id'],
                        'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                        'descuento' => $item['descuento'] ?? 0, 'impuesto' => $impItem,
                        'subtotal' => $subItem, 'reservado' => $reservado,
                        'created_at' => now(),
                    ]);
                }

                $total = $subtotal + $impuestoTotal - ($request->descuento_total ?? 0);
                $adelanto = (float)($request->monto_adelanto ?? 0);

                DB::table('pedidos')->where('id', $pedidoId)->update([
                    'subtotal' => $subtotal, 'impuesto_total' => $impuestoTotal,
                    'total' => $total, 'monto_adelanto' => $adelanto,
                    'monto_pendiente' => $total - $adelanto,
                ]);

                if ($adelanto > 0) {
                    DB::table('pedido_pagos')->insert([
                        'pedido_id' => $pedidoId, 'monto' => $adelanto,
                        'metodo_pago' => $request->metodo_adelanto ?? 'efectivo',
                        'tipo' => 'adelanto', 'usuario_id' => $request->user()->id,
                        'created_at' => now(),
                    ]);
                }

                DB::commit();
                return response()->json(['success' => true, 'pedido_id' => $pedidoId, 'numero_pedido' => $numPedido]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => $e->getMessage()], 500);
            }
        }, response()->json(['error' => 'Ya se está procesando este pedido. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $pedido = DB::table('pedidos as p')
            ->leftJoin('clientes as cl', 'p.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'p.usuario_id', '=', 'u.id')
            ->where('p.id', $id)
            ->select('p.*', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre')
            ->first();
        if (!$pedido) return response()->json(['error' => 'No encontrado'], 404);

        $pedido->items = DB::table('pedido_detalle as d')
            ->join('productos as p', 'd.producto_id', '=', 'p.id')
            ->where('d.pedido_id', $id)
            ->select('d.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        $pedido->pagos = DB::table('pedido_pagos')->where('pedido_id', $id)->orderByDesc('created_at')->get();

        return response()->json(['pedido' => $pedido]);
    }

    public function update(Request $request, $id)
    {
        $pedido = DB::table('pedidos')->where('id', $id)->first();
        if (!$pedido) return response()->json(['error' => 'Pedido no encontrado'], 404);

        $request->validate(['items' => 'required|array|min:1']);

        try {
            DB::beginTransaction();

            $ubicacionPrincipal = DB::table('ubicaciones')->where('activo', 1)->orderBy('id')->value('id');

            $itemsAntiguos = DB::table('pedido_detalle')->where('pedido_id', $id)->get();
            foreach ($itemsAntiguos as $itemAnt) {
                if ($itemAnt->reservado) {
                    DB::table('productos')->where('id', $itemAnt->producto_id)->increment('stock', $itemAnt->cantidad);
                    if ($ubicacionPrincipal) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $itemAnt->producto_id)
                            ->where('ubicacion_id', $ubicacionPrincipal)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad + {$itemAnt->cantidad}"),
                                'updated_at' => now(),
                            ]);
                        }
                    }
                }
            }
            DB::table('pedido_detalle')->where('pedido_id', $id)->delete();

            $subtotal = 0; $impuestoTotal = 0;
            foreach ($request->items as $item) {
                $prod = DB::table('productos')->where('id', $item['producto_id'])->first();
                $impPct = $prod ? (float)$prod->impuesto : 0;
                $subItem = ($item['precio_unitario'] * $item['cantidad']) - ($item['descuento'] ?? 0);
                $impItem = round($subItem * $impPct / 100, 2);
                $subtotal += $subItem; $impuestoTotal += $impItem;

                $reservado = 0;
                if ($pedido->reservar_inventario && $prod && $prod->stock >= $item['cantidad']) {
                    DB::table('productos')->where('id', $item['producto_id'])->decrement('stock', $item['cantidad']);
                    if ($ubicacionPrincipal) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $item['producto_id'])
                            ->where('ubicacion_id', $ubicacionPrincipal)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad - {$item['cantidad']}"),
                                'updated_at' => now(),
                            ]);
                        }
                    }
                    $reservado = 1;
                }

                DB::table('pedido_detalle')->insert([
                    'pedido_id' => $id, 'producto_id' => $item['producto_id'],
                    'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                    'descuento' => $item['descuento'] ?? 0, 'impuesto' => $impItem,
                    'subtotal' => $subItem, 'reservado' => $reservado,
                    'created_at' => now(),
                ]);
            }

            $total = $subtotal + $impuestoTotal - ($request->descuento_total ?? 0);
            $adelanto = (float)($request->monto_adelanto ?? $pedido->monto_adelanto);

            DB::table('pedidos')->where('id', $id)->update([
                'cliente_id' => $request->cliente_id ?? $pedido->cliente_id,
                'subtotal' => $subtotal, 'descuento_total' => $request->descuento_total ?? 0,
                'impuesto_total' => $impuestoTotal, 'total' => $total,
                'monto_adelanto' => $adelanto, 'monto_pendiente' => $total - $adelanto,
                'tipo_entrega' => $request->tipo_entrega ?? $pedido->tipo_entrega,
                'direccion_entrega' => $request->direccion_entrega ?? $pedido->direccion_entrega,
                'fecha_entrega_estimada' => $request->fecha_entrega_estimada ?? $pedido->fecha_entrega_estimada,
                'notas' => $request->notas ?? $pedido->notas,
                'updated_at' => now(),
            ]);

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Pedido actualizado']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function destroy($id)
    {
        $pedido = DB::table('pedidos')->where('id', $id)->first();
        if (!$pedido) return response()->json(['error' => 'Pedido no encontrado'], 404);

        try {
            DB::beginTransaction();

            $ubicacionPrincipal = DB::table('ubicaciones')->where('activo', 1)->orderBy('id')->value('id');
            $items = DB::table('pedido_detalle')->where('pedido_id', $id)->get();
            foreach ($items as $item) {
                if ($item->reservado) {
                    DB::table('productos')->where('id', $item->producto_id)->increment('stock', $item->cantidad);
                    if ($ubicacionPrincipal) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $item->producto_id)
                            ->where('ubicacion_id', $ubicacionPrincipal)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad + {$item->cantidad}"),
                                'updated_at' => now(),
                            ]);
                        }
                    }
                }
            }

            DB::table('pedido_detalle')->where('pedido_id', $id)->delete();
            DB::table('pedido_pagos')->where('pedido_id', $id)->delete();
            DB::table('pedidos')->where('id', $id)->delete();

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Pedido eliminado']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function cambiarEstado(Request $request, $id)
    {
        DB::table('pedidos')->where('id', $id)->update(['estado' => $request->estado, 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }

    public function registrarPago(Request $request, $id)
    {
        $request->validate(['monto' => 'required|numeric|min:0.01', 'metodo_pago' => 'required']);

        DB::table('pedido_pagos')->insert([
            'pedido_id' => $id, 'monto' => $request->monto,
            'metodo_pago' => $request->metodo_pago, 'referencia' => $request->referencia,
            'tipo' => 'abono', 'usuario_id' => $request->user()->id,
            'notas' => $request->notas, 'created_at' => now(),
        ]);

        $totalPagado = DB::table('pedido_pagos')->where('pedido_id', $id)->sum('monto');
        $pedido = DB::table('pedidos')->where('id', $id)->first();
        DB::table('pedidos')->where('id', $id)->update([
            'monto_adelanto' => $totalPagado,
            'monto_pendiente' => (float)$pedido->total - $totalPagado,
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'message' => 'Pago registrado']);
    }
}
