<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Events\NuevoMensajeChat;
use App\Models\Chat;
use App\Models\ChatMensaje;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ChatController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $ultimoMensajeSubquery = DB::table('chat_mensajes')
            ->select('chat_id', DB::raw('MAX(created_at) as ultimo_mensaje_at'))
            ->groupBy('chat_id');

        $chats = Chat::query()
            ->whereHas('participantes', function ($q) use ($userId) {
                $q->where('chat_participantes.usuario_id', $userId);
            })
            ->with(['ultimoMensaje.usuario', 'creador'])
            ->leftJoinSub($ultimoMensajeSubquery, 'ultimo_mensaje', function ($join) {
                $join->on('ultimo_mensaje.chat_id', '=', 'chats.id');
            })
            ->select('chats.*')
            ->where('chats.estado', 'abierto')
            ->orderByDesc('ultimo_mensaje.ultimo_mensaje_at')
            ->orderByDesc('chats.created_at')
            ->get()
            ->map(function ($chat) use ($userId) {
                $chat->no_leidos = $chat->mensajesNoLeidos($userId);
                $chat->participantes_nombres = $chat->participantes()
                    ->pluck('usuarios.nombre')
                    ->toArray();

                return $chat;
            });

        return response()->json(['chats' => $chats]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'titulo' => 'required|string|max:255',
            'descripcion' => 'nullable|string',
            'participantes' => 'required|array|min:1',
            'participantes.*' => 'integer|exists:usuarios,id',
        ]);

        $lockKey = $this->generateLockKey('crear_chat', [
            'user' => $request->user()->id,
            'titulo' => $request->titulo,
            'participantes' => md5(json_encode($request->participantes)),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request) {
            $userId = $request->user()->id;
            $participantes = array_unique(array_merge($request->participantes, [$userId]));

            // Check for duplicate chat with exact same participants
            $existing = Chat::whereHas('participantes', function ($q) use ($participantes) {
                $q->whereIn('chat_participantes.usuario_id', $participantes);
            }, '>=', count($participantes))
            ->where('titulo', $request->titulo)
            ->where('creador_id', $userId)
            ->first();

            if ($existing) {
                // Verify exact same participant set
                $existingIds = $existing->participantes()->pluck('chat_participantes.usuario_id')->sort()->values()->toArray();
                $newIds = collect($participantes)->sort()->values()->toArray();
                if ($existingIds == $newIds) {
                    return response()->json(['error' => 'Ya existe un chat con el mismo título y participantes.', 'chat_id' => $existing->id], 422);
                }
            }

            DB::beginTransaction();
            try {
                $chat = Chat::create([
                    'titulo' => $request->titulo,
                    'descripcion' => $request->descripcion,
                    'creador_id' => $userId,
                    'estado' => 'abierto',
                ]);

                foreach ($participantes as $pid) {
                    $chat->participantes()->attach($pid, ['joined_at' => now()]);
                }

                DB::commit();
                return response()->json(['chat' => $chat, 'message' => 'Chat creado correctamente']);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(['error' => 'Error al crear el chat'], 500);
            }
        }, response()->json(['error' => 'Ya se está creando este chat. Por favor espere.'], 429));
    }

    public function show($id, Request $request)
    {
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })
        ->with(['participantes', 'creador'])
        ->findOrFail($id);

        $chat->no_leidos = $chat->mensajesNoLeidos($userId);

        return response()->json(['chat' => $chat]);
    }

    public function mensajes($id, Request $request)
    {
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })->findOrFail($id);

        $mensajes = ChatMensaje::where('chat_id', $id)
            ->with('usuario:id,nombre')
            ->orderBy('created_at', 'asc')
            ->paginate(50);

        return response()->json(['mensajes' => $mensajes, 'chat' => $chat]);
    }

    public function enviarMensaje(Request $request, $id)
    {
        $request->validate([
            'contenido' => 'nullable|string',
            'archivo' => 'nullable|file|max:3072',
        ]);

        if (!$request->filled('contenido') && !$request->hasFile('archivo')) {
            return response()->json(['error' => 'Debes enviar un mensaje o un archivo.'], 422);
        }

        $lockKey = $this->generateLockKey('enviar_mensaje', [
            'chat_id' => $id,
            'user' => $request->user()->id,
            'contenido_hash' => md5($request->contenido ?? ''),
        ]);

        return $this->withDuplicateLock($lockKey, function () use ($request, $id) {
            $userId = $request->user()->id;

            $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
                $q->where('chat_participantes.usuario_id', $userId);
            })->findOrFail($id);

            if ($chat->estado === 'cerrado') {
                return response()->json(['error' => 'El chat está cerrado.'], 403);
            }

            $data = [
                'chat_id' => $id,
                'usuario_id' => $userId,
                'contenido' => $request->contenido ?? '',
                'created_at' => now(),
            ];

            if ($request->hasFile('archivo')) {
                $file = $request->file('archivo');

                if (!$file->isValid()) {
                    return response()->json(['error' => 'El archivo no se subió correctamente.'], 422);
                }

                // Validación de tamaño de archivo (máximo 3 MB)
                $maxSize = 3 * 1024 * 1024; // 3 MB en bytes
                if ($file->getSize() > $maxSize) {
                    return response()->json(['error' => 'El archivo excede el tamaño máximo permitido de 3 MB.'], 422);
                }

                $dir = storage_path('app/public/chat_adjuntos');
                if (!is_dir($dir)) {
                    mkdir($dir, 0755, true);
                }

                $ext = $file->getClientOriginalExtension() ?: $file->guessExtension() ?: 'bin';
                $basename = Str::uuid() . '.' . $ext;
                $saved = $file->storeAs('chat_adjuntos', $basename, 'public');

                if (!$saved) {
                    Log::error('Chat file storage failed', [
                        'chat_id' => $id,
                        'original_name' => $file->getClientOriginalName(),
                        'path' => 'chat_adjuntos/' . $basename,
                    ]);
                    return response()->json(['error' => 'No se pudo guardar el archivo en el servidor.'], 500);
                }

                $data['archivo_url'] = 'chat_adjuntos/' . $basename;
                $data['archivo_nombre'] = $file->getClientOriginalName();
                $data['archivo_tipo'] = $file->getMimeType();
                $data['archivo_size'] = $file->getSize();
            }

            $mensaje = ChatMensaje::create($data);
            $mensaje->load('usuario:id,nombre');

            $participanteIds = $chat->participantes()
                ->pluck('chat_participantes.usuario_id')
                ->toArray();

            try {
                broadcast(new NuevoMensajeChat($mensaje, (int) $id, $participanteIds));
            } catch (\Throwable $e) {
                Log::warning('Broadcast chat message failed', [
                    'chat_id' => $id,
                    'mensaje_id' => $mensaje->id,
                    'error' => $e->getMessage(),
                ]);
            }

            return response()->json(['mensaje' => $mensaje]);
        }, response()->json(['error' => 'Ya se está enviando este mensaje. Por favor espere.'], 429));
    }

    public function descargarAdjunto($chatId, $mensajeId, Request $request)
    {
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })->findOrFail($chatId);

        $mensaje = ChatMensaje::where('chat_id', $chatId)->where('id', $mensajeId)->firstOrFail();

        if (!$mensaje->archivo_url || !Storage::disk('public')->exists($mensaje->archivo_url)) {
            return response()->json(['error' => 'Archivo no encontrado.'], 404);
        }

        $path = Storage::disk('public')->path($mensaje->archivo_url);

        return response()->stream(function () use ($path) {
            $stream = fopen($path, 'r');
            fpassthru($stream);
            fclose($stream);
        }, 200, [
            'Content-Type' => $mensaje->archivo_tipo ?? 'application/octet-stream',
            'Content-Disposition' => 'attachment; filename="' . ($mensaje->archivo_nombre ?? 'archivo') . '"',
            'Content-Length' => $mensaje->archivo_size ?? filesize($path),
        ]);
    }

    public function verAdjunto($chatId, $mensajeId, Request $request)
    {
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })->findOrFail($chatId);

        $mensaje = ChatMensaje::where('chat_id', $chatId)->where('id', $mensajeId)->firstOrFail();

        if (!$mensaje->archivo_url || !Storage::disk('public')->exists($mensaje->archivo_url)) {
            return response()->json(['error' => 'Archivo no encontrado.'], 404);
        }

        $path = Storage::disk('public')->path($mensaje->archivo_url);
        $mime = $mensaje->archivo_tipo ?? mime_content_type($path) ?? 'application/octet-stream';

        return response()->stream(function () use ($path) {
            $stream = fopen($path, 'r');
            fpassthru($stream);
            fclose($stream);
        }, 200, [
            'Content-Type' => $mime,
            'Content-Disposition' => 'inline; filename="' . ($mensaje->archivo_nombre ?? 'archivo') . '"',
            'Cache-Control' => 'public, max-age=86400',
            'Access-Control-Allow-Origin' => '*',
        ]);
    }

    public function marcarLeido($id, Request $request)
    {
        $userId = $request->user()->id;

        DB::table('chat_participantes')
            ->where('chat_id', $id)
            ->where('usuario_id', $userId)
            ->update(['last_read_at' => now()]);

        return response()->json(['message' => 'Marcado como leído']);
    }

    public function cerrar($id, Request $request)
    {
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })->findOrFail($id);

        if ($chat->estado === 'cerrado') {
            return response()->json(['error' => 'El chat ya está cerrado.'], 422);
        }

        $chat->update([
            'estado' => 'cerrado',
            'cerrado_por' => $userId,
            'cerrado_en' => now(),
        ]);
        return response()->json(['message' => 'Chat cerrado']);
    }

    public function cerrados(Request $request)
    {
        $userId = $request->user()->id;
        $rolNombre = $request->user()->rol->nombre ?? '';
        $isAdmin = $rolNombre === 'admin' || in_array('admin', $request->user()->modulos_acceso ?? []);

        $query = Chat::where('estado', 'cerrado')
            ->with(['creador:id,nombre', 'cerradoPor:id,nombre', 'ultimoMensaje.usuario'])
            ->withCount('mensajes');

        if (!$isAdmin) {
            $query->whereHas('participantes', function ($q) use ($userId) {
                $q->where('chat_participantes.usuario_id', $userId);
            });
        }

        $chats = $query->orderByDesc('cerrado_en')->orderByDesc('created_at')->get()
            ->map(function ($chat) {
                $chat->participantes_nombres = $chat->participantes()->pluck('usuarios.nombre')->toArray();
                return $chat;
            });

        return response()->json(['chats' => $chats]);
    }

    public function destroy($id, Request $request)
    {
        $user = $request->user();
        $rolNombre = $user->rol->nombre ?? '';
        $isAdmin = $rolNombre === 'admin' || in_array('admin', $user->modulos_acceso ?? []);

        $chat = Chat::findOrFail($id);

        if (!$isAdmin && $chat->creador_id !== $user->id) {
            return response()->json(['error' => 'No tienes permiso para eliminar este chat.'], 403);
        }

        $chat->delete();

        return response()->json(['message' => 'Chat eliminado']);
    }

    public function agregarParticipante(Request $request, $id)
    {
        $request->validate(['usuario_id' => 'required|integer|exists:usuarios,id']);
        $userId = $request->user()->id;

        $chat = Chat::whereHas('participantes', function ($q) use ($userId) {
            $q->where('chat_participantes.usuario_id', $userId);
        })->findOrFail($id);

        $chat->participantes()->syncWithoutDetaching([
            $request->usuario_id => ['joined_at' => now()]
        ]);

        return response()->json(['message' => 'Participante agregado']);
    }
}
