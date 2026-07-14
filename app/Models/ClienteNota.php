<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class ClienteNota extends Model
{
    use Auditable;
    protected $table = 'cliente_notas';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['cliente_id', 'usuario_id', 'tipo', 'contenido'];

    public function cliente() { return $this->belongsTo(Cliente::class, 'cliente_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
}
