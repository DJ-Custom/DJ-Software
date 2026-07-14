<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class DevolucionDetalle extends Model
{
    use Auditable;
    protected $table = 'devolucion_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = [
        'devolucion_id', 'producto_id', 'cantidad', 'precio_unitario',
        'subtotal', 'estado_producto',
    ];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
