<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class NotaCredito extends Model
{
    use Auditable;
    protected $table = 'notas_credito';

    protected $fillable = [
        'numero_nota', 'venta_id', 'cliente_id', 'usuario_id',
        'tipo', 'tipo_credito', 'monto_total', 'saldo_restante',
        'motivo', 'estado', 'notas',
    ];

    public function venta() { return $this->belongsTo(Venta::class, 'venta_id'); }
    public function cliente() { return $this->belongsTo(Cliente::class, 'cliente_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
    public function detalles() { return $this->hasMany(NotaCreditoDetalle::class, 'nota_credito_id'); }
}
