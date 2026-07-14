<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class CotizacionDetalle extends Model
{
    use Auditable;
    protected $table = 'cotizacion_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['cotizacion_id', 'producto_id', 'cantidad', 'precio_unitario', 'descuento', 'impuesto', 'subtotal'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
