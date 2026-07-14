<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class ChatMensaje extends Model
{
    use Auditable;
    use HasFactory;

    protected $table = 'chat_mensajes';
    public $timestamps = false;

    protected $fillable = ['chat_id', 'usuario_id', 'contenido', 'created_at', 'archivo_url', 'archivo_nombre', 'archivo_tipo', 'archivo_size'];

    protected $appends = ['archivo_url_completa'];

    public function getArchivoUrlCompletaAttribute(): ?string
    {
        if (!$this->archivo_url) {
            return null;
        }
        return asset('storage/' . $this->archivo_url);
    }

    public function chat()
    {
        return $this->belongsTo(Chat::class, 'chat_id');
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }
}
