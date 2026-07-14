<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Pedido extends Model
{
    use Auditable;
    protected $table = 'pedidos';

    protected $fillable = [
        'numero_pedido', 'cliente_id', 'usuario_id', 'cotizacion_id',
        'subtotal', 'descuento_total', 'impuesto_total', 'total',
        'monto_adelanto', 'monto_pendiente', 'estado', 'tipo_entrega',
        'direccion_entrega', 'fecha_entrega_estimada', 'fecha_entrega_real',
        'reservar_inventario', 'notas', 'venta_id',
    ];

    public function cliente() { return $this->belongsTo(Cliente::class, 'cliente_id'); }
    public function usuario() { return $this->belongsTo(User::class, 'usuario_id'); }
    public function detalles() { return $this->hasMany(PedidoDetalle::class, 'pedido_id'); }
    public function pagos() { return $this->hasMany(PedidoPago::class, 'pedido_id'); }
}
