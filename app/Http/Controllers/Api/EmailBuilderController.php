<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EmailCampaign;
use App\Models\EmailTemplate;
use App\Models\EmailRecipient;
use App\Models\EmailAnalytics;
use App\Services\SmtpConfigHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class EmailBuilderController extends Controller
{
    // ================= CAMPAIGNS =================

    public function campaigns(Request $request)
    {
        $query = EmailCampaign::with('creador:id,nombre')
            ->orderByDesc('created_at');

        if ($request->filled('estado')) {
            $query->where('estado', $request->estado);
        }
        if ($request->filled('busqueda')) {
            $q = $request->busqueda;
            $query->where(function ($sq) use ($q) {
                $sq->where('nombre', 'like', "%$q%")
                ->orWhere('asunto', 'like', "%$q%");
            });
        }

        $campaigns = $query->paginate(20);
        return response()->json(['campaigns' => $campaigns]);
    }

    public function storeCampaign(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'asunto' => 'nullable|string|max:255',
            'html_content' => 'nullable|string',
            'json_content' => 'nullable|string',
        ]);

        try {
            $campaign = EmailCampaign::create([
                'nombre' => $request->nombre,
                'asunto' => $request->asunto,
                'html_content' => $request->html_content,
                'json_content' => $request->json_content,
                'estado' => 'borrador',
                'usuario_id' => auth()->id(),
            ]);

            return response()->json(['campaign' => $campaign]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al crear la campaña: ' . $e->getMessage()], 500);
        }
    }

    public function showCampaign($id)
    {
        $campaign = EmailCampaign::with([
            'creador:id,nombre',
            'recipients' => function ($q) {
                $q->select('id', 'campaign_id', 'email', 'nombre', 'estado', 'abierto_at', 'click_at', 'enviado_at')
                ->orderByDesc('created_at')
                ->limit(50);
            },
        ])->findOrFail($id);

        // Estadísticas rápidas sin cargar todos los recipients
        $campaign->total_recipients_count = EmailRecipient::where('campaign_id', $id)->count();
        $campaign->total_enviados_count = EmailRecipient::where('campaign_id', $id)->where('estado', 'enviado')->count();
        $campaign->total_abiertos_count = EmailRecipient::where('campaign_id', $id)->whereNotNull('abierto_at')->count();

        return response()->json(['campaign' => $campaign]);
    }

    public function updateCampaign(Request $request, $id)
    {
        $request->validate([
            'nombre' => 'sometimes|required|string|max:255',
            'asunto' => 'nullable|string|max:255',
            'html_content' => 'nullable|string',
            'json_content' => 'nullable|string',
            'thumbnail' => 'nullable|string',
        ]);

        try {
            $campaign = EmailCampaign::findOrFail($id);

            $data = array_filter([
                'nombre' => $request->nombre,
                'asunto' => $request->asunto,
                'html_content' => $request->html_content,
                'json_content' => $request->json_content,
                'thumbnail' => $request->thumbnail,
            ], fn($v) => $v !== null);

            if (empty($data)) {
                return response()->json(['error' => 'No se recibieron datos para actualizar.'], 422);
            }

            $campaign->update($data);
            return response()->json(['campaign' => $campaign->fresh()]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al actualizar la campaña: ' . $e->getMessage()], 500);
        }
    }

    public function destroyCampaign($id)
    {
        EmailCampaign::findOrFail($id)->delete();
        return response()->json(['message' => 'Campaña eliminada']);
    }

    // ================= TEMPLATES =================

    public function templates(Request $request)
    {
        $query = EmailTemplate::with('creador:id,nombre')
            ->orderByDesc('created_at');

        if ($request->filled('categoria')) {
            $query->where('categoria', $request->categoria);
        }
        if ($request->filled('busqueda')) {
            $q = $request->busqueda;
            $query->where('nombre', 'like', "%$q%");
        }

        $templates = $query->paginate(30);
        return response()->json(['templates' => $templates]);
    }

    public function storeTemplate(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'html_content' => 'nullable|string',
            'json_content' => 'nullable|string',
        ]);

        try {
            $template = EmailTemplate::create([
                'nombre' => $request->nombre,
                'asunto' => $request->asunto,
                'categoria' => $request->categoria ?? 'General',
                'html_content' => $request->html_content,
                'json_content' => $request->json_content,
                'thumbnail' => $request->thumbnail,
                'es_publico' => $request->boolean('es_publico', false),
                'usuario_id' => auth()->id(),
            ]);

            return response()->json(['template' => $template]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al crear la plantilla: ' . $e->getMessage()], 500);
        }
    }

    public function updateTemplate(Request $request, $id)
    {
        $request->validate([
            'nombre' => 'sometimes|required|string|max:255',
            'asunto' => 'nullable|string|max:255',
            'categoria' => 'nullable|string|max:50',
            'html_content' => 'nullable|string',
            'json_content' => 'nullable|string',
            'thumbnail' => 'nullable|string',
        ]);

        try {
            $template = EmailTemplate::findOrFail($id);

            $data = array_filter([
                'nombre' => $request->nombre,
                'asunto' => $request->asunto,
                'categoria' => $request->categoria,
                'html_content' => $request->html_content,
                'json_content' => $request->json_content,
                'thumbnail' => $request->thumbnail,
            ], fn($v) => $v !== null);

            if (empty($data)) {
                return response()->json(['error' => 'No se recibieron datos para actualizar.'], 422);
            }

            $template->update($data);
            return response()->json(['template' => $template->fresh()]);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al actualizar la plantilla: ' . $e->getMessage()], 500);
        }
    }

    public function showTemplate($id)
    {
        $template = EmailTemplate::with('creador:id,nombre')->findOrFail($id);
        return response()->json(['template' => $template]);
    }

    public function destroyTemplate($id)
    {
        EmailTemplate::findOrFail($id)->delete();
        return response()->json(['message' => 'Plantilla eliminada']);
    }

    // ================= RECIPIENTS & SEND =================

    public function addRecipients(Request $request, $id)
    {
        $campaign = EmailCampaign::findOrFail($id);
        $recipients = [];

        // Usar collection de Laravel en lugar de array PHP para mejor rendimiento
        $existingEmails = collect(
            DB::table('email_recipients')
                ->where('campaign_id', $id)
                ->pluck('email')
        )->map(fn($e) => strtolower(trim($e)))->flip();

        $addRecipient = function ($email, $nombre = null, $clienteId = null) use (&$recipients, $id, $existingEmails) {
            $email = strtolower(trim($email));
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return;
            if ($existingEmails->has($email)) return;
            $existingEmails->put($email, true);
            $recipients[] = [
                'campaign_id' => $id,
                'email' => $email,
                'nombre' => $nombre,
                'cliente_id' => $clienteId,
                'estado' => 'pendiente',
                'created_at' => now(),
            ];
        };

        if ($request->filled('emails')) {
            foreach ($request->emails as $item) {
                $addRecipient($item['email'], $item['nombre'] ?? null, $item['cliente_id'] ?? null);
            }
        }
        if ($request->filled('cliente_ids')) {
            $clientes = DB::table('clientes')
                ->whereIn('id', (array) $request->cliente_ids)
                ->whereNotNull('email')->where('email', '!=', '')
                ->select('id', 'nombre', 'email')->get();
            foreach ($clientes as $c) {
                $addRecipient($c->email, $c->nombre, $c->id);
            }
        }
        if ($request->filled('etiquetas')) {
            $clientes = DB::table('clientes')
                ->join('cliente_etiquetas', 'clientes.id', '=', 'cliente_etiquetas.cliente_id')
                ->whereIn('cliente_etiquetas.etiqueta_id', $request->etiquetas)
                ->whereNotNull('clientes.email')->where('clientes.email', '!=', '')
                ->select('clientes.id', 'clientes.nombre', 'clientes.email')
                ->distinct()->get();
            foreach ($clientes as $c) {
                $addRecipient($c->email, $c->nombre, $c->id);
            }
        }
        if ($request->boolean('todos_clientes')) {
            $clientes = DB::table('clientes')
                ->whereNotNull('email')->where('email', '!=', '')
                ->select('id', 'nombre', 'email')->get();
            foreach ($clientes as $c) {
                $addRecipient($c->email, $c->nombre, $c->id);
            }
        }
        if ($request->filled('filtros')) {
            $filtros = $request->filtros;
            $query = DB::table('clientes')
                ->whereNotNull('email')->where('email', '!=', '');
            if (!empty($filtros['clasificacion'])) {
                $query->where('clasificacion', $filtros['clasificacion']);
            }
            if (!empty($filtros['activo'])) {
                $query->where('activo', $filtros['activo']);
            }
            if (!empty($filtros['q'])) {
                $q = $filtros['q'];
                $query->where(function ($qb) use ($q) {
                    $qb->where('nombre', 'LIKE', "%{$q}%")
                        ->orWhere('telefono', 'LIKE', "%{$q}%")
                        ->orWhere('cedula', 'LIKE', "%{$q}%")
                        ->orWhere('email', 'LIKE', "%{$q}%");
                });
            }
            if (!empty($filtros['etiqueta_ids'])) {
                $query->join('cliente_etiquetas', 'clientes.id', '=', 'cliente_etiquetas.cliente_id')
                    ->whereIn('cliente_etiquetas.etiqueta_id', (array) $filtros['etiqueta_ids'])
                    ->distinct();
            }
            foreach ($query->select('clientes.id', 'clientes.nombre', 'clientes.email')->get() as $c) {
                $addRecipient($c->email, $c->nombre, $c->id);
            }
        }

        // Insertar en bloques de 500 para no saturar la memoria
        if (count($recipients)) {
            $chunks = array_chunk($recipients, 500);
            foreach ($chunks as $chunk) {
                DB::table('email_recipients')->insert($chunk);
            }
            $campaign->increment('total_recipients', count($recipients));
        }

        return response()->json(['agregados' => count($recipients)]);
    }

    /**
     * Envío asíncrono: marca como "enviando" y dispara un Job por cada batch.
     * El envío real se hace en background con queue:work
     */
    public function sendCampaign(Request $request, $id)
    {
        $campaign = EmailCampaign::findOrFail($id);

        if ($campaign->estado === 'enviando') {
            return response()->json(['error' => 'La campaña ya está en proceso de envío.'], 409);
        }

        if (!$campaign->html_content) {
            return response()->json(['error' => 'La campaña no tiene contenido'], 422);
        }

        $pendingCount = EmailRecipient::where('campaign_id', $id)->where('estado', 'pendiente')->count();

        if ($pendingCount === 0) {
            return response()->json(['error' => 'No hay destinatarios pendientes'], 422);
        }

        // Leer configuración del correo una sola vez
        $fromEmail = DB::table('configuracion')->where('clave', 'email_remitente')->value('valor') ?? '';
        if (!$fromEmail || !filter_var($fromEmail, FILTER_VALIDATE_EMAIL)) {
            $fromEmail = DB::table('configuracion')->where('clave', 'email_negocio')->value('valor') ?? '';
        }
        if (!$fromEmail || !filter_var($fromEmail, FILTER_VALIDATE_EMAIL)) {
            return response()->json(['error' => 'No hay un correo remitente configurado. Ve a Configuración > Empresa y define el "Email remitente".'], 422);
        }

        $fromName = DB::table('configuracion')->where('clave', 'nombre_negocio')->value('valor') ?? 'Sistema';

        // Aplicar configuración SMTP desde la base de datos
        SmtpConfigHelper::aplicarConfiguracion();

        // Marcar campaña como "enviando"
        $campaign->update(['estado' => 'enviando']);

        // Enviar en lotes de 50 de forma síncrona pero controlada
        // Cada lote se procesa y se libera memoria
        $batchSize = 50;
        $totalRecipients = $pendingCount;
        $batches = (int) ceil($totalRecipients / $batchSize);
        $enviados = 0;
        $errores = [];

        for ($batch = 0; $batch < $batches; $batch++) {
            $recipients = EmailRecipient::where('campaign_id', $id)
                ->where('estado', 'pendiente')
                ->limit($batchSize)
                ->get();

            if ($recipients->isEmpty()) break;

            foreach ($recipients as $dest) {
                try {
                    $html = $this->injectTrackingPixel($campaign->html_content, $dest->id);
                    Mail::html($html, function ($msg) use ($campaign, $dest, $fromEmail, $fromName) {
                        $msg->to($dest->email, $dest->nombre)
                            ->subject($campaign->asunto)
                            ->from($fromEmail, $fromName);
                    });
                    $dest->update(['estado' => 'enviado', 'enviado_at' => now()]);
                    $enviados++;
                } catch (\Throwable $e) {
                    $errorMsg = substr($e->getMessage(), 0, 255);
                    $dest->update(['estado' => 'error', 'error_mensaje' => $errorMsg]);
                    $errores[] = $errorMsg;
                }
            }

            // Liberar memoria entre lotes
            gc_collect_cycles();
        }

        if ($enviados === 0 && $totalRecipients > 0) {
            $uniqueError = count($errores) ? implode(' | ', array_slice(array_unique($errores), 0, 3)) : 'Verifique la configuración del servidor de correo (SMTP).';
            $campaign->update(['estado' => 'borrador']);
            return response()->json(['error' => 'No se pudo enviar ningún correo. ' . $uniqueError], 500);
        }

        $newEstado = $enviados >= $totalRecipients ? 'enviada' : 'borrador';
        $campaign->update([
            'estado' => $newEstado,
            'enviada_en' => $enviados >= $totalRecipients ? now() : $campaign->enviada_en,
            'total_enviados' => $campaign->total_enviados + $enviados,
        ]);

        return response()->json([
            'enviados' => $enviados,
            'fallidos' => $totalRecipients - $enviados,
        ]);
    }

    private function injectTrackingPixel($html, $recipientId)
    {
        $pixel = '<img src="' . url('/api/email/track/' . $recipientId) . '" width="1" height="1" alt="" />';
        return str_replace('</body>', $pixel . '</body>', $html);
    }

    // ================= ANALYTICS =================

    public function analytics($id)
    {
        $campaign = EmailCampaign::findOrFail($id);

        // Una sola query optimizada con subconsultas para estadísticas
        $stats = DB::table('email_recipients')
            ->where('campaign_id', $id)
            ->selectRaw('
                COUNT(*) as total_recipients,
                SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as total_enviados,
                SUM(CASE WHEN abierto_at IS NOT NULL THEN 1 ELSE 0 END) as total_abiertos,
                SUM(CASE WHEN click_at IS NOT NULL THEN 1 ELSE 0 END) as total_clicks,
                SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as total_rebotes
            ', ['enviado', 'rebote'])
            ->first();

        // Dispositivos en una query
        $deviceBreakdown = DB::table('email_recipients')
            ->where('campaign_id', $id)
            ->whereNotNull('device')
            ->selectRaw('device, COUNT(*) as count')
            ->groupBy('device')
            ->pluck('count', 'device');

        // Datos diarios
        $dailyData = EmailAnalytics::where('campaign_id', $id)
            ->orderBy('fecha')
            ->get();

        return response()->json(['stats' => [
            'total_recipients' => $campaign->total_recipients,
            'total_enviados' => $campaign->total_enviados,
            'total_abiertos' => (int) $stats->total_abiertos,
            'total_clicks' => (int) $stats->total_clicks,
            'total_rebotes' => (int) $stats->total_rebotes,
            'device_breakdown' => $deviceBreakdown,
            'daily_data' => $dailyData,
        ]]);
    }

    public function dashboard()
    {
        $userId = auth()->id();
        $isAdmin = (auth()->user()->rol->nombre ?? '') === 'admin';

        $query = EmailCampaign::query();
        if (!$isAdmin) {
            $query->where('usuario_id', $userId);
        }

        // Una sola query para todos los contadores
        $counts = (clone $query)->selectRaw('
            COUNT(*) as total,
            SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as enviadas,
            SUM(CASE WHEN estado = ? THEN 1 ELSE 0 END) as borradores
        ', ['enviada', 'borrador'])->first();

        $recent = (clone $query)->with('creador:id,nombre')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get();

        return response()->json([
            'total' => (int) $counts->total,
            'enviadas' => (int) $counts->enviadas,
            'borradores' => (int) $counts->borradores,
            'recent' => $recent,
        ]);
    }

    // ================= UPLOADS =================

    public function uploadImage(Request $request)
    {
        $request->validate([
            'file' => 'required|image|max:5120', // 5MB max
        ]);

        $file = $request->file('file');
        $filename = 'email_builder/' . Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs('public', $filename);

        return response()->json([
            'url' => asset('storage/' . $filename),
            'filename' => $filename,
        ]);
    }

    public function listImages()
    {
        $files = Storage::files('public/email_builder');
        $images = array_map(fn($f) => ['src' => asset(str_replace('public/', 'storage/', $f))], $files);
        return response()->json(['images' => $images]);
    }
}
