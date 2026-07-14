<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Notificacion extends Model
{
    use Auditable;
    use HasFactory;

    protected $table = 'notificaciones';

    protected $fillable = ['titulo', 'mensaje', 'color', 'icono', 'tipo', 'prioridad', 'creador_id', 'global', 'enviada_en'];

    protected $casts = [
        'global' => 'boolean',
        'enviada_en' => 'datetime',
    ];

    public function creador()
    {
        return $this->belongsTo(User::class, 'creador_id');
    }

    public function receptores()
    {
        return $this->belongsToMany(User::class, 'notificacion_usuarios', 'notificacion_id', 'usuario_id')
            ->withPivot('leido_at');
    }

    public function receptoresCount()
    {
        return $this->receptores()->count();
    }

    public function leidosCount()
    {
        return $this->receptores()->whereNotNull('notificacion_usuarios.leido_at')->count();
    }
}
