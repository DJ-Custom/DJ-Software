<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CrmController extends Controller
{
    public function dashboard()
    {
        $etapas = DB::table('crm_etapas')->where('activo', 1)->orderBy('orden')->get();
        foreach ($etapas as &$e) {
            $e->oportunidades = DB::table('crm_oportunidades')
                ->leftJoin('clientes', 'clientes.id', '=', 'crm_oportunidades.cliente_id')
                ->where('crm_oportunidades.etapa_id', $e->id)
                ->where('crm_oportunidades.estado', 'abierta')
                ->select('crm_oportunidades.*', 'clientes.nombre as cliente_nombre')
                ->orderByDesc('crm_oportunidades.created_at')->get();
            $e->valor_total = collect($e->oportunidades)->sum('valor_estimado');
        }
        $totalPipeline = DB::table('crm_oportunidades')->where('estado', 'abierta')->sum('valor_estimado');
        $ganadas = DB::table('crm_oportunidades')->where('estado', 'ganada')->whereBetween('updated_at', [now()->startOfMonth(), now()])->sum('valor_estimado');
        return response()->json(['etapas' => $etapas, 'total_pipeline' => $totalPipeline, 'ganadas_mes' => $ganadas]);
    }

    public function oportunidades(Request $request)
    {
        $query = DB::table('crm_oportunidades')
            ->leftJoin('clientes', 'clientes.id', '=', 'crm_oportunidades.cliente_id')
            ->leftJoin('crm_etapas', 'crm_etapas.id', '=', 'crm_oportunidades.etapa_id')
            ->select('crm_oportunidades.*', 'clientes.nombre as cliente_nombre', 'crm_etapas.nombre as etapa_nombre');
        if ($request->filled('estado')) $query->where('crm_oportunidades.estado', $request->estado);
        return response()->json(['oportunidades' => $query->orderByDesc('crm_oportunidades.created_at')->get()]);
    }

    public function crearOportunidad(Request $request)
    {
        $request->validate(['titulo' => 'required|string']);
        $id = DB::table('crm_oportunidades')->insertGetId([
            'titulo' => $request->titulo, 'cliente_id' => $request->cliente_id,
            'usuario_id' => auth()->id(), 'etapa_id' => $request->etapa_id,
            'valor_estimado' => $request->valor_estimado ?? 0,
            'probabilidad' => $request->probabilidad ?? 50,
            'fecha_cierre_estimada' => $request->fecha_cierre_estimada,
            'estado' => 'abierta', 'notas' => $request->notas, 'origen' => $request->origen,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'oportunidad' => DB::table('crm_oportunidades')->find($id)]);
    }

    public function moverOportunidad(Request $request, $id)
    {
        DB::table('crm_oportunidades')->where('id', $id)->update([
            'etapa_id' => $request->etapa_id, 'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function cerrarOportunidad(Request $request, $id)
    {
        DB::table('crm_oportunidades')->where('id', $id)->update([
            'estado' => $request->estado, 'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    public function etapas()
    {
        return response()->json(['etapas' => DB::table('crm_etapas')->orderBy('orden')->get()]);
    }

    public function crearEtapa(Request $request)
    {
        $request->validate(['nombre' => 'required|string']);
        $maxOrden = DB::table('crm_etapas')->max('orden') ?? 0;
        $id = DB::table('crm_etapas')->insertGetId([
            'nombre' => $request->nombre, 'color' => $request->color ?? '#3b82f6',
            'orden' => $maxOrden + 1, 'activo' => true, 'created_at' => now(),
        ]);
        return response()->json(['success' => true, 'etapa' => DB::table('crm_etapas')->find($id)]);
    }

    public function actividades(Request $request)
    {
        $query = DB::table('crm_actividades')
            ->leftJoin('clientes', 'clientes.id', '=', 'crm_actividades.cliente_id')
            ->select('crm_actividades.*', 'clientes.nombre as cliente_nombre');
        if ($request->filled('oportunidad_id')) $query->where('crm_actividades.oportunidad_id', $request->oportunidad_id);
        return response()->json(['actividades' => $query->orderByDesc('crm_actividades.created_at')->limit(50)->get()]);
    }

    public function crearActividad(Request $request)
    {
        $request->validate(['titulo' => 'required|string', 'tipo' => 'required|string']);
        $id = DB::table('crm_actividades')->insertGetId([
            'oportunidad_id' => $request->oportunidad_id, 'cliente_id' => $request->cliente_id,
            'usuario_id' => auth()->id(), 'tipo' => $request->tipo, 'titulo' => $request->titulo,
            'descripcion' => $request->descripcion, 'fecha_programada' => $request->fecha_programada,
            'estado' => 'pendiente', 'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }
}
