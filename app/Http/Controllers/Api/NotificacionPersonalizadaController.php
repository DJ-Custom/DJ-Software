<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Events\NuevaNotificacion;
use App\Models\Notificacion;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificacionPersonalizadaController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;
        $isAdmin = ($request->user()->rol->nombre ?? '') === 'admin' || in_array('admin', $request->user()->modulos_acceso ?? []);

        if ($isAdmin && $request->query('panel') === 'admin') {
            $query = Notificacion::with(['creador:id,nombre'])
                ->withCount('receptores');

            if ($request->Query('tipo')) {
                $query->where('tipo', $request->query('tipo'));
            }
            if ($request->query('prioridad')) {
                $query->where('prioridad', $request->query('prioridad'));
            }
            if ($request->query('desde')) {
                $query->whereDate('enviada_en', '>=', $request->query('desde'));
            }
            if ($request->query('hasta')) {
                $query->whereDate('enviada_en', '<=', $request->query('hasta'));
            }

            $notificaciones = $query->orderByDesc('enviada_en')->paginate(20);

            foreach ($notificaciones as $n) {
                $n->total_enviados = $n->receptores_count ?? 0;
                $n->total_leidos = $n->leidosCount();
            }

            return response()->json(['notificaciones' => $notificaciones]);
        }

        // Para usuario normal: sus notificaciones
        $descartadas = DB::table('notificacion_usuarios')
            ->where('usuario_id', $userId)
            ->whereNotNull('descartado_at')
            ->pluck('notificacion_id');

        $notificaciones = Notificacion::where(function ($q) use ($userId) {
            $q->where('global', true)
              ->orWhereHas('receptores', function ($sq) use ($userId) {
                  $sq->where('notificacion_usuarios.usuario_id', $userId)
                     ->whereNull('notificacion_usuarios.descartado_at');
              });
        })
        ->whereNotIn('id', $descartadas)
        ->with(['creador:id,nombre'])
        ->orderByDesc('enviada_en')
        ->get()
        ->map(function ($n) use ($userId) {
            $receptor = DB::table('notificacion_usuarios')
                ->where('notificacion_id', $n->id)
                ->where('usuario_id', $userId)
                ->whereNull('descartado_at')
                ->first();
            $n->leido = $receptor && $receptor->leido_at !== null;
            $n->leido_at = $receptor?->leido_at;
            return $n;
        });

        return response()->json(['notificaciones' => $notificaciones]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'mensaje' => 'required|string|max:2000',
            'color' => 'nullable|string|max:20',
            'icono' => 'nullable|string|max:100',
            'tipo' => 'required|string|in:informativa,advertencia,urgente,exito,error,sistema,recordatorio',
            'prioridad' => 'required|string|in:baja,normal,alta,urgente',
            'destinatarios' => 'nullable|array',
            'destinatarios.*' => 'integer|exists:usuarios,id',
            'roles' => 'nullable|array',
            'roles.*' => 'integer|exists:roles,id',
            'global' => 'boolean',
        ]);

        $lockKey = $this->generateLockKey('crear_notificacion', [
            'user' => $request->user()->id,
            'titulo' => $request->titulo,
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $userId = $request->user()->id;

            DB::beginTransaction();
            try {
                $notif = Notificacion::create([
                    'titulo' => $request->titulo,
                    'mensaje' => $request->mensaje,
                    'color' => $request->color ?? '#3b82f6',
                    'icono' => $request->icono ?? 'fas fa-bell',
                    'tipo' => $request->tipo,
                    'prioridad' => $request->prioridad,
                    'creador_id' => $userId,
                    'global' => $request->boolean('global', false),
                    'enviada_en' => now(),
                ]);

                $usuarioIds = collect($request->destinatarios ?? [])->unique()->values()->all();

                if ($request->filled('roles')) {
                    $roleUserIds = User::whereIn('rol_id', $request->roles)->pluck('id')->toArray();
                    $usuarioIds = array_unique(array_merge($usuarioIds, $roleUserIds));
                }

                if ($notif->global || empty($usuarioIds)) {
                    $notif->global = true;
                    $notif->save();
                    $usuarioIds = User::where('activo', true)->pluck('id')->toArray();
                }

                $pivot = collect($usuarioIds)->map(fn($uid) => [
                    'notificacion_id' => $notif->id,
                    'usuario_id' => $uid,
                    'created_at' => now(),
                ])->toArray();

                DB::table('notificacion_usuarios')->insert($pivot);

                DB::commit();

                broadcast(new NuevaNotificacion($notif, $usuarioIds));

                return response()->json(['notificacion' => $notif, 'message' => 'Notificación enviada']);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => 'Error al enviar notificación'], 500);
            }
        }, response()->json(['error' => 'Ya se está enviando esta notificación. Por favor espere.'], 429));
    }

    public function marcarLeida($id, Request $request)
    {
        $userId = $request->user()->id;

        DB::table('notificacion_usuarios')
            ->where('notificacion_id', $id)
            ->where('usuario_id', $userId)
            ->update(['leido_at' => now()]);

        return response()->json(['message' => 'Marcada como leída']);
    }

    public function marcarTodasLeidas(Request $request)
    {
        $userId = $request->user()->id;

        DB::table('notificacion_usuarios')
            ->where('usuario_id', $userId)
            ->whereNull('leido_at')
            ->update(['leido_at' => now()]);

        return response()->json(['message' => 'Todas marcadas como leídas']);
    }

    public function destroy($id, Request $request)
    {
        $isAdmin = ($request->user()->rol->nombre ?? '') === 'admin' || in_array('admin', $request->user()->modulos_acceso ?? []);
        if (!$isAdmin) {
            return response()->json(['error' => 'Sin permiso'], 403);
        }

        $notif = Notificacion::findOrFail($id);
        $notif->delete();
        return response()->json(['message' => 'Notificación eliminada']);
    }

    public function descartar($id, Request $request)
    {
        $userId = $request->user()->id;

        DB::table('notificacion_usuarios')->updateOrInsert(
            ['notificacion_id' => $id, 'usuario_id' => $userId],
            ['descartado_at' => now(), 'created_at' => now()]
        );

        return response()->json(['message' => 'Notificación descartada']);
    }

    public function tipos()
    {
        $tipos = [
            ['slug' => 'informativa', 'nombre' => 'Informativa', 'color' => '#3b82f6', 'icono' => 'fas fa-info-circle'],
            ['slug' => 'advertencia', 'nombre' => 'Advertencia', 'color' => '#f59e0b', 'icono' => 'fas fa-exclamation-triangle'],
            ['slug' => 'urgente', 'nombre' => 'Urgente', 'color' => '#dc2626', 'icono' => 'fas fa-bolt'],
            ['slug' => 'exito', 'nombre' => 'Éxito', 'color' => '#16a34a', 'icono' => 'fas fa-check-circle'],
            ['slug' => 'error', 'nombre' => 'Error', 'color' => '#ef4444', 'icono' => 'fas fa-times-circle'],
            ['slug' => 'sistema', 'nombre' => 'Sistema', 'color' => '#6366f1', 'icono' => 'fas fa-cog'],
            ['slug' => 'recordatorio', 'nombre' => 'Recordatorio', 'color' => '#8b5cf6', 'icono' => 'fas fa-clock'],
        ];
        return response()->json(['tipos' => $tipos]);
    }

    public function unreadCount(Request $request)
    {
        $userId = $request->user()->id;

        $count = DB::table('notificacion_usuarios')
            ->join('notificaciones', 'notificaciones.id', '=', 'notificacion_usuarios.notificacion_id')
            ->where('notificacion_usuarios.usuario_id', $userId)
            ->whereNull('notificacion_usuarios.leido_at')
            ->whereNull('notificacion_usuarios.descartado_at')
            ->count();

        return response()->json(['unread' => $count]);
    }
}
