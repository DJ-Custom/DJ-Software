<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Proveedor extends Model
{
    use Auditable;
    protected $table = 'proveedores';

    protected $fillable = [
        'nombre', 'contacto_nombre', 'empresa', 'telefono', 'email',
        'direccion', 'notas', 'notas_internas', 'calificacion', 'activo',
    ];

    public function compras() { return $this->hasMany(Compra::class, 'proveedor_id'); }
    public function productos() { return $this->belongsToMany(Producto::class, 'proveedor_productos', 'proveedor_id', 'producto_id'); }
}
