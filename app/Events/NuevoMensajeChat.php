<?php

namespace App\Events;

use App\Models\ChatMensaje;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NuevoMensajeChat implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public array $mensajeData;

    public function __construct(
        ChatMensaje $mensaje,
        public int $chatId,
        public array $participanteIds = [],
    ) {
        $this->mensajeData = [
            'id' => $mensaje->id,
            'chat_id' => $mensaje->chat_id,
            'usuario_id' => $mensaje->usuario_id,
            'contenido' => $mensaje->contenido,
            'created_at' => $mensaje->created_at,
            'archivo_url' => $mensaje->archivo_url,
            'archivo_nombre' => $mensaje->archivo_nombre,
            'archivo_tipo' => $mensaje->archivo_tipo,
            'archivo_size' => $mensaje->archivo_size,
            'archivo_url_completa' => $mensaje->archivo_url_completa,
            'usuario' => [
                'id' => $mensaje->usuario->id ?? null,
                'nombre' => $mensaje->usuario->nombre ?? 'Usuario',
            ],
        ];
    }

    public function broadcastOn(): array
    {
        $channels = [new PrivateChannel("chat.{$this->chatId}")];

        foreach ($this->participanteIds as $uid) {
            if ($uid !== $this->mensajeData['usuario_id']) {
                $channels[] = new PrivateChannel("user.{$uid}");
            }
        }

        return $channels;
    }

    public function broadcastAs(): string
    {
        return 'NuevoMensajeChat';
    }

    public function broadcastWith(): array
    {
        return [
            'mensaje' => $this->mensajeData,
            'chat_id' => $this->chatId,
        ];
    }
}
