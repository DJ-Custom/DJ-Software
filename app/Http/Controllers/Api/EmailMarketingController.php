<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SmtpConfigHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;

class EmailMarketingController extends Controller
{
    public function campanas(Request $request)
    {
        $campanas = DB::table('campanas_email')
            ->leftJoin('usuarios', 'usuarios.id', '=', 'campanas_email.usuario_id')
            ->select('campanas_email.*', 'usuarios.nombre as creador')
            ->orderByDesc('campanas_email.created_at')->limit(50)->get();
        foreach ($campanas as &$c) {
            $c->destinatarios_count = DB::table('email_destinatarios')->where('campana_id', $c->id)->count();
            $c->enviados_count = DB::table('email_destinatarios')->where('campana_id', $c->id)->where('estado', 'enviado')->count();
        }
        return response()->json(['campanas' => $campanas]);
    }

    public function crearCampana(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:200',
            'asunto' => 'required|string|max:200',
            'contenido_html' => 'required|string',
        ]);
        $id = DB::table('campanas_email')->insertGetId([
            'nombre' => $request->nombre,
            'asunto' => $request->asunto,
            'contenido_html' => $request->contenido_html,
            'estado' => 'borrador',
            'usuario_id' => auth()->id(),
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'campana' => DB::table('campanas_email')->find($id)]);
    }

    public function agregarDestinatarios(Request $request, $id)
    {
        $campana = DB::table('campanas_email')->find($id);
        if (!$campana) return response()->json(['error' => 'Campaña no encontrada'], 404);

        $destinatarios = [];
        if ($request->filled('emails')) {
            foreach ($request->emails as $email) {
                $destinatarios[] = ['campana_id' => $id, 'email' => $email['email'], 'nombre' => $email['nombre'] ?? null, 'cliente_id' => $email['cliente_id'] ?? null, 'estado' => 'pendiente', 'created_at' => now()];
            }
        }
        if ($request->filled('etiquetas')) {
            $clientes = DB::table('clientes')
                ->join('cliente_etiquetas', 'clientes.id', '=', 'cliente_etiquetas.cliente_id')
                ->join('etiquetas', 'etiquetas.id', '=', 'cliente_etiquetas.etiqueta_id')
                ->whereIn('etiquetas.id', $request->etiquetas)
                ->whereNotNull('clientes.email')
                ->select('clientes.id', 'clientes.nombre', 'clientes.email')
                ->distinct()->get();
            foreach ($clientes as $c) {
                $destinatarios[] = ['campana_id' => $id, 'email' => $c->email, 'nombre' => $c->nombre, 'cliente_id' => $c->id, 'estado' => 'pendiente', 'created_at' => now()];
            }
        }
        if ($request->filled('todos_clientes') && $request->todos_clientes) {
            $clientes = DB::table('clientes')->whereNotNull('email')->select('id', 'nombre', 'email')->get();
            foreach ($clientes as $c) {
                $destinatarios[] = ['campana_id' => $id, 'email' => $c->email, 'nombre' => $c->nombre, 'cliente_id' => $c->id, 'estado' => 'pendiente', 'created_at' => now()];
            }
        }
        if (count($destinatarios)) DB::table('email_destinatarios')->insert($destinatarios);
        return response()->json(['success' => true, 'agregados' => count($destinatarios)]);
    }

    public function enviarCampana(Request $request, $id)
    {
        $campana = DB::table('campanas_email')->find($id);
        if (!$campana) return response()->json(['error' => 'Campaña no encontrada'], 404);

        $destinatarios = DB::table('email_destinatarios')
            ->where('campana_id', $id)->where('estado', 'pendiente')->get();

        // Aplicar configuración SMTP desde la base de datos
        SmtpConfigHelper::aplicarConfiguracion();

        $enviados = 0;
        foreach ($destinatarios as $dest) {
            try {
                Mail::html($campana->contenido_html, function ($msg) use ($campana, $dest) {
                    $msg->to($dest->email, $dest->nombre)->subject($campana->asunto);
                });
                DB::table('email_destinatarios')->where('id', $dest->id)->update(['estado' => 'enviado', 'enviado_at' => now()]);
                $enviados++;
            } catch (\Throwable $e) {
                DB::table('email_destinatarios')->where('id', $dest->id)->update(['estado' => 'error', 'error_mensaje' => substr($e->getMessage(), 0, 255)]);
            }
        }
        if ($enviados === 0 && count($destinatarios) > 0) {
            return response()->json(['error' => 'No se pudo enviar ningún correo. Verifique la configuración del servidor de correo (SMTP).'], 500);
        }

        DB::table('campanas_email')->where('id', $id)->update(['estado' => 'enviada', 'fecha_envio' => now(), 'updated_at' => now()]);
        return response()->json(['success' => true, 'enviados' => $enviados]);
    }

    public function registroEmails(Request $request)
    {
        $query = DB::table('email_destinatarios')
            ->join('campanas_email', 'campanas_email.id', '=', 'email_destinatarios.campana_id')
            ->select('email_destinatarios.*', 'campanas_email.nombre as campana_nombre', 'campanas_email.asunto');
        if ($request->filled('estado')) $query->where('email_destinatarios.estado', $request->estado);
        if ($request->filled('campana_id')) $query->where('email_destinatarios.campana_id', $request->campana_id);

        $page = max(1, (int)$request->get('page', 1));
        $limit = 50;
        $total = $query->count();
        $registros = $query->orderByDesc('email_destinatarios.created_at')
            ->offset(($page - 1) * $limit)->limit($limit)->get();

        return response()->json(['registros' => $registros, 'total' => $total, 'pages' => ceil($total / $limit)]);
    }

    public function plantillas()
    {
        return response()->json(['plantillas' => DB::table('plantillas_email')->orderByDesc('created_at')->get()]);
    }

    public function crearPlantilla(Request $request)
    {
        $request->validate(['nombre' => 'required|string', 'contenido_html' => 'required|string']);
        $id = DB::table('plantillas_email')->insertGetId([
            'nombre' => $request->nombre,
            'asunto' => $request->asunto,
            'contenido_html' => $request->contenido_html,
            'contenido_json' => $request->contenido_json,
            'categoria' => $request->categoria,
            'usuario_id' => auth()->id(),
            'created_at' => now(), 'updated_at' => now(),
        ]);
        return response()->json(['success' => true, 'plantilla' => DB::table('plantillas_email')->find($id)]);
    }

    public function actualizarPlantilla(Request $request, $id)
    {
        DB::table('plantillas_email')->where('id', $id)->update(array_filter([
            'nombre' => $request->nombre,
            'asunto' => $request->asunto,
            'contenido_html' => $request->contenido_html,
            'contenido_json' => $request->contenido_json,
            'updated_at' => now(),
        ], fn($v) => $v !== null));
        return response()->json(['success' => true]);
    }
}
