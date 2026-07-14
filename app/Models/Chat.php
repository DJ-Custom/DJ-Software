<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Chat extends Model
{
    use Auditable;
    use HasFactory;

    protected $fillable = ['titulo', 'descripcion', 'creador_id', 'estado', 'cerrado_por', 'cerrado_en'];

    public function creador()
    {
        return $this->belongsTo(User::class, 'creador_id');
    }

    public function cerradoPor()
    {
        return $this->belongsTo(User::class, 'cerrado_por');
    }

    public function participantes()
    {
        return $this->belongsToMany(User::class, 'chat_participantes', 'chat_id', 'usuario_id')
            ->withPivot('joined_at', 'last_read_at');
    }

    public function mensajes()
    {
        return $this->hasMany(ChatMensaje::class, 'chat_id')->orderBy('created_at', 'asc');
    }

    public function ultimoMensaje()
    {
        return $this->hasOne(ChatMensaje::class, 'chat_id')->latest('created_at');
    }

    public function mensajesNoLeidos($userId)
    {
        $participante = $this->participantes()
            ->where('chat_participantes.usuario_id', $userId)
            ->first();
        $lastRead = $participante ? $participante->pivot->last_read_at : null;

        $query = $this->mensajes()->where('chat_mensajes.usuario_id', '!=', $userId);
        if ($lastRead) {
            $query->where('chat_mensajes.created_at', '>', $lastRead);
        }
        return $query->count();
    }
}
