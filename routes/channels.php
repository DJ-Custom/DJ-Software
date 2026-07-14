<?php

use App\Models\Chat;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('chat.{chatId}', function ($user, $chatId) {
    return Chat::whereHas('participantes', function ($q) use ($user) {
        $q->where('chat_participantes.usuario_id', $user->id);
    })->where('id', $chatId)->exists();
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
