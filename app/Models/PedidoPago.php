<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class PedidoPago extends Model
{
    use Auditable;
    protected $table = 'pedido_pagos';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['pedido_id', 'monto', 'metodo_pago', 'referencia', 'tipo', 'usuario_id', 'notas'];

    public function pedido() { return $this->belongsTo(Pedido::class, 'pedido_id'); }
}
