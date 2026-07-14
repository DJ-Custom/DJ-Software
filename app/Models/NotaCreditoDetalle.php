<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class NotaCreditoDetalle extends Model
{
    use Auditable;
    protected $table = 'nota_credito_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['nota_credito_id', 'producto_id', 'cantidad', 'precio_unitario', 'subtotal', 'devolver_inventario', 'estado_producto'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
