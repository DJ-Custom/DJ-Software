<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\Auditable;

class Categoria extends Model
{
    use Auditable;
    protected $table = 'categorias';
    public $timestamps = false;

    protected $fillable = ['nombre', 'descripcion', 'color', 'icono', 'activo'];

    protected function casts(): array
    {
        return ['activo' => 'boolean'];
    }

    public function productos()
    {
        return $this->hasMany(Producto::class, 'categoria_id');
    }
}
