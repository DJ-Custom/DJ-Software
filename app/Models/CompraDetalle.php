<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class CompraDetalle extends Model
{
    use Auditable;
    protected $table = 'compra_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['compra_id', 'producto_id', 'cantidad', 'precio_unitario', 'subtotal'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
