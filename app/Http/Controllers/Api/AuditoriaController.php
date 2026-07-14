<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AuditoriaController extends Controller
{
    public function index(Request $request)
    {
        $query = DB::table('auditoria')
            ->leftJoin('usuarios', 'usuarios.id', '=', 'auditoria.usuario_id')
            ->select('auditoria.*', 'usuarios.nombre as usuario_nombre');

        if ($request->filled('modulo')) $query->where('auditoria.modulo', $request->modulo);
        if ($request->filled('usuario_id')) $query->where('auditoria.usuario_id', $request->usuario_id);
        if ($request->filled('accion')) $query->where('auditoria.accion', $request->accion);
        if ($request->filled('desde')) $query->where('auditoria.created_at', '>=', $request->desde);
        if ($request->filled('hasta')) $query->where('auditoria.created_at', '<=', $request->hasta . ' 23:59:59');

        $total = $query->count();
        $page = max(1, (int) $request->get('page', 1));
        $limit = 50;
        $registros = $query->orderByDesc('auditoria.created_at')
            ->offset(($page - 1) * $limit)->limit($limit)->get();

        $modulos = DB::table('auditoria')->select('modulo')->distinct()->orderBy('modulo')->pluck('modulo');

        return response()->json([
            'registros' => $registros,
            'total' => $total,
            'pages' => ceil($total / $limit),
            'page' => $page,
            'modulos' => $modulos,
        ]);
    }

    public function show($id)
    {
        $registro = DB::table('auditoria')
            ->leftJoin('usuarios', 'usuarios.id', '=', 'auditoria.usuario_id')
            ->select('auditoria.*', 'usuarios.nombre as usuario_nombre')
            ->where('auditoria.id', $id)->first();

        if (!$registro) return response()->json(['error' => 'Registro no encontrado'], 404);
        return response()->json(['registro' => $registro]);
    }
}
