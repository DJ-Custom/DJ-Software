<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class InventarioUbicacion extends Model
{
    use Auditable;
    protected $table = 'inventario_ubicacion';

    protected $fillable = [
        'producto_id', 'ubicacion_id', 'cantidad', 'cantidad_reservada',
        'stock_minimo', 'stock_maximo', 'estado',
    ];

    protected function casts(): array
    {
        return [
            'cantidad' => 'integer',
            'cantidad_reservada' => 'integer',
            'stock_minimo' => 'integer',
            'stock_maximo' => 'integer',
        ];
    }

    public function producto()
    {
        return $this->belongsTo(Producto::class, 'producto_id');
    }

    public function ubicacion()
    {
        return $this->belongsTo(Ubicacion::class, 'ubicacion_id');
    }

    public function disponible(): int
    {
        return max(0, $this->cantidad - $this->cantidad_reservada);
    }

    public function estadoStock(): string
    {
        $disp = $this->disponible();
        if ($disp <= 0) return 'agotado';
        if ($this->stock_minimo !== null && $disp <= $this->stock_minimo) return 'bajo';
        if ($this->stock_maximo !== null && $disp >= $this->stock_maximo) return 'alto';
        return 'medio';
    }
}
