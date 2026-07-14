<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class ProductoVariante extends Model
{
    use Auditable;
    protected $table = 'producto_variantes';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['producto_id', 'nombre', 'tipo', 'valor', 'sku', 'precio_adicional', 'stock', 'activo'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
