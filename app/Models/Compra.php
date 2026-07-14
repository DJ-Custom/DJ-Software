<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Compra extends Model
{
    use Auditable;
    protected $table = 'compras';

    protected $fillable = [
        'numero_compra', 'proveedor_id', 'usuario_id', 'subtotal',
        'impuesto_total', 'total', 'estado', 'fecha_compra',
        'fecha_entrega', 'factura_proveedor', 'archivo_factura', 'notas',
    ];

    public function proveedor() { return $this->belongsTo(Proveedor::class, 'proveedor_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
    public function detalles() { return $this->hasMany(CompraDetalle::class, 'compra_id'); }
}
