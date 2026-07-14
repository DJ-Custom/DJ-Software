<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class InventarioMovimiento extends Model
{
    use Auditable;
    protected $table = 'inventario_movimientos';

    protected $fillable = [
        'producto_id', 'ubicacion_id', 'ubicacion_destino_id', 'tipo',
        'cantidad', 'stock_anterior', 'stock_nuevo',
        'referencia_tipo', 'referencia_id', 'usuario_id', 'notas',
    ];

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id');
    }

    public function ubicacionDestino()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_destino_id');
    }

    public function usuario()
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
