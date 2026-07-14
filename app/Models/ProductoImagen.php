<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class ProductoImagen extends Model
{
    use Auditable;
    protected $table = 'producto_imagenes';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = ['producto_id', 'ruta', 'es_principal', 'orden'];

    public function producto() { return $this->belongsTo(Producto::class, 'producto_id'); }
}
