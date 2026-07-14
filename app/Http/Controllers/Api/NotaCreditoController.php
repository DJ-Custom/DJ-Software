<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotaCreditoController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('notas_credito as nc')
            ->leftJoin('ventas as v', 'nc.venta_id', '=', 'v.id')
            ->leftJoin('clientes as cl', 'nc.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'nc.usuario_id', '=', 'u.id')
            ->select('nc.*', 'v.numero_factura', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre');

        if ($request->estado) $query->where('nc.estado', $request->estado);
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('nc.numero_nota', 'like', "%{$request->q}%")
                  ->orWhere('cl.nombre', 'like', "%{$request->q}%");
            });
        }

        $data = $query->orderByDesc('nc.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['venta_id' => 'required|exists:ventas,id', 'items' => 'required|array|min:1']);

        try {
            DB::beginTransaction();
            $date = date('Ymd');
            $cnt = DB::table('notas_credito')->whereDate('created_at', today())->count() + 1;
            $numNota = 'NC-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

            $venta = DB::table('ventas')->where('id', $request->venta_id)->first();

            $notaId = DB::table('notas_credito')->insertGetId([
                'numero_nota' => $numNota,
                'venta_id' => $request->venta_id,
                'cliente_id' => $venta->cliente_id,
                'usuario_id' => $request->user()->id,
                'tipo' => $request->tipo ?? 'parcial',
                'tipo_credito' => $request->tipo_credito ?? 'credito_tienda',
                'monto_total' => 0, 'saldo_restante' => 0,
                'motivo' => $request->motivo,
                'estado' => 'activa',
                'notas' => $request->notas,
                'created_at' => now(), 'updated_at' => now(),
            ]);

            $ventaItems = DB::table('venta_detalle')
                ->where('venta_id', $request->venta_id)
                ->get()
                ->keyBy('producto_id');

            $montoTotal = 0;
            $ubicacionId = $venta->ubicacion_id ?? null;
            foreach ($request->items as $item) {
                $original = $ventaItems->get($item['producto_id']);
                if (!$original || $item['cantidad'] > $original->cantidad) {
                    DB::rollBack();
                    return response()->json(['error' => 'La cantidad a devolver no puede superar la cantidad facturada.'], 422);
                }
                $sub = $item['precio_unitario'] * $item['cantidad'];
                $montoTotal += $sub;
                DB::table('nota_credito_detalle')->insert([
                    'nota_credito_id' => $notaId, 'producto_id' => $item['producto_id'],
                    'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                    'subtotal' => $sub,
                    'devolver_inventario' => $item['devolver_inventario'] ?? false,
                    'estado_producto' => $item['estado_producto'] ?? 'bueno',
                    'created_at' => now(),
                ]);
                if (!empty($item['devolver_inventario'])) {
                    DB::table('productos')->where('id', $item['producto_id'])->increment('stock', $item['cantidad']);
                    if ($ubicacionId) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $item['producto_id'])
                            ->where('ubicacion_id', $ubicacionId)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad + {$item['cantidad']}"),
                                'updated_at' => now(),
                            ]);
                        } else {
                            DB::table('inventario_ubicacion')->insert([
                                'producto_id' => $item['producto_id'],
                                'ubicacion_id' => $ubicacionId,
                                'cantidad' => $item['cantidad'],
                                'created_at' => now(), 'updated_at' => now(),
                            ]);
                        }
                    }
                }
            }

            DB::table('notas_credito')->where('id', $notaId)->update(['monto_total' => $montoTotal, 'saldo_restante' => $montoTotal]);

            if ($request->tipo_credito === 'credito_tienda' && $venta->cliente_id) {
                DB::table('clientes')->where('id', $venta->cliente_id)->increment('credito_tienda', $montoTotal);
            }

            $nuevoEstado = ($request->tipo === 'total') ? 'cancelada' : 'parcialmente_anulada';
            DB::table('ventas')->where('id', $request->venta_id)->update([
                'estado' => $nuevoEstado,
                'updated_at' => now(),
            ]);

            DB::commit();
            return response()->json(['success' => true, 'nota_id' => $notaId, 'numero_nota' => $numNota]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $nota = DB::table('notas_credito as nc')
            ->leftJoin('ventas as v', 'nc.venta_id', '=', 'v.id')
            ->leftJoin('clientes as cl', 'nc.cliente_id', '=', 'cl.id')
            ->where('nc.id', $id)
            ->select('nc.*', 'v.numero_factura', 'cl.nombre as cliente_nombre')
            ->first();
        if (!$nota) return response()->json(['error' => 'No encontrada'], 404);

        $nota->items = DB::table('nota_credito_detalle as d')
            ->join('productos as p', 'd.producto_id', '=', 'p.id')
            ->where('d.nota_credito_id', $id)
            ->select('d.*', 'p.nombre as producto_nombre')
            ->get();

        $nota->usos = DB::table('nota_credito_usos')->where('nota_credito_id', $id)->orderByDesc('created_at')->get();

        return response()->json(['nota' => $nota]);
    }

    public function cancelar($id)
    {
        $nota = DB::table('notas_credito')->where('id', $id)->first();
        if (!$nota) return response()->json(['error' => 'No encontrada'], 404);

        DB::table('notas_credito')->where('id', $id)->update(['estado' => 'cancelada', 'updated_at' => now()]);

        $otrasActivas = DB::table('notas_credito')
            ->where('venta_id', $nota->venta_id)
            ->where('id', '!=', $id)
            ->where('estado', '!=', 'cancelada')
            ->count();

        if ($otrasActivas === 0) {
            DB::table('ventas')->where('id', $nota->venta_id)->update([
                'estado' => 'completada',
                'updated_at' => now(),
            ]);
        }

        return response()->json(['success' => true]);
    }
}
