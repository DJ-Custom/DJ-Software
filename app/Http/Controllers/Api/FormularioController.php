<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FormularioController extends Controller
{
    public function index()
    {
        $formularios = DB::table('formularios')
            ->selectRaw('formularios.*, (SELECT COUNT(*) FROM formulario_respuestas WHERE formulario_respuestas.formulario_id = formularios.id) as respuestas_count')
            ->orderByDesc('created_at')
            ->get();
        return response()->json(['formularios' => $formularios]);
    }

    public function store(Request $request)
    {
        $request->validate(['nombre' => 'required|string|max:100']);
        $id = DB::table('formularios')->insertGetId([
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'campos_json' => $request->campos_json ?? '[]',
            'activo' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'id' => $id]);
    }

    public function respuestas()
    {
        $respuestas = DB::table('formulario_respuestas as r')
            ->join('formularios as f', 'r.formulario_id', '=', 'f.id')
            ->select('r.*', 'f.nombre as formulario_nombre')
            ->orderByDesc('r.created_at')
            ->limit(100)
            ->get()
            ->map(function ($r) {
                $r->datos = json_decode($r->datos_json, true);
                return $r;
            });
        return response()->json(['respuestas' => $respuestas]);
    }

    public function atender($id)
    {
        DB::table('formulario_respuestas')->where('id', $id)->update([
            'atendido' => true,
            'atendido_en' => now(),
            'updated_at' => now(),
        ]);
        return response()->json(['success' => true]);
    }

    /**
     * Public webhook endpoint - no auth required
     */
    public function webhook(Request $request, $id)
    {
        $apiActiva = DB::table('configuracion')->where('clave', 'api_webhook_activa')->value('valor') ?? '1';
        if ($apiActiva === '0' || $apiActiva === 'false') {
            return response()->json(['error' => 'La API de leads está temporalmente desactivada.'], 503);
        }

        $formulario = DB::table('formularios')->where('id', $id)->where('activo', true)->first();
        if (!$formulario) return response()->json(['error' => 'Formulario no encontrado o inactivo'], 404);

        $datos = $request->except(['_token']);

        DB::table('formulario_respuestas')->insert([
            'formulario_id' => $id,
            'datos_json' => json_encode($datos),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'atendido' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Return JSON for AJAX or redirect for form submit
        if ($request->wantsJson() || $request->ajax()) {
            return response()->json(['success' => true, 'message' => 'Formulario recibido correctamente']);
        }

        return response()->json(['success' => true, 'message' => 'Gracias, hemos recibido tu información.']);
    }
}
