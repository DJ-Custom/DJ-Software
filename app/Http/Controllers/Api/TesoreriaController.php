<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TesoreriaController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('tesoreria_movimientos')
            ->leftJoin('usuarios', 'usuarios.id', '=', 'tesoreria_movimientos.usuario_id')
            ->select('tesoreria_movimientos.*', 'usuarios.nombre as usuario_nombre');
        if ($request->filled('tipo')) $query->where('tesoreria_movimientos.tipo', $request->tipo);
        if ($request->filled('desde')) $query->where('tesoreria_movimientos.fecha', '>=', $request->desde);
        if ($request->filled('hasta')) $query->where('tesoreria_movimientos.fecha', '<=', $request->hasta);

        $movimientos = $query->orderByDesc('tesoreria_movimientos.fecha')->limit(200)->get();

        $ingresos = DB::table('tesoreria_movimientos')->where('tipo', 'ingreso')->sum('monto');
        $egresos = DB::table('tesoreria_movimientos')->where('tipo', 'egreso')->sum('monto');

        return response()->json([
            'movimientos' => $movimientos,
            'resumen' => ['ingresos' => $ingresos, 'egresos' => $egresos, 'saldo' => $ingresos - $egresos],
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'tipo' => 'required|in:ingreso,egreso',
            'monto' => 'required|numeric|min:0.01',
            'fecha' => 'required|date',
        ]);
        $id = DB::table('tesoreria_movimientos')->insertGetId([
            'tipo' => $request->tipo,
            'categoria' => $request->categoria,
            'monto' => $request->monto,
            'descripcion' => $request->descripcion,
            'referencia' => $request->referencia,
            'metodo_pago' => $request->metodo_pago,
            'usuario_id' => auth()->id(),
            'ubicacion_id' => $request->ubicacion_id,
            'fecha' => $request->fecha,
            'estado' => 'confirmado',
            'notas' => $request->notas,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'movimiento' => DB::table('tesoreria_movimientos')->find($id)]);
    }

    public function update(Request $request, $id)
    {
        $movimiento = DB::table('tesoreria_movimientos')->where('id', $id)->first();
        if (!$movimiento) return response()->json(['error' => 'Movimiento no encontrado'], 404);

        $request->validate([
            'tipo' => 'sometimes|in:ingreso,egreso',
            'monto' => 'sometimes|numeric|min:0.01',
            'fecha' => 'sometimes|date',
        ]);

        DB::table('tesoreria_movimientos')->where('id', $id)->update([
            'tipo' => $request->tipo ?? $movimiento->tipo,
            'categoria' => $request->categoria ?? $movimiento->categoria,
            'monto' => $request->monto ?? $movimiento->monto,
            'descripcion' => $request->descripcion ?? $movimiento->descripcion,
            'referencia' => $request->referencia ?? $movimiento->referencia,
            'metodo_pago' => $request->metodo_pago ?? $movimiento->metodo_pago,
            'fecha' => $request->fecha ?? $movimiento->fecha,
            'notas' => $request->notas ?? $movimiento->notas,
            'updated_at' => now(),
        ]);

        return response()->json(['success' => true, 'movimiento' => DB::table('tesoreria_movimientos')->find($id)]);
    }

    public function destroy($id)
    {
        $movimiento = DB::table('tesoreria_movimientos')->where('id', $id)->first();
        if (!$movimiento) return response()->json(['error' => 'Movimiento no encontrado'], 404);

        DB::table('tesoreria_movimientos')->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }
}
