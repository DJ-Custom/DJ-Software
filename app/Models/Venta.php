<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Venta extends Model
{
    use Auditable;
    protected $table = 'ventas';

    protected $fillable = [
        'numero_factura', 'cliente_id', 'usuario_id', 'ubicacion_id', 'subtotal',
        'descuento_total', 'impuesto_total', 'total', 'metodo_pago',
        'monto_efectivo', 'monto_tarjeta', 'monto_sinpe', 'referencia_sinpe',
        'dinero_recibido', 'cambio', 'estado', 'canal', 'notas',
        'cancelada_por', 'motivo_cancelacion', 'cupon_id',
        'descuento_cupon', 'ip_compra',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'total' => 'decimal:2',
            'descuento_total' => 'decimal:2',
            'impuesto_total' => 'decimal:2',
        ];
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'cliente_id');
    }

    public function usuario()
    {
        return $this->belongsTo(User::class, 'usuario_id');
    }

    public function detalles()
    {
        return $this->hasMany(VentaDetalle::class, 'venta_id');
    }

    public function devoluciones()
    {
        return $this->hasMany(Devolucion::class, 'venta_id');
    }

    public function notasCredito()
    {
        return $this->hasMany(\App\Models\NotaCredito::class, 'venta_id');
    }
}
