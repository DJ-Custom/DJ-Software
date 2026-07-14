<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Cotizacion extends Model
{
    use Auditable;
    protected $table = 'cotizaciones';

    protected $fillable = [
        'numero_cotizacion', 'cliente_id', 'usuario_id', 'subtotal',
        'descuento_total', 'impuesto_total', 'total', 'estado',
        'fecha_vencimiento', 'condiciones', 'notas', 'venta_id', 'pedido_id',
    ];

    public function cliente() { return $this->belongsTo(Cliente::class, 'cliente_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
    public function detalles() { return $this->hasMany(CotizacionDetalle::class, 'cotizacion_id'); }
}
