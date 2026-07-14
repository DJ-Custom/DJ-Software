<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PresupuestoController extends Controller
{
    public function index()
    {
        $presupuestos = DB::table('presupuestos')
            ->leftJoin('usuarios', 'usuarios.id', '=', 'presupuestos.usuario_id')
            ->select('presupuestos.*', 'usuarios.nombre as creador')
            ->orderByDesc('presupuestos.created_at')->get();
        $presupuestosConDetalle = [];
        foreach ($presupuestos as $p) {
            $arr = (array) $p;
            $arr['detalle'] = DB::table('presupuesto_detalle')->where('presupuesto_id', $arr['id'])->get();
            $arr['porcentaje_ejecutado'] = $arr['monto_total'] > 0
                ? round(($arr['monto_ejecutado'] / $arr['monto_total']) * 100, 1)
                : 0;
            $presupuestosConDetalle[] = $arr;
        }
        $presupuestos = $presupuestosConDetalle;
        return response()->json(['presupuestos' => $presupuestos]);
    }

    public function store(Request $request)
    {
        $request->validate(['nombre' => 'required|string', 'fecha_inicio' => 'required|date', 'fecha_fin' => 'required|date', 'monto_total' => 'required|numeric|min:0']);
        $id = DB::table('presupuestos')->insertGetId([
            'nombre' => $request->nombre, 'periodo' => $request->periodo ?? 'mensual',
            'fecha_inicio' => $request->fecha_inicio, 'fecha_fin' => $request->fecha_fin,
            'monto_total' => $request->monto_total, 'estado' => 'activo', 'notas' => $request->notas,
            'usuario_id' => auth()->id(), 'created_at' => now(), 'updated_at' => now(),
        ]);
        if ($request->filled('detalle')) {
            foreach ($request->detalle as $d) {
                DB::table('presupuesto_detalle')->insert([
                    'presupuesto_id' => $id, 'categoria' => $d['categoria'],
                    'monto_asignado' => $d['monto_asignado'] ?? 0, 'created_at' => now(),
                ]);
            }
        }
        return response()->json(['success' => true, 'presupuesto' => DB::table('presupuestos')->find($id)]);
    }

    public function show($id)
    {
        $p = DB::table('presupuestos')->find($id);
        if (!$p) return response()->json(['error' => 'No encontrado'], 404);
        $p->detalle = DB::table('presupuesto_detalle')->where('presupuesto_id', $id)->get();
        return response()->json(['presupuesto' => $p]);
    }
}
