<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class VentaDetalle extends Model
{
    use Auditable;
    protected $table = 'venta_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = [
        'venta_id', 'producto_id', 'cantidad', 'precio_unitario',
        'descuento', 'impuesto', 'subtotal', 'combo_id',
    ];

    public function venta()
    {
        return $this->belongsTo(Venta::class, 'venta_id');
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id');
    }
}
