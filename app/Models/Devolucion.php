<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Devolucion extends Model
{
    use Auditable;
    protected $table = 'devoluciones';

    protected $fillable = [
        'numero_devolucion', 'venta_id', 'cliente_id', 'usuario_id',
        'aprobado_por', 'tipo', 'tipo_reembolso', 'monto_total',
        'motivo', 'estado', 'notas',
    ];

    public function venta() { return $this->belongsTo(Venta::class, 'venta_id'); }
    public function cliente() { return $this->belongsTo(Cliente::class, 'cliente_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
    public function detalles() { return $this->hasMany(DevolucionDetalle::class, 'devolucion_id'); }
}
