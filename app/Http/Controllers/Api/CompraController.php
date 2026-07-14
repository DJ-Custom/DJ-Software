<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CompraController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('compras as c')
            ->leftJoin('proveedores as pr', 'c.proveedor_id', '=', 'pr.id')
            ->leftJoin('usuarios as u', 'c.usuario_id', '=', 'u.id')
            ->select('c.*', 'pr.nombre as proveedor_nombre', 'u.nombre as usuario_nombre');

        if ($request->estado) $query->where('c.estado', $request->estado);
        if ($request->q) {
            $query->where(function ($q) use ($request) {
                $q->where('c.numero_compra', 'like', "%{$request->q}%")
                  ->orWhere('pr.nombre', 'like', "%{$request->q}%");
            });
        }

        $data = $query->orderByDesc('c.created_at')->paginate(20);
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate(['proveedor_id' => 'required|exists:proveedores,id', 'items' => 'required|array|min:1']);

        $lockKey = $this->generateLockKey('crear_compra', [
            'user' => $request->user()?->id,
            'proveedor' => $request->proveedor_id,
            'items_hash' => md5(json_encode($request->items)),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            try {
                DB::beginTransaction();
                $date = date('Ymd');
                $cnt = DB::table('compras')->whereDate('created_at', today())->count() + 1;
                $numCompra = 'OC-' . $date . '-' . str_pad($cnt, 4, '0', STR_PAD_LEFT);

                $compraId = DB::table('compras')->insertGetId([
                    'numero_compra' => $numCompra,
                    'proveedor_id' => $request->proveedor_id,
                    'usuario_id' => $request->user()->id,
                    'subtotal' => 0, 'impuesto_total' => 0, 'total' => 0,
                    'estado' => 'pendiente',
                    'fecha_compra' => $request->fecha_compra ?? today(),
                    'fecha_entrega' => $request->fecha_entrega,
                    'factura_proveedor' => $request->factura_proveedor,
                    'notas' => $request->notas,
                    'created_at' => now(), 'updated_at' => now(),
                ]);

                $subtotal = 0;
                foreach ($request->items as $item) {
                    $sub = $item['precio_unitario'] * $item['cantidad'];
                    $subtotal += $sub;
                    DB::table('compra_detalle')->insert([
                        'compra_id' => $compraId, 'producto_id' => $item['producto_id'],
                        'cantidad' => $item['cantidad'], 'precio_unitario' => $item['precio_unitario'],
                        'subtotal' => $sub, 'created_at' => now(),
                    ]);
                }

                DB::table('compras')->where('id', $compraId)->update([
                    'subtotal' => $subtotal, 'total' => $subtotal,
                ]);

                DB::commit();
                return response()->json(['success' => true, 'compra_id' => $compraId, 'numero_compra' => $numCompra]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => $e->getMessage()], 500);
            }
        }, response()->json(['error' => 'Ya se está procesando esta compra. Por favor espere.'], 429));
    }

    public function show($id)
    {
        $compra = DB::table('compras as c')
            ->leftJoin('proveedores as pr', 'c.proveedor_id', '=', 'pr.id')
            ->leftJoin('usuarios as u', 'c.usuario_id', '=', 'u.id')
            ->where('c.id', $id)
            ->select('c.*', 'pr.nombre as proveedor_nombre', 'u.nombre as usuario_nombre')
            ->first();
        if (!$compra) return response()->json(['error' => 'No encontrada'], 404);

        $compra->items = DB::table('compra_detalle as d')
            ->join('productos as p', 'd.producto_id', '=', 'p.id')
            ->where('d.compra_id', $id)
            ->select('d.*', 'p.nombre as producto_nombre', 'p.codigo')
            ->get();

        return response()->json(['compra' => $compra]);
    }

    public function recibir(Request $request, $id)
    {
        try {
            DB::beginTransaction();
            $compra = DB::table('compras')->where('id', $id)->first();
            $ubicacionId = $compra->ubicacion_id ?? DB::table('ubicaciones')->where('activo', 1)->orderBy('id')->value('id');
            $items = DB::table('compra_detalle')->where('compra_id', $id)->get();
            foreach ($items as $item) {
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

                $stockGlobal = DB::table('productos')->where('id', $item->producto_id)->value('stock');
                DB::table('inventario_movimientos')->insert([
                    'producto_id' => $item->producto_id, 'tipo' => 'entrada',
                    'cantidad' => $item->cantidad,
                    'stock_anterior' => $stockGlobal - $item->cantidad,
                    'stock_nuevo' => $stockGlobal,
                    'referencia_tipo' => 'compra', 'referencia_id' => $id,
                    'usuario_id' => $request->user()->id, 'notas' => 'Recepción de compra',
                    'created_at' => now(),
                ]);
            }
            DB::table('compras')->where('id', $id)->update(['estado' => 'recibida', 'fecha_entrega' => today(), 'updated_at' => now()]);
            DB::commit();
            return response()->json(['success' => true, 'message' => 'Compra recibida y stock actualizado']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function cancelar($id)
    {
        DB::table('compras')->where('id', $id)->update(['estado' => 'cancelada', 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }
}
