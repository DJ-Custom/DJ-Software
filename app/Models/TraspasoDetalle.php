<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class TraspasoDetalle extends Model
{
    use Auditable;
    protected $table = 'traspaso_detalle';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['traspaso_id', 'producto_id', 'cantidad_enviada', 'cantidad_recibida', 'diferencia', 'notas_diferencia'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
