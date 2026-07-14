<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class CajaMovimiento extends Model
{
    use Auditable;
    protected $table = 'caja_movimientos';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['tipo', 'monto', 'concepto', 'referencia_tipo', 'referencia_id', 'usuario_id'];

    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
}
