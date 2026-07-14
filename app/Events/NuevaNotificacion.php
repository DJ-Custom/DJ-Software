<?php

namespace App\Events;

use App\Models\Notificacion;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NuevaNotificacion implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public array $notificacionData;

    public function __construct(
        Notificacion $notificacion,
        public array $usuarioIds = [],
    ) {
        $this->notificacionData = [
            'id' => $notificacion->id,
            'titulo' => $notificacion->titulo,
            'mensaje' => $notificacion->mensaje,
            'tipo' => $notificacion->tipo,
            'prioridad' => $notificacion->prioridad,
            'color' => $notificacion->color,
            'icono' => $notificacion->icono,
            'enviada_en' => $notificacion->enviada_en?->toISOString(),
        ];
    }

    public function broadcastOn(): array
    {
        return collect($this->usuarioIds)->map(
            fn ($uid) => new PrivateChannel("user.{$uid}")
        )->all();
    }

    public function broadcastAs(): string
    {
        return 'NuevaNotificacion';
    }

    public function broadcastWith(): array
    {
        return [
            'notificacion' => $this->notificacionData,
        ];
    }
}
