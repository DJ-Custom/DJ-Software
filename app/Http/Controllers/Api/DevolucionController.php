<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DevolucionController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('devoluciones as d')
            ->leftJoin('ventas as v', 'd.venta_id', '=', 'v.id')
            ->leftJoin('clientes as cl', 'd.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'd.usuario_id', '=', 'u.id')
            ->select('d.*', 'v.numero_factura', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre');

        if ($request->estado) $query->where('d.estado', $request->estado);
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('d.numero_devolucion', 'like', "%{$request->q}%")
                  ->orWhere('v.numero_factura', 'like', "%{$request->q}%");
            });
        }

        $data = $query->orderByDesc('d.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['venta_id' => 'required|exists:ventas,id', 'items' => 'required|array|min:1']);

        try {
            DB::beginTransaction();
            $date = date('Ymd');
            $cnt = DB::table('devoluciones')->whereDate('created_at', today())->count() + 1;
            $numDev = 'DEV-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

            $venta = DB::table('ventas')->where('id', $request->venta_id)->first();

            $devId = DB::table('devoluciones')->insertGetId([
                'numero_devolucion' => $numDev,
                'venta_id' => $request->venta_id,
                'cliente_id' => $venta->cliente_id,
                'usuario_id' => $request->user()->id,
                'tipo' => $request->tipo ?? 'parcial',
                'tipo_reembolso' => $request->tipo_reembolso ?? 'efectivo',
                'monto_total' => 0,
                'motivo' => $request->motivo,
                'estado' => 'pendiente',
                'notas' => $request->notas,
                'created_at' => now(), 'updated_at' => now(),
            ]);

            $ventaItems = DB::table('venta_detalle')
                ->where('venta_id', $request->venta_id)
                ->get()
                ->keyBy('producto_id');

            $montoTotal = 0;
            foreach ($request->items as $item) {
                $original = $ventaItems->get($item['producto_id']);
                if (!$original || $item['cantidad'] > $original->cantidad) {
                    DB::rollBack();
                    return response()->json(['error' => 'La cantidad a devolver no puede superar la cantidad facturada.'], 422);
                }
                $sub = $item['precio_unitario'] * $item['cantidad'];
                $montoTotal += $sub;
                DB::table('devolucion_detalle')->insert([
                    'devolucion_id' => $devId, 'producto_id' => $item['producto_id'],
                    'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                    'subtotal' => $sub, 'estado_producto' => $item['estado_producto'] ?? 'bueno',
                    'created_at' => now(),
                ]);
            }

            DB::table('devoluciones')->where('id', $devId)->update(['monto_total' => $montoTotal]);
            DB::commit();
            return response()->json(['success' => true, 'devolucion_id' => $devId, 'numero_devolucion' => $numDev]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $dev = DB::table('devoluciones as d')
            ->leftJoin('ventas as v', 'd.venta_id', '=', 'v.id')
            ->leftJoin('clientes as cl', 'd.cliente_id', '=', 'cl.id')
            ->leftJoin('usuarios as u', 'd.usuario_id', '=', 'u.id')
            ->where('d.id', $id)
            ->select('d.*', 'v.numero_factura', 'cl.nombre as cliente_nombre', 'u.nombre as usuario_nombre')
            ->first();
        if (!$dev) return response()->json(['error' => 'No encontrada'], 404);

        $dev->items = DB::table('devolucion_detalle as dd')
            ->join('productos as p', 'dd.producto_id', '=', 'p.id')
            ->where('dd.devolucion_id', $id)
            ->select('dd.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        return response()->json(['devolucion' => $dev]);
    }

    public function aprobar(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $devolucion = DB::table('devoluciones')->where('id', $id)->first();
            $venta = DB::table('ventas')->where('id', $devolucion->venta_id)->first();
            $ubicacionId = $venta->ubicacion_id ?? null;
            $items = DB::table('devolucion_detalle')->where('devolucion_id', $id)->get();
            foreach ($items as $item) {
                if ($item->estado_producto === 'bueno') {
                    DB::table('productos')->where('id', $item->producto_id)->increment('stock', $item->cantidad);
                    if ($ubicacionId) {
                        $existe = DB::table('inventario_ubicacion')
                            ->where('producto_id', $item->producto_id)
                            ->where('ubicacion_id', $ubicacionId)
                            ->first();
                        if ($existe) {
                            DB::table('inventario_ubicacion')->where('id', $existe->id)->update([
                                'cantidad' => DB::raw("cantidad + {$item->cantidad}"),
                                'updated_at' => now(),
                            ]);
                        } else {
                            DB::table('inventario_ubicacion')->insert([
                                'producto_id' => $item->producto_id,
                                'ubicacion_id' => $ubicacionId,
                                'cantidad' => $item->cantidad,
                                'created_at' => now(), 'updated_at' => now(),
                            ]);
                        }
                    }
                }
            }
            DB::table('devoluciones')->where('id', $id)->update([
                'estado' => 'completada', 'aprobado_por' => $request->user()->id, 'updated_at' => now()
            ]);
            DB::commit();
            return response()->json(['success' => true, 'message' => 'Devolución aprobada']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function rechazar($id)
    {
        DB::table('devoluciones')->where('id', $id)->update(['estado' => 'rechazada', 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }

    public function buscarVenta(Request $request)
    {
        $ventas = DB::table('ventas as v')
            ->leftJoin('clientes as c', 'v.cliente_id', '=', 'c.id')
            ->where('v.estado', 'completada')
            ->where(function ($q) use ($request) {
                $q->where('v.numero_factura', 'like', "%{$request->q}%")
                  ->orWhere('c.nombre', 'like', "%{$request->q}%");
            })
            ->select('v.*', 'c.nombre as cliente_nombre')
            ->orderByDesc('v.created_at')->limit(20)->get();

        foreach ($ventas as $v) {
            $v->items = DB::table('venta_detalle as vd')
                ->join('productos as p', 'vd.producto_id', '=', 'p.id')
                ->where('vd.venta_id', $v->id)
                ->select('vd.*', 'p.nombre as producto_nombre', 'p.codigo')
                ->get();
        }

        return response()->json(['ventas' => $ventas]);
    }
}
