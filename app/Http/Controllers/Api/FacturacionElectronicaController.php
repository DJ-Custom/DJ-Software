<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FacturacionElectronicaController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('facturacion_electronica')
            ->leftJoin('ventas', 'ventas.id', '=', 'facturacion_electronica.venta_id')
            ->select('facturacion_electronica.*', 'ventas.numero_factura', 'ventas.total as venta_total');
        if ($request->filled('estado')) $query->where('facturacion_electronica.estado_hacienda', $request->estado);
        if ($request->filled('desde')) $query->where('facturacion_electronica.fecha_emision', '>=', $request->desde);
        if ($request->filled('hasta')) $query->where('facturacion_electronica.fecha_emision', '<=', $request->hasta . ' 23:59:59');

        $page = max(1, (int)$request->get('page', 1));
        $limit = 50;
        $total = $query->count();
        $facturas = $query->orderByDesc('facturacion_electronica.created_at')
            ->offset(($page - 1) * $limit)->limit($limit)->get();

        return response()->json(['facturas' => $facturas, 'total' => $total, 'pages' => ceil($total / $limit)]);
    }

    public function emitir(Request $request)
    {
        $request->validate(['venta_id' => 'required|exists:ventas,id']);
        $venta = DB::table('ventas')->find($request->venta_id);
        $clave = str_pad(rand(0, 99999999), 20, '0', STR_PAD_LEFT) . date('dmY') . str_pad(rand(0, 9999999999), 10, '0', STR_PAD_LEFT);
        $consecutivo = str_pad(DB::table('facturacion_electronica')->count() + 1, 10, '0', STR_PAD_LEFT);

        $id = DB::table('facturacion_electronica')->insertGetId([
            'venta_id' => $request->venta_id,
            'clave_numerica' => $clave,
            'numero_consecutivo' => $consecutivo,
            'tipo_documento' => $request->tipo_documento ?? 'FE',
            'estado_hacienda' => 'pendiente',
            'fecha_emision' => now(),
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'factura' => DB::table('facturacion_electronica')->find($id)]);
    }

    public function show($id)
    {
        $f = DB::table('facturacion_electronica')
            ->leftJoin('ventas', 'ventas.id', '=', 'facturacion_electronica.venta_id')
            ->select('facturacion_electronica.*', 'ventas.numero_factura', 'ventas.total as venta_total')
            ->where('facturacion_electronica.id', $id)->first();
        if (!$f) return response()->json(['error' => 'No encontrado'], 404);
        return response()->json(['factura' => $f]);
    }

    public function reenviar($id)
    {
        $f = DB::table('facturacion_electronica')->find($id);
        if (!$f) return response()->json(['error' => 'No encontrado'], 404);
        DB::table('facturacion_electronica')->where('id', $id)->update(['estado_hacienda' => 'reenviada', 'updated_at' => now()]);
        return response()->json(['success' => true]);
    }
}
